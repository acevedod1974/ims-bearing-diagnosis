function features = extract_rms_kurtosis(signal_xyz)
%EXTRACT_RMS_KURTOSIS Extrae RMS y Curtosis de señales triaxiales
%
% SINTAXIS:
%   features = extract_rms_kurtosis(signal_xyz)
%
% INPUTS:
%   signal_xyz - Matriz Nx3 [X, Y, Z]
%
% OUTPUTS:
%   features - Vector 1x6 [RMS_X, RMS_Y, RMS_Z, Kurt_X, Kurt_Y, Kurt_Z]
%
% TEORÍA:
%   RMS = sqrt(mean(x^2)) - Energía de vibración
%   Curtosis = E[(x-μ)/σ]^4 - Impulsividad

    if size(signal_xyz, 2) ~= 3
        error('Señal debe tener 3 columnas (X, Y, Z)');
    end

    features = zeros(1, 6);

    % RMS para cada eje
    for i = 1:3
        features(i) = rms(signal_xyz(:, i));
    end

    % Curtosis para cada eje
    for i = 1:3
        features(i+3) = kurtosis(signal_xyz(:, i));
    end

    % Validar salida
    if any(isnan(features)) || any(isinf(features))
        warning('Características inválidas detectadas');
        features(isnan(features)) = 0;
        features(isinf(features)) = 0;
    end
end
