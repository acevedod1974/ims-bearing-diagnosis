% config_example.m
% Archivo de configuración de ejemplo para el sistema IMS
% 
% INSTRUCCIONES:
%   1. Edita las rutas según tu sistema
%   2. Ejecuta este script para generar config.mat
%   3. El script principal usará config.mat automáticamente
%
% Autor: Daniel Acevedo Lopez
% Fecha: Enero 2026

clear; clc;

fprintf('=== Generando archivo de configuración ===\n\n');

% =========================================================================
% RUTAS A CARPETAS DE DATOS
% =========================================================================
% Ajusta estas rutas según donde hayas descargado el dataset IMS
config.data_folders = {
    fullfile('data', '1st_test');
    fullfile('data', '2nd_test');
    fullfile('data', '3rd_test')
};

% Si tus datos están en otra ubicación, usa rutas absolutas:
% config.data_folders = {
%     'C:\Users\tuusuario\Documents\MATLAB\Datasets\IMS\1st_test';
%     'C:\Users\tuusuario\Documents\MATLAB\Datasets\IMS\2nd_test';
%     'C:\Users\tuusuario\Documents\MATLAB\Datasets\IMS\3rd_test'
% };

% =========================================================================
% RUTA AL MODELO ENTRENADO
% =========================================================================
% El modelo Random Forest pre-entrenado
config.model_file = fullfile('models', 'ims_modelo_especifico.mat');

% =========================================================================
% DIRECTORIO DE SALIDA
% =========================================================================
% Donde se guardarán los resultados (CSV, gráficos, etc.)
config.output_dir = 'results';

% =========================================================================
% PARÁMETROS OPCIONALES
% =========================================================================
% Activar/desactivar funcionalidades adicionales

% Mostrar progreso detallado en consola
config.verbose = true;

% Guardar figuras automáticamente
config.save_figures = true;

% Formato de las figuras: 'png', 'jpg', 'fig', 'pdf'
config.figure_format = 'png';

% Resolución de las figuras (DPI)
config.figure_dpi = 300;

% =========================================================================
% GUARDAR CONFIGURACIÓN
% =========================================================================
save('config.mat', '-struct', 'config');

fprintf('✓ Configuración guardada en config.mat\n');
fprintf('\nCarpetas configuradas:\n');
for i = 1:length(config.data_folders)
    if isfolder(config.data_folders{i})
        fprintf('  ✓ %s\n', config.data_folders{i});
    else
        fprintf('  ✗ %s (NO ENCONTRADA)\n', config.data_folders{i});
    end
end

fprintf('\nModelo configurado:\n');
if isfile(config.model_file)
    fprintf('  ✓ %s\n', config.model_file);
else
    fprintf('  ✗ %s (NO ENCONTRADO)\n', config.model_file);
end

fprintf('\nDirectorio de salida: %s\n', config.output_dir);
if ~isfolder(config.output_dir)
    mkdir(config.output_dir);
    fprintf('  ✓ Directorio creado\n');
else
    fprintf('  ✓ Directorio ya existe\n');
end

fprintf('\n=== Configuración completa ===\n');
fprintf('Ahora puedes ejecutar: IMS_bearing_diagnosis_main()\n\n');
