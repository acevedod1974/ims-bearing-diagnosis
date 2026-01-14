% prepare_training_data.m
% Preparar datos etiquetados para entrenar un nuevo modelo
% Compatible con MATLAB R2020a+
%
% ANTES DE EJECUTAR:
%   1. Crea un archivo CSV con etiquetas: 'labeled_data.csv'
%      Formato: archivo,etiqueta
%      Ejemplo:
%      2003.10.22.12.06.24,normal
%      2004.02.15.12.52.01,outer_race_fault
%      2004.02.17.08.02.38,inner_race_fault
%
%   2. Coloca labeled_data.csv en la raíz del proyecto

clear; clc;

fprintf('\n╔═══════════════════════════════════════════╗\n');
fprintf('║   PREPARACIÓN DE DATOS DE ENTRENAMIENTO   ║\n');
fprintf('╚═══════════════════════════════════════════╝\n\n');

%% ========================================================================
%  PASO 1: Cargar etiquetas desde CSV
%  ========================================================================
fprintf('PASO 1: Cargando archivo de etiquetas...\n');

labels_file = 'labeled_data.csv';

if ~isfile(labels_file)
    error(['Archivo no encontrado: %s\n', ...
           'Crea un CSV con formato: archivo,etiqueta'], labels_file);
end

% Leer CSV
labeled_data = readtable(labels_file, 'TextType', 'string');

fprintf('  ✓ Etiquetas cargadas: %d archivos\n', height(labeled_data));

% Mostrar distribución de clases
fprintf('\n  Distribución de clases:\n');
unique_labels = unique(labeled_data.etiqueta);
for i = 1:length(unique_labels)
    count = sum(labeled_data.etiqueta == unique_labels{i});
    fprintf('    %-20s: %d archivos\n', unique_labels{i}, count);
end

%% ========================================================================
%  PASO 2: Extraer características de cada archivo
%  ========================================================================
fprintf('\nPASO 2: Extrayendo características...\n');

% Rutas a carpetas de datos
data_folders = {
    fullfile('data', '1st_test');
    fullfile('data', '2nd_test');
    fullfile('data', '3rd_test')
};

% Inicializar matriz de características y vector de etiquetas
n_samples = height(labeled_data);
features = zeros(n_samples, 6); % 6 características: RMS_XYZ + Kurt_XYZ
labels = strings(n_samples, 1);

% Barra de progreso
h = waitbar(0, 'Extrayendo características...');

for i = 1:n_samples
    archivo = labeled_data.archivo(i);
    etiqueta = labeled_data.etiqueta(i);

    % Buscar archivo en todas las carpetas
    found = false;

    for f = 1:length(data_folders)
        file_path = fullfile(data_folders{f}, archivo);

        if isfile(file_path)
            try
                % Leer datos
                data = readmatrix(file_path, 'FileType', 'text');

                % Extraer señales triaxiales
                signal_xyz = data(:, 1:3);

                % Extraer características
                features(i, :) = extract_rms_kurtosis(signal_xyz);
                labels(i) = etiqueta;

                found = true;
                break;

            catch ME
                warning('Error procesando %s: %s', archivo, ME.message);
            end
        end
    end

    if ~found
        warning('Archivo no encontrado: %s', archivo);
    end

    waitbar(i/n_samples, h);
end

close(h);

% Eliminar filas sin datos
valid_idx = labels ~= "";
features = features(valid_idx, :);
labels = labels(valid_idx);

fprintf('  ✓ Características extraídas: %d muestras válidas\n', length(labels));

%% ========================================================================
%  PASO 3: Guardar dataset preparado
%  ========================================================================
fprintf('\nPASO 3: Guardando dataset de entrenamiento...\n');

% Crear tabla con características y etiquetas
feature_names = {'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'};
training_data = array2table(features, 'VariableNames', feature_names);
training_data.Label = categorical(labels);

% Guardar en formato MAT
save('training_dataset.mat', 'features', 'labels', 'training_data');

% Guardar también en CSV para inspección
writetable(training_data, 'training_dataset.csv');

fprintf('  ✓ Dataset guardado:\n');
fprintf('    - training_dataset.mat\n');
fprintf('    - training_dataset.csv\n');

%% ========================================================================
%  PASO 4: Visualizar distribución de datos
%  ========================================================================
fprintf('\nPASO 4: Generando visualizaciones...\n');

figure('Position', [100, 100, 1400, 600]);

% Subplot 1: RMS_X vs Kurt_X
subplot(1,3,1);
gscatter(features(:,1), features(:,4), labels);
xlabel('RMS_X'); ylabel('Kurt_X');
title('RMS vs Curtosis (Canal X)', 'FontWeight', 'bold');
grid on; legend('Location', 'best');

% Subplot 2: RMS_Y vs Kurt_Y
subplot(1,3,2);
gscatter(features(:,2), features(:,5), labels);
xlabel('RMS_Y'); ylabel('Kurt_Y');
title('RMS vs Curtosis (Canal Y)', 'FontWeight', 'bold');
grid on; legend('Location', 'best');

% Subplot 3: RMS_Z vs Kurt_Z
subplot(1,3,3);
gscatter(features(:,3), features(:,6), labels);
xlabel('RMS_Z'); ylabel('Kurt_Z');
title('RMS vs Curtosis (Canal Z)', 'FontWeight', 'bold');
grid on; legend('Location', 'best');

sgtitle('Distribución de Características por Clase', ...
        'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, 'training_data_visualization.png');

fprintf('  ✓ Visualización guardada: training_data_visualization.png\n');

fprintf('\n╔═══════════════════════════════════════════╗\n');
fprintf('║    PREPARACIÓN DE DATOS COMPLETADA        ║\n');
fprintf('╚═══════════════════════════════════════════╝\n');
fprintf('\nPróximo paso:\n');
fprintf('  → run(''train_new_model.m'')\n\n');
