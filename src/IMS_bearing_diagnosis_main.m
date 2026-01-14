function IMS_bearing_diagnosis_main(config_file)
%% IMS_bearing_diagnosis_main.m
% Sistema de Diagnóstico Predictivo de Fallas en Rodamientos
% Dataset: IMS Bearing Dataset
% Método: Random Forest con características estadísticas
% Compatible con: MATLAB R2020a+
% Autor: Daniel Acevedo Lopez
% Fecha: Enero 2026

    if nargin < 1
        config_file = 'config.mat';
    end

    close all; clc;
    fprintf('\n====================================================\n');
    fprintf('   Sistema de Diagnóstico de Rodamientos IMS\n');
    fprintf('====================================================\n\n');

    config = load_configuration(config_file);

    try
        model_data = load(config.model_file);
        rf_model = model_data.rf_ims;
        fprintf('✓ Modelo cargado: %s\n', config.model_file);
    catch ME
        error('Error al cargar modelo: %s', ME.message);
    end

    results = process_bearing_data(config.data_folders, rf_model);
    save_results(results, config.output_dir);
    generate_visualizations(results, config.output_dir);
    generate_statistical_report(results);

    fprintf('\n✓ Análisis completado exitosamente\n');
end

function config = load_configuration(config_file)
    config.data_folders = {
        fullfile('data', '1st_test');
        fullfile('data', '2nd_test');
        fullfile('data', '3rd_test')
    };
    config.model_file = fullfile('models', 'ims_modelo_especifico.mat');
    config.output_dir = 'results';

    if isfile(config_file)
        try
            custom_config = load(config_file);
            fields = fieldnames(custom_config);
            for i = 1:length(fields)
                config.(fields{i}) = custom_config.(fields{i});
            end
        catch
            warning('No se pudo cargar config, usando defaults');
        end
    end

    if ~isfolder(config.output_dir)
        mkdir(config.output_dir);
    end
end

function results = process_bearing_data(folders, model)
    varTypes = [{'string'}, {'string'}, {'double'}, repmat({'double'}, 1, 6)];
    varNames = {'Archivo', 'Prediccion', 'Confianza', 'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'};
    results = table('Size', [0 9], 'VariableTypes', varTypes, 'VariableNames', varNames);

    total_files = 0;
    processed_files = 0;

    for f = 1:length(folders)
        folder = folders{f};

        if ~isfolder(folder)
            warning('Carpeta no encontrada: %s', folder);
            continue;
        end

        files = dir(fullfile(folder, '*'));
        files = files(~[files.isdir] & ~startsWith({files.name}, '.'));
        total_files = total_files + numel(files);

        fprintf('Procesando: %s (%d archivos)\n', folder, numel(files));
        h = waitbar(0, sprintf('Procesando %s...', folder));

        for i = 1:numel(files)
            try
                file_path = fullfile(folder, files(i).name);
                data = readmatrix(file_path, 'FileType', 'text');

                if size(data, 2) < 3
                    continue;
                end

                signal_xyz = data(:, 1:3);
                features = extract_rms_kurtosis(signal_xyz);
                [pred, scores] = predict(model, features);
                confidence = 100 * max(scores);

                newRow = table(string(files(i).name), string(char(pred)), confidence, ...
                    features(1), features(2), features(3), features(4), features(5), features(6), ...
                    'VariableNames', varNames);
                results = [results; newRow];
                processed_files = processed_files + 1;

            catch ME
                warning('Error: %s', files(i).name);
            end

            waitbar(i/numel(files), h);
        end
        close(h);
    end

    fprintf('✓ Procesados %d/%d archivos\n', processed_files, total_files);
end

function save_results(results, output_dir)
    writetable(results, fullfile(output_dir, 'resultados_diagnostico.csv'));
    save(fullfile(output_dir, 'resultados_diagnostico.mat'), 'results');
    fprintf('✓ Resultados guardados\n');
end

function generate_visualizations(results, output_dir)
    % Histograma confianza
    figure('Position', [100, 100, 900, 600]);
    histogram(results.Confianza, 'Normalization', 'probability', 'BinWidth', 5);
    title('Distribución de Confianza');
    xlabel('Confianza (%)');
    ylabel('Frecuencia');
    grid on;
    saveas(gcf, fullfile(output_dir, 'histograma_confianza.png'));
    close;

    % Características
    figure('Position', [100, 100, 1400, 900]);
    subplot(2,3,1); gscatter(results.RMS_X, results.RMS_Y, results.Prediccion);
    title('RMS X vs Y'); xlabel('RMS_X'); ylabel('RMS_Y'); grid on;

    subplot(2,3,2); gscatter(results.RMS_X, results.RMS_Z, results.Prediccion);
    title('RMS X vs Z'); xlabel('RMS_X'); ylabel('RMS_Z'); grid on;

    subplot(2,3,3); gscatter(results.RMS_Y, results.RMS_Z, results.Prediccion);
    title('RMS Y vs Z'); xlabel('RMS_Y'); ylabel('RMS_Z'); grid on;

    subplot(2,3,4); gscatter(results.Kurt_X, results.Kurt_Y, results.Prediccion);
    title('Kurt X vs Y'); xlabel('Kurt_X'); ylabel('Kurt_Y'); grid on;

    subplot(2,3,5); gscatter(results.Kurt_X, results.Kurt_Z, results.Prediccion);
    title('Kurt X vs Z'); xlabel('Kurt_X'); ylabel('Kurt_Z'); grid on;

    subplot(2,3,6); gscatter(results.Kurt_Y, results.Kurt_Z, results.Prediccion);
    title('Kurt Y vs Z'); xlabel('Kurt_Y'); ylabel('Kurt_Z'); grid on;

    saveas(gcf, fullfile(output_dir, 'caracteristicas_distribucion.png'));
    close;

    fprintf('✓ Visualizaciones generadas\n');
end

function generate_statistical_report(results)
    fprintf('\n=== REPORTE ESTADÍSTICO ===\n');
    fprintf('Confianza Media: %.2f%%\n', mean(results.Confianza));
    fprintf('Confianza Mediana: %.2f%%\n', median(results.Confianza));
    fprintf('Desv. Estándar: %.2f%%\n', std(results.Confianza));

    categories = unique(results.Prediccion);
    fprintf('\nDistribución:\n');
    for i = 1:numel(categories)
        count = sum(strcmp(results.Prediccion, categories{i}));
        fprintf('  %s: %d (%.1f%%)\n', categories{i}, count, 100*count/height(results));
    end
end
