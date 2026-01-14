% demo_01_single_file.m
% DEMO: Análisis de un archivo individual del dataset IMS
% 
% Este script demuestra el procesamiento paso a paso de UNA señal de vibración:
%   1. Carga de datos
%   2. Visualización de señales triaxiales
%   3. Extracción de características (RMS y Curtosis)
%   4. Clasificación con Random Forest
%
% PROPÓSITO PEDAGÓGICO:
%   - Ideal para clases magistrales de Procesos de Fabricación
%   - Muestra visualmente cada etapa del diagnóstico
%   - Interpreta físicamente los resultados
%
% AUTOR: Daniel Acevedo Lopez
% FECHA: Enero 2026

clear; clc; close all;

fprintf('\n===============================================\n');
fprintf('  DEMO: Análisis de Señal Individual\n');
fprintf('  Sistema de Diagnóstico de Rodamientos\n');
fprintf('===============================================\n\n');

%% ========================================================================
%  PASO 1: Cargar archivo de datos
%  ========================================================================
fprintf('PASO 1: Cargando datos de vibración...\n');

% Definir ruta del archivo (ajusta según tu estructura)
data_file = fullfile('..', 'data', '1st_test', '2003.10.22.12.06.24');

if ~isfile(data_file)
    error(['Archivo no encontrado: %s\n', ...
           'Ajusta la ruta en la línea 25 de este script.'], data_file);
end

% Leer datos
data = readmatrix(data_file, 'FileType', 'text');

fprintf('  ✓ Archivo: %s\n', data_file);
fprintf('  ✓ Muestras: %d\n', size(data, 1));
fprintf('  ✓ Canales: %d (X, Y, Z)\n', size(data, 2));

% Extraer señales triaxiales
signal_x = data(:, 1);
signal_y = data(:, 2);
signal_z = data(:, 3);

%% ========================================================================
%  PASO 2: Visualizar señales en el tiempo
%  ========================================================================
fprintf('\nPASO 2: Visualizando señales en el tiempo...\n');

% Frecuencia de muestreo típica del IMS dataset
fs = 20000; % Hz
n_samples = length(signal_x);
time = (0:n_samples-1) / fs;

figure('Position', [100, 100, 1200, 700]);

% Subplot 1: Canal X
subplot(3,1,1);
plot(time, signal_x, 'b', 'LineWidth', 0.5);
title('Vibración - Canal X (Horizontal)', 'FontWeight', 'bold');
ylabel('Amplitud (g)');
xlabel('Tiempo (s)');
grid on;

% Subplot 2: Canal Y
subplot(3,1,2);
plot(time, signal_y, 'r', 'LineWidth', 0.5);
title('Vibración - Canal Y (Vertical)', 'FontWeight', 'bold');
ylabel('Amplitud (g)');
xlabel('Tiempo (s)');
grid on;

% Subplot 3: Canal Z
subplot(3,1,3);
plot(time, signal_z, 'g', 'LineWidth', 0.5);
title('Vibración - Canal Z (Axial)', 'FontWeight', 'bold');
ylabel('Amplitud (g)');
xlabel('Tiempo (s)');
grid on;

sgtitle('Señales Triaxiales de Vibración', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('  ✓ Gráficas generadas\n');
fprintf('  ✓ Duración de la señal: %.2f segundos\n', max(time));

%% ========================================================================
%  PASO 3: Extraer características estadísticas
%  ========================================================================
fprintf('\nPASO 3: Extrayendo características (RMS y Curtosis)...\n');

% Usar la función mejorada
signal_xyz = [signal_x, signal_y, signal_z];
features = extract_rms_kurtosis(signal_xyz);

% Desempacar características
rms_x   = features(1);
rms_y   = features(2);
rms_z   = features(3);
kurt_x  = features(4);
kurt_y  = features(5);
kurt_z  = features(6);

% Mostrar en formato tabla
fprintf('\n  📊 CARACTERÍSTICAS EXTRAÍDAS:\n');
fprintf('  ┌────────────────────────────────────┐\n');
fprintf('  │ Característica  │  X     │  Y     │  Z     │\n');
fprintf('  ├────────────────────────────────────┤\n');
fprintf('  │ RMS            │ %.4f │ %.4f │ %.4f │\n', rms_x, rms_y, rms_z);
fprintf('  │ Curtosis       │ %.4f │ %.4f │ %.4f │\n', kurt_x, kurt_y, kurt_z);
fprintf('  └────────────────────────────────────┘\n');

fprintf('\n  💡 INTERPRETACIÓN FÍSICA:\n');
fprintf('     RMS → Energía de vibración (relacionada con desgaste)\n');
fprintf('     Curtosis → Impulsividad (detecta impactos por fallas)\n');
fprintf('     Curtosis ≈ 3 → Distribución normal (saludable)\n');
fprintf('     Curtosis > 5 → Presencia de impactos repetitivos\n');

%% ========================================================================
%  PASO 4: Clasificar con modelo Random Forest
%  ========================================================================
fprintf('\nPASO 4: Clasificando estado con Random Forest...\n');

% Cargar modelo pre-entrenado
model_file = fullfile('..', 'models', 'ims_modelo_especifico.mat');

if ~isfile(model_file)
    error(['Modelo no encontrado: %s\n', ...
           'Asegúrate de que el modelo esté en la carpeta models/'], model_file);
end

model_data = load(model_file);
rf_model = model_data.rf_ims;

% Clasificar
[prediction, scores] = predict(rf_model, features);
confidence = 100 * max(scores);

% Mostrar resultado
fprintf('\n  🔍 DIAGNÓSTICO:\n');
fprintf('  ┌────────────────────────────────────┐\n');
fprintf('  │ Estado:     %-20s │\n', char(prediction));
fprintf('  │ Confianza:  %.1f%%%%                  │\n', confidence);
fprintf('  └────────────────────────────────────┘\n');

% Interpretación de confianza
fprintf('\n  📋 INTERPRETACIÓN:\n');
if confidence > 90
    fprintf('     ✓ Alta confianza: resultado muy confiable\n');
elseif confidence > 75
    fprintf('     ⚠ Confianza moderada: revisar manualmente\n');
else
    fprintf('     ⚠ Baja confianza: requiere análisis adicional\n');
end

% Mostrar scores de todas las clases
fprintf('\n  📊 SCORES POR CLASE:\n');
class_names = rf_model.ClassNames;
[sorted_scores, idx] = sort(scores, 'descend');

for i = 1:length(class_names)
    % Convertir a string de forma segura (compatible con categorical, string, cell)
    class_str = char(string(class_names(idx(i))));

    % Barra de progreso visual
    bar_len = round(sorted_scores(i) * 50);
    bar = repmat('█', 1, bar_len);

    fprintf('     %-20s: %5.1f%%%%  %s\n', ...
            class_str, sorted_scores(i)*100, bar);
end

%% ========================================================================
%  PASO 5: Análisis Espectral (BONUS)
%  ========================================================================
fprintf('\nPASO 5 (BONUS): Análisis espectral...\n');

% FFT del canal con mayor RMS
[~, dominant_channel] = max([rms_x, rms_y, rms_z]);
channel_names = {'X', 'Y', 'Z'};

if dominant_channel == 1
    signal_fft = signal_x;
elseif dominant_channel == 2
    signal_fft = signal_y;
else
    signal_fft = signal_z;
end

% Calcular FFT
N = length(signal_fft);
Y = fft(signal_fft);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(N/2))/N;

% Graficar espectro
figure('Position', [100, 100, 1000, 500]);
plot(f, P1, 'LineWidth', 1);
title(sprintf('Espectro de Frecuencia - Canal %s (Dominante)', ...
              channel_names{dominant_channel}), 'FontWeight', 'bold');
xlabel('Frecuencia (Hz)');
ylabel('Magnitud');
xlim([0 5000]); % Mostrar hasta 5 kHz
grid on;

fprintf('  ✓ Espectro del canal %s generado\n', channel_names{dominant_channel});
fprintf('  ✓ Canal dominante seleccionado por mayor RMS\n');

%% ========================================================================
%  RESUMEN FINAL
%  ========================================================================
fprintf('\n===============================================\n');
fprintf('  DEMO COMPLETADO\n');
fprintf('===============================================\n');
fprintf('\nPara analizar otro archivo:\n');
fprintf('  1. Edita la línea 25: data_file = ''ruta/al/archivo''\n');
fprintf('  2. Ejecuta: run(''demo_01_single_file.m'')\n\n');
fprintf('Para procesar TODOS los archivos:\n');
fprintf('  → IMS_bearing_diagnosis_main()\n\n');