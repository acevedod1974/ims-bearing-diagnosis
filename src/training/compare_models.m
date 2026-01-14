% compare_models.m
% Comparar rendimiento del modelo original vs nuevo modelo
% Compatible con MATLAB R2020a+

clear; clc;

fprintf('\n╔═══════════════════════════════════════════╗\n');
fprintf('║      COMPARACIÓN DE MODELOS RF            ║\n');
fprintf('╚═══════════════════════════════════════════╝\n\n');

%% ========================================================================
%  PASO 1: Cargar ambos modelos
%  ========================================================================
fprintf('PASO 1: Cargando modelos...\n');

% Modelo original
old_model_file = fullfile('models', 'ims_modelo_especifico.mat');
if ~isfile(old_model_file)
    error('Modelo original no encontrado: %s', old_model_file);
end
old_model_data = load(old_model_file);
rf_old = old_model_data.rf_ims;
fprintf('  ✓ Modelo original cargado\n');

% Modelo nuevo
new_model_file = fullfile('models', 'ims_modelo_nuevo.mat');
if ~isfile(new_model_file)
    error(['Modelo nuevo no encontrado: %s\n', ...
           'Ejecuta primero: run(''train_new_model.m'')'], new_model_file);
end
new_model_data = load(new_model_file);
rf_new = new_model_data.rf_ims;
fprintf('  ✓ Modelo nuevo cargado\n');

%% ========================================================================
%  PASO 2: Cargar datos de validación
%  ========================================================================
fprintf('\nPASO 2: Cargando datos de validación...\n');

if ~isfile('training_dataset.mat')
    error(['Dataset no encontrado.\n', ...
           'Ejecuta primero: run(''prepare_training_data.m'')']);
end

load('training_dataset.mat', 'features', 'labels');

% División para validación (usar misma semilla para reproducibilidad)
rng(42); % Semilla fija
labels_cat = categorical(labels);
cv = cvpartition(labels_cat, 'HoldOut', 0.3);

X_test = features(test(cv), :);
y_test = labels_cat(test(cv));

fprintf('  ✓ Datos de validación: %d muestras\n', size(X_test, 1));

%% ========================================================================
%  PASO 3: Evaluar ambos modelos
%  ========================================================================
fprintf('\nPASO 3: Evaluando modelos...\n');

% Predicciones modelo original
[y_pred_old, scores_old] = predict(rf_old, X_test);
y_pred_old_cat = categorical(y_pred_old);
acc_old = sum(y_pred_old_cat == y_test) / length(y_test) * 100;
conf_mat_old = confusionmat(y_test, y_pred_old_cat);

% Predicciones modelo nuevo
[y_pred_new, scores_new] = predict(rf_new, X_test);
y_pred_new_cat = categorical(y_pred_new);
acc_new = sum(y_pred_new_cat == y_test) / length(y_test) * 100;
conf_mat_new = confusionmat(y_test, y_pred_new_cat);

%% ========================================================================
%  PASO 4: Comparar métricas
%  ========================================================================
fprintf('\n╔═══════════════════════════════════════════╗\n');
fprintf('║           COMPARACIÓN DE MÉTRICAS         ║\n');
fprintf('╚═══════════════════════════════════════════╝\n\n');

fprintf('┌─────────────────────────────────────────────┐\n');
fprintf('│ Métrica              │  Original  │  Nuevo   │\n');
fprintf('├─────────────────────────────────────────────┤\n');
fprintf('│ Accuracy             │   %.2f%%%%   │  %.2f%%%%  │\n', acc_old, acc_new);
fprintf('│ Error OOB            │   %.2f%%%%   │  %.2f%%%%  │\n', ...
        oobError(rf_old)*100, oobError(rf_new)*100);
fprintf('│ Número de árboles    │   %4d     │  %4d    │\n', ...
        rf_old.NumTrees, rf_new.NumTrees);
fprintf('│ Clases predichas     │   %4d     │  %4d    │\n', ...
        length(rf_old.ClassNames), length(rf_new.ClassNames));
fprintf('└─────────────────────────────────────────────┘\n');

% Mejora
mejora = acc_new - acc_old;
fprintf('\n');
if mejora > 0
    fprintf('✅ MEJORA: +%.2f%% en accuracy\n', mejora);
elseif mejora < 0
    fprintf('⚠️  DEGRADACIÓN: %.2f%% en accuracy\n', mejora);
else
    fprintf('➖ SIN CAMBIOS en accuracy\n');
end

%% ========================================================================
%  PASO 5: Comparar métricas por clase
%  ========================================================================
fprintf('\n📊 COMPARACIÓN POR CLASE:\n\n');

class_names = categories(y_test);

for i = 1:length(class_names)
    fprintf('  Clase: %s\n', class_names{i});

    % Modelo original
    if i <= size(conf_mat_old, 1)
        prec_old = conf_mat_old(i,i) / sum(conf_mat_old(:,i)) * 100;
        rec_old = conf_mat_old(i,i) / sum(conf_mat_old(i,:)) * 100;
        f1_old = 2 * (prec_old * rec_old) / (prec_old + rec_old);
    else
        prec_old = 0; rec_old = 0; f1_old = 0;
    end

    % Modelo nuevo
    prec_new = conf_mat_new(i,i) / sum(conf_mat_new(:,i)) * 100;
    rec_new = conf_mat_new(i,i) / sum(conf_mat_new(i,:)) * 100;
    f1_new = 2 * (prec_new * rec_new) / (prec_new + rec_new);

    fprintf('    Precision: %.1f%%%% → %.1f%%%%   ', prec_old, prec_new);
    if prec_new > prec_old
        fprintf('✅ +%.1f%%\n', prec_new - prec_old);
    else
        fprintf('\n');
    end

    fprintf('    Recall:    %.1f%%%% → %.1f%%%%   ', rec_old, rec_new);
    if rec_new > rec_old
        fprintf('✅ +%.1f%%\n', rec_new - rec_old);
    else
        fprintf('\n');
    end

    fprintf('    F1-Score:  %.2f → %.2f\n\n', f1_old, f1_new);
end

%% ========================================================================
%  PASO 6: Visualización comparativa
%  ========================================================================
fprintf('PASO 6: Generando visualizaciones comparativas...\n');

figure('Position', [100, 100, 1400, 600]);

% Subplot 1: Matrices de confusión lado a lado
subplot(1,2,1);
confusionchart(y_test, y_pred_old_cat);
title(sprintf('Modelo Original (Acc: %.1f%%%%)', acc_old), ...
      'FontWeight', 'bold');

subplot(1,2,2);
confusionchart(y_test, y_pred_new_cat);
title(sprintf('Modelo Nuevo (Acc: %.1f%%%%)', acc_new), ...
      'FontWeight', 'bold');

sgtitle('Comparación de Matrices de Confusión', ...
        'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, 'model_comparison.png');
fprintf('  ✓ Comparación guardada: model_comparison.png\n');

%% ========================================================================
%  PASO 7: Recomendación
%  ========================================================================
fprintf('\n╔═══════════════════════════════════════════╗\n');
fprintf('║            RECOMENDACIÓN                  ║\n');
fprintf('╚═══════════════════════════════════════════╝\n\n');

if acc_new > acc_old + 2 % Al menos 2% de mejora
    fprintf('✅ RECOMENDACIÓN: REEMPLAZAR modelo original\n');
    fprintf('\n   El nuevo modelo muestra mejora significativa.\n');
    fprintf('\n   Para reemplazarlo:\n');
    fprintf('   >> movefile(''models/ims_modelo_nuevo.mat'', ...\n');
    fprintf('               ''models/ims_modelo_especifico.mat'', ''f'')\n');
elseif acc_new >= acc_old
    fprintf('➖ RECOMENDACIÓN: CONSIDERAR reemplazo\n');
    fprintf('\n   El nuevo modelo es ligeramente mejor o similar.\n');
    fprintf('   Revisa las métricas por clase para decidir.\n');
else
    fprintf('⚠️  RECOMENDACIÓN: MANTENER modelo original\n');
    fprintf('\n   El nuevo modelo NO supera al original.\n');
    fprintf('   Considera:\n');
    fprintf('   - Aumentar número de muestras de entrenamiento\n');
    fprintf('   - Agregar más características\n');
    fprintf('   - Ajustar hiperparámetros\n');
end

fprintf('\n');
