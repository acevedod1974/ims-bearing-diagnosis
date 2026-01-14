# 📖 Manual de Usuario - Sistema IMS

Guía completa para usar el Sistema de Diagnóstico Predictivo de Rodamientos.

---

## 🎯 Tabla de Contenidos

1. [Inicio Rápido](#-inicio-rápido)
2. [Demo Interactivo](#-demo-interactivo)
3. [Procesamiento Completo](#-procesamiento-completo)
4. [Configuración Personalizada](#-configuración-personalizada)
5. [Interpretación de Resultados](#-interpretación-de-resultados)
6. [Casos de Uso Avanzados](#-casos-de-uso-avanzados)

---

## 🚀 Inicio Rápido

### Primera Ejecución

```matlab
% 1. Navegar al proyecto
cd('ruta/a/ims-bearing-diagnosis')

% 2. Configurar entorno
run('startup_ims.m')

% 3. Ejecutar demo
run('examples/demo_01_single_file.m')
```

Esto analiza UN archivo y muestra todo el proceso paso a paso.

---

## 🎓 Demo Interactivo

### ¿Qué es el Demo?

El demo analiza un archivo individual de vibración mostrando:
- ✅ Señales triaxiales en el tiempo
- ✅ Extracción de características (RMS, Curtosis)
- ✅ Clasificación con Random Forest
- ✅ Análisis espectral (FFT)

### Ejecutar el Demo

```matlab
run('examples/demo_01_single_file.m')
```

### Resultado del Demo

**Consola:**
```
===============================================
  DEMO: Análisis de Señal Individual
===============================================

PASO 1: Cargando datos...
  ✓ Archivo: ../data/1st_test/2003.10.22.12.06.24
  ✓ Muestras: 20480
  ✓ Canales: 8

PASO 2: Visualizando señales...
  ✓ Gráficas generadas

PASO 3: Extrayendo características...
  📊 RMS:      X=0.1246, Y=0.1175, Z=0.1305
  📊 Curtosis: X=4.07, Y=6.07, Z=3.21

PASO 4: Clasificando...
  🔍 Estado: normal
  🔍 Confianza: 99.0%

PASO 5: Análisis espectral...
  ✓ Espectro generado
```

**Gráficas:**
- Figura 1: Señales de vibración (3 subplots)
- Figura 2: Espectro de frecuencia

### Analizar Otro Archivo

Edita la línea 25 del demo:

```matlab
% Abrir editor
edit examples/demo_01_single_file.m

% Cambiar línea 25:
data_file = fullfile('..', 'data', '1st_test', 'NOMBRE_ARCHIVO');

% Ejecutar nuevamente
run('examples/demo_01_single_file.m')
```

---

## ⚙️ Procesamiento Completo

### Ejecutar Sistema Completo

Procesa **todos los archivos** del dataset (9,464):

```matlab
IMS_bearing_diagnosis_main()
```

### Tiempo de Procesamiento

| Dataset | Archivos | Tiempo Estimado |
|---------|----------|-----------------|
| 1st_test | 2,156 | ~29 min |
| 2nd_test | 984 | ~13 min |
| 3rd_test | 6,324 | ~84 min |
| **TOTAL** | **9,464** | **~2 horas** |

### Resultados Generados

Al completarse, encontrarás en `results/`:

**1. resultados_diagnostico.csv**
```csv
Archivo,Prediccion,Confianza,RMS_X,RMS_Y,RMS_Z,Kurt_X,Kurt_Y,Kurt_Z
2003.10.22.12.06.24,normal,99.0,0.1246,0.1175,0.1305,4.07,6.07,3.21
...
```

**2. resultados_diagnostico.mat**
- Tabla MATLAB con todos los resultados
- Cargable con: `load('results/resultados_diagnostico.mat')`

**3. Gráficas PNG**
- `histograma_confianza.png` - Distribución de confianzas
- `caracteristicas_distribucion.png` - Features por clase (6 subplots)
- `boxplots_caracteristicas.png` - Box plots de RMS y Curtosis

**4. Reporte en Consola**
```
╔═══════════════════════════════════════════╗
║     REPORTE ESTADISTICO DEL SISTEMA      ║
╚═══════════════════════════════════════════╝

📊 CONFIANZA DE PREDICCIONES:
   Media:    96.50%
   Mediana:  98.00%

🔍 DISTRIBUCION DE DIAGNOSTICOS:
   normal              : 8234 (87.0%) ███████████████████████
   outer_race_fault    : 1230 (13.0%) ██████

⚠️  ALERTAS DE MANTENIMIENTO:
   🔴 CRITICO: 1150 archivos con fallas de ALTA CONFIANZA
```

---

## 🔧 Configuración Personalizada

### Estructura de config.mat

El archivo `config.mat` contiene:

```matlab
config.data_folders = {...}     % Rutas a carpetas de datos
config.model_file = '...'       % Ruta al modelo RF
config.output_dir = '...'       % Carpeta de resultados
config.verbose = true           % Mostrar mensajes detallados
config.save_figures = true      % Guardar gráficas
```

### Modificar Configuración

**Método 1: Editar config_example.m**

```matlab
% Abrir
edit src/utils/config_example.m

% Modificar líneas 22-26:
config.data_folders = {
    'C:\MisCarpetas\Datos1';
    'C:\MisCarpetas\Datos2'
};

% Guardar y ejecutar
run('src/utils/config_example.m')
```

**Método 2: Crear config personalizado**

```matlab
% Cargar config existente
config = load('config.mat');

% Modificar
config.data_folders = {fullfile('data', '1st_test')};
config.output_dir = 'resultados_test1';

% Guardar con nuevo nombre
save('config_test1.mat', '-struct', 'config');

% Usar
IMS_bearing_diagnosis_main('config_test1.mat')
```

### Configuraciones Comunes

**Solo 1st_test (rápido):**
```matlab
config = load('config.mat');
config.data_folders = {fullfile('data', '1st_test')};
save('config_1st.mat', '-struct', 'config');
IMS_bearing_diagnosis_main('config_1st.mat');
```

**Carpeta personalizada:**
```matlab
config = load('config.mat');
config.data_folders = {'C:\MisDatos\Vibraciones'};
save('config_custom.mat', '-struct', 'config');
IMS_bearing_diagnosis_main('config_custom.mat');
```

---

## 📊 Interpretación de Resultados

### Entender la Confianza

**Confianza del clasificador:**
- **>95%**: Diagnóstico muy confiable
- **85-95%**: Confianza moderada, revisar
- **<85%**: Baja confianza, análisis manual requerido

### Características Físicas

**RMS (Root Mean Square):**
- Representa la **energía** de vibración
- RMS alto → Mayor nivel de vibración (desgaste, desbalanceo)
- Unidades: g (aceleración de gravedad)

**Curtosis (Kurtosis):**
- Mide **impulsividad** de la señal
- Curtosis ≈ 3 → Distribución normal (rodamiento sano)
- Curtosis > 5 → Impactos repetitivos (grietas, fallas)
- Curtosis > 10 → Falla severa

### Ejemplo de Interpretación

```
Archivo: 2004.02.19.07.56.16
Predicción: outer_race_fault
Confianza: 96.5%
RMS_Z: 0.256 (alto)
Kurt_Z: 12.4 (muy alto)
```

**Interpretación:**
- ✅ Alta confianza (96.5%) → Diagnóstico confiable
- ⚠️ RMS alto en eje Z → Vibración elevada axial
- 🔴 Curtosis muy alta (12.4) → Impactos severos
- **Conclusión**: Falla en pista externa confirmada, mantenimiento urgente

---

## 🎯 Casos de Uso Avanzados

### Caso 1: Análisis de Evolución Temporal

Analizar cómo evolucionan las características con el tiempo:

```matlab
% Cargar resultados
load('results/resultados_diagnostico.mat');

% Extraer fechas de nombres de archivos (formato: YYYY.MM.DD.HH.MM.SS)
dates = datetime(results.Archivo, ...
                 'InputFormat', 'yyyy.MM.dd.HH.mm.ss', ...
                 'Format', 'yyyy-MM-dd HH:mm:ss');

% Graficar RMS_Z vs tiempo
figure;
plot(dates, results.RMS_Z, 'LineWidth', 1.5);
xlabel('Fecha');
ylabel('RMS Z (g)');
title('Evolución de RMS en Eje Z');
grid on;

% Identificar tendencia
trend = polyfit(datenum(dates), results.RMS_Z, 1);
hold on;
plot(dates, polyval(trend, datenum(dates)), 'r--', 'LineWidth', 2);
legend('RMS medido', 'Tendencia', 'Location', 'best');
```

### Caso 2: Filtrar Resultados

Encontrar archivos con alta probabilidad de falla:

```matlab
% Cargar resultados
load('results/resultados_diagnostico.mat');

% Filtrar fallas con >90% confianza
fallas_criticas = results(results.Prediccion ~= "normal" & ...
                          results.Confianza > 90, :);

% Mostrar
disp('Archivos con fallas críticas:');
disp(fallas_criticas(:, {'Archivo', 'Prediccion', 'Confianza'}));

% Exportar
writetable(fallas_criticas, 'fallas_criticas.csv');
```

### Caso 3: Comparar Características por Clase

```matlab
% Cargar resultados
load('results/resultados_diagnostico.mat');

% Separar por clase
normal_data = results(results.Prediccion == "normal", :);
fault_data = results(results.Prediccion ~= "normal", :);

% Estadísticas comparativas
fprintf('\n=== COMPARACIÓN POR CLASE ===\n');
fprintf('RMS_Z promedio:\n');
fprintf('  Normal: %.4f\n', mean(normal_data.RMS_Z));
fprintf('  Falla:  %.4f\n', mean(fault_data.RMS_Z));

fprintf('\nCurtosis_Z promedio:\n');
fprintf('  Normal: %.4f\n', mean(normal_data.Kurt_Z));
fprintf('  Falla:  %.4f\n', mean(fault_data.Kurt_Z));

% Visualización
figure;
subplot(1,2,1);
boxplot([normal_data.RMS_Z; fault_data.RMS_Z], ...
        [zeros(height(normal_data),1); ones(height(fault_data),1)], ...
        'Labels', {'Normal', 'Falla'});
ylabel('RMS Z');
title('Distribución de RMS');

subplot(1,2,2);
boxplot([normal_data.Kurt_Z; fault_data.Kurt_Z], ...
        [zeros(height(normal_data),1); ones(height(fault_data),1)], ...
        'Labels', {'Normal', 'Falla'});
ylabel('Curtosis Z');
title('Distribución de Curtosis');
```

### Caso 4: Procesar Carpeta Personalizada

```matlab
% Función custom para procesar cualquier carpeta
function analizar_carpeta_custom(folder_path, output_name)
    % Cargar modelo
    model_data = load('models/ims_modelo_especifico.mat');
    rf_model = model_data.rf_ims;

    % Listar archivos
    files = dir(fullfile(folder_path, '*'));
    files = files(~[files.isdir]);

    fprintf('Procesando %d archivos de %s...\n', ...
            length(files), folder_path);

    % Procesar
    results = table();
    for i = 1:length(files)
        file_path = fullfile(folder_path, files(i).name);

        try
            data = readmatrix(file_path, 'FileType', 'text');
            features = extract_rms_kurtosis(data(:,1:3));
            [pred, scores] = predict(rf_model, features);

            % Agregar a tabla
            new_row = table(string(files(i).name), ...
                           string(char(pred)), ...
                           100*max(scores), ...
                           features(1), features(2), features(3), ...
                           features(4), features(5), features(6), ...
                           'VariableNames', ...
                           {'Archivo','Prediccion','Confianza',...
                            'RMS_X','RMS_Y','RMS_Z',...
                            'Kurt_X','Kurt_Y','Kurt_Z'});
            results = [results; new_row];
        catch
            warning('Error en %s', files(i).name);
        end
    end

    % Guardar
    writetable(results, sprintf('%s.csv', output_name));
    fprintf('\nResultados guardados: %s.csv\n', output_name);
end

% Uso:
% analizar_carpeta_custom('C:\MisDatos', 'resultados_custom');
```

---

## 📞 Soporte y Ayuda

### Comandos Útiles

```matlab
% Verificar instalación
run('check_installation.m')

% Ver configuración actual
config = load('config.mat')

% Inspeccionar modelo
run('inspect_current_model.m')

% Limpiar workspace y figuras
clear; clc; close all;

% Ver ayuda de función
help extract_rms_kurtosis
```

### Documentación Adicional

- [Referencia de API](API_REFERENCE.md) - Documentación de funciones
- [Entrenar Modelo](MODEL_TRAINING.md) - Guía de reentrenamiento
- [FAQ](FAQ.md) - Preguntas frecuentes

---

**[⬆ Volver al README principal](../README.md)**
