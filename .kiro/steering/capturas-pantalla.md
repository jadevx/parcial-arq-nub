---
title: "Capturas de Pantalla"
description: "Sistema de capturas con Playwright para documentar visualmente la aplicación."
version: "1.0.0"
tags: ["capturas", "screenshots", "playwright"]
inclusion: always
---

# Capturas de Pantalla

## Cuándo se ejecuta

Solo si la variable `APP_URL` está disponible en el entorno. Si no existe, se omiten las capturas.

---

## Proceso

1. Crear `scripts/screenshots/core.js` con utilidades
2. Crear `scripts/screenshots/run-all.js` con la lista de páginas a capturar
3. Ejecutar: `node scripts/screenshots/run-all.js`
4. Las capturas se guardan en `docs/screenshots/`

---

## core.js — Utilidades

```javascript
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const SCREENSHOTS_DIR = path.resolve(__dirname, '../../docs/screenshots');
fs.mkdirSync(SCREENSHOTS_DIR, { recursive: true });

async function launchBrowser() {
  return chromium.launch({ headless: true });
}

async function newPage(browser) {
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 900 });
  return page;
}

function save(name, buffer) {
  fs.writeFileSync(path.join(SCREENSHOTS_DIR, name), buffer);
  console.log(`  ✓ ${name}`);
}

function getUrl() { return (process.env.APP_URL || '').replace(/\/+$/, ''); }
function getUser() { return process.env.APP_USER || ''; }
function getPass() { return process.env.APP_PASSWORD || ''; }
function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

module.exports = { launchBrowser, newPage, save, getUrl, getUser, getPass, sleep };
```

---

## run-all.js — Orquestador

El agente debe crear este archivo basándose en las rutas/pantallas que identificó en el análisis del código:

```javascript
const { launchBrowser, newPage, save, getUrl, sleep } = require('./core');

const PAGES = [
  // El agente llena esto basándose en las rutas del proyecto
  { name: '01-home', path: '/' },
  { name: '02-endpoint', path: '/api/ruta' },
];

async function main() {
  const browser = await launchBrowser();
  const baseUrl = getUrl();
  if (!baseUrl) { console.log('APP_URL no definida, omitiendo capturas'); process.exit(0); }

  for (const p of PAGES) {
    const page = await newPage(browser);
    try {
      await page.goto(baseUrl + p.path, { waitUntil: 'networkidle', timeout: 15000 });
      await sleep(1000);
      const buffer = await page.screenshot({ fullPage: true });
      save(p.name + '.png', buffer);
    } catch (err) {
      console.error(`  ✗ ${p.name}: ${err.message}`);
    }
    await page.close();
  }
  await browser.close();
}

main().catch(err => { console.error(err); process.exit(1); });
```

---

## Reglas

- Modo headless siempre (CI/CD no tiene pantalla)
- Viewport 1280x900
- Capturas fullPage
- Si una página falla, continuar con las demás
- Nombrar con prefijo numérico: `01-nombre.png`, `02-nombre.png`
- Si APP_URL no existe, salir sin error (exit 0)

---

## Referencia en el Markdown

Después de generar las capturas, referenciarlas en `docs/DOCUMENTACION.md`:

```markdown
![Pantalla principal](screenshots/01-home.png)
```

La ruta es relativa desde `docs/`.
