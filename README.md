# 🔧 Sistema de Diagnóstico Predictivo de Rodamientos IMS

<div align="center">

![MATLAB](https://img.shields.io/badge/MATLAB-R2020a+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-active-success.svg)

**Sistema inteligente de mantenimiento predictivo para rodamientos industriales usando Machine Learning**

[Características](#-características-principales) •
[Instalación](#-instalación-rápida) •
[Uso](#-uso) •
[Documentación](#-documentación) •
[Contribuir](#-contribuir)

</div>

---

## 📋 Descripción

Sistema de diagnóstico automático para detección temprana de fallas en rodamientos utilizando análisis de señales de vibración triaxiales y clasificación con Random Forest. Diseñado para aplicaciones industriales de mantenimiento predictivo.

### 🎯 Objetivo

Predecir y clasificar el estado de salud de rodamientos industriales mediante análisis de vibraciones, permitiendo:
- ✅ Detección temprana de fallas
- ✅ Reducción de paradas no programadas
- ✅ Optimización de costos de mantenimiento
- ✅ Extensión de vida útil de equipos

---

## ⚡ Características Principales

### 🔬 Análisis Técnico
- **Extracción de características estadísticas**: RMS y Curtosis triaxiales
- **Clasificación inteligente**: Random Forest con validación cruzada
- **Procesamiento batch**: Análisis de miles de archivos automáticamente
- **Código vectorizado**: Optimizado para máximo rendimiento

### 📊 Visualizaciones
- Distribución de confianza de predicciones
- Gráficas de características en espacio 2D/3D
- Box plots por canal y característica
- Análisis espectral (FFT) de señales

### 🎓 Valor Pedagógico
- Scripts de demostración interactivos
- Documentación técnica completa en español
- Ejemplos paso a paso para enseñanza
- Interpretación física de resultados

---

## 🚀 Instalación Rápida

### Requisitos

- **MATLAB**: R2020a o superior
- **Toolboxes requeridos**:
  - Statistics and Machine Learning Toolbox
- **Dataset**: IMS Bearing Dataset (NASA)
- **Espacio en disco**: ~2 GB (con dataset completo)

### Pasos de Instalación

```bash
# 1. Clonar repositorio
git clone https://github.com/tu-usuario/ims-bearing-diagnosis.git
cd ims-bearing-diagnosis

# 2. Abrir MATLAB y navegar al directorio
cd('ruta/a/ims-bearing-diagnosis')

# 3. Configurar entorno
run('startup_ims.m')

# 4. Verificar instalación
run('check_installation.m')

# 5. Generar configuración
run('src/utils/config_example.m')
```

### Descarga del Dataset IMS

El dataset IMS está disponible en el repositorio de la NASA:

1. Visita: [NASA PCoE Data Repository](https://www.nasa.gov/content/prognostics-center-of-excellence-data-set-repository)
2. Descarga: **IMS Bearing Dataset**
3. Extrae los archivos en las carpetas:
   - `data/1st_test/` (2,156 archivos)
   - `data/2nd_test/` (984 archivos)
   - `data/3rd_test/` (6,324 archivos)

---

## 💻 Uso

### Demo Rápido (5 minutos)

Analiza un archivo individual con visualizaciones paso a paso:

```matlab
% Configurar entorno
run('startup_ims.m')

% Ejecutar demo interactivo
run('examples/demo_01_single_file.m')
```

**Resultado:** Visualización completa del proceso de diagnóstico para un archivo.

### Procesamiento Completo (~2 horas)

Procesa todo el dataset IMS (9,464 archivos):

```matlab
% Ejecutar sistema completo
IMS_bearing_diagnosis_main()
```

**Resultado:** 
- CSV con diagnósticos: `results/resultados_diagnostico.csv`
- 3 gráficas PNG de análisis
- Reporte estadístico completo

### Procesamiento Personalizado

```matlab
% Modificar configuración
config = load('config.mat');
config.data_folders = {fullfile('data', '1st_test')}; % Solo una carpeta
save('config_custom.mat', '-struct', 'config');

% Ejecutar con configuración personalizada
IMS_bearing_diagnosis_main('config_custom.mat')
```

---

## 📊 Resultados Típicos

### Métricas de Rendimiento

| Métrica | Valor |
|---------|-------|
| Accuracy | 94-98% |
| Precision (normal) | 97-99% |
| Recall (outer_race_fault) | 92-96% |
| Tiempo por archivo | ~0.8 seg |

### Características Extraídas

- **RMS (Root Mean Square)**: Energía de vibración en cada eje
- **Curtosis (Kurtosis)**: Detección de impulsividad (fallas localizadas)

**Interpretación física:**
- RMS elevado → Desgaste general, desbalanceo
- Curtosis > 5 → Impactos repetitivos (grietas, fallas localizadas)

---

## 📁 Estructura del Proyecto

```
ims-bearing-diagnosis/
│
├── data/                          # Datos del dataset IMS
│   ├── 1st_test/                  # Experimento 1 (2,156 archivos)
│   ├── 2nd_test/                  # Experimento 2 (984 archivos)
│   └── 3rd_test/                  # Experimento 3 (6,324 archivos)
│
├── models/                        # Modelos entrenados
│   └── ims_modelo_especifico.mat  # Random Forest pre-entrenado
│
├── src/                           # Código fuente
│   ├── IMS_bearing_diagnosis_main.m    # Script principal
│   ├── extract_rms_kurtosis.m          # Extracción de características
│   └── utils/
│       └── config_example.m            # Configuración
│
├── examples/                      # Scripts de demostración
│   └── demo_01_single_file.m      # Demo interactivo
│
├── docs/                          # Documentación
│   ├── INSTALLATION.md            # Guía de instalación
│   ├── USER_GUIDE.md              # Manual de usuario
│   ├── API_REFERENCE.md           # Referencia de funciones
│   └── MEJORAS_IMPLEMENTADAS.md   # Historial de mejoras
│
├── results/                       # Resultados generados
│
├── config.mat                     # Configuración activa
├── startup_ims.m                  # Script de inicio
├── check_installation.m           # Verificación de instalación
└── README.md                      # Este archivo
```

---

## 🎓 Aplicaciones Educativas

### Para Cursos de Procesos de Fabricación

Este sistema es ideal para enseñar:

1. **Mantenimiento Predictivo**: Conceptos de CBM (Condition-Based Maintenance)
2. **Análisis de Vibraciones**: Interpretación física de señales
3. **Machine Learning Industrial**: Aplicación práctica de Random Forest
4. **Procesamiento de Señales**: FFT, RMS, estadísticos de orden superior

### Ejercicios Propuestos

- **Ejercicio 1**: Comparar señales de rodamiento sano vs fallado
- **Ejercicio 2**: Entrenar modelo con nuevas clases de fallas
- **Ejercicio 3**: Optimizar hiperparámetros del Random Forest
- **Ejercicio 4**: Agregar nuevas características (envolvente, cepstrum)

---

## 🔧 Modificar el Modelo

### Agregar Nuevas Clases de Fallas

```matlab
% 1. Crear CSV con etiquetas
% labeled_data.csv:
% archivo,etiqueta
% 2003.10.22.12.06.24,normal
% 2004.02.15.12.52.01,outer_race_fault
% 2004.02.17.08.02.38,inner_race_fault

% 2. Preparar datos
run('prepare_training_data.m')

% 3. Entrenar nuevo modelo
run('train_new_model.m')

% 4. Comparar con modelo anterior
run('compare_models.m')

% 5. Implementar si es mejor
movefile('models/ims_modelo_nuevo.mat', ...
         'models/ims_modelo_especifico.mat', 'f');
```

**Ver documentación completa:** [docs/MODEL_TRAINING.md](docs/MODEL_TRAINING.md)

---

## 📚 Documentación

- **[Guía de Instalación](docs/INSTALLATION.md)**: Instalación paso a paso
- **[Manual de Usuario](docs/USER_GUIDE.md)**: Guía completa de uso
- **[Referencia de API](docs/API_REFERENCE.md)**: Documentación de funciones
- **[Entrenar Modelo](docs/MODEL_TRAINING.md)**: Guía de reentrenamiento
- **[Mejoras Implementadas](docs/MEJORAS_IMPLEMENTADAS.md)**: Historial de cambios

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

**Ver guía completa:** [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**Daniel Acevedo Lopez**  
UNEXPO - Departamento de Ingenieria Mecacnica 

---

## 🙏 Agradecimientos

- **NASA**: Por el dataset IMS Bearing
- **UNEXPO**: Por el apoyo en investigación
- **Comunidad MATLAB**: Por recursos y documentación

---

## 📧 Contacto

¿Preguntas? ¿Sugerencias?

- 📧 Email: dacevedo@unexpo.edu.ve
- 🐙 GitHub: [@tu-usuario](https://github.com/acevedod1974)
- 💼 LinkedIn: [Tu Perfil](https://linkedin.com/in/acevedod1974)

---

## 📊 Estadísticas del Proyecto

- **Archivos procesables**: 9,464
- **Clases de fallas**: 2 (expandible)
- **Características extraídas**: 6 por archivo
- **Velocidad de procesamiento**: ~0.8 seg/archivo
- **Accuracy del modelo**: 94-98%

---

<div align="center">

**[⬆ Volver arriba](#-sistema-de-diagnóstico-predictivo-de-rodamientos-ims)**

Desarrollado para la comunidad de Ingeniería Mecánica de la UNEXPO PZO

</div>
