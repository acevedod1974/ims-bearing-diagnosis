# 📦 Guía de Instalación Completa

Esta guía te llevará paso a paso por la instalación del Sistema de Diagnóstico Predictivo de Rodamientos IMS.

---

## 📋 Requisitos del Sistema

### Software Requerido

| Componente        | Versión Mínima                   | Recomendado           | Notas                                  |
| ----------------- | -------------------------------- | --------------------- | -------------------------------------- |
| MATLAB            | R2020a                           | R2023b+               | Versiones antiguas no soportadas       |
| Sistema Operativo | Windows 10 / macOS 10.14 / Linux | Windows 11 / macOS 14 | Cualquier OS compatible con MATLAB     |
| RAM               | 8 GB                             | 16 GB                 | Para procesamiento de datasets grandes |
| Espacio en Disco  | 5 GB                             | 10 GB                 | Incluye dataset y resultados           |

### MATLAB Toolboxes

**Requeridos:**

- ✅ Statistics and Machine Learning Toolbox

**Opcionales (mejoran funcionalidad):**

- Signal Processing Toolbox (para análisis espectral avanzado)
- Parallel Computing Toolbox (para procesamiento paralelo)

### Verificar Toolboxes Instalados

```matlab
% En MATLAB, ejecuta:
ver

% O verifica toolbox específico:
license('test', 'Statistics_Toolbox')
```

---

## 🔽 Descarga del Proyecto

### Opción 1: Git Clone (Recomendado)

```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/ims-bearing-diagnosis.git

# Navegar al directorio
cd ims-bearing-diagnosis
```

### Opción 2: Descarga Directa

1. Ir a [GitHub Repository](https://github.com/tu-usuario/ims-bearing-diagnosis)
2. Click en **Code** → **Download ZIP**
3. Extraer a ubicación deseada
4. Renombrar carpeta a `ims-bearing-diagnosis`

---

## 📊 Descarga del Dataset IMS

El sistema requiere el dataset IMS Bearing de la NASA.

### Paso 1: Acceder al Repositorio

1. Visita: [NASA PCoE Data Repository](https://www.nasa.gov/content/prognostics-center-of-excellence-data-set-repository)
2. Busca: **"IMS Bearing Dataset"**
3. Descarga el archivo ZIP completo (~1.5 GB)

### Paso 2: Extraer Archivos

```
IMS_Bearing_Dataset.zip
├── 1st_test/        → Extraer a: data/1st_test/
├── 2nd_test/        → Extraer a: data/2nd_test/
└── 3rd_test/        → Extraer a: data/3rd_test/
```

### Paso 3: Verificar Estructura

Tu directorio `data/` debe verse así:

```
data/
├── 1st_test/
│   ├── 2003.10.22.12.06.24
│   ├── 2003.10.22.12.16.24
│   └── ... (2,156 archivos totales)
│
├── 2nd_test/
│   ├── 2004.02.12.10.32.39
│   └── ... (984 archivos totales)
│
└── 3rd_test/
    ├── 2007.11.13.09.02.28
    └── ... (6,324 archivos totales)
```

**Verificación rápida en MATLAB:**

```matlab
% Contar archivos en cada carpeta
n1 = length(dir('data/1st_test/*')) - 2;  % Excluir . y ..
n2 = length(dir('data/2nd_test/*')) - 2;
n3 = length(dir('data/3rd_test/*')) - 2;

fprintf('1st_test: %d archivos\n', n1);  % Esperado: 2156
fprintf('2nd_test: %d archivos\n', n2);  % Esperado: 984
fprintf('3rd_test: %d archivos\n', n3);  % Esperado: 6324
```

---

## 🔧 Instalación del Sistema

### Paso 1: Abrir MATLAB

Abre MATLAB y navega al directorio del proyecto:

```matlab
cd('C:\Users\TuUsuario\ims-bearing-diagnosis')
% O en macOS/Linux:
% cd('/home/usuario/ims-bearing-diagnosis')
```

### Paso 2: Configurar Entorno

Ejecuta el script de inicio:

```matlab
run('startup_ims.m')
```

**Resultado esperado:**

```
╔═══════════════════════════════════════════════════╗
║   Sistema de Diagnóstico de Rodamientos IMS      ║
║            Configurando entorno...               ║
╚═══════════════════════════════════════════════════╝

✓ Navegado a raíz: C:\Users\...\ims-bearing-diagnosis

Agregando al path de MATLAB:
  ✓ src
  ✓ src\utils
  ✓ examples

✅ Sistema listo para usar
```

### Paso 3: Verificar Instalación

```matlab
run('check_installation.m')
```

**Deberías ver:**

```
╔═══════════════════════════════════════════════════╗
║  VERIFICACIÓN DE INSTALACIÓN - SISTEMA IMS       ║
╚═══════════════════════════════════════════════════╝

1️⃣  Verificando versión de MATLAB...
   ✓ Compatible (R2020a o superior)

2️⃣  Verificando toolboxes requeridos...
   ✓ Statistics and Machine Learning Toolbox

...

Total de verificaciones: 20
Pasadas:                 20 ✓
Fallidas:                0 ✗

🎉 ESTADO: SISTEMA COMPLETAMENTE INSTALADO
```

### Paso 4: Generar Configuración

```matlab
run('src/utils/config_example.m')
```

Esto crea `config.mat` con las rutas correctas.

---

## ✅ Verificación Final

### Prueba Rápida

Ejecuta el demo para verificar que todo funciona:

```matlab
run('examples/demo_01_single_file.m')
```

**Resultado esperado:**

- 3 gráficas de señales de vibración
- Tabla de características extraídas
- Diagnóstico con confianza >95%
- Gráfica de espectro de frecuencia

---

## 🚨 Solución de Problemas

### Problema 1: "Toolbox not found"

**Error:**

```
Error: Statistics and Machine Learning Toolbox is required
```

**Solución:**

1. Abre MATLAB
2. Ir a **Home** → **Add-Ons** → **Get Add-Ons**
3. Buscar "Statistics and Machine Learning Toolbox"
4. Instalar

### Problema 2: "Data folder not found"

**Error:**

```
✗ data\1st_test (NO ENCONTRADA)
```

**Solución:**

1. Verifica que descargaste el dataset IMS
2. Extrae los archivos en las carpetas correctas
3. Ejecuta nuevamente `config_example.m`

### Problema 3: "Model file not found"

**Error:**

```
✗ models\ims_modelo_especifico.mat (NO ENCONTRADO)
```

**Solución:**

1. Verifica que el archivo `ims_modelo_especifico.mat` existe en `models/`
2. Si no existe, necesitas entrenarlo o descargarlo
3. Ver: [docs/MODEL_TRAINING.md](MODEL_TRAINING.md)

### Problema 4: Función no encontrada

**Error:**

```
'IMS_bearing_diagnosis_main' is not found in the current folder
```

**Solución:**

```matlab
% Agregar carpetas al path
addpath('src');
addpath('src/utils');

% O ejecutar startup_ims.m nuevamente
run('startup_ims.m')
```

### Problema 5: Warnings de Waitbar (Windows)

**Warning:**

```
Warning: Error updating Text. String scalar or character vector...
```

**Solución:**

- Estos warnings NO afectan el funcionamiento
- El sistema continúa procesando correctamente
- Para eliminarlos, descarga la versión corregida:
  - `IMS_bearing_diagnosis_main_FIXED.m` de Recursos

---

## 🔄 Actualización del Sistema

### Actualizar desde Git

```bash
# Guardar cambios locales
git stash

# Actualizar repositorio
git pull origin main

# Restaurar cambios locales (si los hay)
git stash pop
```

### Actualizar Manualmente

1. Descarga la última versión de GitHub
2. Reemplaza archivos en `src/`
3. **NO reemplaces:** `config.mat`, `models/`, `data/`
4. Ejecuta `check_installation.m` para verificar

---

## 📂 Estructura Post-Instalación

Después de una instalación exitosa, tu proyecto debe verse así:

```
ims-bearing-diagnosis/
├── ✅ data/                    (9,464 archivos totales)
├── ✅ models/                  (modelo .mat presente)
├── ✅ src/                     (código fuente)
├── ✅ examples/                (demos)
├── ✅ docs/                    (documentación)
├── ✅ results/                 (carpeta vacía, se llenará)
├── ✅ config.mat               (configuración generada)
├── ✅ startup_ims.m
├── ✅ check_installation.m
└── ✅ README.md
```

---

## 🎯 Próximos Pasos

Instalación completa ✅ → Ahora puedes:

1. **Ejecutar el demo**: `run('examples/demo_01_single_file.m')`
2. **Leer el manual**: [docs/USER_GUIDE.md](USER_GUIDE.md)
3. **Procesar dataset completo**: `IMS_bearing_diagnosis_main()`
4. **Entrenar modelo personalizado**: [docs/MODEL_TRAINING.md](MODEL_TRAINING.md)

---

## 📞 Soporte

Si tienes problemas con la instalación:

1. Revisa esta guía completa
2. Consulta la sección [Preguntas Frecuentes](FAQ.md)
3. Abre un issue en GitHub
4. Contacta: dacevedo@unexpo.edu.ve

---

**[⬆ Volver al README principal](../README.md)**
