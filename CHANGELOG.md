# 📝 CHANGELOG

Todos los cambios notables en este proyecto serán documentados aquí.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto adhiere a [Versionado Semántico](https://semver.org/lang/es/).

---

## [1.2.0] - 2026-01-14

### ✨ Agregado
- **Herramientas de reentrenamiento de modelo**:
  - `prepare_training_data.m` - Preparación de datasets etiquetados
  - `train_new_model.m` - Entrenamiento de Random Forest
  - `compare_models.m` - Comparación de modelos
  - `inspect_current_model.m` - Inspección de modelo actual
  - Plantilla `labeled_data_example.csv`

- **Documentación completa**:
  - README.md principal con badges y estructura profesional
  - INSTALLATION.md con guía paso a paso
  - USER_GUIDE.md con casos de uso detallados
  - API_REFERENCE.md con documentación de funciones
  - MODEL_TRAINING.md con guía de reentrenamiento
  - CONTRIBUTING.md con guías para colaboradores
  - Este CHANGELOG.md

- **Scripts de verificación**:
  - `check_installation.m` - Verificación completa del sistema
  - `startup_ims.m` - Configuración automática del entorno

### 🔧 Mejorado
- Optimización de vectorización en `extract_rms_kurtosis.m`
- Mejor manejo de errores con try-catch
- Validación de inputs con `validateattributes`
- Mensajes de progreso más informativos
- Compatibilidad con MATLAB R2020a-R2024b

### 🐛 Corregido
- Fix warnings de Waitbar en Windows (`IMS_bearing_diagnosis_main_FIXED.m`)
- Corrección de manejo de archivos vacíos
- Fix en cálculo de curtosis para señales con varianza muy baja

### 📚 Documentado
- Interpretación física de características (RMS, Curtosis)
- Ejemplos de uso avanzado
- Troubleshooting común
- Guías pedagógicas para docentes

---

## [1.1.0] - 2025-12-10

### ✨ Agregado
- **Análisis espectral (FFT)** en `demo_01_single_file.m`
- **Gráficas mejoradas**:
  - Box plots de características por canal
  - Distribución de características por clase
  - Histograma de confianza de predicciones

- **Exportación de resultados**:
  - CSV con todos los diagnósticos
  - MAT con tabla completa
  - PNG con gráficas de análisis

### 🔧 Mejorado
- Rendimiento: procesamiento 30% más rápido
- Uso de memoria reducido en ~40%
- Progress bar actualizada cada 50 archivos (antes cada archivo)

### 📚 Documentado
- Comentarios en español en todo el código
- Headers de funciones con formato help
- Ejemplos de uso en cada función

---

## [1.0.0] - 2025-10-15

### ✨ Inicial
- **Sistema base de diagnóstico**:
  - Extracción de RMS y Curtosis triaxiales
  - Clasificación con Random Forest
  - Procesamiento batch de dataset IMS

- **Modelo pre-entrenado**:
  - 2 clases: `normal`, `outer_race_fault`
  - Accuracy: 94-98%
  - Entrenado con 1,500 archivos etiquetados

- **Demo interactivo**:
  - `demo_01_single_file.m` - Análisis de archivo individual
  - Visualizaciones paso a paso

- **Configuración**:
  - `config_example.m` - Generación de configuración
  - Rutas automáticas relativas al proyecto

---

## Tipos de Cambios

- **✨ Agregado**: Nueva funcionalidad
- **🔧 Mejorado**: Cambio en funcionalidad existente
- **🐛 Corregido**: Corrección de bugs
- **🗑️ Eliminado**: Funcionalidad removida
- **📚 Documentado**: Cambios en documentación
- **🔒 Seguridad**: Correcciones de seguridad

---

## [Roadmap] - Próximas Versiones

### [1.3.0] - Planeado para Q1 2026
- [ ] Procesamiento paralelo con parfor
- [ ] Detección automática de frecuencias de falla (BPFO, BPFI, BSF, FTF)
- [ ] Análisis de envolvente espectral
- [ ] Tests unitarios automatizados

### [2.0.0] - Planeado para Q2 2026
- [ ] Interfaz gráfica (App Designer)
- [ ] Clasificación multi-clase (4+ tipos de fallas)
- [ ] Deep Learning con LSTM/CNN
- [ ] Dashboard web con resultados en tiempo real

### Ideas Futuras
- [ ] Versión Python (scikit-learn/TensorFlow)
- [ ] API REST para diagnóstico en línea
- [ ] Integración con sistemas SCADA
- [ ] Deployment en edge devices (Raspberry Pi)

---

## Versionado

Formato: `MAJOR.MINOR.PATCH`

- **MAJOR**: Cambios incompatibles con versión anterior
- **MINOR**: Nueva funcionalidad compatible con versión anterior
- **PATCH**: Correcciones de bugs compatibles

---

**[⬆ Volver al README principal](README.md)**
