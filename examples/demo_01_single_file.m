%% DEMO 1: Análisis de un archivo individual
% Este script muestra el procesamiento básico de una señal de vibración
% Propósito: Entender el flujo de trabajo del sistema paso a paso
%
% Autor: Daniel Acevedo Lopez
% Curso: Procesos de Fabricación
% Fecha: Enero 2026

clear; clc; close all;

fprintf('\n===============================================\n');
fprintf('  DEMO: Análisis de Señal Individual\n');
fprintf('  Sistema de Diagnóstico de Rodamientos\n');
fprintf('===============================================\n\n');

%% PASO 1: Cargar datos de vibración
fprintf('PASO 1: Cargando datos de vibración...\n');

% NOTA: Ajusta esta ruta según tu instalación
archivo = fullfile('..', 'data', '1st_test', '2003.10.22.12.06.24');

if ~isfile(archivo)
    error(['Archivo no encontrado. Ajusta la ruta en la línea 21.\n', ...
           'Formato esperado: data/1st_test/YYYY.MM.DD.HH.MM.SS']);
end

% Leer archivo de texto con datos de vibración
data = readmatrix(archivo, 'FileType', 'text');
signal = data(:, 1:3);  % Columnas 1-3: canales X, Y, Z

fprintf('  ✓ Archivo: %s\n', archivo);
fprintf('  ✓ Muestras: %d\n', size(signal,1));
fprintf('  ✓ Canales: %d (X, Y, Z)\n\n', size(signal,2));

%% PASO 2: Visualizar señal en el dominio del tiempo
fprintf('PASO 2: Visualizando señales en el tiempo...\n');

% Crear vector de tiempo (frecuencia de muestreo: 20 kHz)
fs = 20000;  % Hz
t = (0:size(signal,1)-1) / fs;  % Vector de tiempo en segundos

figure('Position', [100, 100, 1200, 400]);

subplot(1,3,1); 
plot(t, signal(:,1), 'b', 'LineWidth', 0.5); 
title('Canal X (Horizontal)', 'FontWeight', 'bold'); 
xlabel('Tiempo (s)'); 
ylabel('Amplitud (g)');
grid on;

subplot(1,3,2); 
plot(t, signal(:,2), 'r', 'LineWidth', 0.5);
title('Canal Y (Horizontal)', 'FontWeight', 'bold'); 
xlabel('Tiempo (s)'); 
ylabel('Amplitud (g)');
grid on;

subplot(1,3,3); 
plot(t, signal(:,3), 'g', 'LineWidth', 0.5);
title('Canal Z (Vertical)', 'FontWeight', 'bold'); 
xlabel('Tiempo (s)'); 
ylabel('Amplitud (g)');
grid on;

sgtitle('Señales de Vibración Triaxial', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('  ✓ Gráficas generadas\n');
fprintf('  ✓ Duración de la señal: %.2f segundos\n\n', max(t));

%% PASO 3: Extraer características estadísticas
fprintf('PASO 3: Extrayendo características (RMS y Curtosis)...\n');

% Llamar a la función de extracción
features = extract_rms_kurtosis(signal);

fprintf('\n  📊 CARACTERÍSTICAS EXTRAÍDAS:\n');
fprintf('  ┌────────────────────────────────────┐\n');
fprintf('  │ Característica  │  X     │  Y     │  Z     │\n');
fprintf('  ├────────────────────────────────────┤\n');
fprintf('  │ RMS            │ %.4f │ %.4f │ %.4f │\n', ...
        features(1), features(2), features(3));
fprintf('  │ Curtosis       │ %.4f │ %.4f │ %.4f │\n', ...
        features(4), features(5), features(6));
fprintf('  └────────────────────────────────────┘\n');

% Interpretación física
fprintf('\n  💡 INTERPRETACIÓN FÍSICA:\n');
fprintf('     RMS → Energía de vibración (relacionada con desgaste)\n');
fprintf('     Curtosis → Impulsividad (detecta impactos por fallas)\n');
fprintf('     Curtosis ≈ 3 → Distribución normal (saludable)\n');
fprintf('     Curtosis > 5 → Presencia de impactos repetitivos\n\n');

%% PASO 4: Clasificar estado del rodamiento
fprintf('PASO 4: Clasificando estado con Random Forest...\n');

% Cargar modelo pre-entrenado
model_path = fullfile('..', 'models', 'ims_modelo_especifico.mat');

if ~isfile(model_path)
    error('Modelo no encontrado: %s\nEjecuta primero el script principal.', model_path);
end

model_data = load(model_path);
rf_model = model_data.rf_ims;

% Predecir clase y confianza
[pred, scores] = predict(rf_model, features);
conf = 100 * max(scores);

fprintf('\n  🔍 DIAGNÓSTICO:\n');
fprintf('  ┌────────────────────────────────────┐\n');
fprintf('  │ Estado:     %-20s │\n', char(pred));
fprintf('  │ Confianza:  %.1f%%%%                  │\n', conf);
fprintf('  └────────────────────────────────────┘\n');

% Interpretación del resultado
fprintf('\n  📋 INTERPRETACIÓN:\n');
if conf > 90
    fprintf('     ✓ Alta confianza: resultado muy confiable\n');
elseif conf > 75
    fprintf('     ⚠ Confianza media: revisar contexto operacional\n');
else
    fprintf('     ✗ Baja confianza: verificar calidad de datos\n');
end

% Visualizar scores de todas las clases
fprintf('\n  📊 SCORES POR CLASE:\n');
[sorted_scores, idx] = sort(scores, 'descend');
class_names = rf_model.ClassNames;
for i = 1:length(class_names)
    bar_len = round(sorted_scores(i) * 50);
    bar = repmat('█', 1, bar_len);
    fprintf('     %-15s: %.1f%%%% %s\n', ...
            char(class_names{idx(i)}), sorted_scores(i)*100, bar);
end

%% PASO 5: Visualización comparativa de características
fprintf('\nPASO 5: Generando visualización comparativa...\n');

figure('Position', [100, 100, 1000, 400]);

subplot(1,2,1);
bar([features(1:3)]);
set(gca, 'XTickLabel', {'X', 'Y', 'Z'});
title('RMS por Eje', 'FontWeight', 'bold');
ylabel('Valor RMS');
grid on;

subplot(1,2,2);
bar([features(4:6)]);
set(gca, 'XTickLabel', {'X', 'Y', 'Z'});
title('Curtosis por Eje', 'FontWeight', 'bold');
ylabel('Valor de Curtosis');
hold on;
yline(3, 'r--', 'LineWidth', 2, 'Label', 'Normal (Kurt=3)');
grid on;

sgtitle(sprintf('Características del Archivo - Estado: %s (%.1f%%%% confianza)', ...
        char(pred), conf), 'FontSize', 12, 'FontWeight', 'bold');

fprintf('  ✓ Visualizaciones completadas\n');

%% RESUMEN FINAL
fprintf('\n===============================================\n');
fprintf('  ✓ DEMO COMPLETADO EXITOSAMENTE\n');
fprintf('===============================================\n');
fprintf('\nPróximos pasos:\n');
fprintf('  1. Ejecuta IMS_bearing_diagnosis_main() para procesar todos los archivos\n');
fprintf('  2. Revisa los resultados en la carpeta results/\n');
fprintf('  3. Analiza las gráficas generadas\n\n');
