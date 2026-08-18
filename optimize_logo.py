from PIL import Image
from pathlib import Path
p=Path('logo-home.png')
if not p.exists():
    print('logo-home.png not found')
    raise SystemExit(1)
img=Image.open(p)
if img.mode not in ('RGB','RGBA'):
    img=img.convert('RGBA')
for size, name in [(320,'logo-home-320.webp'),(640,'logo-home-640.webp')]:
    im=img.copy()
    im.thumbnail((size,size), Image.Resampling.LANCZOS)
    im.save(name, 'WEBP', quality=90, method=6)
    print('Saved', name)
