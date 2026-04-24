#!/usr/bin/env node
/**
 * Script per ottimizzare immagini della galleria
 * Crea versioni thumb (350px) e full (1200px)
 * 
 * INSTALLAZIONE:
 * 1. npm install sharp
 * 2. node optimize_images.js
 */

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const THUMB_SIZE = 350;
const FULL_SIZE = 1200;
const QUALITY = 90;

async function optimizeImage(inputPath, thumbPath, fullPath) {
  try {
    const filename = path.basename(inputPath);
    
    // Crea thumbnail
    await sharp(inputPath)
      .resize(THUMB_SIZE, THUMB_SIZE, {
        fit: 'cover',
        position: 'center'
      })
      .jpeg({ quality: QUALITY, progressive: true })
      .toFile(thumbPath);
    
    // Crea versione full
    await sharp(inputPath)
      .resize(FULL_SIZE, FULL_SIZE, {
        fit: 'cover',
        position: 'center',
        withoutEnlargement: true
      })
      .jpeg({ quality: QUALITY, progressive: true })
      .toFile(fullPath);
    
    console.log(`✅ ${filename}`);
    return true;
  } catch (err) {
    console.error(`❌ ${path.basename(inputPath)}: ${err.message}`);
    return false;
  }
}

async function main() {
  console.log('\n🚀 INIZIO OTTIMIZZAZIONE IMMAGINI\n');
  
  const portfolioDir = __dirname;
  let count = 0;
  
  // Elabora BASKET (BRY_*.jpg)
  console.log('📸 ELABORO BASKET (BRY)...');
  const bryFiles = fs.readdirSync(portfolioDir)
    .filter(f => f.startsWith('BRY_') && f.endsWith('.jpg'))
    .sort();
  
  for (const file of bryFiles) {
    const inputPath = path.join(portfolioDir, file);
    const thumbPath = path.join(portfolioDir, `${path.parse(file).name}-thumb.jpg`);
    const fullPath = path.join(portfolioDir, `${path.parse(file).name}-full.jpg`);
    
    if (await optimizeImage(inputPath, thumbPath, fullPath)) {
      count++;
    }
  }
  
  // Elabora CALCIO (MAT*.jpg)
  console.log('\n⚽ ELABORO CALCIO (MAT)...');
  const matFiles = fs.readdirSync(portfolioDir)
    .filter(f => f.startsWith('MAT') && f.endsWith('.jpg'))
    .sort();
  
  for (const file of matFiles) {
    const inputPath = path.join(portfolioDir, file);
    const thumbPath = path.join(portfolioDir, `${path.parse(file).name}-thumb.jpg`);
    const fullPath = path.join(portfolioDir, `${path.parse(file).name}-full.jpg`);
    
    if (await optimizeImage(inputPath, thumbPath, fullPath)) {
      count++;
    }
  }
  
  // Elabora EDIT
  console.log('\n🎨 ELABORO EDIT...');
  const editDir = path.join(portfolioDir, 'edit');
  if (fs.existsSync(editDir)) {
    const editFiles = fs.readdirSync(editDir)
      .filter(f => /\.(jpg|jpeg|png)$/i.test(f))
      .sort();
    
    for (const file of editFiles) {
      const inputPath = path.join(editDir, file);
      const ext = path.parse(file).ext;
      const baseName = path.parse(file).name;
      const thumbPath = path.join(editDir, `${baseName}-thumb${ext}`);
      const fullPath = path.join(editDir, `${baseName}-full${ext}`);
      
      if (await optimizeImage(inputPath, thumbPath, fullPath)) {
        count++;
      }
    }
  }
  
  console.log(`\n✨ COMPLETATO! ${count} immagini elaborate.`);
  console.log('\n📝 PROSSIMI STEP:');
  console.log('1. Commit le nuove immagini: git add . && git commit -m "Add optimized images"');
  console.log('2. Push: git push origin main');
  console.log('3. Aggiorna galleria.html per usare le versioni ottimizzate');
  console.log('4. Il lightbox caricherà automaticamente le versioni -full\n');
}

main().catch(err => {
  console.error('Errore:', err.message);
  console.log('\n⚠️  Se vedi "sharp not found", esegui:');
  console.log('npm install sharp');
  process.exit(1);
});
