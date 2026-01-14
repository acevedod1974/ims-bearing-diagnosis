# 🏋️‍♂️ Guía de Entrenamiento de Modelo IMS

Esta guía explica cómo reentrenar el modelo de diagnóstico predictivo de rodamientos IMS usando tus propios datos.

---

## 📋 Requisitos Previos

- MATLAB R2020a o superior
- Dataset IMS descargado y etiquetado
- Scripts del sistema en `src/`

## 🗂️ Preparar Datos de Entrenamiento

1. Organiza tus archivos en carpetas por clase dentro de `data/`.
2. Usa la plantilla `templates/labeled_data_example.csv` para etiquetar los archivos.
3. Ejecuta:
   ```matlab
   run('prepare_training_data.m')
   ```
   Esto genera la tabla de datos para entrenamiento.

## 🏋️‍♂️ Entrenar un Nuevo Modelo

1. Ejecuta:
   ```matlab
   run('train_new_model.m')
   ```
2. El script entrenará un Random Forest y guardará el modelo en `models/ims_modelo_especifico.mat`.
3. Revisa métricas de desempeño (accuracy, error OOB, F1-score).

## 🔬 Comparar Modelos

1. Para comparar el modelo actual con uno nuevo:
   ```matlab
   run('compare_models.m')
   ```
2. Se mostrarán las métricas lado a lado.

## 🧑‍🔬 Inspeccionar el Modelo

- Usa:
  ```matlab
  run('inspect_current_model.m')
  ```
  para ver detalles del modelo entrenado.

## 📝 Notas

- Puedes modificar los scripts para probar otros clasificadores (SVM, KNN).
- Si agregas nuevas características, reentrena el modelo.

## 📚 Referencias

- [Referencia de API](API_REFERENCE.md)
- [Manual de Usuario](USER_GUIDE.md)
- [Guía de Instalación](INSTALLATION.md)

---

**[⬆ Volver al README principal](../README.md)**
