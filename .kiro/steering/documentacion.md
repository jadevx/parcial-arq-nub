---
title: "Proceso Principal — Documentación Automática"
description: "Flujo completo para documentar aplicaciones web: análisis, documentación funcional/técnica, capturas de pantalla, diagramas y generación de PDF."
version: "1.0.0"
tags: ["proceso", "headless", "documentacion"]
inclusion: always
---

# Proceso Principal — Documentación Automática

## Modo de Operación

Ejecución headless (sin interacción humana). Completar TODO el proceso sin detenerse.

---

## Estructura de Salida

```
docs/
├── DOCUMENTACION.md          ← Documento consolidado (funcional + técnico + diagramas)
├── screenshots/              ← Capturas de pantalla
```

---

## Flujo Completo

### Paso 1: Explorar el proyecto

- Listar estructura de carpetas (ignorar node_modules, .git, dist, build)
- Leer archivos de configuración (package.json, requirements.txt, pom.xml, etc.)
- Determinar lenguaje, framework y stack tecnológico
- Identificar entrypoints, rutas, controladores, modelos

### Paso 2: Analizar código fuente

- Leer archivos principales
- Identificar endpoints API (rutas HTTP, métodos, parámetros)
- Identificar modelos de datos (schemas, entidades, interfaces)
- Identificar variables de entorno usadas
- Identificar dependencias y servicios externos

### Paso 3: Tomar capturas de pantalla (si APP_URL está definida)

Si existe la variable `APP_URL` en el entorno, tomar capturas con Playwright:

1. Crear scripts de captura en `scripts/screenshots/`
2. Ejecutar con `node scripts/screenshots/run-all.js`
3. Las capturas se guardan en `docs/screenshots/`
4. Referenciar en el markdown

Ver `steering/capturas-pantalla.md` para instrucciones detalladas.

Si NO hay APP_URL, omitir capturas y documentar solo desde el código.

### Paso 4: Generar documentación

Escribir `docs/DOCUMENTACION.md` con la estructura definida en los steerings:
- Documentación funcional (ver `steering/documentacion-funcional.md`)
- Documentación técnica (ver `steering/documentacion-no-funcional.md`)
- Diagramas (ver `steering/diagramacion.md`)

Todo en un solo archivo consolidado.

### Paso 5: Verificar

- Verificar que `docs/DOCUMENTACION.md` existe y tiene contenido
- Verificar que las imágenes referenciadas existen en `docs/screenshots/`

---

## Reglas

1. **No detenerse** — Completar todo sin pedir confirmación
2. **No inventar** — Solo documentar lo que existe en el código
3. **Diagramas Mermaid** — Nunca ASCII art
4. **Todo en español**
5. **Un solo archivo** — Todo consolidado en docs/DOCUMENTACION.md
6. **Capturas opcionales** — Solo si APP_URL está disponible
