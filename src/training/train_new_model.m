% train_new_model.m
% Entrenar un nuevo modelo Random Forest con datos personalizados
% Compatible con MATLAB R2020a+
%
% ANTES DE EJECUTAR:
%   1. Asegúrate de haber ejecutado prepare_training_data.m
%   2. Verifica que training_dataset.mat exista

clear; clc; close all;

fprintf('\n╔═══════════════════════════════════════════╗\n');
fprintf('║    ENTRENAMIENTO DE NUEVO MODELO RF       ║\n');
fprintf('╚═══════════════════════════════════════════╝\n\n');

%% ========================================================================
%  PASO 1: Cargar dataset de entrenamiento
%  ========================================================================
fprintf('PASO 1: Cargando dataset...\n');

if ~isfile('training_dataset.mat')
    error(['Dataset no encontrado.\n', ...
           'Ejecuta primero: run(''prepare_training_data.m'')']);
end

load('training_dataset.mat', 'features', 'labels');

fprintf('  ✓ Dataset cargado: %d muestras\n', size(features, 1));

%% ========================================================================
%  PASO 2: Dividir datos en entrenamiento y validación
%  ========================================================================
fprintf('\nPASO 2: Dividiendo datos (70%% entrenamiento, 30%% validación)...\n');

% Convertir etiquetas a categorical
labels_cat = categorical(labels);

% División estratificada (mantiene proporciones de clases)
cv = cvpartition(labels_cat, 'HoldOut', 0.3);

% Conjuntos de entrenamiento
X_train = features(training(cv), :);
y_train = labels_cat(training(cv));

% Conjuntos de validación
X_test = features(test(cv), :);
y_test = labels_cat(test(cv));

fprintf('  ✓ Entrenamiento: %d muestras\n', size(X_train, 1));
fprintf('  ✓ Validación:    %d muestras\n', size(X_test, 1));

%% ========================================================================
%  PASO 3: Configurar hiperparámetros
%  ========================================================================
fprintf('\nPASO 3: Configurando hiperparámetros del modelo...\n');

% HIPERPARÁMETROS CONFIGURABLES:
n_trees = 100;              % Número de árboles (más = mejor, pero más lento)
min_leaf_size = 5;          % Mínimo de muestras por hoja
max_num_splits = [];        % Máximo de divisiones ([] = sin límite)
num_variables_to_sample = 'all'; % Variables a considerar por división

fprintf('  Configuración:\n');
fprintf('    - Número de árboles:          %d\n', n_trees);
fprintf('    - Tamaño mínimo de hoja:      %d\n', min_leaf_size);
fprintf('    - Variables por división:     %s\n', num_variables_to_sample);

%% ========================================================================
%  PASO 4: Entrenar modelo Random Forest
%  ========================================================================
fprintf('\nPASO 4: Entrenando Random Forest...\n');
fprintf('  ⏳ Esto puede tomar varios minutos...\n');

tic;

rf_new = TreeBagger(n_trees, X_train, y_train, ...
                    'Method', 'classification', ...
                    'MinLeafSize', min_leaf_size, ...
                    'MaxNumSplits', max_num_splits, ...
                    'NumPredictorsToSample', num_variables_to_sample, ...
                    'OOBPrediction', 'on', ...
                    'OOBPredictorImportance', 'on');

elapsed = toc;

fprintf('  ✓ Entrenamiento completado en %.1f segundos\n', elapsed);

%% ========================================================================
%  PASO 5: Evaluar rendimiento en validación
%  ========================================================================
fprintf('\nPASO 5: Evaluando rendimiento...\n');

% Predicciones en conjunto de validación
[y_pred, scores] = predict(rf_new, X_test);
y_pred_cat = categorical(y_pred);

% Calcular accuracy
accuracy = sum(y_pred_cat == y_test) / length(y_test) * 100;

fprintf('\n  📊 MÉTRICAS DE RENDIMIENTO:\n');
fprintf('    - Accuracy total:     %.2f%%%%\n', accuracy);
fprintf('    - Error OOB:          %.2f%%%%\n', oobError(rf_new) * 100);

% Matriz de confusión
fprintf('\n  📊 MATRIZ DE CONFUSIÓN:\n');
conf_mat = confusionmat(y_test, y_pred_cat);
class_names = categories(y_test);

% Mostrar matriz de confusión
fprintf('\n');
fprintf('       Predicho →\n');
fprintf('  Real ↓   ');
for i = 1:length(class_names)
    fprintf('%-12s', class_names{i});
end
fprintf('\n');

for i = 1:length(class_names)
    fprintf('  %-10s ', class_names{i});
    for j = 1:length(class_names)
        fprintf('%-12d', conf_mat(i,j));
    end
    fprintf('\n');
end

% Métricas por clase
fprintf('\n  📊 MÉTRICAS POR CLASE:\n');
for i = 1:length(class_names)
    % Precision = VP / (VP + FP)
    precision = conf_mat(i,i) / sum(conf_mat(:,i)) * 100;

    % Recall = VP / (VP + FN)
    recall = conf_mat(i,i) / sum(conf_mat(i,:)) * 100;

    % F1-Score
    f1 = 2 * (precision * recall) / (precision + recall);

    fprintf('    %-20s: Precision=%.1f%%%%, Recall=%.1f%%%%, F1=%.2f\n', ...
            class_names{i}, precision, recall, f1);
end

% Importancia de características
fprintf('\n  📊 IMPORTANCIA DE CARACTERÍSTICAS:\n');
importance = oobPermutedPredictorImportance(rf_new);
feature_names = {'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'};

[sorted_imp, idx] = sort(importance, 'descend');
for i = 1:length(sorted_imp)
    bar_len = round(sorted_imp(i) / max(sorted_imp) * 30);
    bar = repmat('█', 1, bar_len);
    fprintf('    %-10s: %.4f  %s\n', ...
            feature_names{idx(i)}, sorted_imp(i), bar);
end

%% ========================================================================
%  PASO 6: Visualizar resultados
%  ========================================================================
fprintf('\nPASO 6: Generando visualizaciones...\n');

% Figura 1: Matriz de confusión
figure('Position', [100, 100, 700, 600]);
confusionchart(y_test, y_pred_cat);
title('Matriz de Confusión - Conjunto de Validación', ...
      'FontWeight', 'bold', 'FontSize', 12);
saveas(gcf, 'confusion_matrix.png');

% Figura 2: Importancia de características
figure('Position', [100, 100, 800, 500]);
bar(sorted_imp);
set(gca, 'XTickLabel', feature_names(idx));
ylabel('Importancia');
title('Importancia de Características', 'FontWeight', 'bold');
grid on;
saveas(gcf, 'feature_importance.png');

% Figura 3: Error OOB vs número de árboles
figure('Position', [100, 100, 800, 500]);
plot(oobError(rf_new), 'LineWidth', 2);
xlabel('Número de árboles');
ylabel('Error OOB');
title('Evolución del Error Out-of-Bag', 'FontWeight', 'bold');
grid on;
saveas(gcf, 'oob_error_evolution.png');

fprintf('  ✓ Gráficas guardadas\n');

%% ========================================================================
%  PASO 7: Guardar modelo
%  ========================================================================
fprintf('\nPASO 7: Guardando modelo...\n');

% Renombrar para compatibilidad con el sistema
rf_ims = rf_new;

% Guardar modelo nuevo
model_file = fullfile('models', 'ims_modelo_nuevo.mat');
save(model_file, 'rf_ims', 'accuracy', 'importance', 'class_names');

fprintf('  ✓ Modelo guardado: %s\n', model_file);

% Backup del modelo anterior
old_model = fullfile('models', 'ims_modelo_especifico.mat');
if isfile(old_model)
    backup_file = fullfile('models', 'ims_modelo_especifico_BACKUP.mat');
    copyfile(old_model, backup_file);
    fprintf('  ✓ Backup creado: ims_modelo_especifico_BACKUP.mat\n');
end

fprintf('\n╔═══════════════════════════════════════════╗\n');
fprintf('║      ENTRENAMIENTO COMPLETADO             ║\n');
fprintf('╚═══════════════════════════════════════════╝\n');

fprintf('\nPara usar el nuevo modelo:\n');
fprintf('  1. Evalúa el rendimiento: run(''compare_models.m'')\n');
fprintf('  2. Si estás satisfecho, reemplaza el modelo:\n');
fprintf('     movefile(''models/ims_modelo_nuevo.mat'', ..\n');
fprintf('              ''models/ims_modelo_especifico.mat'', ''f'')\n');
fprintf('  3. Ejecuta el sistema: IMS_bearing_diagnosis_main()\n\n');
