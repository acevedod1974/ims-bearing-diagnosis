% INSTALL_FIXES.m
% Script de instalación automática de correcciones
%
% Este script:
%   1. Descarga los archivos FIXED desde Recursos
%   2. Los copia a sus ubicaciones correctas
%   3. Recarga el entorno
%
% INSTRUCCIONES:
%   1. Descarga estos archivos desde Recursos:
%      - startup_ims_FIXED.m
%      - analizar_resultados_detallado_FIXED.m
%      - generar_reporte_diagnostico_FIXED.m
%
%   2. Coloca INSTALL_FIXES.m y los archivos FIXED en la carpeta raíz:
%      C:\Users\acevedod\Documents\MATLAB\Sistema Predictivo\ims-bearing-diagnosis
%
%   3. Ejecuta en MATLAB:
%      >> cd('C:\Users\acevedod\Documents\MATLAB\Sistema Predictivo\ims-bearing-diagnosis')
%      >> INSTALL_FIXES

clear; clc;

fprintf('\n');
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║     INSTALACIÓN DE CORRECCIONES - IMS v1.2.1      ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

%% Verificar ubicación
current_dir = pwd;
fprintf('📂 Directorio actual: %s\n\n', current_dir);

%% Verificar archivos FIXED
files_to_install = {
    'startup_ims_FIXED.m', ...
    'analizar_resultados_detallado_FIXED.m', ...
    'generar_reporte_diagnostico_FIXED.m'
};

fprintf('🔍 Verificando archivos FIXED...\n');
all_found = true;

for i = 1:length(files_to_install)
    if exist(files_to_install{i}, 'file')
        fprintf('  ✓ %s\n', files_to_install{i});
    else
        fprintf('  ✗ %s (NO ENCONTRADO)\n', files_to_install{i});
        all_found = false;
    end
end

fprintf('\n');

if ~all_found
    error(['❌ Faltan archivos. Por favor descarga todos los archivos FIXED desde Recursos\n' ...
           'y colócalos en: %s'], current_dir);
end

%% Hacer backup de archivos originales
fprintf('💾 Creando backup de archivos originales...\n');

backup_dir = fullfile(current_dir, 'backup_old_files');
if ~exist(backup_dir, 'dir')
    mkdir(backup_dir);
end

% Backup startup_ims.m
if exist('startup_ims.m', 'file')
    copyfile('startup_ims.m', fullfile(backup_dir, 'startup_ims_OLD.m'));
    fprintf('  ✓ startup_ims.m → backup_old_files/startup_ims_OLD.m\n');
end

% Backup analizar_resultados_detallado.m
old_analizar = fullfile('src', 'analysis', 'analizar_resultados_detallado.m');
if exist(old_analizar, 'file')
    copyfile(old_analizar, fullfile(backup_dir, 'analizar_resultados_detallado_OLD.m'));
    fprintf('  ✓ analizar_resultados_detallado.m → backup\n');
end

% Backup generar_reporte_diagnostico.m
old_reporte = fullfile('src', 'analysis', 'generar_reporte_diagnostico.m');
if exist(old_reporte, 'file')
    copyfile(old_reporte, fullfile(backup_dir, 'generar_reporte_diagnostico_OLD.m'));
    fprintf('  ✓ generar_reporte_diagnostico.m → backup\n');
end

fprintf('\n');

%% Instalar archivos corregidos
fprintf('📦 Instalando archivos corregidos...\n');

% 1. startup_ims.m
copyfile('startup_ims_FIXED.m', 'startup_ims.m');
fprintf('  ✓ startup_ims.m actualizado\n');

% 2. Crear carpeta analysis si no existe
analysis_dir = fullfile('src', 'analysis');
if ~exist(analysis_dir, 'dir')
    mkdir(analysis_dir);
    fprintf('  ✓ Creada carpeta: src/analysis/\n');
end

% 3. analizar_resultados_detallado.m
copyfile('analizar_resultados_detallado_FIXED.m', ...
         fullfile(analysis_dir, 'analizar_resultados_detallado.m'));
fprintf('  ✓ analizar_resultados_detallado.m instalado\n');

% 4. generar_reporte_diagnostico.m
copyfile('generar_reporte_diagnostico_FIXED.m', ...
         fullfile(analysis_dir, 'generar_reporte_diagnostico.m'));
fprintf('  ✓ generar_reporte_diagnostico.m instalado\n');

fprintf('\n');

%% Recargar entorno
fprintf('🔄 Recargando entorno MATLAB...\n\n');
run('startup_ims.m');

%% Verificación final
fprintf('\n');
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║         ✅ INSTALACIÓN COMPLETADA                 ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');

fprintf('📋 Archivos instalados:\n');
fprintf('  • startup_ims.m\n');
fprintf('  • src/analysis/analizar_resultados_detallado.m\n');
fprintf('  • src/analysis/generar_reporte_diagnostico.m\n');
fprintf('\n');

fprintf('💾 Backup guardado en: backup_old_files/\n\n');

fprintf('🎯 Próximos pasos:\n');
fprintf('\n');
fprintf('  1. Ejecutar análisis detallado:\n');
fprintf('     >> run(''src/analysis/analizar_resultados_detallado.m'')\n');
fprintf('\n');
fprintf('  2. Generar reporte:\n');
fprintf('     >> run(''src/analysis/generar_reporte_diagnostico.m'')\n');
fprintf('\n');
fprintf('  3. Ver reporte generado:\n');
fprintf('     >> edit(''results/REPORTE_DIAGNOSTICO.txt'')\n');
fprintf('\n');

fprintf('═══════════════════════════════════════════════════════\n');
fprintf('\n');
