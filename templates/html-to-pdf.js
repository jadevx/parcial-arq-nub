const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const htmlPath = process.argv[2];
const pdfPath = process.argv[3];

if (!htmlPath || !pdfPath) {
  console.error('Uso: node html-to-pdf.js <input.html> <output.pdf>');
  process.exit(1);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  const absoluteHtml = path.resolve(htmlPath);
  await page.goto('file://' + absoluteHtml, { waitUntil: 'networkidle', timeout: 60000 });

  // Esperar a que Mermaid renderice los diagramas
  await page.waitForTimeout(3000);

  await page.pdf({
    path: path.resolve(pdfPath),
    format: 'A4',
    margin: { top: '2cm', bottom: '2cm', left: '2cm', right: '2cm' },
    printBackground: true
  });

  await browser.close();
  console.log('PDF generado: ' + pdfPath);
})();
