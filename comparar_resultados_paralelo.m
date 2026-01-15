%% comparar_resultados_paralelo.m
% ═══════════════════════════════════════════════════════════════════════
% VALIDACIÓN CRUZADA: SECUENCIAL vs PARALELO
% ═══════════════════════════════════════════════════════════════════════

clear; clc;

% 1. Configurar rutas
script_dir = fileparts(mfilename('fullpath'));
if contains(script_dir, 'src')
    project_root = fileparts(fileparts(script_dir));
else
    project_root = script_dir;
end

path_original = fullfile(project_root, 'results', 'resultados_diagnostico.mat');
path_paralelo = fullfile(project_root, 'results', 'resultados_diagnostico_paralelo.mat');

fprintf('╔═══════════════════════════════════════════════════════════╗\n');
fprintf('║  VALIDACIÓN DE RESULTADOS: SECUENCIAL vs PARALELO       ║\n');
fprintf('╚═══════════════════════════════════════════════════════════╝\n\n');

% 2. Cargar archivos
if ~exist(path_original, 'file') || ~exist(path_paralelo, 'file')
    error('❌ Faltan archivos. Asegúrate de tener ambos .mat en la carpeta results/');
end

fprintf('📂 Cargando resultados...\n');
data_seq = load(path_original);
results_seq = data_seq.results;

data_par = load(path_paralelo);
results_par = data_par.results;

fprintf('   Original (Secuencial): %d archivos\n', height(results_seq));
fprintf('   Nuevo (Paralelo):      %d archivos\n\n', height(results_par));

% 3. Sincronizar tablas (ordenar por nombre de archivo)
% El parfor no garantiza orden, así que ordenamos ambos para comparar fila por fila
results_seq = sortrows(results_seq, 'Archivo');
results_par = sortrows(results_par, 'Archivo');

% Verificar si coinciden los nombres de archivo
files_seq = results_seq.Archivo;
files_par = results_par.Archivo;

if ~isequal(files_seq, files_par)
    % Si no son idénticos, buscar intersección
    [common_files, idx_seq, idx_par] = intersect(files_seq, files_par);
    results_seq = results_seq(idx_seq, :);
    results_par = results_par(idx_par, :);
    warning('⚠️ Los datasets tienen archivos distintos. Se compararán solo los %d archivos comunes.', length(common_files));
else
    fprintf('✅ Ambos sets contienen exactamente los mismos archivos.\n');
end

% 4. Comparación de Predicciones
matches = strcmp(string(results_seq.Prediccion), string(results_par.Prediccion));
accuracy_match = sum(matches) / height(results_seq) * 100;

fprintf('\n📊 Comparación de Diagnósticos (Normal/Falla):\n');
if accuracy_match == 100
    fprintf('   ✅ COINCIDENCIA PERFECTA (100%%)\n');
    fprintf('      El método paralelo diagnosticó exactamente lo mismo que el secuencial.\n');
else
    fprintf('   ⚠️  Diferencias encontradas: %.2f%% coincidencia\n', accuracy_match);
    fprintf('      %d archivos tienen diagnósticos diferentes.\n', sum(~matches));
end

% 5. Comparación Numérica (RMS y Curtosis)
% Calculamos la diferencia absoluta promedio
diff_rms_x = mean(abs(results_seq.RMS_X - results_par.RMS_X));
diff_kurt_x = mean(abs(results_seq.Kurt_X - results_par.Kurt_X));

fprintf('\n🔢 Comparación Numérica (Precisión de Cálculo):\n');
fprintf('   Diferencia promedio RMS (Eje X):      %.10f\n', diff_rms_x);
fprintf('   Diferencia promedio Curtosis (Eje X): %.10f\n', diff_kurt_x);

if diff_rms_x < 1e-6 && diff_kurt_x < 1e-6
    fprintf('\n✅ VALIDACIÓN EXITOSA: Los cálculos numéricos son idénticos.\n');
    fprintf('   El procesamiento paralelo es seguro para usar en producción.\n');
else
    fprintf('\n⚠️ Hay pequeñas variaciones numéricas (posiblemente por redondeo o lectura).\n');
end

fprintf('\n═══════════════════════════════════════════════════════════\n');
