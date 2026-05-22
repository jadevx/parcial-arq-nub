const path = require('path');
const fs = require('fs');

const htmlPath = process.argv[2];
const pdfPath = process.argv[3];
const workDir = process.argv[4] || process.cwd();

if (!htmlPath || !pdfPath) {
  console.error('Uso: node html-to-pdf.js <input.html> <output.pdf> [workDir]');
  process.exit(1);
}

// Buscar playwright en el workDir/node_modules
const playwrightPath = path.join(workDir, 'node_modules', 'playwright');
const { chromium } = require(playwrightPath);

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  const absoluteHtml = path.resolve(htmlPath);
  await page.goto('file://' + absoluteHtml, { waitUntil: 'networkidle', timeout: 60000 });

  // Esperar a que Mermaid renderice
  await page.waitForTimeout(4000);

  await page.pdf({
    path: path.resolve(pdfPath),
    format: 'A4',
    margin: { top: '2cm', bottom: '2cm', left: '2cm', right: '2cm' },
    printBackground: true
  });

  await browser.close();
  console.log('PDF generado: ' + pdfPath);
})();
