function features = extract_rms_kurtosis(signal_xyz)
%EXTRACT_RMS_KURTOSIS Extrae RMS y Curtosis de señales triaxiales
%
% SINTAXIS:
%   features = extract_rms_kurtosis(signal_xyz)
%
% INPUTS:
%   signal_xyz - Matriz Nx3 [X, Y, Z] con señales de vibración
%
% OUTPUTS:
%   features - Vector 1x6 [RMS_X, RMS_Y, RMS_Z, Kurt_X, Kurt_Y, Kurt_Z]
%
% TEORÍA FÍSICA:
%   RMS = sqrt(mean(x^2))    - Energía total de vibración
%   Curtosis = E[(x-μ)/σ]^4  - Detecta impactos repetitivos (fallas)
%
% INTERPRETACIÓN:
%   - RMS alto: Mayor energía de vibración (desgaste/desbalance)
%   - Curtosis > 3: Presencia de impactos (grietas, desprendimientos)
%   - Curtosis ≈ 3: Distribución normal (estado saludable)
%
% AUTOR: Daniel Acevedo Lopez
% FECHA: Enero 2026
% COMPATIBLE: MATLAB R2020a+

% Validación de entrada
assert(size(signal_xyz, 2) == 3, ...
    'extract_rms_kurtosis:InvalidInput', ...
    'La señal debe tener exactamente 3 columnas [X, Y, Z]');

assert(size(signal_xyz, 1) > 0, ...
    'extract_rms_kurtosis:EmptySignal', ...
    'La señal no puede estar vacía');

% Extracción vectorizada (más eficiente que bucles for)
rms_vals = sqrt(mean(signal_xyz.^2, 1));      % RMS de cada columna
kurt_vals = kurtosis(signal_xyz, 0, 1);        % Curtosis de cada columna

% Construir vector de características
features = [rms_vals, kurt_vals];

% Validación de salida
if any(isnan(features)) || any(isinf(features))
    error('extract_rms_kurtosis:InvalidOutput', ...
          ['Características inválidas detectadas (NaN o Inf).\n', ...
           'Posibles causas:\n', ...
           '  - Señal con valores constantes (desv. estándar = 0)\n', ...
           '  - Valores extremos o corruptos en los datos\n', ...
           '  - Archivo de datos dañado\n', ...
           'Verifique la calidad de los datos de entrada.']);
end

end
