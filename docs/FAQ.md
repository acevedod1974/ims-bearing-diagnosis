# ❓ Preguntas Frecuentes (FAQ) - Sistema IMS

---

## 1. ¿Qué hago si el modelo no se encuentra?

- Verifica que `models/ims_modelo_especifico.mat` existe.
- Si no existe, sigue la [Guía de Entrenamiento](MODEL_TRAINING.md) para generarlo.

## 2. ¿Cómo agrego mis propios datos?

- Coloca tus archivos en `data/` y usa la plantilla `labeled_data_example.csv`.
- Sigue la guía de entrenamiento para procesarlos.

## 3. ¿Por qué recibo el error 'Función no encontrada'?

- Asegúrate de ejecutar `startup_ims.m` para agregar las carpetas al path.
- Usa `addpath('src'); addpath('src/utils');` si es necesario.

## 4. ¿Cómo verifico la instalación?

- Ejecuta `run('check_installation.m')` para comprobar dependencias y rutas.

## 5. ¿Dónde encuentro ejemplos de uso?

- Revisa `examples/demo_01_single_file.m` y el [Manual de Usuario](USER_GUIDE.md).

## 6. ¿Cómo obtengo soporte?

- Consulta la documentación, abre un issue en GitHub o escribe a dacevedo@unexpo.edu.ve.

## 7. ¿Cómo reentreno el modelo?

- Sigue la [Guía de Entrenamiento](MODEL_TRAINING.md).

## 8. ¿Qué hago si aparecen warnings de waitbar?

- Son comunes en Windows, no afectan el funcionamiento.

---

**[⬆ Volver al README principal](../README.md)**
