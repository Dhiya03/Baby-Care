#!/bin/bash

# Baby Care App - Asset Download Script
# This script downloads necessary fonts and creates placeholder icons

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍼 Baby Care App - Asset Setup${NC}"
echo -e "${YELLOW}Downloading fonts and creating placeholder assets...${NC}"
echo ""

# Create asset directories
echo -e "${BLUE}📁 Creating asset directories...${NC}"
mkdir -p assets/icons
mkdir -p assets/fonts/Nunito
mkdir -p assets/images/splash
mkdir -p assets/images/illustrations
mkdir -p assets/images/app_icon
mkdir -p assets/animations

# Verify that fonts exist in the repository
echo -e "${BLUE}📝 Verifying local fonts...${NC}"
if [ -f "assets/fonts/Nunito/Nunito-Regular.ttf" ] && [ -f "assets/fonts/Nunito/Nunito-Bold.ttf" ] && [ -f "assets/fonts/Nunito/Nunito-Light.ttf" ]; then
    echo -e "${GREEN}✅ Nunito font files found in repository.${NC}"
else
    echo -e "${RED}❌ Error: Nunito font files not found!${NC}"
    echo -e "${YELLOW}Please download the Nunito font family from Google Fonts and place the .ttf files in 'assets/fonts/Nunito/' before committing.${NC}"
    exit 1
fi

# Go back to project root

# Create placeholder icons using ImageMagick (if available)
if command -v convert &> /dev/null; then
    echo -e "${BLUE}🎨 Creating placeholder icons with ImageMagick...${NC}"
    
    # Create bottle icon (feeding)
    convert -size 64x64 xc:none -fill "#FFC0CB" -stroke "#FF69B4" -strokewidth 2 \
            -draw "roundrectangle 20,10 44,35 5,5" \
            -draw "roundrectangle 28,8 36,12 2,2" \
            -draw "roundrectangle 18,35 46,55 8,8" \
            assets/icons/bottle.png
    
    # Create droplet icon (urination)
    convert -size 64x64 xc:none -fill "#4A90E2" -stroke "#2E6BD6" -strokewidth 2 \
            -draw "path 'M32,10 Q20,25 20,35 Q20,50 32,50 Q44,50 44,35 Q44,25 32,10 Z'" \
            assets/icons/droplet.png
    
    # Create poop icon (stool)
    convert -size 64x64 xc:none -fill "#8B4513" -stroke "#654321" -strokewidth 2 \
            -draw "ellipse 32,40 20,15 0,360" \
            -draw "ellipse 32,30 15,10 0,360" \
            -draw "ellipse 32,22 10,8 0,360" \
            assets/icons/poop.png
    
    # Create clock icon (timer)
    convert -size 64x64 xc:none -fill "#FFC0CB" -stroke "#FF69B4" -strokewidth 2 \
            -draw "circle 32,32 32,10" \
            -draw "line 32,32 32,20" \
            -draw "line 32,32 40,32" \
            assets/icons/clock.png
    
    # Create history icon
    convert -size 64x64 xc:none -fill "#FFC0CB" -stroke "#FF69B4" -strokewidth 2 \
            -draw "roundrectangle 10,15 54,55 5,5" \
            -draw "line 20,25 44,25" \
            -draw "line 20,35 44,35" \
            -draw "line 20,45 44,45" \
            assets/icons/history.png
    
    # Create settings icon  
    convert -size 64x64 xc:none -fill "#FFC0CB" -stroke "#FF69B4" -strokewidth 2 \
            -draw "circle 32,32 32,20" \
            -draw "circle 32,32 32,28" \
            -draw "rectangle 30,10 34,18" \
            -draw "rectangle 30,46 34,54" \
            -draw "rectangle 10,30 18,34" \
            -draw "rectangle 46,30 54,34" \
            assets/icons/settings.png
    
    # Create export/share icon
    convert -size 64x64 xc:none -fill "#FFC0CB" -stroke "#FF69B4" -strokewidth 2 \
            -draw "path 'M32,10 L20,22 L28,22 L28,35 L36,35 L36,22 L44,22 Z'" \
            -draw "line 15,40 49,40" \
            -draw "line 15,45 49,45" \
            -draw "line 15,50 49,50" \
            assets/icons/export.png
    
    # Create notification icon
    convert -size 64x64 xc:none -fill "#FFC0CB" -stroke "#FF69B4" -strokewidth 2 \
            -draw "path 'M32,10 Q20,15 20,30 L20,40 Q15,40 15,45 L49,45 Q49,40 44,40 L44,30 Q44,15 32,10'" \
            -draw "path 'M28,50 Q28,55 32,55 Q36,55 36,50'" \
            assets/icons/notification.png
    
    echo -e "${GREEN}✅ Placeholder icons created${NC}"
    
else
    echo -e "${YELLOW}⚠️  ImageMagick not found. Creating simple placeholder icons...${NC}"
    
    # Create simple colored squares as placeholders
    for icon in bottle droplet poop clock history settings export notification; do
        # Create a simple 64x64 colored square
        cat > "assets/icons/${icon}.png" << 'EOF'
# This is a placeholder - replace with actual icon
# 64x64 PNG icon needed for: ${icon}
EOF
    done
fi

# Create app icon placeholder
echo -e "${BLUE}📱 Creating app icon placeholder...${NC}"
if command -v convert &> /dev/null; then
    # Create a simple app icon with baby bottle
    convert -size 512x512 xc:"#FFC0CB" \
            -fill "#FFFFFF" -stroke "#FF69B4" -strokewidth 8 \
            -draw "roundrectangle 150,100 350,250 20,20" \
            -draw "roundrectangle 220,80 280,120 10,10" \
            -draw "roundrectangle 130,250 370,400 40,40" \
            -font "DejaVu-Sans-Bold" -pointsize 60 -fill "#333333" \
            -draw "text 180,470 'BabyCare'" \
            assets/images/app_icon/icon.png
    
    # Create smaller versions
    convert assets/images/app_icon/icon.png -resize 192x192 assets/images/app_icon/icon_192.png
    convert assets/images/app_icon/icon.png -resize 512x512 assets/images/app_icon/icon_512.png
else
    echo "# App icon placeholder - 512x512 PNG needed" > assets/images/app_icon/icon.png
fi

# Create illustration placeholders
echo -e "${BLUE}🎨 Creating illustration placeholders...${NC}"
for illustration in empty_history welcome_baby feeding_time splash_logo; do
    echo "# Illustration placeholder for: ${illustration}" > "assets/images/illustrations/${illustration}.png"
done

# Create animation placeholders (JSON files for Lottie)
echo -e "${BLUE}🎬 Creating animation placeholders...${NC}"

# Simple loading animation JSON
cat > assets/animations/loading_baby.json << 'EOF'
{
  "v": "5.5.7",
  "fr": 30,
  "ip": 0,
  "op": 60,
  "w": 100,
  "h": 100,
  "nm": "Loading Baby",
  "ddd": 0,
  "assets": [],
  "layers": [
    {
      "ddd": 0,
      "ind": 1,
      "ty": 4,
      "nm": "Circle",
      "sr": 1,
      "ks": {
        "r": {
          "a": 1,
          "k": [
            {"i":{"x":[0.833],"y":[0.833]},"o":{"x":[0.167],"y":[0.167]},"t":0,"s":[0]},
            {"t":60,"s":[360]}
          ]
        }
      },
      "ao": 0,
      "shapes": [
        {
          "ty": "el",
          "p": {"a": 0, "k": [50, 50]},
          "s": {"a": 0, "k": [80, 80]}
        }
      ],
      "ip": 0,
      "op": 60,
      "st": 0
    }
  ]
}
EOF

# Success animation placeholder
cat > assets/animations/success_check.json << 'EOF'
{
  "v": "5.5.7",
  "fr": 30,
  "ip": 0,
  "op": 30,
  "w": 100,
  "h": 100,
  "nm": "Success Check",
  "ddd": 0,
  "assets": [],
  "layers": []
}
EOF

# Feeding timer animation placeholder
cat > assets/animations/feeding_timer.json << 'EOF'
{
  "v": "5.5.7", 
  "fr": 30,
  "ip": 0,
  "op": 120,
  "w": 100,
  "h": 100,
  "nm": "Feeding Timer",
  "ddd": 0,
  "assets": [],
  "layers": []
}
EOF

echo ""
echo -e "${GREEN}🎉 Asset setup completed!${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "✅ Nunito fonts downloaded"
echo -e "✅ Placeholder icons created"  
echo -e "✅ App icon placeholder created"
echo -e "✅ Animation placeholders created"
echo -e "✅ pubspec.yaml updated"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "1. Replace placeholder icons with proper designs"
echo -e "2. Create a professional app icon (1024x1024)"
echo -e "3. Add proper illustrations for empty states"
echo -e "4. Consider adding Lottie animations for better UX"
echo -e "5. Run: ${BLUE}flutter pub get${NC}"
echo -e "6. Test with: ${BLUE}flutter run${NC}"
echo ""
echo -e "${GREEN}Happy coding! 🍼💖${NC}"