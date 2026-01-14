% config_example.m
% Archivo de configuración de ejemplo para el sistema IMS
%
% INSTRUCCIONES:
% 1. Ejecuta este script desde CUALQUIER ubicación del proyecto
% 2. Se generará config.mat automáticamente en la raíz
% 3. El script principal usará config.mat automáticamente
%
% Autor: Daniel Acevedo Lopez
% Fecha: Enero 2026

clear; clc;
fprintf('=== Generando archivo de configuración ===\n\n');

% =========================================================================
% DETECTAR RAÍZ DEL PROYECTO AUTOMÁTICAMENTE
% =========================================================================
current_dir = pwd;
project_root = current_dir;

% Buscar la raíz (donde está la carpeta 'src')
while ~isfolder(fullfile(project_root, 'src'))
    parent = fileparts(project_root);
    if strcmp(parent, project_root)
        % Llegamos al directorio raíz del sistema sin encontrar 'src'
        error(['No se pudo encontrar la raíz del proyecto.\n', ...
               'Asegúrate de ejecutar este script desde dentro del proyecto ims-bearing-diagnosis']);
    end
    project_root = parent;
end

fprintf('✓ Raíz del proyecto detectada: %s\n\n', project_root);

% =========================================================================
% RUTAS A CARPETAS DE DATOS (RELATIVAS A LA RAÍZ)
% =========================================================================
config.data_folders = {
    fullfile(project_root, 'data', '1st_test');
    fullfile(project_root, 'data', '2nd_test');
    fullfile(project_root, 'data', '3rd_test')
};

% Si tus datos están en otra ubicación, usa rutas absolutas:
% config.data_folders = {
%     'C:\NASA_IMS_Dataset\1st_test';
%     'C:\NASA_IMS_Dataset\2nd_test';
%     'C:\NASA_IMS_Dataset\3rd_test'
% };

% =========================================================================
% RUTA AL MODELO ENTRENADO
% =========================================================================
config.model_file = fullfile(project_root, 'models', 'ims_modelo_especifico.mat');

% =========================================================================
% DIRECTORIO DE SALIDA
% =========================================================================
config.output_dir = fullfile(project_root, 'results');

% =========================================================================
% PARÁMETROS OPCIONALES
% =========================================================================
config.verbose = true;
config.save_figures = true;
config.figure_format = 'png';
config.figure_dpi = 300;

% =========================================================================
% GUARDAR CONFIGURACIÓN EN LA RAÍZ
% =========================================================================
config_file = fullfile(project_root, 'config.mat');
save(config_file, '-struct', 'config');
fprintf('✓ Configuración guardada en: %s\n\n', config_file);

% =========================================================================
% VERIFICAR COMPONENTES
% =========================================================================
fprintf('Verificando componentes...\n');
fprintf('\nCarpetas de datos configuradas:\n');

all_data_found = true;
for i = 1:length(config.data_folders)
    if isfolder(config.data_folders{i})
        files = dir(fullfile(config.data_folders{i}, '*'));
        files = files(~[files.isdir] & ~startsWith({files.name}, '.'));
        fprintf('  ✓ %s (%d archivos)\n', config.data_folders{i}, length(files));
    else
        fprintf('  ✗ %s (NO ENCONTRADA)\n', config.data_folders{i});
        all_data_found = false;
    end
end

fprintf('\nModelo configurado:\n');
if isfile(config.model_file)
    fprintf('  ✓ %s\n', config.model_file);
else
    fprintf('  ✗ %s (NO ENCONTRADO)\n', config.model_file);
    fprintf('\n  ⚠ ACCIÓN REQUERIDA:\n');
    fprintf('     Coloca el modelo en: %s\n', fullfile(project_root, 'models'));
end

fprintf('\nDirectorio de salida: %s\n', config.output_dir);
if ~isfolder(config.output_dir)
    mkdir(config.output_dir);
    fprintf('  ✓ Directorio creado\n');
else
    fprintf('  ✓ Directorio ya existe\n');
end

% =========================================================================
% INSTRUCCIONES FINALES
% =========================================================================
fprintf('\n=== Configuración completa ===\n');

if ~all_data_found
    fprintf('\n⚠️  DATOS NO ENCONTRADOS\n');
    fprintf('Para descargar el dataset IMS:\n');
    fprintf('  1. Visita: https://www.nasa.gov/content/prognostics-center-of-excellence-data-set-repository\n');
    fprintf('  2. Descarga: IMS Bearing Dataset\n');
    fprintf('  3. Extrae en: %s\n', fullfile(project_root, 'data'));
    fprintf('\nO edita config.data_folders con la ubicación de tus datos.\n\n');
else
    fprintf('\n✅ Todo listo. Ahora puedes ejecutar:\n');
    fprintf('   cd(''%s'')\n', project_root);
    fprintf('   IMS_bearing_diagnosis_main()\n\n');
end