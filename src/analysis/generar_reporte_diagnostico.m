% generar_reporte_diagnostico.m
% Genera un reporte de diagnóstico en formato texto
%
% Crea archivo: results/REPORTE_DIAGNOSTICO.txt
%
% Uso:
%   run('src/analysis/generar_reporte_diagnostico.m')

clear; clc;

%% Configurar rutas
script_path = fileparts(mfilename('fullpath'));
project_root = fileparts(fileparts(script_path));  % Subir 2 niveles
results_path = fullfile(project_root, 'results', 'resultados_diagnostico.mat');
output_path = fullfile(project_root, 'results', 'REPORTE_DIAGNOSTICO.txt');

fprintf('\n');
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║       GENERADOR DE REPORTE DE DIAGNÓSTICO         ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

%% Cargar resultados
fprintf('📂 Cargando resultados desde:\n   %s\n\n', results_path);

if ~exist(results_path, 'file')
    error('❌ Archivo no encontrado: %s', results_path);
end

load(results_path);

fprintf('✓ Resultados cargados: %d archivos\n\n', height(results));

%% Abrir archivo de reporte
fprintf('📝 Generando reporte en:\n   %s\n\n', output_path);

fid = fopen(output_path, 'w', 'n', 'UTF-8');

if fid == -1
    error('No se pudo crear el archivo de reporte');
end

%% Escribir reporte
fprintf(fid, '════════════════════════════════════════════════════════════\n');
fprintf(fid, '  REPORTE DE DIAGNÓSTICO - DATASET IMS BEARING               \n');
fprintf(fid, '  Fecha: %s                                    \n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '════════════════════════════════════════════════════════════\n');
fprintf(fid, '\n\n');

%% 1. RESUMEN EJECUTIVO
fprintf(fid, '1. RESUMEN EJECUTIVO\n');
fprintf(fid, '   ═════════════════\n\n');

total_archivos = height(results);
archivos_normales = sum(results.Prediccion == "normal");
archivos_fallas = sum(results.Prediccion ~= "normal");

fprintf(fid, '   Total de archivos analizados: %d\n\n', total_archivos);
fprintf(fid, '   Distribución de diagnósticos:\n');
fprintf(fid, '   • Archivos normales:    %5d (%5.1f%%%%)\n', ...
    archivos_normales, 100*archivos_normales/total_archivos);
fprintf(fid, '   • Archivos con fallas:  %5d (%5.1f%%%%)\n\n', ...
    archivos_fallas, 100*archivos_fallas/total_archivos);

%% 2. DISTRIBUCIÓN POR TIPO DE FALLA
fprintf(fid, '\n2. DISTRIBUCIÓN POR TIPO DE FALLA\n');
fprintf(fid, '   ═══════════════════════════════\n\n');

unique_faults = unique(results.Prediccion);
for i = 1:length(unique_faults)
    fault_type = unique_faults(i);
    count = sum(results.Prediccion == fault_type);
    pct = 100 * count / total_archivos;

    fprintf(fid, '   • %-25s: %5d (%5.1f%%%%)\n', ...
        char(fault_type), count, pct);
end

fprintf(fid, '\n');

%% 3. CONFIANZA DEL MODELO
fprintf(fid, '\n3. CONFIANZA DEL MODELO\n');
fprintf(fid, '   ════════════════════\n\n');

fprintf(fid, '   Estadísticas generales:\n');
fprintf(fid, '   • Media:              %.2f%%%%\n', mean(results.Confianza));
fprintf(fid, '   • Mediana:            %.2f%%%%\n', median(results.Confianza));
fprintf(fid, '   • Desviación estándar: %.2f%%%%\n', std(results.Confianza));
fprintf(fid, '   • Mínimo:             %.2f%%%%\n', min(results.Confianza));
fprintf(fid, '   • Máximo:             %.2f%%%%\n\n', max(results.Confianza));

% Distribución por niveles
alta_conf = sum(results.Confianza >= 90);
media_conf = sum(results.Confianza >= 75 & results.Confianza < 90);
baja_conf = sum(results.Confianza < 75);

fprintf(fid, '   Distribución por nivel de confianza:\n');
fprintf(fid, '   • Alta (≥90%%):       %5d archivos (%5.1f%%%%)\n', ...
    alta_conf, 100*alta_conf/total_archivos);
fprintf(fid, '   • Media (75-90%%):    %5d archivos (%5.1f%%%%)\n', ...
    media_conf, 100*media_conf/total_archivos);
fprintf(fid, '   • Baja (<75%%):       %5d archivos (%5.1f%%%%)\n\n', ...
    baja_conf, 100*baja_conf/total_archivos);

%% 4. ESTADÍSTICAS DE CARACTERÍSTICAS
fprintf(fid, '\n4. ESTADÍSTICAS DE CARACTERÍSTICAS\n');
fprintf(fid, '   ═══════════════════════════════\n\n');

fprintf(fid, '   RMS (Root Mean Square):\n');
fprintf(fid, '   • Eje X - Media: %.6f, Desv: %.6f\n', ...
    mean(results.RMS_X), std(results.RMS_X));
fprintf(fid, '   • Eje Y - Media: %.6f, Desv: %.6f\n', ...
    mean(results.RMS_Y), std(results.RMS_Y));
fprintf(fid, '   • Eje Z - Media: %.6f, Desv: %.6f\n\n', ...
    mean(results.RMS_Z), std(results.RMS_Z));

fprintf(fid, '   Curtosis (Kurtosis):\n');
fprintf(fid, '   • Eje X - Media: %.4f, Desv: %.4f\n', ...
    mean(results.Kurt_X), std(results.Kurt_X));
fprintf(fid, '   • Eje Y - Media: %.4f, Desv: %.4f\n', ...
    mean(results.Kurt_Y), std(results.Kurt_Y));
fprintf(fid, '   • Eje Z - Media: %.4f, Desv: %.4f\n\n', ...
    mean(results.Kurt_Z), std(results.Kurt_Z));

%% 5. ANÁLISIS POR DATASET
fprintf(fid, '\n5. ANÁLISIS POR DATASET (1st, 2nd, 3rd TEST)\n');
fprintf(fid, '   ══════════════════════════════════════════\n\n');

datasets = ["1st_test", "2nd_test", "3rd_test"];

for i = 1:length(datasets)
    dataset = datasets(i);
    idx = contains(results.Archivo, dataset);
    subset = results(idx, :);

    if height(subset) > 0
        fprintf(fid, '   %s:\n', char(dataset));
        fprintf(fid, '   ───────────────\n');
        fprintf(fid, '   • Total archivos:  %d\n', height(subset));
        fprintf(fid, '   • Archivos normales: %d (%.1f%%%%)\n', ...
            sum(subset.Prediccion == "normal"), ...
            100*sum(subset.Prediccion == "normal")/height(subset));
        fprintf(fid, '   • Archivos con fallas: %d (%.1f%%%%)\n', ...
            sum(subset.Prediccion ~= "normal"), ...
            100*sum(subset.Prediccion ~= "normal")/height(subset));
        fprintf(fid, '   • RMS Z promedio: %.6f\n', mean(subset.RMS_Z));
        fprintf(fid, '   • Curtosis Z promedio: %.4f\n', mean(subset.Kurt_Z));
        fprintf(fid, '   • Confianza promedio: %.2f%%%%\n\n', mean(subset.Confianza));
    end
end

%% 6. FALLAS MÁS CRÍTICAS
fprintf(fid, '\n6. TOP 10 FALLAS MÁS CRÍTICAS (MAYOR CURTOSIS)\n');
fprintf(fid, '   ═══════════════════════════════════════════\n\n');

fallas = results(results.Prediccion ~= "normal", :);

if height(fallas) > 0
    [~, idx] = sort(fallas.Kurt_Z, 'descend');
    n_top = min(10, height(fallas));
    top_fallas = fallas(idx(1:n_top), :);

    fprintf(fid, '   %-30s %-20s %10s %10s\n', ...
        'Archivo', 'Tipo Falla', 'Confianza', 'Kurt_Z');
    fprintf(fid, '   %s\n', repmat('-', 1, 75));

    for j = 1:n_top
        fprintf(fid, '   %-30s %-20s %9.1f%%%% %10.4f\n', ...
            top_fallas.Archivo{j}(1:min(29, length(top_fallas.Archivo{j}))), ...
            char(top_fallas.Prediccion(j)), ...
            top_fallas.Confianza(j), ...
            top_fallas.Kurt_Z(j));
    end
else
    fprintf(fid, '   No se detectaron fallas en el dataset.\n');
end

fprintf(fid, '\n\n');

%% 7. CONCLUSIONES Y RECOMENDACIONES
fprintf(fid, '\n7. CONCLUSIONES Y RECOMENDACIONES\n');
fprintf(fid, '   ═══════════════════════════════\n\n');

fprintf(fid, '   • El modelo procesó exitosamente %d archivos\n', total_archivos);
fprintf(fid, '   • La confianza promedio del modelo es %.2f%%%%\n', mean(results.Confianza));

if archivos_fallas > 0
    pct_fallas = 100 * archivos_fallas / total_archivos;
    fprintf(fid, '   • Se detectaron %.1f%%%% archivos con fallas\n', pct_fallas);

    if pct_fallas > 10
        fprintf(fid, '   • ⚠️  ATENCIÓN: Porcentaje alto de fallas detectadas\n');
        fprintf(fid, '   • Se recomienda inspección manual de los rodamientos\n');
    else
        fprintf(fid, '   • ℹ️  Nivel de fallas dentro de rangos esperados\n');
    end
else
    fprintf(fid, '   • ✓ No se detectaron fallas en el dataset\n');
end

fprintf(fid, '\n');

% Análisis de confianza
if baja_conf > total_archivos * 0.05
    fprintf(fid, '   • ⚠️  ADVERTENCIA: %.1f%%%% de predicciones con baja confianza (<75%%%%)\n', ...
        100*baja_conf/total_archivos);
    fprintf(fid, '   • Se recomienda revisar manualmente estos casos\n');
else
    fprintf(fid, '   • ✓ La mayoría de predicciones tienen alta confianza\n');
end

fprintf(fid, '\n\n');

%% PIE DE PÁGINA
fprintf(fid, '════════════════════════════════════════════════════════════\n');
fprintf(fid, '  Reporte generado automáticamente por:                     \n');
fprintf(fid, '  Sistema de Diagnóstico de Rodamientos IMS v1.2.0           \n');
fprintf(fid, '════════════════════════════════════════════════════════════\n');

%% Cerrar archivo
fclose(fid);

fprintf('✓ Reporte generado exitosamente\n');
fprintf('✓ Ubicación: %s\n\n', output_path);

fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  Para visualizar el reporte, ejecuta:\n');
fprintf('  edit(''%s'')\n', output_path);
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('\n');
