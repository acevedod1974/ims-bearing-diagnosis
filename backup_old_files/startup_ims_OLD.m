% startup_ims.m
% Script de inicialización del Sistema de Diagnóstico de Rodamientos IMS
% Configura el entorno de trabajo agregando carpetas al path de MATLAB
%
% Uso:
%   run('startup_ims.m')

fprintf('\n');
fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║   Sistema de Diagnóstico de Rodamientos IMS      ║\n');
fprintf('║            Configurando entorno...               ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n\n');

%% Obtener la raíz del proyecto
project_root = fileparts(mfilename('fullpath'));

%% Cambiar a la carpeta del proyecto
cd(project_root);
fprintf('📂 Directorio de trabajo: %s\n\n', project_root);

%% Agregar carpetas al path
fprintf('Agregando al path de MATLAB:\n');

folders_to_add = {
    'src', ...
    fullfile('src', 'utils'), ...
    fullfile('src', 'training'), ...
    fullfile('src', 'analysis'), ...
    'examples'
};

for i = 1:length(folders_to_add)
    folder_path = fullfile(project_root, folders_to_add{i});

    if exist(folder_path, 'dir')
        addpath(folder_path);
        fprintf('  ✓ %s\n', folders_to_add{i});
    else
        % Crear carpeta si no existe
        mkdir(folder_path);
        addpath(folder_path);
        fprintf('  ✓ %s (creada)\n', folders_to_add{i});
    end
end

fprintf('\n✅ Sistema listo para usar\n\n');

%% Mostrar comandos disponibles
fprintf('Comandos disponibles:\n');
fprintf('  • IMS_bearing_diagnosis_main()      - Ejecutar sistema completo\n');
fprintf('  • run(''examples/demo_01_single_file.m'')  - Ejecutar demo\n');
fprintf('  • run(''check_installation.m'')            - Verificar instalación\n');
fprintf('  • run(''src/utils/config_example.m'')      - Regenerar configuración\n');
fprintf('\n');
fprintf('Scripts de análisis:\n');
fprintf('  • run(''src/analysis/analizar_resultados_detallado.m'')\n');
fprintf('  • run(''src/analysis/generar_reporte_diagnostico.m'')\n');
fprintf('\n');

fprintf('╔═══════════════════════════════════════════════════╗\n');
fprintf('║              Entorno Configurado ✓               ║\n');
fprintf('╚═══════════════════════════════════════════════════╝\n');
fprintf('\n');