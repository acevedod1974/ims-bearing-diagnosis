# 🔧 Referencia de API

Documentación técnica completa de todas las funciones del sistema.

---

## 📋 Índice de Funciones

### Funciones Principales

- [IMS_bearing_diagnosis_main](#ims_bearing_diagnosis_main)
- [extract_rms_kurtosis](#extract_rms_kurtosis)

### Funciones de Utilidad

- [config_example](#config_example)
- [check_installation](#check_installation)
- [startup_ims](#startup_ims)

### Funciones de Entrenamiento

- [prepare_training_data](#prepare_training_data)
- [train_new_model](#train_new_model)
- [compare_models](#compare_models)

### Funciones de Demostración

- [demo_01_single_file](#demo_01_single_file)

---

## Funciones Principales

### IMS_bearing_diagnosis_main

Sistema principal de diagnóstico de rodamientos.

**Sintaxis:**

```matlab
IMS_bearing_diagnosis_main()
IMS_bearing_diagnosis_main(config_file)
```

**Descripción:**
Procesa archivos de vibración del dataset IMS, extrae características estadísticas y clasifica el estado de los rodamientos usando un modelo Random Forest pre-entrenado.

**Parámetros:**

| Nombre        | Tipo   | Requerido | Descripción                                              |
| ------------- | ------ | --------- | -------------------------------------------------------- |
| `config_file` | string | No        | Ruta al archivo de configuración (default: 'config.mat') |

**Salidas:**

- Archivo CSV: `results/resultados_diagnostico.csv`
- Archivo MAT: `results/resultados_diagnostico.mat`
- Gráficas PNG: 3 archivos en `results/`
- Reporte estadístico en consola

**Ejemplo:**

```matlab
% Usar configuración por defecto
IMS_bearing_diagnosis_main()

% Usar configuración personalizada
IMS_bearing_diagnosis_main('config_custom.mat')
```

**Notas:**

- Tiempo de ejecución: ~2 horas para dataset completo (9,464 archivos)
- Actualiza barra de progreso cada 50 archivos
- Continúa procesamiento si archivos individuales fallan

**Ver también:** [config_example](#config_example), [extract_rms_kurtosis](#extract_rms_kurtosis)

---

### extract_rms_kurtosis

Extrae características estadísticas de señales de vibración triaxiales.

**Sintaxis:**

```matlab
features = extract_rms_kurtosis(signal_xyz)
```

**Descripción:**
Calcula el RMS (Root Mean Square) y la Curtosis para cada canal de una señal triaxial. Implementación completamente vectorizada para máximo rendimiento.

**Parámetros:**

| Nombre       | Tipo   | Dimensiones | Descripción                            |
| ------------ | ------ | ----------- | -------------------------------------- |
| `signal_xyz` | double | [N×3]       | Matriz con señales X, Y, Z en columnas |

Donde:

- N: Número de muestras (típicamente 20,480)
- Columna 1: Señal eje X (horizontal)
- Columna 2: Señal eje Y (vertical)
- Columna 3: Señal eje Z (axial)

**Salidas:**

| Nombre     | Tipo   | Dimensiones | Descripción               |
| ---------- | ------ | ----------- | ------------------------- |
| `features` | double | [1×6]       | Vector de características |

Elementos del vector:

- `features(1)`: RMS canal X
- `features(2)`: RMS canal Y
- `features(3)`: RMS canal Z
- `features(4)`: Curtosis canal X
- `features(5)`: Curtosis canal Y
- `features(6)`: Curtosis canal Z

**Ejemplo:**

```matlab
% Cargar datos
data = readmatrix('data/1st_test/2003.10.22.12.06.24', 'FileType', 'text');
signal_xyz = data(:, 1:3);

% Extraer características
features = extract_rms_kurtosis(signal_xyz);

% Visualizar
fprintf('RMS:  X=%.4f, Y=%.4f, Z=%.4f\n', features(1:3));
fprintf('Kurt: X=%.4f, Y=%.4f, Z=%.4f\n', features(4:6));
```

**Validaciones:**

- Verifica que entrada sea matriz [N×3]
- N debe ser ≥10 muestras
- No admite valores NaN o Inf

**Errores:**

```matlab
% Error si dimensiones incorrectas
signal_bad = rand(100, 2);  % Solo 2 columnas
features = extract_rms_kurtosis(signal_bad);
% → Error: signal_xyz debe tener exactamente 3 columnas

% Error si muy pocas muestras
signal_bad = rand(5, 3);  % Solo 5 muestras
features = extract_rms_kurtosis(signal_bad);
% → Error: signal_xyz debe tener al menos 10 filas
```

**Rendimiento:**

- Tiempo típico: <1 ms para 20,480 muestras
- Implementación vectorizada (sin bucles)
- Compatible con MATLAB R2020a+

**Interpretación Física:**

**RMS (Root Mean Square):**

- Representa energía de vibración
- Valores típicos rodamiento sano: 0.05-0.15 g
- Valores altos (>0.3 g): desgaste, desbalanceo

**Curtosis:**

- Mide impulsividad de señal
- Distribución normal: Kurt ≈ 3
- Kurt > 5: presencia de impactos (fallas)
- Kurt > 10: falla severa

**Ver también:** [IMS_bearing_diagnosis_main](#ims_bearing_diagnosis_main)

---

## Funciones de Utilidad

### config_example

Genera archivo de configuración con rutas del proyecto.

**Sintaxis:**

```matlab
run('src/utils/config_example.m')
```

**Descripción:**
Crea `config.mat` en la raíz del proyecto con todas las rutas necesarias. Detecta automáticamente la ubicación del proyecto.

**Genera:**

- `config.mat` - Archivo de configuración

**Estructura de config.mat:**

```matlab
config.data_folders = {...}     % Cell array con rutas a datos
config.model_file = '...'       % String con ruta al modelo
config.output_dir = '...'       % String con carpeta de salida
config.verbose = true           % Boolean para mensajes
config.save_figures = true      % Boolean para guardar gráficas
```

**Ejemplo de personalización:**

```matlab
% Editar src/utils/config_example.m líneas 22-26
config.data_folders = {
    'C:\MisDatos\Test1';
    'C:\MisDatos\Test2'
};

% Ejecutar
run('src/utils/config_example.m')
```

---

### check_installation

Verifica que todos los componentes estén instalados correctamente.

**Sintaxis:**

```matlab
run('check_installation.m')
```

**Descripción:**
Realiza 8 verificaciones del sistema:

1. Versión de MATLAB (≥R2020a)
2. Toolboxes requeridos
3. Estructura de carpetas
4. Archivos de código
5. Modelo pre-entrenado
6. Datos del dataset IMS
7. Archivo de configuración
8. Funciones de MATLAB

**Salida:**
Reporte con porcentaje de éxito y estado del sistema.

**Ejemplo de salida:**

```
Total de verificaciones: 20
Pasadas:                 20 ✓
Fallidas:                0 ✗

🎉 ESTADO: SISTEMA COMPLETAMENTE INSTALADO
```

---

### startup_ims

Configura el entorno de MATLAB para el proyecto.

**Sintaxis:**

```matlab
run('startup_ims.m')
```

**Descripción:**
Agrega carpetas necesarias al path de MATLAB y muestra comandos disponibles.

**Acciones:**

- Detecta raíz del proyecto
- Agrega `src/`, `src/utils/`, `examples/` al path
- Verifica funciones principales
- Muestra menú de comandos

**Ejecutar automáticamente:**
Para que se ejecute cada vez que abres MATLAB:

1. Crea `startup.m` en carpeta de usuario MATLAB
2. Agrega línea:

```matlab
run('ruta/completa/a/startup_ims.m')
```

---

## Funciones de Entrenamiento

### prepare_training_data

Prepara dataset etiquetado para entrenamiento.

**Sintaxis:**

```matlab
run('prepare_training_data.m')
```

**Requisitos previos:**

- Archivo `labeled_data.csv` en raíz del proyecto

**Formato de labeled_data.csv:**

```csv
archivo,etiqueta
2003.10.22.12.06.24,normal
2004.02.15.12.52.01,outer_race_fault
```

**Genera:**

- `training_dataset.mat` - Dataset listo
- `training_dataset.csv` - Versión legible
- `training_data_visualization.png` - Gráficas

**Salida (training_dataset.mat):**

```matlab
features    % Matriz [N×6] con características
labels      % Vector [N×1] con etiquetas
training_data  % Tabla con features + labels
```

---

### train_new_model

Entrena un nuevo modelo Random Forest.

**Sintaxis:**

```matlab
run('train_new_model.m')
```

**Requisitos previos:**

- Ejecutar `prepare_training_data.m` primero

**Hiperparámetros configurables (líneas 48-51):**

```matlab
n_trees = 100;              % Número de árboles
min_leaf_size = 5;          % Mínimo muestras por hoja
max_num_splits = [];        % Máximo divisiones ([] = sin límite)
num_variables_to_sample = 'all';  % Variables por división
```

**Genera:**

- `models/ims_modelo_nuevo.mat` - Modelo entrenado
- `models/ims_modelo_especifico_BACKUP.mat` - Backup
- `confusion_matrix.png`
- `feature_importance.png`
- `oob_error_evolution.png`

**Métricas reportadas:**

- Accuracy total
- Error OOB
- Precision/Recall/F1 por clase
- Importancia de características

---

### compare_models

Compara modelo original vs nuevo.

**Sintaxis:**

```matlab
run('compare_models.m')
```

**Requisitos previos:**

- Modelo original: `models/ims_modelo_especifico.mat`
- Modelo nuevo: `models/ims_modelo_nuevo.mat`

**Genera:**

- `model_comparison.png` - Matrices de confusión lado a lado
- Reporte comparativo en consola
- Recomendación automática

**Salida ejemplo:**

```
╔═══════════════════════════════════════════╗
║           COMPARACIÓN DE MÉTRICAS         ║
╚═══════════════════════════════════════════╝

┌─────────────────────────────────────────────┐
│ Métrica              │  Original  │  Nuevo   │
├─────────────────────────────────────────────┤
│ Accuracy             │   94.50%   │  96.80%  │
│ Error OOB            │   5.80%    │  3.50%   │
└─────────────────────────────────────────────┘

✅ MEJORA: +2.30% en accuracy
```

---

## Funciones de Demostración

### demo_01_single_file

Analiza un archivo individual con visualizaciones paso a paso.

**Sintaxis:**

```matlab
run('examples/demo_01_single_file.m')
```

**Descripción:**
Script educativo que muestra TODO el proceso de diagnóstico:

1. Carga de datos
2. Visualización de señales
3. Extracción de características
4. Clasificación
5. Análisis espectral (BONUS)

**Archivo analizado (por defecto):**

```matlab
data_file = fullfile('..', 'data', '1st_test', '2003.10.22.12.06.24');
```

**Personalizar archivo:**
Edita línea 25 del script.

**Genera:**

- Figura 1: Señales triaxiales (3 subplots)
- Figura 2: Espectro de frecuencia
- Reporte completo en consola

**Propósito pedagógico:**
Ideal para clases de Procesos de Fabricación, muestra físicamente cada etapa del diagnóstico.

---

## 📌 Convenciones

### Tipos de Datos

| Tipo          | Descripción               | Ejemplo                           |
| ------------- | ------------------------- | --------------------------------- |
| `double`      | Números de punto flotante | `0.1246`                          |
| `string`      | Cadena de texto           | `"normal"`                        |
| `categorical` | Categoría                 | `categorical("outer_race_fault")` |
| `table`       | Tabla de datos            | `results = table(...)`            |
| `struct`      | Estructura                | `config.data_folders`             |

### Nomenclatura

- **Funciones**: snake_case (`extract_rms_kurtosis`)
- **Variables**: snake_case (`signal_xyz`, `rf_model`)
- **Constantes**: UPPER_CASE (no usadas en este proyecto)

---

## 🗂️ Soporte

Para más información y ayuda:

- [Manual de Usuario](USER_GUIDE.md)
- [Guía de Instalación](INSTALLATION.md)
- [Entrenamiento de Modelo](MODEL_TRAINING.md)
- [Preguntas Frecuentes](FAQ.md)

---

**[⬆ Volver al README principal](../README.md)**
