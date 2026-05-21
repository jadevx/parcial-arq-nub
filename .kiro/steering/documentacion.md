---
title: "Documentación Automática"
description: "Flujo para documentar un proyecto analizando su código fuente. Ejecución headless sin interacción."
version: "1.0.0"
tags: ["documentacion", "headless"]
inclusion: always
---

# Documentación Automática

## Modo de Operación

Ejecución headless. Completar TODO sin detenerse a preguntar.

---

## Salida

`docs/DOCUMENTACION.md`

---

## Flujo

### 1. Explorar proyecto

- Listar estructura (ignorar node_modules, .git, dist, build)
- Leer archivos de configuración (package.json, requirements.txt, etc.)
- Determinar lenguaje y framework

### 2. Analizar código

- Leer entrypoints, rutas, controladores, modelos
- Identificar endpoints API (rutas, métodos, parámetros)
- Identificar modelos de datos
- Identificar variables de entorno
- Identificar dependencias

### 3. Generar docs/DOCUMENTACION.md

```markdown
# Documentación — [NOMBRE]

## 1. Información General
Nombre, descripción, stack

## 2. Arquitectura
Diagrama C4 contexto y contenedores (Mermaid)

## 3. Instalación y Configuración
Requisitos, pasos, variables de entorno

## 4. Endpoints API
Tabla: método, ruta, descripción, request/response de ejemplo

## 5. Modelo de Datos
Entidades con campos, tipos, descripciones

## 6. Flujos Principales
Diagramas de secuencia (Mermaid)

## 7. Casos de Uso
Diagrama de casos de uso (Mermaid)

## 8. Dependencias
Tabla: nombre, versión, propósito
```

---

## Reglas

1. No detenerse — completar sin confirmación
2. No inventar — solo lo que existe en el código
3. Diagramas Mermaid — nunca ASCII
4. Todo en español
5. Crear carpeta docs/ si no existe
6. Un solo archivo consolidado
