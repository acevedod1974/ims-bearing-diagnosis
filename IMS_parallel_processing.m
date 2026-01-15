function IMS_parallel_processing()
%% IMS_parallel_processing.m
% ═══════════════════════════════════════════════════════════════════════
% PROCESAMIENTO PARALELO DE DIAGNÓSTICO IMS (v1.3.1 - Corregido)
% ═══════════════════════════════════════════════════════════════════════

    % Limpiar consola pero mantener variables locales
    clc;
    
    %% 1. CONFIGURACIÓN DE RUTAS Y PARÁMETROS
    % -----------------------------------------------------------------------
    % Detectar ruta raíz del script
    script_dir = fileparts(mfilename('fullpath'));
    project_root = script_dir; % Script está en la raíz

    % Rutas relativas
    data_dir = fullfile(project_root, 'data');
    model_path = fullfile(project_root, 'models', 'ims_modelo_especifico.mat');
    results_file = fullfile(project_root, 'results', 'resultados_diagnostico_paralelo.mat');

    fprintf('╔═══════════════════════════════════════════════════════════╗\n');
    fprintf('║  PROCESAMIENTO PARALELO DE ALTO RENDIMIENTO (HPC)       ║\n');
    fprintf('╚═══════════════════════════════════════════════════════════╝\n\n');

    %% 2. VERIFICACIÓN DE RECURSOS
    % -----------------------------------------------------------------------
    fprintf('🔍 Verificando entorno...\n');

    % Verificar Toolbox
    if ~license('test', 'Distrib_Computing_Toolbox')
        error('❌ Parallel Computing Toolbox no está instalada o licenciada.');
    end

    % Cargar Modelo
    fprintf('   📂 Cargando modelo: %s\n', model_path);
    if ~exist(model_path, 'file')
        error('❌ No se encuentra el archivo del modelo.');
    end

    loaded_data = load(model_path);
    % Lógica inteligente para encontrar el objeto modelo dentro del .mat
    vars = fieldnames(loaded_data);
    found_model = false;
    for i = 1:length(vars)
        obj = loaded_data.(vars{i});
        if isa(obj, 'TreeBagger') || isa(obj, 'classreg.learning.classif.CompactClassificationEnsemble')
            RF_Model = obj;
            found_model = true;
            fprintf('   ✓ Modelo detectado en variable: "%s"\n', vars{i});
            break;
        elseif isstruct(obj) && isfield(obj, 'predict') 
             RF_Model = obj;
             found_model = true;
             fprintf('   ✓ Struct de modelo detectado en variable: "%s"\n', vars{i});
             break;
        end
    end

    if ~found_model
        RF_Model = loaded_data.(vars{1});
        warning('⚠️ No se identificó tipo de modelo estándar. Usando variable: "%s"', vars{1});
    end

    % Escanear Archivos
    fprintf('   📂 Escaneando directorio de datos: %s\n', data_dir);
    file_list = dir(fullfile(data_dir, '**', '*.*')); 
    file_list = file_list(~[file_list.isdir]); 

    % Filtrar por tamaño (> 10KB)
    valid_files = [file_list.bytes] > 10000;
    file_list = file_list(valid_files);

    n_files = length(file_list);
    if n_files == 0
        error('❌ No se encontraron archivos de datos válidos en %s', data_dir);
    end
    fprintf('   ✓ Archivos válidos encontrados: %d\n', n_files);

    %% 3. CONFIGURACIÓN DEL POOL PARALELO
    % -----------------------------------------------------------------------
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        fprintf('\n🚀 Iniciando Parallel Pool (esto puede tardar unos segundos)...\n');
        parpool; 
    else
        fprintf('\n🚀 Parallel Pool ya está activo (%d workers)\n', poolobj.NumWorkers);
    end
    poolobj = gcp;
    fprintf('   ✓ Trabajando con %d núcleos simultáneos\n\n', poolobj.NumWorkers);

    %% 4. PROCESAMIENTO PARALELO (PARFOR)
    % -----------------------------------------------------------------------
    fprintf('⚡ Iniciando procesamiento masivo...\n');
    tic; 

    % Pre-allocating variables
    filenames = cell(n_files, 1);
    predictions = cell(n_files, 1);
    confidences = zeros(n_files, 1);
    rms_x = zeros(n_files, 1); rms_y = zeros(n_files, 1); rms_z = zeros(n_files, 1);
    kurt_x = zeros(n_files, 1); kurt_y = zeros(n_files, 1); kurt_z = zeros(n_files, 1);

    % Configurar cola de datos para barra de progreso
    q = parallel.pool.DataQueue;
    afterEach(q, @updateProgress); % Llama a la función anidada
    p_count = 0; % Variable compartida con la función anidada
    fprintf('   Progreso: 0%%\n');

    % --- BUCLE PARALELO ---
    parfor i = 1:n_files
        try
            this_file = file_list(i);
            full_path = fullfile(this_file.folder, this_file.name);
            
            % Lectura rápida
            fid = fopen(full_path, 'rt');
            if fid == -1, continue; end
            C = textscan(fid, '%f %f %f %f', 'CollectOutput', true); 
            fclose(fid);
            raw_data = C{1}; 
            
            [rows, cols] = size(raw_data);
            
            if rows < 100
                 pred_label = "error_vacio";
                 conf = 0;
                 feat = zeros(1, 6);
            else
                % Extracción
                r_x = sqrt(mean(raw_data(:,1).^2));
                k_x = sum((raw_data(:,1) - mean(raw_data(:,1))).^4) / (length(raw_data(:,1)) * var(raw_data(:,1))^2);
                
                if cols >= 2
                    r_y = sqrt(mean(raw_data(:,2).^2));
                    k_y = sum((raw_data(:,2) - mean(raw_data(:,2))).^4) / (length(raw_data(:,2)) * var(raw_data(:,2))^2);
                else, r_y = 0; k_y = 0; end
                
                if cols >= 4
                    r_z = sqrt(mean(raw_data(:,4).^2)); 
                    k_z = sum((raw_data(:,4) - mean(raw_data(:,4))).^4) / (length(raw_data(:,4)) * var(raw_data(:,4))^2);
                elseif cols >= 3
                    r_z = sqrt(mean(raw_data(:,3).^2));
                    k_z = sum((raw_data(:,3) - mean(raw_data(:,3))).^4) / (length(raw_data(:,3)) * var(raw_data(:,3))^2);
                else, r_z = 0; k_z = 0; end
                
                feat = [r_x, r_y, r_z, k_x, k_y, k_z];
                
                % Predicción
                if isa(RF_Model, 'TreeBagger') || isa(RF_Model, 'classreg.learning.classif.CompactClassificationEnsemble')
                    [pred_cell, scores] = predict(RF_Model, feat);
                    pred_label = string(pred_cell{1});
                    conf = max(scores(1, :)) * 100;
                elseif isstruct(RF_Model) && isfield(RF_Model, 'predictFcn')
                     [pred_cell, scores] = RF_Model.predictFcn(array2table(feat));
                     pred_label = string(pred_cell{1});
                     conf = max(scores(1, :)) * 100;
                else
                     [pred_cell, scores] = predict(RF_Model, feat);
                     pred_label = string(pred_cell{1});
                     conf = max(scores(1, :)) * 100;
                end
            end
            
            % Asignación
            filenames{i} = this_file.name;
            predictions{i} = pred_label;
            confidences(i) = conf;
            rms_x(i) = feat(1); rms_y(i) = feat(2); rms_z(i) = feat(3);
            kurt_x(i) = feat(4); kurt_y(i) = feat(5); kurt_z(i) = feat(6);
            
            send(q, i); % Notificar progreso
            
        catch
            filenames{i} = file_list(i).name;
            predictions{i} = "error_lectura";
            confidences(i) = 0;
        end
    end

    total_time = toc;

    %% 5. CONSOLIDACIÓN Y GUARDADO
    % -----------------------------------------------------------------------
    fprintf('\n\n✅ Procesamiento finalizado en %.2f minutos.\n', total_time/60);
    fprintf('   Velocidad: %.1f archivos/segundo\n', n_files/total_time);

    fprintf('💾 Guardando resultados...\n');

    % Crear tabla final
    results = table(filenames, string(predictions), confidences, ...
        rms_x, rms_y, rms_z, kurt_x, kurt_y, kurt_z, ...
        'VariableNames', {'Archivo', 'Prediccion', 'Confianza', ...
        'RMS_X', 'RMS_Y', 'RMS_Z', 'Kurt_X', 'Kurt_Y', 'Kurt_Z'});

    idx_valid = results.Prediccion ~= "error_lectura" & results.Prediccion ~= "error_vacio";
    results = results(idx_valid, :);

    save(results_file, 'results');
    fprintf('✓ Resultados guardados en: %s\n', results_file);

    % -----------------------------------------------------------------------
    % FUNCIÓN ANIDADA PARA BARRA DE PROGRESO
    % -----------------------------------------------------------------------
    function updateProgress(~)
        p_count = p_count + 1;
        % Actualizar cada 2%
        if mod(p_count, max(1, floor(n_files/50))) == 0
            pct = round(p_count / n_files * 100);
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bProgreso: %3d%%', pct);
        end
    end

end
