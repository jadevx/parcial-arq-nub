---
title: "Documentación No Funcional — Técnica"
description: "Guía para generar documentación técnica: endpoints, variables, modelo de datos, arquitectura."
version: "1.0.0"
tags: ["no-funcional", "tecnica", "api"]
inclusion: always
---

# Documentación No Funcional — Técnica

## Sección en el documento

Va como parte de `docs/DOCUMENTACION.md`, después de la documentación funcional.

---

## Estructura

```markdown
## Documentación Técnica

### Stack Tecnológico
Tabla: tecnología, versión, rol.

### Variables de Entorno
Tabla: variable, descripción, ejemplo.

### Autenticación
Flujo de auth, request/response de login, manejo de sesión.

### Endpoints API
Para cada endpoint:
- Método, ruta, descripción
- Headers requeridos
- Request body (JSON de ejemplo)
- Response body (JSON de ejemplo)
- Códigos HTTP

### Modelo de Datos
Para cada entidad:
- Tabla: campo, tipo, descripción, requerido

### Arquitectura
Diagrama C4 contexto y contenedores (Mermaid).

### Dependencias
Tabla: nombre, versión, propósito.

### Seguridad
Autenticación, tokens, HTTPS, almacenamiento de credenciales.
```

---

## Reglas

1. **Lenguaje técnico** — para desarrolladores
2. **Tablas para todo** — endpoints, campos, variables, errores
3. **Ejemplos JSON** de request/response para cada endpoint
4. **Códigos HTTP** documentados por endpoint
5. **Modelo de datos completo** — cada campo con tipo
6. **Diagramas Mermaid** para arquitectura
