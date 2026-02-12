"""Generate PWA icons for MoneyTrace."""
import base64
# Simple 1-color PNG icon (MoneyTrace "M" logo)
# This creates a minimal valid PNG with the app's accent color
def create_icon(size):
    """Create a simple colored square PNG as placeholder icon."""
    # Using a simple approach - create an SVG first, then note for manual conversion
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">
  <rect width="{size}" height="{size}" fill="#1a1a2e"/>
  <rect x="{size*0.1}" y="{size*0.1}" width="{size*0.8}" height="{size*0.8}" rx="{size*0.15}" fill="#e94560"/>
  <text x="50%" y="55%" text-anchor="middle" dominant-baseline="middle" 
        font-family="Arial, sans-serif" font-size="{size*0.5}" font-weight="bold" fill="white">M</text>
</svg>'''
    return svg
# Write SVG files (can be converted to PNG later)
for size in [192, 512]:
    svg = create_icon(size)
    with open(f"icon-{size}.svg", "w") as f:
        f.write(svg)
    print(f"Created icon-{size}.svg")
print("\nNote: Convert SVG to PNG using an online tool or:")
print("  - https://svgtopng.com/")
print("  - Or install: pip install cairosvg")
