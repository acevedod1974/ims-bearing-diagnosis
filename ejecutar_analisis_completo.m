%% ejecutar_analisis_completo.m
% ═══════════════════════════════════════════════════════════════════════
% AUTOMATIZACIÓN TOTAL DEL ANÁLISIS IMS - VERSIÓN FINAL ROBUSTA
% ═══════════════════════════════════════════════════════════════════════

clear; clc;

fprintf('🚀 INICIANDO PIPELINE DE ANÁLISIS COMPLETO\n\n');

%% 1. LOCALIZAR ARCHIVO DE RESULTADOS
current_dir = pwd;
script_dir = fileparts(mfilename('fullpath'));

% Lista de posibles ubicaciones
posibles_rutas = {
    fullfile(current_dir, 'results', 'resultados_diagnostico.mat'),
    fullfile(script_dir, '..', '..', 'results', 'resultados_diagnostico.mat'),
    fullfile(current_dir, 'resultados_diagnostico.mat'),
    'C:\Users\acevedod\Documents\MATLAB\Sistema Predictivo\ims-bearing-diagnosis\results\resultados_diagnostico.mat'
};

results_path = '';
for i = 1:length(posibles_rutas)
    if exist(posibles_rutas{i}, 'file')
        results_path = posibles_rutas{i};
        break;
    end
end

if isempty(results_path)
    fprintf('❌ No se encontró el archivo automáticamente.\n');
    [file, path] = uigetfile('*.mat', 'Seleccione resultados_diagnostico.mat');
    if isequal(file, 0), error('Cancelado por usuario'); end
    results_path = fullfile(path, file);
end

% Definir raíz del proyecto basada en la ubicación del .mat
project_root = fileparts(fileparts(results_path));
fprintf('📂 Archivo localizado en:\n   %s\n', results_path);
fprintf('📂 Raíz del proyecto detectada:\n   %s\n\n', project_root);

%% 2. PARCHE DE METADATOS (DATASETS)
fprintf('🛠️ Verificando etiquetas de datasets...\n');
data = load(results_path);
results = data.results;
new_names = results.Archivo; 
count_mods = 0;

for i = 1:height(results)
    fname = results.Archivo{i};
    if startsWith(fname, '2003.10') || startsWith(fname, '2003.11')
        if ~contains(fname, '1st_test'), new_names{i} = ['1st_test_' fname]; count_mods=count_mods+1; end
    elseif startsWith(fname, '2004.02')
        if ~contains(fname, '2nd_test'), new_names{i} = ['2nd_test_' fname]; count_mods=count_mods+1; end
    elseif startsWith(fname, '2004.04')
        if ~contains(fname, '3rd_test'), new_names{i} = ['3rd_test_' fname]; count_mods=count_mods+1; end
    end
end

if count_mods > 0
    results.Archivo = new_names;
    save(results_path, 'results');
    fprintf('   ✓ Se etiquetaron %d archivos.\n', count_mods);
else
    fprintf('   ✓ Etiquetas correctas.\n');
end
fprintf('\n');

%% 3. EJECUTAR ANÁLISIS DETALLADO
try
    % Recalculamos rutas por si el script anterior hizo 'clear'
    script_analisis = fullfile(project_root, 'src', 'analysis', 'analizar_resultados_detallado_v2.m');
    
    if exist(script_analisis, 'file')
        run(script_analisis);
    else
        % Si no encuentra el archivo por ruta absoluta, intenta por nombre
        analizar_resultados_detallado_v2; 
    end
catch ME
    warning('⚠️ Error en análisis: %s', ME.message);
end

%% 4. GENERAR REPORTE FINAL
try
    % Recalculamos rutas OTRA VEZ (seguridad contra 'clear')
    % Nota: project_root puede haberse borrado, lo re-detectamos
    if ~exist('project_root', 'var')
        project_root = fileparts(fileparts(results_path)); 
    end
    
    script_reporte = fullfile(project_root, 'src', 'analysis', 'generar_reporte_diagnostico_v2.m');
    
    if exist(script_reporte, 'file')
        run(script_reporte);
    else
        generar_reporte_diagnostico_v2;
    end
catch ME
    warning('⚠️ Error en reporte: %s', ME.message);
end

%% FINALIZACIÓN
fprintf('\n═══════════════════════════════════════════════════════════\n');
fprintf('🎉 PROCESO COMPLETADO EXITOSAMENTE\n');
fprintf('═══════════════════════════════════════════════════════════\n');
