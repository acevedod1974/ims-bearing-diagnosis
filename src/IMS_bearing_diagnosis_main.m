function IMS_bearing_diagnosis_main(config_file)
%% IMS_bearing_diagnosis_main.m
% Sistema de Diagnóstico Predictivo de Fallas en Rodamientos
% Dataset: IMS Bearing Dataset
% Método: Random Forest con características estadísticas
% Compatible con: MATLAB R2020a+
%
% SINTAXIS:
%   IMS_bearing_diagnosis_main()           % Usa config.mat por defecto
%   IMS_bearing_diagnosis_main('mi_config.mat')  % Usa configuración personalizada
%
% AUTOR: Daniel Acevedo Lopez
% FECHA: Enero 2026

if nargin < 1
    config_file = 'config.mat';
end

close all; clc;
fprintf('\n====================================================\n');
fprintf('  Sistema de Diagnóstico de Rodamientos IMS\n');
fprintf('  Mantenimiento Predictivo - MATLAB R2020a+\n');
fprintf('====================================================\n\n');

% Cargar configuración
config = load_configuration(config_file);

% Cargar modelo pre-entrenado
try
    model_data = load(config.model_file);
    rf_model = model_data.rf_ims;
    fprintf('✓ Modelo cargado: %s\n', config.model_file);
catch ME
    error('Error al cargar modelo: %s\nVerifique que el archivo existe.', ME.message);
end

% Procesar datos
results = process_bearing_data(config.data_folders, rf_model);

% Guardar resultados
save_results(results, config.output_dir);

% Generar visualizaciones mejoradas
generate_visualizations(results, config.output_dir);

% Reporte estadístico enriquecido
generate_statistical_report(results);

fprintf('\n✓ Análisis completado exitosamente\n');
fprintf('  Resultados guardados en: %s\n\n', config.output_dir);

end

%% ========================================================================
%  FUNCIÓN: Cargar Configuración
%  ========================================================================
function config = load_configuration(config_file)
    % Valores por defecto
    config.data_folders = {
        fullfile('data', '1st_test');
        fullfile('data', '2nd_test');
        fullfile('data', '3rd_test')
    };
    config.model_file = fullfile('models', 'ims_modelo_especifico.mat');
    config.output_dir = 'results';

    % Intentar cargar configuración personalizada
    if isfile(config_file)
        try
            custom_config = load(config_file);
            fields = fieldnames(custom_config);
            for i = 1:length(fields)
                config.(fields{i}) = custom_config.(fields{i});
            end
            fprintf('✓ Configuración cargada: %s\n', config_file);
        catch
            warning('No se pudo cargar %s, usando configuración por defecto', config_file);
        end
    else
        fprintf('⚠ Archivo %s no encontrado, usando configuración por defecto\n', config_file);
    end

    % Crear directorio de salida si no existe
    if ~isfolder(config.output_dir)
        mkdir(config.output_dir);
    end
end

%% ========================================================================
%  FUNCIÓN: Procesar Datos de Rodamientos
%  ========================================================================
function results = process_bearing_data(folders, model)
    % Inicializar tabla de resultados
    varTypes = [{'string'}, {'string'}, {'double'}, repmat({'double'}, 1, 6)];
    varNames = {'Archivo', 'Prediccion', 'Confianza', ...
                'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'};
    results = table('Size', [0 9], 'VariableTypes', varTypes, 'VariableNames', varNames);

    total_files = 0;
    processed_files = 0;

    % Iterar por cada carpeta de datos
    for f = 1:length(folders)
        folder = folders{f};

        if ~isfolder(folder)
            warning('Carpeta no encontrada: %s', folder);
            continue;
        end

        % Listar archivos (excluir directorios y archivos ocultos)
        files = dir(fullfile(folder, '*'));
        files = files(~[files.isdir] & ~startsWith({files.name}, '.'));
        total_files = total_files + numel(files);

        fprintf('Procesando: %s (%d archivos)\n', folder, numel(files));

        % Barra de progreso - VERSIÓN COMPATIBLE R2020a
        % Extraer solo el nombre de la carpeta (sin ruta completa)
        [~, folder_name] = fileparts(folder);
        h = waitbar(0, sprintf('Procesando carpeta %d/%d...', f, length(folders)));
        tic; % Iniciar cronómetro

        for i = 1:numel(files)
            try
                file_path = fullfile(folder, files(i).name);

                % Leer datos
                data = readmatrix(file_path, 'FileType', 'text');

                % Validar que tenga al menos 3 columnas
                if size(data, 2) < 3
                    warning('Archivo %s: menos de 3 columnas, omitido', files(i).name);
                    continue;
                end

                % Extraer señales triaxiales
                signal_xyz = data(:, 1:3);

                % Extraer características
                features = extract_rms_kurtosis(signal_xyz);

                % Clasificar
                [pred, scores] = predict(model, features);
                confidence = 100 * max(scores);

                % Agregar a tabla de resultados
                newRow = table(string(files(i).name), string(char(pred)), confidence, ...
                              features(1), features(2), features(3), ...
                              features(4), features(5), features(6), ...
                              'VariableNames', varNames);
                results = [results; newRow];

                processed_files = processed_files + 1;

            catch ME
                warning('Error procesando %s: %s', files(i).name, ME.message);
            end

            % Actualizar waitbar cada 50 archivos para evitar overhead
            if mod(i, 50) == 0 || i == numel(files)
                elapsed = toc;
                est_total = elapsed / i * numel(files);
                remaining = est_total - elapsed;

                % Mensaje simple sin caracteres especiales
                progress_pct = 100 * i / numel(files);
                msg = sprintf('Carpeta %d/%d: %.1f%% completado (%.0f min restantes)', ...
                              f, length(folders), progress_pct, remaining/60);

                try
                    waitbar(i/numel(files), h, msg);
                catch
                    % Si falla el waitbar, continuar sin él
                end
            end
        end

        close(h);
        fprintf('  ✓ Completado: %d archivos procesados\n', numel(files));
    end

    fprintf('\n✓ Procesados %d/%d archivos exitosamente\n', processed_files, total_files);

    if processed_files == 0
        warning('No se procesó ningún archivo. Verifique las rutas de datos.');
    end
end

%% ========================================================================
%  FUNCIÓN: Guardar Resultados
%  ========================================================================
function save_results(results, output_dir)
    % Guardar en formato CSV
    csv_file = fullfile(output_dir, 'resultados_diagnostico.csv');
    writetable(results, csv_file);

    % Guardar en formato MAT
    mat_file = fullfile(output_dir, 'resultados_diagnostico.mat');
    save(mat_file, 'results');

    fprintf('✓ Resultados guardados:\n');
    fprintf('  - CSV: %s\n', csv_file);
    fprintf('  - MAT: %s\n', mat_file);
end

%% ========================================================================
%  FUNCIÓN: Generar Visualizaciones Mejoradas
%  ========================================================================
function generate_visualizations(results, output_dir)

    fprintf('\nGenerando visualizaciones...\n');

    % =====================================================================
    % GRÁFICA 1: Histograma de Confianza con Referencias
    % =====================================================================
    figure('Position', [100, 100, 900, 600]);
    h = histogram(results.Confianza, 'Normalization', 'probability', ...
                  'BinWidth', 5, 'FaceColor', [0.2 0.6 0.8]);
    hold on;

    % Líneas de referencia
    xline(85, 'r--', 'LineWidth', 2, 'Label', 'Umbral optimo (85%)');
    xline(mean(results.Confianza), 'g--', 'LineWidth', 1.5, ...
          'Label', sprintf('Media: %.1f%%', mean(results.Confianza)));

    title('Distribucion de Confianza del Clasificador', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Confianza de Prediccion (%)', 'FontSize', 12);
    ylabel('Frecuencia Relativa', 'FontSize', 12);
    legend('Datos', 'Umbral optimo', 'Media', 'Location', 'northwest');
    grid on;

    saveas(gcf, fullfile(output_dir, 'histograma_confianza.png'));
    close;

    % =====================================================================
    % GRÁFICA 2: Características en Espacio 2D (6 subplots)
    % =====================================================================
    figure('Position', [100, 100, 1400, 900]);

    subplot(2,3,1); 
    gscatter(results.RMS_X, results.RMS_Y, results.Prediccion);
    title('RMS: Canal X vs Y', 'FontWeight', 'bold'); 
    xlabel('RMS_X'); ylabel('RMS_Y'); 
    grid on; legend('Location', 'best');

    subplot(2,3,2); 
    gscatter(results.RMS_X, results.RMS_Z, results.Prediccion);
    title('RMS: Canal X vs Z', 'FontWeight', 'bold'); 
    xlabel('RMS_X'); ylabel('RMS_Z'); 
    grid on; legend('Location', 'best');

    subplot(2,3,3); 
    gscatter(results.RMS_Y, results.RMS_Z, results.Prediccion);
    title('RMS: Canal Y vs Z', 'FontWeight', 'bold'); 
    xlabel('RMS_Y'); ylabel('RMS_Z'); 
    grid on; legend('Location', 'best');

    subplot(2,3,4); 
    gscatter(results.Kurt_X, results.Kurt_Y, results.Prediccion);
    title('Curtosis: Canal X vs Y', 'FontWeight', 'bold'); 
    xlabel('Kurt_X'); ylabel('Kurt_Y'); 
    grid on; legend('Location', 'best');

    subplot(2,3,5); 
    gscatter(results.Kurt_X, results.Kurt_Z, results.Prediccion);
    title('Curtosis: Canal X vs Z', 'FontWeight', 'bold'); 
    xlabel('Kurt_X'); ylabel('Kurt_Z'); 
    grid on; legend('Location', 'best');

    subplot(2,3,6); 
    gscatter(results.Kurt_Y, results.Kurt_Z, results.Prediccion);
    title('Curtosis: Canal Y vs Z', 'FontWeight', 'bold'); 
    xlabel('Kurt_Y'); ylabel('Kurt_Z'); 
    grid on; legend('Location', 'best');

    sgtitle('Distribucion de Caracteristicas por Clase de Falla', ...
            'FontSize', 16, 'FontWeight', 'bold');

    saveas(gcf, fullfile(output_dir, 'caracteristicas_distribucion.png'));
    close;

    % =====================================================================
    % GRÁFICA 3: Box Plots por Característica
    % =====================================================================
    figure('Position', [100, 100, 1400, 600]);

    subplot(1,2,1);
    boxplot([results.RMS_X, results.RMS_Y, results.RMS_Z], ...
            'Labels', {'RMS_X', 'RMS_Y', 'RMS_Z'});
    title('Distribucion de RMS por Eje', 'FontWeight', 'bold');
    ylabel('Valor RMS');
    grid on;

    subplot(1,2,2);
    boxplot([results.Kurt_X, results.Kurt_Y, results.Kurt_Z], ...
            'Labels', {'Kurt_X', 'Kurt_Y', 'Kurt_Z'});
    title('Distribucion de Curtosis por Eje', 'FontWeight', 'bold');
    ylabel('Valor de Curtosis');
    yline(3, 'r--', 'LineWidth', 1.5, 'Label', 'Kurt = 3 (Normal)');
    grid on;

    saveas(gcf, fullfile(output_dir, 'boxplots_caracteristicas.png'));
    close;

    fprintf('  ✓ histograma_confianza.png\n');
    fprintf('  ✓ caracteristicas_distribucion.png\n');
    fprintf('  ✓ boxplots_caracteristicas.png\n');
end

%% ========================================================================
%  FUNCIÓN: Reporte Estadístico Enriquecido
%  ========================================================================
function generate_statistical_report(results)
    fprintf('\n');
    fprintf('╔═══════════════════════════════════════════╗\n');
    fprintf('║     REPORTE ESTADISTICO DEL SISTEMA      ║\n');
    fprintf('╚═══════════════════════════════════════════╝\n\n');

    % =====================================================================
    % ESTADÍSTICOS DE CONFIANZA
    % =====================================================================
    fprintf('📊 CONFIANZA DE PREDICCIONES:\n');
    fprintf('   Media:    %.2f%%%%\n', mean(results.Confianza));
    fprintf('   Mediana:  %.2f%%%%\n', median(results.Confianza));
    fprintf('   Desv.Est: %.2f%%%%\n', std(results.Confianza));
    fprintf('   Min/Max:  %.2f%%%% / %.2f%%%%\n\n', ...
            min(results.Confianza), max(results.Confianza));

    % =====================================================================
    % DISTRIBUCIÓN POR CLASE
    % =====================================================================
    categories = unique(results.Prediccion);
    fprintf('🔍 DISTRIBUCION DE DIAGNOSTICOS:\n');
    for i = 1:numel(categories)
        count = sum(strcmp(results.Prediccion, categories{i}));
        pct = 100*count/height(results);

        % Barra de progreso visual (máximo 50 caracteres)
        bar_len = round(pct/2);
        bar = repmat('█', 1, bar_len);

        fprintf('   %-20s: %4d (%5.1f%%%%) %s\n', ...
                categories{i}, count, pct, bar);
    end

    % =====================================================================
    % ALERTAS DE MANTENIMIENTO
    % =====================================================================
    fprintf('\n⚠️  ALERTAS DE MANTENIMIENTO:\n');

    % Definir alertas de alta confianza
    high_risk = sum(results.Confianza > 90 & ...
                    ~strcmp(results.Prediccion, 'Normal'));

    medium_risk = sum(results.Confianza > 75 & results.Confianza <= 90 & ...
                      ~strcmp(results.Prediccion, 'Normal'));

    if high_risk > 0
        fprintf('   🔴 CRITICO: %d archivos con fallas de ALTA CONFIANZA (>90%%%%)\n', high_risk);
    end

    if medium_risk > 0
        fprintf('   🟡 ADVERTENCIA: %d archivos con fallas de MEDIA CONFIANZA (75-90%%%%)\n', medium_risk);
    end

    if high_risk == 0 && medium_risk == 0
        fprintf('   🟢 Sin alertas criticas detectadas\n');
    end

    % =====================================================================
    % ESTADÍSTICOS DE CARACTERÍSTICAS
    % =====================================================================
    fprintf('\n📈 ESTADISTICOS DE CARACTERISTICAS:\n');
    fprintf('   RMS Promedio:   X=%.4f, Y=%.4f, Z=%.4f\n', ...
            mean(results.RMS_X), mean(results.RMS_Y), mean(results.RMS_Z));
    fprintf('   Kurt Promedio:  X=%.4f, Y=%.4f, Z=%.4f\n', ...
            mean(results.Kurt_X), mean(results.Kurt_Y), mean(results.Kurt_Z));

    fprintf('\n');
end