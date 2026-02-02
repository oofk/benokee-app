#!/usr/bin/env python3
"""
Script to generate Benokee app logo icons.
Creates a white background with a green circle and white "OK" text.
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_logo(size):
    """Create a logo image with the specified size."""
    # Create white background
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)
    
    # Calculate green circle size (80% of image size)
    circle_size = int(size * 0.8)
    circle_margin = (size - circle_size) // 2
    
    # Draw green circle
    green_color = (76, 175, 80)  # #4CAF50
    draw.ellipse(
        [circle_margin, circle_margin, size - circle_margin, size - circle_margin],
        fill=green_color
    )
    
    # Draw white "OK" text
    try:
        # Try to use a system font
        font_size = int(size * 0.3)
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", font_size)
        except:
            # Fallback to default font
            font = ImageFont.load_default()
    
    text = "OK"
    # Get text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    text_x = (size - text_width) // 2
    text_y = (size - text_height) // 2
    
    draw.text((text_x, text_y), text, fill='white', font=font)
    
    return img

def main():
    """Generate all required icon sizes."""
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    base_path = 'android/app/src/main/res'
    
    for folder, size in sizes.items():
        folder_path = os.path.join(base_path, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        img = create_logo(size)
        output_path = os.path.join(folder_path, 'ic_launcher.png')
        img.save(output_path)
        print(f'Created {output_path} ({size}x{size})')
    
    # Also create a 1024x1024 version for reference
    img = create_logo(1024)
    os.makedirs('assets/icon', exist_ok=True)
    img.save('assets/icon/icon.png')
    print('Created assets/icon/icon.png (1024x1024)')

if __name__ == '__main__':
    main()
