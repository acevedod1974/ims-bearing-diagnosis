# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir al Sistema de Diagnóstico de Rodamientos IMS!

---

## 📋 Formas de Contribuir

Puedes contribuir de varias maneras:

### 🐛 Reportar Bugs
- Usa el [Issue Tracker](https://github.com/tu-usuario/ims-bearing-diagnosis/issues)
- Incluye pasos para reproducir
- Especifica tu versión de MATLAB y OS
- Adjunta logs o screenshots

### ✨ Sugerir Mejoras
- Abre un Issue con label `enhancement`
- Describe el caso de uso
- Explica el beneficio esperado

### 📝 Mejorar Documentación
- Corregir errores
- Agregar ejemplos
- Traducir a otros idiomas
- Mejorar claridad

### 💻 Contribuir Código
- Nuevas características (features)
- Algoritmos de extracción de características
- Mejoras de rendimiento
- Tests

---

## 🚀 Proceso de Contribución

### 1. Fork del Repositorio

```bash
# Haz fork desde GitHub UI
# Luego clona tu fork
git clone https://github.com/TU-USUARIO/ims-bearing-diagnosis.git
cd ims-bearing-diagnosis

# Agrega upstream
git remote add upstream https://github.com/ORIGINAL-USUARIO/ims-bearing-diagnosis.git
```

### 2. Crea una Rama

```bash
# Sincroniza con upstream
git fetch upstream
git checkout main
git merge upstream/main

# Crea rama para tu feature
git checkout -b feature/mi-nueva-caracteristica
```

**Nomenclatura de ramas:**
- `feature/nombre` - Nueva funcionalidad
- `bugfix/nombre` - Corrección de bug
- `docs/nombre` - Cambios en documentación
- `refactor/nombre` - Refactorización de código

### 3. Desarrolla tu Contribución

#### Estándares de Código

**Estilo MATLAB:**
```matlab
% BIEN: Funciones documentadas
function features = extract_features(signal)
% EXTRACT_FEATURES Extrae características de señal
%
%   features = EXTRACT_FEATURES(signal) calcula RMS y curtosis
%
%   Inputs:
%       signal - Matriz [N×3] con señales X, Y, Z
%
%   Outputs:
%       features - Vector [1×6] con [RMS_X, RMS_Y, RMS_Z, Kurt_X, Kurt_Y, Kurt_Z]
%
%   Example:
%       data = readmatrix('archivo.txt');
%       features = extract_features(data(:,1:3));

    % Validaciones
    validateattributes(signal, {'double'}, {'2d', 'ncols', 3});

    % Cálculos vectorizados
    rms_vals = sqrt(mean(signal.^2, 1));
    kurt_vals = kurtosis(signal, 1, 1);

    % Resultado
    features = [rms_vals, kurt_vals];
end
```

**Convenciones:**
- ✅ Nombres descriptivos: `extract_rms_kurtosis` no `func1`
- ✅ Comentarios en español para código didáctico
- ✅ Vectorización sobre bucles cuando sea posible
- ✅ Validación de inputs con `validateattributes`
- ✅ Documentación en header de función

**Evitar:**
- ❌ Variables de una letra (excepto `i`, `j` en loops cortos)
- ❌ Código duplicado
- ❌ Warnings sin resolver
- ❌ Paths hardcoded

#### Testing

Prueba tu código antes de enviar:

```matlab
% 1. Verificación básica
run('check_installation.m')

% 2. Ejecutar demo
run('examples/demo_01_single_file.m')

% 3. Si modificaste extracción de características:
signal = rand(1000, 3);
features = extract_rms_kurtosis(signal);
assert(length(features) == 6, 'Debe retornar 6 características');
```

### 4. Commit y Push

```bash
# Agrega cambios
git add .

# Commit con mensaje descriptivo
git commit -m "feat: agregar extracción de envolvente espectral

- Implementa análisis de envolvente Hilbert
- Agrega función envelope_spectrum.m
- Incluye ejemplo en demo_02_envelope.m
- Actualiza documentación API"

# Push a tu fork
git push origin feature/mi-nueva-caracteristica
```

**Formato de mensajes de commit:**
```
<tipo>: <descripción corta>

<descripción detallada>
- Punto 1
- Punto 2
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato (sin cambio de funcionalidad)
- `refactor`: Refactorización
- `test`: Agregar tests
- `chore`: Mantenimiento

### 5. Abre Pull Request

1. Ve a tu fork en GitHub
2. Click "Compare & pull request"
3. Completa el template:

```markdown
## Descripción
Breve descripción de los cambios.

## Tipo de cambio
- [ ] Bug fix
- [ ] Nueva funcionalidad
- [ ] Breaking change
- [ ] Documentación

## ¿Cómo se probó?
Describe los tests realizados.

## Checklist
- [ ] Mi código sigue el estilo del proyecto
- [ ] He agregado comentarios (especialmente en partes complejas)
- [ ] He actualizado la documentación
- [ ] Mis cambios no generan warnings nuevos
- [ ] He agregado tests si corresponde
- [ ] Todos los tests pasan
```

---

## 📝 Guías Específicas

### Agregar Nueva Característica de Señal

Ejemplo: Agregar cálculo de crest factor.

**1. Crear función:**

```matlab
% src/extract_crest_factor.m
function cf = extract_crest_factor(signal)
% EXTRACT_CREST_FACTOR Calcula factor de cresta de señal
%
%   cf = EXTRACT_CREST_FACTOR(signal) calcula peak/RMS
%
%   Inputs:
%       signal - Matriz [N×3] con señales X, Y, Z
%
%   Outputs:
%       cf - Vector [1×3] con crest factor de cada canal

    validateattributes(signal, {'double'}, {'2d', 'ncols', 3});

    peak_vals = max(abs(signal), [], 1);
    rms_vals = sqrt(mean(signal.^2, 1));
    cf = peak_vals ./ rms_vals;
end
```

**2. Integrar en sistema:**

Modificar `extract_rms_kurtosis.m` para incluir CF:

```matlab
function features = extract_all_features(signal_xyz)
    rms = sqrt(mean(signal_xyz.^2, 1));
    kurt = kurtosis(signal_xyz, 1, 1);
    cf = extract_crest_factor(signal_xyz);
    features = [rms, kurt, cf];  % Ahora retorna 9 características
end
```

**3. Actualizar documentación:**
- Modificar API_REFERENCE.md
- Actualizar README.md
- Agregar ejemplo en demo

**4. Reentrenar modelo:**
```matlab
run('prepare_training_data.m')  % Con nuevas características
run('train_new_model.m')
```

### Agregar Nuevo Tipo de Gráfica

Ejemplo: Agregar waterfall plot de características vs tiempo.

```matlab
% src/utils/plot_waterfall.m
function plot_waterfall(results_table)
% PLOT_WATERFALL Genera waterfall de evolución temporal

    dates = datetime(results_table.Archivo, ...
                     'InputFormat', 'yyyy.MM.dd.HH.mm.ss');

    figure('Position', [100, 100, 1200, 600]);

    subplot(2,1,1);
    plot(dates, results_table.RMS_Z, 'LineWidth', 1.5);
    ylabel('RMS Z (g)');
    title('Evolución RMS');
    grid on;

    subplot(2,1,2);
    plot(dates, results_table.Kurt_Z, 'LineWidth', 1.5, 'Color', [0.8 0.2 0.2]);
    ylabel('Curtosis Z');
    xlabel('Fecha');
    title('Evolución Curtosis');
    grid on;

    % Guardar
    saveas(gcf, 'results/waterfall_plot.png');
    fprintf('✓ Gráfica guardada: waterfall_plot.png\n');
end
```

---

## 🔍 Review Process

Los Pull Requests serán revisados considerando:

1. **Funcionalidad**: ¿Resuelve el problema?
2. **Calidad de código**: ¿Sigue estándares?
3. **Documentación**: ¿Está documentado?
4. **Tests**: ¿Fue probado?
5. **Breaking changes**: ¿Mantiene compatibilidad?

**Tiempo de revisión:** 1-7 días típicamente.

---

## 🎯 Ideas para Contribuir

### Features Sugeridas

**Prioridad Alta:**
- [ ] Procesamiento paralelo con `parfor`
- [ ] Interfaz gráfica (App Designer)
- [ ] Exportación a otros formatos (Excel, JSON)
- [ ] Tests unitarios automatizados

**Prioridad Media:**
- [ ] Análisis de envolvente espectral
- [ ] Detección de frecuencias de falla (BPFO, BPFI)
- [ ] Filtrado adaptativo de señales
- [ ] Clustering de patrones de falla

**Prioridad Baja:**
- [ ] Integración con bases de datos SQL
- [ ] API REST para diagnóstico en línea
- [ ] Versión Python del extractor
- [ ] Dashboard web con resultados

### Mejoras de Documentación

- [ ] Video tutorial en YouTube
- [ ] Traducción a inglés
- [ ] Casos de estudio detallados
- [ ] Comparación con otros métodos (SVM, CNN)

---

## 📧 Contacto

¿Dudas sobre cómo contribuir?

- 💬 Abre un [Discussion](https://github.com/tu-usuario/ims-bearing-diagnosis/discussions)
- 📧 Email: tu-email@example.com
- 💼 LinkedIn: [Tu Perfil](https://linkedin.com/in/tu-perfil)

---

## 📜 Código de Conducta

Este proyecto adhiere a valores de respeto y profesionalismo:

✅ **Esperamos:**
- Comunicación respetuosa
- Retroalimentación constructiva
- Colaboración abierta
- Mentalidad de aprendizaje

❌ **No toleramos:**
- Lenguaje ofensivo
- Ataques personales
- Discriminación
- Comportamiento no profesional

---

## 🙏 Reconocimientos

Todos los contribuidores serán reconocidos en el README y CHANGELOG.

¡Gracias por hacer este proyecto mejor! 🚀

---

**[⬆ Volver al README principal](README.md)**
