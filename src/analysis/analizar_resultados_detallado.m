% analizar_resultados_detallado.m
% Análisis profundo de los resultados del diagnóstico IMS
%
% Genera:
%   - Tabla de las 20 fallas más severas
%   - Gráficas de evolución temporal
%   - Estadísticas por dataset
%
% Uso:
%   run('src/analysis/analizar_resultados_detallado.m')

clear; clc;

%% Configurar rutas
script_path = fileparts(mfilename('fullpath'));
project_root = fileparts(fileparts(script_path));  % Subir 2 niveles
results_path = fullfile(project_root, 'results', 'resultados_diagnostico.mat');

fprintf('\n');
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║     ANÁLISIS DETALLADO DE RESULTADOS IMS          ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

%% 1. CARGAR RESULTADOS
fprintf('📂 Cargando resultados desde:\n   %s\n\n', results_path);

if ~exist(results_path, 'file')
    error('❌ Archivo no encontrado: %s', results_path);
end

load(results_path);

fprintf('✓ Resultados cargados: %d archivos analizados\n\n', height(results));

%% 2. IDENTIFICAR ARCHIVOS CRÍTICOS
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║          ANÁLISIS DE FALLAS DETECTADAS            ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

fallas = results(results.Prediccion ~= "normal", :);
fprintf('📊 Total de fallas detectadas: %d (%.1f%%%%)\n\n', ...
    height(fallas), 100*height(fallas)/height(results));

if height(fallas) > 0
    % Top 20 fallas más severas (mayor curtosis)
    [~, idx] = sort(fallas.Kurt_Z, 'descend');
    n_top = min(20, height(fallas));
    top_fallas = fallas(idx(1:n_top), :);

    fprintf('🔴 Top %d Fallas Más Severas (Mayor Curtosis):\n\n', n_top);

    % Mostrar tabla formateada
    fprintf('%-25s %-20s %10s %10s %10s\n', ...
        'Archivo', 'Tipo de Falla', 'Confianza', 'Kurt_Z', 'RMS_Z');
    fprintf('%s\n', repmat('-', 1, 85));

    for i = 1:n_top
        fprintf('%-25s %-20s %9.1f%% %10.4f %10.6f\n', ...
            top_fallas.Archivo{i}(1:min(24, length(top_fallas.Archivo{i}))), ...
            char(top_fallas.Prediccion(i)), ...
            top_fallas.Confianza(i), ...
            top_fallas.Kurt_Z(i), ...
            top_fallas.RMS_Z(i));
    end
    fprintf('\n');
else
    fprintf('✅ No se detectaron fallas en el dataset\n\n');
end

%% 3. ANÁLISIS TEMPORAL
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║            EVOLUCIÓN TEMPORAL                     ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

try
    % Extraer fechas de los nombres de archivo
    dates = datetime(results.Archivo, 'InputFormat', 'yyyy.MM.dd.HH.mm.ss');

    % Crear figura
    fig = figure('Position', [100, 100, 1400, 900], 'Name', 'Análisis Temporal IMS');

    % RMS vs Tiempo
    subplot(3,1,1);
    plot(dates, results.RMS_Z, 'LineWidth', 1.5, 'Color', [0.2 0.4 0.8]);
    ylabel('RMS Z (g)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Evolución de Vibración (RMS)', 'FontSize', 14);
    grid on;
    set(gca, 'FontSize', 10);

    % Curtosis vs Tiempo
    subplot(3,1,2);
    plot(dates, results.Kurt_Z, 'LineWidth', 1.5, 'Color', [0.8 0.2 0.2]);
    ylabel('Curtosis Z', 'FontSize', 12, 'FontWeight', 'bold');
    title('Evolución de Impulsividad (Curtosis)', 'FontSize', 14);
    grid on;
    set(gca, 'FontSize', 10);

    % Predicciones vs Tiempo
    subplot(3,1,3);
    fault_indicator = double(results.Prediccion ~= "normal");
    plot(dates, fault_indicator, '.', 'MarkerSize', 10, 'Color', [0.8 0.4 0.0]);
    ylim([-0.1, 1.1]);
    yticks([0, 1]);
    yticklabels({'Normal', 'Falla'});
    xlabel('Fecha', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Estado', 'FontSize', 12, 'FontWeight', 'bold');
    title('Estado del Rodamiento en el Tiempo', 'FontSize', 14);
    grid on;
    set(gca, 'FontSize', 10);

    % Guardar gráfica
    output_file = fullfile(project_root, 'results', 'analisis_temporal.png');
    saveas(fig, output_file);
    fprintf('✓ Gráfica guardada: %s\n\n', output_file);

catch ME
    warning('No se pudo generar gráfica temporal: %s', ME.message);
end

%% 4. ESTADÍSTICAS POR DATASET
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║         ESTADÍSTICAS POR DATASET                  ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

datasets = ["1st_test", "2nd_test", "3rd_test"];

fprintf('%-12s %10s %12s %12s %12s %12s\n', ...
    'Dataset', 'Archivos', 'Fallas', '% Fallas', 'RMS Medio', 'Kurt Medio');
fprintf('%s\n', repmat('-', 1, 80));

for i = 1:length(datasets)
    dataset = datasets(i);
    idx = contains(results.Archivo, dataset);
    subset = results(idx, :);

    if height(subset) > 0
        n_total = height(subset);
        n_fallas = sum(subset.Prediccion ~= "normal");
        pct_fallas = 100 * n_fallas / n_total;
        rms_medio = mean(subset.RMS_Z);
        kurt_medio = mean(subset.Kurt_Z);

        fprintf('%-12s %10d %12d %11.1f%% %12.6f %12.4f\n', ...
            char(dataset), n_total, n_fallas, pct_fallas, rms_medio, kurt_medio);
    end
end

fprintf('\n');

%% 5. DISTRIBUCIÓN DE CONFIANZA
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║      ANÁLISIS DE CONFIANZA DEL MODELO             ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

% Clasificar por nivel de confianza
alta_conf = sum(results.Confianza >= 90);
media_conf = sum(results.Confianza >= 75 & results.Confianza < 90);
baja_conf = sum(results.Confianza < 75);

fprintf('Distribución de confianza:\n');
fprintf('  🟢 Alta (≥90%%):    %5d archivos (%5.1f%%%%)\n', ...
    alta_conf, 100*alta_conf/height(results));
fprintf('  🟡 Media (75-90%%): %5d archivos (%5.1f%%%%)\n', ...
    media_conf, 100*media_conf/height(results));
fprintf('  🔴 Baja (<75%%):    %5d archivos (%5.1f%%%%)\n', ...
    baja_conf, 100*baja_conf/height(results));

fprintf('\n');
fprintf('Estadísticas de confianza:\n');
fprintf('  Media:    %.2f%%%%\n', mean(results.Confianza));
fprintf('  Mediana:  %.2f%%%%\n', median(results.Confianza));
fprintf('  Mínimo:   %.2f%%%%\n', min(results.Confianza));
fprintf('  Máximo:   %.2f%%%%\n', max(results.Confianza));

fprintf('\n');

%% 6. RESUMEN FINAL
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║              RESUMEN DEL ANÁLISIS                 ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

fprintf('✓ Análisis completado exitosamente\n');
fprintf('✓ Total de archivos: %d\n', height(results));
fprintf('✓ Archivos normales: %d (%.1f%%%%)\n', ...
    sum(results.Prediccion == "normal"), ...
    100*sum(results.Prediccion == "normal")/height(results));
fprintf('✓ Archivos con fallas: %d (%.1f%%%%)\n', ...
    height(fallas), 100*height(fallas)/height(results));
fprintf('✓ Confianza promedio: %.2f%%%%\n', mean(results.Confianza));

fprintf('\n');
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  Para más detalles, ver: results/analisis_temporal.png\n');
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('\n');
