%% check_installation.m
% Script de verificación de instalación del sistema IMS
% Valida que todos los componentes necesarios estén presentes
%
% Autor: Daniel Acevedo Lopez
% Fecha: Enero 2026

clear; clc;

fprintf('\n╔═══════════════════════════════════════════════════╗\n');
fprintf('║  VERIFICACIÓN DE INSTALACIÓN - SISTEMA IMS       ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n\n');

total_checks = 0;
passed_checks = 0;
warnings_count = 0;

%% =========================================================================
%% VERIFICACIÓN 1: Versión de MATLAB
%% =========================================================================
fprintf('1️⃣  Verificando versión de MATLAB...\n');
total_checks = total_checks + 1;

matlab_ver = version('-release');
matlab_year = str2double(matlab_ver(1:4));

fprintf('   Versión instalada: MATLAB %s\n', matlab_ver);

if matlab_year >= 2020
    fprintf('   ✓ Compatible (R2020a o superior)\n\n');
    passed_checks = passed_checks + 1;
else
    fprintf('   ✗ INCOMPATIBLE: Se requiere R2020a o superior\n');
    fprintf('   Por favor actualice MATLAB\n\n');
end

%% =========================================================================
%% VERIFICACIÓN 2: Toolboxes Requeridos
%% =========================================================================
fprintf('2️⃣  Verificando toolboxes requeridos...\n');

% Statistics and Machine Learning Toolbox
total_checks = total_checks + 1;
if license('test', 'Statistics_Toolbox')
    fprintf('   ✓ Statistics and Machine Learning Toolbox\n');
    passed_checks = passed_checks + 1;
else
    fprintf('   ✗ Statistics and Machine Learning Toolbox NO DISPONIBLE\n');
    fprintf('   Este toolbox es REQUERIDO para Random Forest\n');
end

fprintf('\n');

%% =========================================================================
%% VERIFICACIÓN 3: Estructura de Carpetas
%% =========================================================================
fprintf('3️⃣  Verificando estructura de carpetas...\n');

required_folders = {
    'data';
    'models';
    'results';
    'src';
    'docs';
    'examples'
};

for i = 1:length(required_folders)
    total_checks = total_checks + 1;
    if isfolder(required_folders{i})
        fprintf('   ✓ %s/\n', required_folders{i});
        passed_checks = passed_checks + 1;
    else
        fprintf('   ⚠ %s/ (NO ENCONTRADA - creando...)\n', required_folders{i});
        mkdir(required_folders{i});
        warnings_count = warnings_count + 1;
    end
end

fprintf('\n');

%% =========================================================================
%% VERIFICACIÓN 4: Archivos de Código
%% =========================================================================
fprintf('4️⃣  Verificando archivos de código...\n');

required_files = {
    fullfile('src', 'IMS_bearing_diagnosis_main.m');
    fullfile('src', 'extract_rms_kurtosis.m');
    fullfile('src', 'utils', 'config_example.m')
};

for i = 1:length(required_files)
    total_checks = total_checks + 1;
    if isfile(required_files{i})
        fprintf('   ✓ %s\n', required_files{i});
        passed_checks = passed_checks + 1;
    else
        fprintf('   ✗ %s (NO ENCONTRADO)\n', required_files{i});
    end
end

fprintf('\n');

%% =========================================================================
%% VERIFICACIÓN 5: Modelo Pre-entrenado
%% =========================================================================
fprintf('5️⃣  Verificando modelo pre-entrenado...\n');
total_checks = total_checks + 1;

model_file = fullfile('models', 'ims_modelo_especifico.mat');

if isfile(model_file)
    fprintf('   ✓ %s\n', model_file);

    % Verificar contenido del modelo
    try
        model_data = load(model_file);
        if isfield(model_data, 'rf_ims')
            fprintf('   ✓ Modelo Random Forest encontrado en archivo\n');
            fprintf('   ✓ Clases: ');
            disp(model_data.rf_ims.ClassNames');
            passed_checks = passed_checks + 1;
        else
            fprintf('   ⚠ Advertencia: Variable "rf_ims" no encontrada en modelo\n');
            warnings_count = warnings_count + 1;
        end
    catch ME
        fprintf('   ✗ Error al cargar modelo: %s\n', ME.message);
    end
else
    fprintf('   ✗ %s (NO ENCONTRADO)\n', model_file);
    fprintf('   ACCIÓN REQUERIDA: Coloca el modelo en la carpeta models/\n');
end

fprintf('\n');

%% =========================================================================
%% VERIFICACIÓN 6: Datos IMS
%% =========================================================================
fprintf('6️⃣  Verificando datos del dataset IMS...\n');

data_folders = {
    fullfile('data', '1st_test');
    fullfile('data', '2nd_test');
    fullfile('data', '3rd_test')
};

data_found = false;

for i = 1:length(data_folders)
    total_checks = total_checks + 1;
    if isfolder(data_folders{i})
        files = dir(fullfile(data_folders{i}, '*'));
        files = files(~[files.isdir] & ~startsWith({files.name}, '.'));
        n_files = length(files);

        if n_files > 0
            fprintf('   ✓ %s (%d archivos)\n', data_folders{i}, n_files);
            passed_checks = passed_checks + 1;
            data_found = true;
        else
            fprintf('   ⚠ %s (carpeta vacía)\n', data_folders{i});
            warnings_count = warnings_count + 1;
        end
    else
        fprintf('   ✗ %s (NO ENCONTRADA)\n', data_folders{i});
    end
end

if ~data_found
    fprintf('\n   ⚠ ADVERTENCIA: No se encontraron datos del IMS Dataset\n');
    fprintf('   ACCIÓN REQUERIDA:\n');
    fprintf('     1. Descarga el dataset de: https://www.nasa.gov/...\n');
    fprintf('     2. Extrae los archivos en las carpetas correspondientes\n');
    warnings_count = warnings_count + 1;
end

fprintf('\n');

%% =========================================================================
%% VERIFICACIÓN 7: Archivo de Configuración
%% =========================================================================
fprintf('7️⃣  Verificando archivo de configuración...\n');
total_checks = total_checks + 1;

if isfile('config.mat')
    fprintf('   ✓ config.mat encontrado\n');
    passed_checks = passed_checks + 1;
else
    fprintf('   ⚠ config.mat NO encontrado\n');
    fprintf('   RECOMENDACIÓN: Ejecuta config_example.m para crearlo\n');
    warnings_count = warnings_count + 1;
end

fprintf('\n');

%% =========================================================================
%% VERIFICACIÓN 8: Funciones Básicas
%% =========================================================================
fprintf('8️⃣  Verificando funciones de MATLAB...\n');

% Test de funciones críticas
functions_to_test = {'readmatrix', 'predict', 'kurtosis', 'rms'};
all_functions_ok = true;

for i = 1:length(functions_to_test)
    total_checks = total_checks + 1;
    func_name = functions_to_test{i};

    if exist(func_name, 'builtin') || exist(func_name, 'file')
        fprintf('   ✓ %s()\n', func_name);
        passed_checks = passed_checks + 1;
    else
        fprintf('   ✗ %s() NO DISPONIBLE\n', func_name);
        all_functions_ok = false;
    end
end

fprintf('\n');

%% =========================================================================
%% RESUMEN FINAL
%% =========================================================================
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║              RESUMEN DE VERIFICACIÓN             ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n\n');

fprintf('Total de verificaciones: %d\n', total_checks);
fprintf('Pasadas:                 %d ✓\n', passed_checks);
fprintf('Fallidas:                %d ✗\n', total_checks - passed_checks);
fprintf('Advertencias:            %d ⚠\n\n', warnings_count);

% Calcular porcentaje
success_rate = 100 * passed_checks / total_checks;

if success_rate == 100
    fprintf('🎉 ESTADO: SISTEMA COMPLETAMENTE INSTALADO\n');
    fprintf('   Puedes ejecutar IMS_bearing_diagnosis_main()\n\n');
elseif success_rate >= 80
    fprintf('✅ ESTADO: INSTALACIÓN FUNCIONAL\n');
    fprintf('   El sistema debería funcionar, pero revisa las advertencias\n\n');
elseif success_rate >= 60
    fprintf('⚠️  ESTADO: INSTALACIÓN INCOMPLETA\n');
    fprintf('   Revisa los elementos faltantes antes de continuar\n\n');
else
    fprintf('❌ ESTADO: INSTALACIÓN DEFICIENTE\n');
    fprintf('   Múltiples componentes faltantes. Consulta documentación.\n\n');
end

fprintf('═══════════════════════════════════════════════════\n\n');
