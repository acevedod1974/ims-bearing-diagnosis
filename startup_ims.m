%% startup_ims.m
% Script de inicio para el Sistema de Diagnóstico IMS
% Configura automáticamente el path de MATLAB
%
% INSTRUCCIONES:
%   1. Ejecuta este script UNA VEZ al abrir MATLAB
%   2. O agrégalo al path permanente
%
% Autor: Daniel Acevedo Lopez
% Fecha: Enero 2026

clear; clc;

fprintf('\n╔═══════════════════════════════════════════════════╗\n');
fprintf('║   Sistema de Diagnóstico de Rodamientos IMS      ║\n');
fprintf('║            Configurando entorno...               ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n\n');

% Detectar raíz del proyecto
current_dir = pwd;
project_root = current_dir;

% Buscar la raíz (donde está la carpeta 'src')
while ~isfolder(fullfile(project_root, 'src'))
    parent = fileparts(project_root);
    if strcmp(parent, project_root)
        error(['No se pudo encontrar la raíz del proyecto.\n', ...
               'Ejecuta este script desde dentro de ims-bearing-diagnosis/']);
    end
    project_root = parent;
end

% Cambiar al directorio raíz si no estamos ahí
if ~strcmp(pwd, project_root)
    cd(project_root);
    fprintf('✓ Navegado a raíz: %s\n', project_root);
end

% Agregar carpetas necesarias al path
folders_to_add = {
    'src';
    fullfile('src', 'utils');
    fullfile(project_root, 'src', 'training');
    'examples'
};

fprintf('\nAgregando al path de MATLAB:\n');
for i = 1:length(folders_to_add)
    folder_path = fullfile(project_root, folders_to_add{i});
    if isfolder(folder_path)
        addpath(folder_path);
        fprintf('  ✓ %s\n', folders_to_add{i});
    else
        fprintf('  ⚠ %s (no encontrada)\n', folders_to_add{i});
    end
end

% Verificar que todo esté configurado
fprintf('\n');
if exist('IMS_bearing_diagnosis_main', 'file')
    fprintf('✅ Sistema listo para usar\n\n');
    fprintf('Comandos disponibles:\n');
    fprintf('  • IMS_bearing_diagnosis_main()      - Ejecutar sistema completo\n');
    fprintf('  • run(''examples/demo_01_single_file.m'')  - Ejecutar demo\n');
    fprintf('  • run(''check_installation.m'')            - Verificar instalación\n');
    fprintf('  • run(''src/utils/config_example.m'')      - Regenerar configuración\n');
else
    fprintf('⚠️  Advertencia: Funciones principales no encontradas\n');
    fprintf('   Verifica la estructura del proyecto\n');
end

fprintf('\n╔═══════════════════════════════════════════════════╗\n');
fprintf('║              Entorno Configurado ✓               ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n\n');
addpath(fullfile(project_root, 'src', 'training'));
