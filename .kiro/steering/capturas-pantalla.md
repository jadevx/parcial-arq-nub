---
title: "Capturas de Pantalla"
description: "Sistema de capturas con Playwright. Solo aplica si el proyecto tiene frontend web."
version: "2.0.0"
tags: ["capturas", "screenshots", "playwright"]
inclusion: always
---

# Capturas de Pantalla

## Cuándo se ejecuta

SOLO si el proyecto tiene un frontend web (HTML, React, Vue, Angular, etc.). Si el proyecto es solo una API REST sin interfaz visual, NO se toman capturas.

Para determinar si hay frontend, verificar:
- Archivos HTML, JSX, TSX, Vue, Svelte en el proyecto
- Carpetas como `public/`, `views/`, `templates/`, `frontend/`, `client/`
- Dependencias de frontend (react, vue, angular, svelte, ejs, pug, handlebars)

Si es solo una API (Express, FastAPI, Spring Boot sin vistas), NO generar capturas. Documentar los endpoints con tablas y ejemplos JSON en su lugar.

---

## Proceso (solo si hay frontend)

1. El script `document.sh` levanta la app localmente antes de ejecutar el agente
2. El agente crea scripts de captura y los ejecuta contra `http://localhost:PORT`
3. Las capturas se guardan en `docs/screenshots/`
4. Se referencian en el markdown

---

## Reglas

- **Sin frontend = sin capturas** — No inventar capturas de endpoints JSON
- Si hay frontend, capturar las pantallas principales
- Modo headless siempre
- Si la app no levanta o falla, omitir capturas sin error
