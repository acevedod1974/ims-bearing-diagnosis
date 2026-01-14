%% analizar_resultados_detallado_v2.m
% ═══════════════════════════════════════════════════════════════════════
% ANÁLISIS PROFUNDO DE RESULTADOS IMS - VERSIÓN MEJORADA v2.0
% ═══════════════════════════════════════════════════════════════════════
%
% Mejoras sobre v1.0:
% ✓ Parseo robusto de fechas con regexp
% ✓ Validación completa de estructura de datos
% ✓ Exportación a CSV para análisis posterior
% ✓ Análisis de correlación entre características
% ✓ Estadísticas avanzadas (percentiles, IQR, CV)
% ✓ Manejo de memoria optimizado
% ✓ Compatibilidad MATLAB R2020a
%
% Uso:
%   run('src/analysis/analizar_resultados_detallado_v2.m')
%
% Autor: Sistema IMS Bearing Diagnosis
% Fecha: Enero 2026
% ═══════════════════════════════════════════════════════════════════════

clear; clc; close all;

%% CONFIGURACIÓN INICIAL
script_path = fileparts(mfilename('fullpath'));
project_root = fileparts(fileparts(script_path));
results_path = fullfile(project_root, 'results', 'resultados_diagnostico.mat');
output_dir = fullfile(project_root, 'results');

fprintf('\n');
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  ANÁLISIS DETALLADO DE RESULTADOS IMS - v2.0            ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

%% 1. CARGAR Y VALIDAR RESULTADOS
fprintf('📂 Cargando resultados...\n');
fprintf('   Ruta: %s\n\n', results_path);

if ~exist(results_path, 'file')
    error('❌ ERROR: Archivo no encontrado:\n   %s', results_path);
end

data = load(results_path);

% Validar estructura de datos
if ~isfield(data, 'results')
    error('❌ ERROR: El archivo no contiene la variable "results"');
end

results = data.results;

% Validar columnas requeridas
required_cols = {'Archivo', 'Prediccion', 'Confianza', ...
                 'RMS_X', 'RMS_Y', 'RMS_Z', ...
                 'Kurt_X', 'Kurt_Y', 'Kurt_Z'};

missing_cols = setdiff(required_cols, results.Properties.VariableNames);
if ~isempty(missing_cols)
    error('❌ ERROR: Faltan columnas en results: %s', strjoin(missing_cols, ', '));
end

fprintf('✓ Resultados cargados y validados: %d archivos\n\n', height(results));

%% 2. PARSEO ROBUSTO DE FECHAS
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  EXTRACCIÓN DE INFORMACIÓN TEMPORAL                      ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

dates = NaT(height(results), 1);
parse_success = false(height(results), 1);

for i = 1:height(results)
    try
        % Método 1: Parseo directo (más rápido)
        dates(i) = datetime(results.Archivo{i}, 'InputFormat', 'yyyy.MM.dd.HH.mm.ss');
        parse_success(i) = true;
    catch
        % Método 2: Regex robusto (fallback)
        pattern = '(\d{4})\.(\d{2})\.(\d{2})\.(\d{2})\.(\d{2})\.(\d{2})';
        tokens = regexp(results.Archivo{i}, pattern, 'tokens', 'once');
        
        if ~isempty(tokens)
            year = str2double(tokens{1});
            month = str2double(tokens{2});
            day = str2double(tokens{3});
            hour = str2double(tokens{4});
            minute = str2double(tokens{5});
            second = str2double(tokens{6});
            
            dates(i) = datetime(year, month, day, hour, minute, second);
            parse_success(i) = true;
        else
            warning('No se pudo parsear fecha: %s', results.Archivo{i});
        end
    end
end

n_parsed = sum(parse_success);
fprintf('✓ Fechas parseadas exitosamente: %d/%d (%.1f%%)\n\n', ...
        n_parsed, height(results), 100*n_parsed/height(results));

% Agregar fechas a la tabla
results.Fecha = dates;

%% 3. IDENTIFICAR FALLAS CRÍTICAS
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  ANÁLISIS DE FALLAS DETECTADAS                           ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

fallas = results(results.Prediccion ~= "normal", :);
n_fallas = height(fallas);
pct_fallas = 100 * n_fallas / height(results);

fprintf('📊 Total de fallas detectadas: %d (%.1f%%)\n\n', n_fallas, pct_fallas);

if n_fallas > 0
    % Top 20 fallas más severas
    [~, idx] = sort(fallas.Kurt_Z, 'descend');
    n_top = min(20, n_fallas);
    top_fallas = fallas(idx(1:n_top), :);
    
    fprintf('🔴 Top %d Fallas Más Severas (Mayor Curtosis):\n\n', n_top);
    
    % Tabla formateada
    fprintf('%-30s %-18s %10s %10s %10s\n', ...
            'Archivo', 'Tipo de Falla', 'Confianza', 'Kurt_Z', 'RMS_Z');
    fprintf('%s\n', repmat('-', 1, 90));
    
    for i = 1:n_top
        archivo_corto = top_fallas.Archivo{i};
        if length(archivo_corto) > 29
            archivo_corto = archivo_corto(1:29);
        end
        
        fprintf('%-30s %-18s %9.1f%% %10.4f %10.6f\n', ...
                archivo_corto, ...
                char(top_fallas.Prediccion(i)), ...
                top_fallas.Confianza(i), ...
                top_fallas.Kurt_Z(i), ...
                top_fallas.RMS_Z(i));
    end
    fprintf('\n');
    
    % Exportar fallas críticas a CSV
    csv_file = fullfile(output_dir, 'top_fallas_criticas.csv');
    writetable(top_fallas, csv_file);
    fprintf('✓ Fallas críticas exportadas: %s\n\n', csv_file);
else
    fprintf('✅ No se detectaron fallas en el dataset\n\n');
end

%% 4. ESTADÍSTICAS AVANZADAS
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  ESTADÍSTICAS DESCRIPTIVAS AVANZADAS                     ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Función auxiliar para estadísticas completas
function print_stats(data, label)
    fprintf('%s:\n', label);
    fprintf('  Media:        %10.6f\n', mean(data));
    fprintf('  Mediana:      %10.6f\n', median(data));
    fprintf('  Desv. Std:    %10.6f\n', std(data));
    fprintf('  Mín-Máx:      %10.6f - %.6f\n', min(data), max(data));
    fprintf('  Percentiles:  [P25: %.6f | P50: %.6f | P75: %.6f]\n', ...
            prctile(data, 25), prctile(data, 50), prctile(data, 75));
    fprintf('  IQR:          %10.6f\n', iqr(data));
    fprintf('  CV:           %10.2f%%\n', 100*std(data)/mean(data));
    fprintf('\n');
end

% RMS por eje
fprintf('═══ RMS (Root Mean Square) ═══\n\n');
print_stats(results.RMS_X, 'RMS Eje X');
print_stats(results.RMS_Y, 'RMS Eje Y');
print_stats(results.RMS_Z, 'RMS Eje Z');

% Curtosis por eje
fprintf('═══ Curtosis (Kurtosis) ═══\n\n');
print_stats(results.Kurt_X, 'Curtosis Eje X');
print_stats(results.Kurt_Y, 'Curtosis Eje Y');
print_stats(results.Kurt_Z, 'Curtosis Eje Z');

%% 5. ANÁLISIS DE CORRELACIÓN
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  ANÁLISIS DE CORRELACIÓN ENTRE CARACTERÍSTICAS           ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Matriz de características
features_matrix = [results.RMS_X, results.RMS_Y, results.RMS_Z, ...
                   results.Kurt_X, results.Kurt_Y, results.Kurt_Z];
feature_names = {'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'};

% Calcular correlaciones
corr_matrix = corrcoef(features_matrix);

fprintf('Matriz de Correlación (Pearson):\n\n');
fprintf('%12s', 'Feature');
for i = 1:length(feature_names)
    fprintf('%10s', feature_names{i});
end
fprintf('\n%s\n', repmat('-', 1, 12 + 10*length(feature_names)));

for i = 1:length(feature_names)
    fprintf('%12s', feature_names{i});
    for j = 1:length(feature_names)
        if i == j
            fprintf('%10s', '1.00');
        else
            fprintf('%10.3f', corr_matrix(i, j));
        end
    end
    fprintf('\n');
end
fprintf('\n');

% Identificar correlaciones fuertes
fprintf('🔍 Correlaciones Significativas (|r| > 0.7):\n\n');
strong_corr_found = false;
for i = 1:length(feature_names)
    for j = (i+1):length(feature_names)
        r = corr_matrix(i, j);
        if abs(r) > 0.7
            fprintf('  • %s ↔ %s: r = %.3f\n', ...
                    feature_names{i}, feature_names{j}, r);
            strong_corr_found = true;
        end
    end
end
if ~strong_corr_found
    fprintf('  (No se encontraron correlaciones fuertes)\n');
end
fprintf('\n');

%% 6. ANÁLISIS TEMPORAL
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  EVOLUCIÓN TEMPORAL DE CARACTERÍSTICAS                   ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

if n_parsed > 0
    % Ordenar por fecha
    [dates_sorted, sort_idx] = sort(dates(parse_success));
    results_sorted = results(parse_success, :);
    results_sorted = results_sorted(sort_idx, :);
    
    % Crear figura con mejor calidad
    fig = figure('Position', [100, 100, 1600, 1000], ...
                 'Name', 'Análisis Temporal IMS', ...
                 'Color', 'white');
    
    % Subplot 1: RMS en los 3 ejes
    subplot(4, 1, 1);
    hold on;
    plot(dates_sorted, results_sorted.RMS_X, '-', 'LineWidth', 1.2, ...
         'Color', [0.8 0.2 0.2], 'DisplayName', 'RMS X');
    plot(dates_sorted, results_sorted.RMS_Y, '-', 'LineWidth', 1.2, ...
         'Color', [0.2 0.8 0.2], 'DisplayName', 'RMS Y');
    plot(dates_sorted, results_sorted.RMS_Z, '-', 'LineWidth', 1.5, ...
         'Color', [0.2 0.4 0.8], 'DisplayName', 'RMS Z');
    hold off;
    ylabel('RMS (g)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Evolución de Vibración (RMS) - Comparación 3 Ejes', ...
          'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9);
    grid on;
    set(gca, 'FontSize', 10);
    
    % Subplot 2: Curtosis en los 3 ejes
    subplot(4, 1, 2);
    hold on;
    plot(dates_sorted, results_sorted.Kurt_X, '-', 'LineWidth', 1.2, ...
         'Color', [0.8 0.2 0.2], 'DisplayName', 'Kurt X');
    plot(dates_sorted, results_sorted.Kurt_Y, '-', 'LineWidth', 1.2, ...
         'Color', [0.2 0.8 0.2], 'DisplayName', 'Kurt Y');
    plot(dates_sorted, results_sorted.Kurt_Z, '-', 'LineWidth', 1.5, ...
         'Color', [0.8 0.4 0.0], 'DisplayName', 'Kurt Z');
    hold off;
    ylabel('Curtosis', 'FontSize', 11, 'FontWeight', 'bold');
    title('Evolución de Impulsividad (Curtosis) - Comparación 3 Ejes', ...
          'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9);
    grid on;
    set(gca, 'FontSize', 10);
    
    % Subplot 3: Confianza del modelo
    subplot(4, 1, 3);
    plot(dates_sorted, results_sorted.Confianza, '-', 'LineWidth', 1.3, ...
         'Color', [0.5 0.2 0.8]);
    ylabel('Confianza (%)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Confianza del Modelo a lo Largo del Tiempo', ...
          'FontSize', 13, 'FontWeight', 'bold');
    ylim([0 100]);
    grid on;
    set(gca, 'FontSize', 10);
    
    % Subplot 4: Estado del rodamiento
    subplot(4, 1, 4);
    fault_indicator = double(results_sorted.Prediccion ~= "normal");
    plot(dates_sorted, fault_indicator, '.', 'MarkerSize', 12, ...
         'Color', [0.8 0.2 0.2]);
    ylim([-0.15, 1.15]);
    yticks([0, 1]);
    yticklabels({'✓ Normal', '✗ Falla'});
    xlabel('Fecha y Hora', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Estado', 'FontSize', 11, 'FontWeight', 'bold');
    title('Estado Diagnosticado del Rodamiento', ...
          'FontSize', 13, 'FontWeight', 'bold');
    grid on;
    set(gca, 'FontSize', 10);
    
    % Guardar gráfica
    output_png = fullfile(output_dir, 'analisis_temporal_v2.png');
    saveas(fig, output_png);
    fprintf('✓ Gráfica guardada: %s\n\n', output_png);
    
else
    fprintf('⚠️  No se pudieron parsear fechas para análisis temporal\n\n');
end

%% 7. ANÁLISIS POR DATASET
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  COMPARACIÓN ENTRE DATASETS (1st, 2nd, 3rd TEST)        ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

datasets = ["1st_test", "2nd_test", "3rd_test"];

fprintf('%-12s %10s %10s %10s %12s %12s %12s\n', ...
        'Dataset', 'Archivos', 'Fallas', '% Fallas', ...
        'RMS Z', 'Kurt Z', 'Confianza');
fprintf('%s\n', repmat('-', 1, 88));

dataset_stats = table();
for i = 1:length(datasets)
    dataset = datasets(i);
    idx = contains(results.Archivo, dataset);
    subset = results(idx, :);
    
    if height(subset) > 0
        n_total = height(subset);
        n_fallas = sum(subset.Prediccion ~= "normal");
        pct_fallas = 100 * n_fallas / n_total;
        rms_z = mean(subset.RMS_Z);
        kurt_z = mean(subset.Kurt_Z);
        conf = mean(subset.Confianza);
        
        fprintf('%-12s %10d %10d %9.1f%% %12.6f %12.4f %11.2f%%\n', ...
                char(dataset), n_total, n_fallas, pct_fallas, ...
                rms_z, kurt_z, conf);
        
        % Guardar para exportación
        row = table({char(dataset)}, n_total, n_fallas, pct_fallas, ...
                    rms_z, kurt_z, conf, ...
                    'VariableNames', {'Dataset', 'Total', 'Fallas', ...
                    'Pct_Fallas', 'RMS_Z_Mean', 'Kurt_Z_Mean', 'Confianza_Mean'});
        dataset_stats = [dataset_stats; row]; %#ok<AGROW>
    end
end
fprintf('\n');

% Exportar estadísticas por dataset
csv_file = fullfile(output_dir, 'estadisticas_por_dataset.csv');
writetable(dataset_stats, csv_file);
fprintf('✓ Estadísticas por dataset exportadas: %s\n\n', csv_file);

%% 8. DISTRIBUCIÓN DE CONFIANZA
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  ANÁLISIS DE CONFIANZA DEL MODELO                        ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

alta_conf = sum(results.Confianza >= 90);
media_conf = sum(results.Confianza >= 75 & results.Confianza < 90);
baja_conf = sum(results.Confianza < 75);

fprintf('Distribución por nivel de confianza:\n');
fprintf('  🟢 Alta (≥90%%):     %5d archivos (%5.1f%%)\n', ...
        alta_conf, 100*alta_conf/height(results));
fprintf('  🟡 Media (75-90%%):  %5d archivos (%5.1f%%)\n', ...
        media_conf, 100*media_conf/height(results));
fprintf('  🔴 Baja (<75%%):     %5d archivos (%5.1f%%)\n\n', ...
        baja_conf, 100*baja_conf/height(results));

fprintf('Estadísticas generales de confianza:\n');
fprintf('  Media:           %.2f%%\n', mean(results.Confianza));
fprintf('  Mediana:         %.2f%%\n', median(results.Confianza));
fprintf('  Desv. Estándar:  %.2f%%\n', std(results.Confianza));
fprintf('  Rango:           [%.2f%% - %.2f%%]\n\n', ...
        min(results.Confianza), max(results.Confianza));

%% 9. EXPORTAR RESULTADOS COMPLETOS
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  EXPORTACIÓN DE RESULTADOS                               ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Exportar tabla completa con fechas
csv_full = fullfile(output_dir, 'resultados_completos_con_fechas.csv');
writetable(results, csv_full);
fprintf('✓ Resultados completos: %s\n', csv_full);

% Exportar solo casos de baja confianza
if baja_conf > 0
    low_conf = results(results.Confianza < 75, :);
    csv_low = fullfile(output_dir, 'casos_baja_confianza.csv');
    writetable(low_conf, csv_low);
    fprintf('✓ Casos baja confianza: %s\n', csv_low);
end

fprintf('\n');

%% 10. RESUMEN FINAL
fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  RESUMEN DEL ANÁLISIS                                    ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

fprintf('✓ Análisis completado exitosamente\n');
fprintf('✓ Total de archivos analizados:    %d\n', height(results));
fprintf('✓ Archivos normales:                %d (%.1f%%)\n', ...
        sum(results.Prediccion == "normal"), ...
        100*sum(results.Prediccion == "normal")/height(results));
fprintf('✓ Archivos con fallas detectadas:  %d (%.1f%%)\n', ...
        n_fallas, pct_fallas);
fprintf('✓ Confianza promedio del modelo:   %.2f%%\n\n', ...
        mean(results.Confianza));

fprintf('📁 Archivos generados:\n');
fprintf('   • analisis_temporal_v2.png\n');
fprintf('   • resultados_completos_con_fechas.csv\n');
fprintf('   • estadisticas_por_dataset.csv\n');
if n_fallas > 0
    fprintf('   • top_fallas_criticas.csv\n');
end
if baja_conf > 0
    fprintf('   • casos_baja_confianza.csv\n');
end
fprintf('\n');

fprintf('═══════════════════════════════════════════════════════════\n');
fprintf('  Para visualizar gráficas: open results/analisis_temporal_v2.png\n');
fprintf('═══════════════════════════════════════════════════════════\n');
fprintf('\n');
