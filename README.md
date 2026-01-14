# 🔧 Sistema de Diagnóstico Predictivo de Fallas en Rodamientos

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Dataset](https://img.shields.io/badge/Dataset-IMS_Bearing-orange.svg)](https://www.nasa.gov/intelligent-systems-division/)

Sistema automatizado de diagnóstico de fallas en rodamientos mediante análisis de vibraciones usando **Machine Learning** (Random Forest) y el dataset **IMS Bearing** de la NASA.

---

## 📋 Descripción

Este proyecto implementa un **sistema de mantenimiento predictivo** para rodamientos industriales basado en análisis de señales de vibración. Utiliza técnicas de aprendizaje automático para clasificar el estado del rodamiento (normal, falla temprana, falla avanzada) a partir de características extraídas de señales triaxiales.

### Aplicaciones
- Mantenimiento predictivo en maquinaria industrial
- Detección temprana de fallas en rodamientos
- Reducción de tiempos de parada no programados
- Optimización de costos de mantenimiento

---

## ✨ Características

- ✅ **Procesamiento automatizado** de datasets IMS
- ✅ **Extracción de características** estadísticas (RMS, Curtosis)
- ✅ **Clasificación con Random Forest** pre-entrenado
- ✅ **Análisis de confianza** de predicciones
- ✅ **Visualizaciones automáticas** de resultados
- ✅ **Reportes estadísticos** detallados
- ✅ **Compatible con MATLAB R2020a+**
- ✅ **Código modular y documentado**

---

## 📦 Requisitos

### Software
- **MATLAB R2020a o superior**
- **Statistics and Machine Learning Toolbox**

### Hardware (Recomendado)
- RAM: 8 GB mínimo
- Procesador: Intel i5 o equivalente
- Espacio en disco: 500 MB para datos

---

## 🚀 Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/ims-bearing-diagnosis.git
cd ims-bearing-diagnosis
```

### 2. Descargar el dataset IMS
Descarga el [IMS Bearing Dataset](https://www.nasa.gov/intelligent-systems-division/) y extrae los archivos en la carpeta `data/`:

```
data/
├── 1st_test/
├── 2nd_test/
└── 3rd_test/
```

### 3. Configurar rutas
Edita el archivo `config_example.m` y guárdalo como `config.mat`:

```matlab
% Ejecutar config_example.m para generar config.mat
run('config_example.m');
```

---

## 💻 Uso

### Ejecución Básica
```matlab
% En la carpeta del proyecto
IMS_bearing_diagnosis_main();
```

### Ejecución con Configuración Personalizada
```matlab
% Crear configuración personalizada
config.data_folders = {'ruta/a/tus/datos'};
config.model_file = 'models/mi_modelo.mat';
config.output_dir = 'mis_resultados';
save('mi_config.mat', '-struct', 'config');

% Ejecutar
IMS_bearing_diagnosis_main('mi_config.mat');
```

### Ejemplo de Uso de Funciones Individuales
```matlab
% Cargar señal
data = readmatrix('data/1st_test/archivo.txt');
signal = data(:,1:3);

% Extraer características
features = extract_rms_kurtosis(signal);

% Cargar modelo y predecir
load('models/ims_modelo_especifico.mat');
[prediccion, confianza] = predict(rf_ims, features);
```

---

## 📁 Estructura del Proyecto

```
ims-bearing-diagnosis/
│
├── README.md                          # Este archivo
├── LICENSE                            # Licencia MIT
├── .gitignore                         # Archivos ignorados
│
├── src/                               # Código fuente
│   ├── IMS_bearing_diagnosis_main.m  # Script principal
│   ├── extract_rms_kurtosis.m        # Extracción de características
│   └── config_example.m              # Configuración de ejemplo
│
├── models/                            # Modelos entrenados
│   └── ims_modelo_especifico.mat     # Modelo Random Forest
│
├── data/                              # Datasets (no incluido)
│   ├── 1st_test/
│   ├── 2nd_test/
│   └── 3rd_test/
│
├── results/                           # Resultados generados
│   ├── resultados_diagnostico.csv
│   └── *.png
│
└── docs/                              # Documentación
    ├── RESUMEN_EJECUTIVO.md
    ├── paper_draft.md
    └── MEJORAS.md
```

---

## 🔬 Metodología

### 1. Adquisición de Datos
Dataset IMS con señales de vibración hasta la falla.

### 2. Extracción de Características

#### RMS (Root Mean Square)
```
RMS = sqrt(1/N * Σ(x_i²))
```
Indica la energía de la vibración. Aumenta con el deterioro.

#### Curtosis
```
Kurt = (1/N * Σ((x_i - μ)/σ)⁴)
```
Mide la "puntiagudez". Sensible a impactos por fallas.

### 3. Clasificación
- **Algoritmo:** Random Forest
- **Características:** 6 features (RMS y Curtosis en X, Y, Z)
- **Salida:** Clase de falla + confianza

---

## 📊 Resultados

El sistema genera:
1. **Tabla CSV** con todas las predicciones
2. **Histograma** de distribución de confianza
3. **Gráficos de dispersión** de características
4. **Box plots** por clase de falla
5. **Reporte estadístico** en consola

### Métricas Típicas
- **Confianza promedio:** >85%
- **Tiempo de procesamiento:** <1 segundo por archivo

---

## 🤝 Contribuir

Las contribuciones son bienvenidas:

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📚 Referencias

1. **Dataset:** [NASA IMS Bearing Dataset](https://www.nasa.gov/content/prognostics-center-of-excellence-data-set-repository)
2. **Random Forest:** Breiman, L. (2001). Random Forests. Machine Learning, 45(1), 5-32.
3. **Mantenimiento Predictivo:** Lee, J., et al. (2014). Prognostics and health management design

---

## 📄 Licencia

Licencia MIT. Ver archivo `LICENSE` para detalles.

---

## 👤 Autor

**[Tu Nombre]**
- GitHub: [@tu-usuario](https://github.com/tu-usuario)
- Email: tu-email@example.com

---

⭐ **Si este proyecto te fue útil, dale una estrella en GitHub**
