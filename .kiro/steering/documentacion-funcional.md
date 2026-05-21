---
title: "Documentación Funcional"
description: "Guía para generar documentación funcional orientada al usuario final."
version: "1.0.0"
tags: ["funcional", "manual", "usuario"]
inclusion: always
---

# Documentación Funcional

## Sección en el documento

La documentación funcional va como parte del archivo `docs/DOCUMENTACION.md`, en las secciones iniciales.

---

## Objetivo

Describir qué hace la aplicación y cómo se usa. Debe ser comprensible para un usuario NO técnico.

---

## Estructura

```markdown
## Manual de Usuario

### Introducción
Qué es la app, para qué sirve, cómo acceder.

### Pantallas / Vistas principales
Para cada pantalla:
- Descripción de qué hace
- Captura de pantalla (si existe)
- Elementos visibles (campos, botones, tablas)
- Acciones disponibles
- Paso a paso de uso

### Flujos principales
Diagrama Mermaid del flujo completo del usuario por la app.

### Errores comunes
Tabla: error, causa, solución.
```

---

## Reglas de Redacción

1. **Lenguaje de negocio** — sin jerga técnica
2. **Paso a paso numerado** — cada acción es un paso claro
3. **Diagramas Mermaid** para flujos y navegación
4. **Tablas** para describir campos, botones, errores
5. **Capturas de pantalla** referenciadas como `![Descripción](screenshots/XX-nombre.png)`

---

## Sobre las Imágenes

Si se generaron capturas:
- TODAS las pantallas deben tener su screenshot
- Formato: `![Pantalla de login](screenshots/01-login.png)`
- Insertar debajo de la descripción de cada pantalla

Si NO hay capturas, usar solo diagramas Mermaid y tablas descriptivas.
