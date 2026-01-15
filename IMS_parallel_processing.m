function IMS_parallel_processing()
%% IMS_parallel_processing.m
% ═══════════════════════════════════════════════════════════════════════
% PROCESAMIENTO PARALELO FINAL (v1.3.3)
% ═══════════════════════════════════════════════════════════════════════

    clc;
    warning('off', 'MATLAB:mir_warning_variable_used_as_tmp');
    
    % --- CONFIGURACIÓN ---
    script_dir = fileparts(mfilename('fullpath'));
    project_root = script_dir; 
    data_dir = fullfile(project_root, 'data');
    model_path = fullfile(project_root, 'models', 'ims_modelo_especifico.mat');
    results_file = fullfile(project_root, 'results', 'resultados_diagnostico_paralelo.mat');

    fprintf('╔═══════════════════════════════════════════════════════════╗\n');
    fprintf('║  PROCESAMIENTO PARALELO ROBUSTO (v1.3.3 - FIX TIPOS)    ║\n');
    fprintf('╚═══════════════════════════════════════════════════════════╝\n\n');

    % --- 1. CARGAR RECURSOS ---
    if ~license('test', 'Distrib_Computing_Toolbox'), error('Falta Toolbox Paralelo'); end

    fprintf('📂 Cargando modelo...\n');
    loaded_data = load(model_path);
    vars = fieldnames(loaded_data);
    found = false;
    for i=1:length(vars)
        if isa(loaded_data.(vars{i}), 'TreeBagger') || isa(loaded_data.(vars{i}), 'classreg.learning.classif.CompactClassificationEnsemble') || isstruct(loaded_data.(vars{i}))
            RF_Model = loaded_data.(vars{i});
            found = true; break;
        end
    end
    if ~found, RF_Model = loaded_data.(vars{1}); end

    fprintf('📂 Escaneando archivos...\n');
    file_list = dir(fullfile(data_dir, '**', '*.*'));
    file_list = file_list(~[file_list.isdir]);
    file_list = file_list([file_list.bytes] > 10000); 
    n_files = length(file_list);
    fprintf('   ✓ Archivos a procesar: %d\n', n_files);

    % --- 2. INICIAR PARPOOL ---
    poolobj = gcp('nocreate');
    if isempty(poolobj), parpool; end
    
    % --- 3. PROCESAMIENTO ---
    fprintf('⚡ Iniciando loop paralelo...\n');
    tic;

    filenames = cell(n_files, 1);
    predictions = cell(n_files, 1);
    confidences = zeros(n_files, 1);
    rms_vals = zeros(n_files, 3);
    kurt_vals = zeros(n_files, 3);

    q = parallel.pool.DataQueue;
    afterEach(q, @updateProgress);
    p_count = 0;
    
    parfor i = 1:n_files
        try
            file_info = file_list(i);
            full_path = fullfile(file_info.folder, file_info.name);
            
            % Lectura
            raw_data = readmatrix(full_path, 'FileType', 'text');
            [rows, cols] = size(raw_data);
            
            if rows < 100
                 pred_str = "error_vacio"; conf = 0;
                 feat = zeros(1, 6);
            else
                % Extracción
                c1 = raw_data(:,1);
                if cols >= 2, c2 = raw_data(:,2); else, c2 = c1*0; end
                if cols >= 4, c3 = raw_data(:,4); elseif cols>=3, c3 = raw_data(:,3); else, c3 = c1*0; end
                
                feat = [sqrt(mean(c1.^2)), sqrt(mean(c2.^2)), sqrt(mean(c3.^2)), ...
                        kurtosis(c1), kurtosis(c2), kurtosis(c3)];
                
                % --- PREDICCIÓN ROBUSTA (FIX v1.3.3) ---
                if isa(RF_Model, 'TreeBagger') || isa(RF_Model, 'classreg.learning.classif.CompactClassificationEnsemble')
                    [Yfit, scores] = predict(RF_Model, feat);
                elseif isstruct(RF_Model)
                    [Yfit, scores] = RF_Model.predictFcn(array2table(feat));
                else
                    error('Modelo desconocido');
                end

                % Manejar TODOS los tipos de salida posibles de predict()
                if iscell(Yfit)
                    pred_str = string(Yfit{1});      % Caso Cell: {'normal'}
                elseif iscategorical(Yfit)
                    pred_str = string(char(Yfit));   % Caso Categorical
                elseif isstring(Yfit)
                    pred_str = Yfit(1);              % Caso String Array
                elseif ischar(Yfit)
                    pred_str = string(Yfit);         % Caso Char
                else
                    pred_str = string(Yfit);         % Fallback numérico
                end
                
                conf = max(scores(1,:))*100;
            end
            
            % Asignar
            filenames{i} = file_info.name;
            predictions{i} = pred_str;
            confidences(i) = conf;
            rms_vals(i,:) = feat(1:3);
            kurt_vals(i,:) = feat(4:6);
            
            send(q, i);
            
        catch ME
            filenames{i} = file_list(i).name;
            predictions{i} = "error_fatal"; 
            confidences(i) = 0;
            % Solo imprimimos errores que NO sean el que ya corregimos
            if ~contains(ME.message, 'Cell contents reference')
                fprintf('\n⚠️ Error en %s: %s\n', file_list(i).name, ME.message);
            end
        end
    end
    
    total_time = toc;
    
    % --- 4. GUARDAR ---
    fprintf('\n\n✅ Finalizado en %.2f min.\n', total_time/60);
    
    results = table(filenames, string(predictions), confidences, ...
        rms_vals(:,1), rms_vals(:,2), rms_vals(:,3), ...
        kurt_vals(:,1), kurt_vals(:,2), kurt_vals(:,3), ...
        'VariableNames', {'Archivo', 'Prediccion', 'Confianza', ...
        'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'});
    
    n_err = sum(results.Prediccion == "error_fatal" | results.Prediccion == "error_vacio");
    if n_err > 0
        fprintf('⚠️  ADVERTENCIA: %d archivos resultaron en error.\n', n_err);
    else
        fprintf('✓ 0 Errores. Todo procesado correctamente.\n');
    end
    
    save(results_file, 'results');
    fprintf('💾 Guardado en: %s\n', results_file);

    function updateProgress(~)
        p_count = p_count + 1;
        if mod(p_count, 200) == 0, fprintf('.'); end
        if mod(p_count, 10000) == 0, fprintf('\n'); end
    end
end
