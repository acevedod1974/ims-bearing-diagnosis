% inspect_current_model.m
% Script para inspeccionar las características del modelo Random Forest actual
%
% Muestra:
%   - Número de árboles
%   - Clases que predice
%   - Importancia de características
%   - Métricas de rendimiento
%
% Uso:
%   run('src/training/inspect_current_model.m')

clear; clc;

fprintf('\n');
fprintf('╔═══════════════════════════════════════════╗\n');
fprintf('║   INSPECCIÓN DEL MODELO RANDOM FOREST     ║\n');
fprintf('╚═══════════════════════════════════════════╝\n');
fprintf('\n');

%% 1. CARGAR MODELO
model_path = fullfile('models', 'ims_modelo_especifico.mat');

if ~exist(model_path, 'file')
    error('❌ Modelo no encontrado en: %s', model_path);
end

fprintf('📂 Cargando modelo desde: %s\n', model_path);
model_data = load(model_path);

% Buscar el modelo en la estructura
field_names = fieldnames(model_data);
rf_model = model_data.(field_names{1});

fprintf('✓ Modelo cargado exitosamente\n\n');

%% 2. INFORMACIÓN BÁSICA
fprintf('📊 CARACTERÍSTICAS DEL MODELO:\n\n');

fprintf('1. Tipo de modelo: %s\n', class(rf_model));

% Obtener número de árboles (compatible con diferentes versiones)
try
    if isprop(rf_model, 'NumTrained')
        num_trees = rf_model.NumTrained;
    elseif isprop(rf_model, 'NTrees')
        num_trees = rf_model.NTrees;
    elseif isa(rf_model, 'TreeBagger')
        num_trees = rf_model.NumTrees;
    else
        % Para ClassificationBaggedEnsemble
        num_trees = numel(rf_model.Trained);
    end
    fprintf('2. Número de árboles: %d\n', num_trees);
catch
    fprintf('2. Número de árboles: No disponible para este tipo de modelo\n');
end

% Clases - manejar diferentes tipos
fprintf('3. Clases predichas:\n');
class_names = rf_model.ClassNames;

% Convertir a cell array si es categórico o string
if iscategorical(class_names)
    class_names_cell = cellstr(class_names);
elseif isstring(class_names)
    class_names_cell = cellstr(class_names);
elseif iscell(class_names)
    class_names_cell = class_names;
else
    class_names_cell = {class_names};
end

for i = 1:length(class_names_cell)
    fprintf('   - %s\n', class_names_cell{i});
end

% Predictores
fprintf('4. Número de características (features): %d\n', size(rf_model.X, 2));
fprintf('\n');

%% 3. NOMBRES DE CARACTERÍSTICAS
fprintf('📋 CARACTERÍSTICAS EXTRAÍDAS:\n\n');
feature_names = {'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'};
for i = 1:length(feature_names)
    fprintf('   %d. %s\n', i, feature_names{i});
end
fprintf('\n');

%% 4. IMPORTANCIA DE CARACTERÍSTICAS
fprintf('⭐ IMPORTANCIA DE CARACTERÍSTICAS:\n\n');

try
    % Intentar obtener importancia (OOB permutation)
    if isprop(rf_model, 'OOBPermutedPredictorDeltaError')
        importance = rf_model.OOBPermutedPredictorDeltaError;
    elseif isa(rf_model, 'TreeBagger')
        importance = rf_model.OOBPermutedVarDeltaError;
    else
        % Método alternativo para ClassificationBaggedEnsemble
        try
            importance = oobPermutedPredictorImportance(rf_model);
        catch
            warning('No se pudo calcular importancia. Calculando manualmente...');
            importance = [];
        end
    end

    if ~isempty(importance)
        % Normalizar a porcentaje
        importance_pct = 100 * importance / sum(importance);

        % Crear tabla
        importance_table = table(feature_names', importance', importance_pct', ...
            'VariableNames', {'Caracteristica', 'Importancia', 'Porcentaje'});

        % Ordenar por importancia
        importance_table = sortrows(importance_table, 'Importancia', 'descend');

        % Mostrar
        disp(importance_table);

        % Gráfica
        figure('Position', [100, 100, 800, 500]);
        bar(importance_table.Porcentaje);
        set(gca, 'XTickLabel', importance_table.Caracteristica);
        xlabel('Característica');
        ylabel('Importancia Relativa (%)');
        title('Importancia de Características en el Modelo');
        grid on;

        fprintf('\n✓ Gráfica de importancia generada\n');
    else
        fprintf('⚠️  Importancia no disponible para este modelo\n');
    end
catch ME
    fprintf('⚠️  No se pudo calcular importancia de características\n');
    fprintf('   Razón: %s\n', ME.message);
end

fprintf('\n');

%% 5. MÉTRICAS DE RENDIMIENTO
fprintf('📈 MÉTRICAS DE RENDIMIENTO:\n\n');

try
    % Error OOB
    if isprop(rf_model, 'OOBLoss')
        oob_error = rf_model.OOBLoss;
        fprintf('   Error OOB:     %.2f%%%%\n', oob_error * 100);
        fprintf('   Accuracy OOB:  %.2f%%%%\n', (1 - oob_error) * 100);
    elseif isprop(rf_model, 'oobError')
        oob_error = rf_model.oobError;
        fprintf('   Error OOB:     %.2f%%%%\n', oob_error * 100);
        fprintf('   Accuracy OOB:  %.2f%%%%\n', (1 - oob_error) * 100);
    elseif isa(rf_model, 'TreeBagger')
        oob_error = rf_model.OOBError(end);
        fprintf('   Error OOB:     %.2f%%%%\n', oob_error * 100);
        fprintf('   Accuracy OOB:  %.2f%%%%\n', (1 - oob_error) * 100);
    else
        fprintf('   Error OOB:     No disponible\n');
        fprintf('   Accuracy OOB:  No disponible\n');
    end
catch
    fprintf('   Error OOB:     No calculado\n');
    fprintf('   Accuracy OOB:  No calculado\n');
end

fprintf('\n');

%% 6. INFORMACIÓN DEL DATASET DE ENTRENAMIENTO
fprintf('💾 DATASET DE ENTRENAMIENTO:\n\n');

fprintf('   Muestras totales: %d\n', size(rf_model.X, 1));

% Distribución de clases
if isprop(rf_model, 'Y')
    try
        labels = rf_model.Y;

        % Convertir labels si es necesario
        if iscategorical(labels)
            labels_cell = cellstr(labels);
        elseif isstring(labels)
            labels_cell = cellstr(labels);
        elseif iscell(labels)
            labels_cell = labels;
        else
            labels_cell = {labels};
        end

        fprintf('\n   Distribución de clases:\n');
        for i = 1:length(class_names_cell)
            count = sum(strcmp(labels_cell, class_names_cell{i}));
            pct = 100 * count / length(labels);
            fprintf('   - %-20s: %4d muestras (%5.1f%%%%)\n', ...
                class_names_cell{i}, count, pct);
        end
    catch ME
        fprintf('   Distribución de clases: Error - %s\n', ME.message);
    end
else
    fprintf('   Distribución de clases: No disponible\n');
end

fprintf('\n');

%% 7. RESUMEN Y RECOMENDACIONES
fprintf('╔═══════════════════════════════════════════╗\n');
fprintf('║              RESUMEN                      ║\n');
fprintf('╚═══════════════════════════════════════════╝\n');
fprintf('\n');

fprintf('✓ Modelo cargado y funcional\n');
fprintf('✓ Tipo: Random Forest (%s)\n', class(rf_model));

try
    fprintf('✓ Número de árboles: %d\n', num_trees);
catch
    fprintf('✓ Número de árboles: Múltiples learners\n');
end

fprintf('✓ Clases: %d (%s)\n', length(class_names_cell), ...
    strjoin(class_names_cell, ', '));
fprintf('\n');

fprintf('📌 RECOMENDACIONES:\n\n');
fprintf('   1. Si deseas mejorar el modelo, ejecuta:\n');
fprintf('      run(''src/training/prepare_training_data.m'')\n');
fprintf('      run(''src/training/train_new_model.m'')\n');
fprintf('\n');
fprintf('   2. Para agregar nuevas clases de fallas:\n');
fprintf('      - Crea labeled_data.csv con archivos etiquetados\n');
fprintf('      - Usa templates/labeled_data_example.csv como plantilla\n');
fprintf('      - Ejecuta prepare_training_data.m\n');
fprintf('\n');
fprintf('   3. Para comparar con un modelo nuevo:\n');
fprintf('      run(''src/training/compare_models.m'')\n');
fprintf('\n');

fprintf('═══════════════════════════════════════════════\n');
fprintf('✓ Inspección completada exitosamente\n');
fprintf('═══════════════════════════════════════════════\n');
fprintf('\n');