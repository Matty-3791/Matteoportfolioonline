#!/usr/bin/env python3
"""
Script per ottimizzare immagini della galleria:
- Crea versioni thumbnail (350px max) per la galleria
- Crea versioni full (1200px max) per il lightbox
- Ridimensiona e comprime le immagini
"""

from PIL import Image
import os
from pathlib import Path

# Configurazione
PORTFOLIO_DIR = Path(__file__).parent
THUMB_SIZE = (350, 350)
FULL_SIZE = (1200, 1200)
QUALITY_THUMB = 85
QUALITY_FULL = 90

def optimize_image(input_path, output_thumb, output_full):
    """Ridimensiona un'immagine in versioni thumb e full."""
    try:
        img = Image.open(input_path)
        # Converte RGBA in RGB se necessario (per JPG)
        if img.mode in ('RGBA', 'LA'):
            rgb_img = Image.new('RGB', img.size, (255, 255, 255))
            rgb_img.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
            img = rgb_img
        
        # Thumbnail (piccolo per galleria)
        img_thumb = img.copy()
        img_thumb.thumbnail(THUMB_SIZE, Image.Resampling.LANCZOS)
        ext = Path(input_path).suffix.lower()
        if ext in ['.jpg', '.jpeg']:
            img_thumb.save(output_thumb, 'JPEG', quality=QUALITY_THUMB, optimize=True)
        else:
            img_thumb.save(output_thumb, quality=QUALITY_THUMB, optimize=True)
        
        # Full (grande per lightbox)
        img_full = img.copy()
        img_full.thumbnail(FULL_SIZE, Image.Resampling.LANCZOS)
        if ext in ['.jpg', '.jpeg']:
            img_full.save(output_full, 'JPEG', quality=QUALITY_FULL, optimize=True)
        else:
            img_full.save(output_full, quality=QUALITY_FULL, optimize=True)
        
        print(f"✅ {Path(input_path).name}")
        return True
    except Exception as e:
        print(f"❌ {Path(input_path).name}: {e}")
        return False

# Elabora immagini BASKET (BRY_*.jpg)
print("\n📸 ELABORO BASKET (BRY)...")
bry_files = sorted(PORTFOLIO_DIR.glob("BRY_*.jpg"))
for f in bry_files:
    thumb = PORTFOLIO_DIR / f"{f.stem}-thumb.jpg"
    full = PORTFOLIO_DIR / f"{f.stem}-full.jpg"
    optimize_image(f, thumb, full)

# Elabora immagini CALCIO (MAT*.jpg)
print("\n⚽ ELABORO CALCIO (MAT)...")
mat_files = sorted(PORTFOLIO_DIR.glob("MAT*.jpg"))
for f in mat_files:
    thumb = PORTFOLIO_DIR / f"{f.stem}-thumb.jpg"
    full = PORTFOLIO_DIR / f"{f.stem}-full.jpg"
    optimize_image(f, thumb, full)

# Elabora immagini EDIT
print("\n🎨 ELABORO EDIT...")
edit_dir = PORTFOLIO_DIR / "edit"
for f in sorted(edit_dir.glob("*")):
    if f.is_file() and f.suffix.lower() in ['.jpg', '.jpeg', '.png']:
        thumb = edit_dir / f"{f.stem}-thumb{f.suffix}"
        full = edit_dir / f"{f.stem}-full{f.suffix}"
        optimize_image(f, thumb, full)

print("\n✨ OTTIMIZZAZIONE COMPLETATA!")
print(f"Cartella: {PORTFOLIO_DIR}")
print("Prossimo passo: aggiornare galleria.html per usare le immagini ottimizzate")
