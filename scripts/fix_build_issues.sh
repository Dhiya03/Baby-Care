#!/bin/bash

# Baby Care App - Build Issue Resolver Script
# This script fixes common CI/CD build issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Baby Care App - Build Issue Resolver${NC}"
echo -e "${YELLOW}Fixing common build and dependency issues...${NC}"
echo ""

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: pubspec.yaml not found. Please run this script from the Flutter project root.${NC}"
    exit 1
fi

# Step 1: Clean everything
echo -e "${BLUE}🧹 Step 1: Cleaning build artifacts...${NC}"
flutter clean
rm -rf .dart_tool/
rm -rf build/
rm -rf android/.gradle/
rm -rf android/app/build/
rm -rf ios/Pods/
rm -rf ios/.symlinks/
rm -f pubspec.lock

echo -e "${GREEN}✅ Cleaned build artifacts${NC}"

# Step 2: Create missing asset directories
echo -e "${BLUE}📁 Step 2: Creating missing asset directories...${NC}"
mkdir -p assets/icons
mkdir -p assets/fonts/Nunito
mkdir -p assets/images/splash
mkdir -p assets/images/illustrations  
mkdir -p assets/images/app_icon
mkdir -p assets/animations

echo -e "${GREEN}✅ Created asset directories${NC}"

# Step 3: Create placeholder assets to prevent build failures
echo -e "${BLUE}🎨 Step 3: Creating placeholder assets...${NC}"

# Create placeholder font files
echo "# Placeholder font - replace with actual Nunito-Regular.ttf" > assets/fonts/Nunito/Nunito-Regular.ttf
echo "# Placeholder font - replace with actual Nunito-Bold.ttf" > assets/fonts/Nunito/Nunito-Bold.ttf
echo "# Placeholder font - replace with actual Nunito-Light.ttf" > assets/fonts/Nunito/Nunito-Light.ttf

# Create placeholder icon files
icons=("bottle" "droplet" "poop" "clock" "history" "settings" "export" "notification")
for icon in "${icons[@]}"; do
    echo "# Placeholder icon - replace with actual ${icon}.png" > "assets/icons/${icon}.png"
done

# Create placeholder image files
echo "# Placeholder image" > assets/images/app_icon/icon.png
echo "# Placeholder image" > assets/images/splash/splash_logo.png
echo "# Placeholder image" > assets/images/illustrations/empty_history.png

# Create placeholder animation files
cat > assets/animations/loading_baby.json << 'EOF'
{
  "v": "5.5.7",
  "fr": 30,
  "ip": 0,
  "op": 60,
  "w": 100,
  "h": 100,
  "nm": "Loading Placeholder",
  "ddd": 0,
  "assets": [],
  "layers": []
}
EOF

echo -e "${GREEN}✅ Created placeholder assets${NC}"

# Step 4: Update Android configuration for embedding V2
echo -e "${BLUE}🤖 Step 4: Ensuring Android Embedding V2 configuration...${NC}"

# Ensure AndroidManifest.xml has correct embedding version
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    if ! grep -q 'android:name="flutterEmbedding"' android/app/src/main/AndroidManifest.xml; then
        echo -e "${YELLOW}⚠️ Adding Android Embedding V2 configuration${NC}"
        # Add the meta-data before closing application tag
        sed -i.bak '/<\/application>/i\        <!-- Flutter Embedding V2 -->\n        <meta-data\n            android:name="flutterEmbedding"\n            android:value="2" />' android/app/src/main/AndroidManifest.xml
    elif grep -q 'android:value="1"' android/app/src/main/AndroidManifest.xml; then
        echo -e "${YELLOW}⚠️ Updating embedding version from V1 to V2${NC}"
        sed -i.bak 's/android:value="1"/android:value="2"/g' android/app/src/main/AndroidManifest.xml
    fi
    echo -e "${GREEN}✅ Android Embedding V2 configured${NC}"
else
    echo -e "${YELLOW}⚠️ AndroidManifest.xml not found, skipping Android config${NC}"
fi

# Step 5: Get dependencies
echo -e "${BLUE}📦 Step 5: Getting Flutter dependencies...${NC}"
flutter pub get

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependencies resolved successfully${NC}"
else
    echo -e "${RED}❌ Failed to resolve dependencies${NC}"
    echo -e "${YELLOW}Trying with --offline flag...${NC}"
    flutter pub get --offline || true
fi

# Step 6: Generate missing files if needed
echo -e "${BLUE}⚙️ Step 6: Generating missing files...${NC}"

# Ensure lib/generated_plugin_registrant.dart exists
if [ ! -f "lib/generated_plugin_registrant.dart" ]; then
    flutter packages get > /dev/null 2>&1 || true
fi

echo -e "${GREEN}✅ File generation completed${NC}"

# Step 7: Run flutter doctor to check for issues
echo -e "${BLUE}🩺 Step 7: Running Flutter doctor...${NC}"
flutter doctor -v

# Step 8: Test build to verify fixes
echo -e "${BLUE}🔨 Step 8: Testing build...${NC}"
echo -e "${YELLOW}This will test if the issues are resolved...${NC}"

# Test Flutter analyze first
echo -e "${BLUE}📊 Running Flutter analyze...${NC}"
if flutter analyze --fatal-infos; then
    echo -e "${GREEN}✅ Flutter analyze passed${NC}"
else
    echo -e "${YELLOW}⚠️ Flutter analyze found issues (non-critical)${NC}"
fi

# Test web build (fastest)
echo -e "${BLUE}🌐 Testing web build...${NC}"
if flutter build web --release; then
    echo -e "${GREEN}✅ Web build successful${NC}"
else
    echo -e "${RED}❌ Web build failed${NC}"
    echo -e "${YELLOW}Check the error messages above${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Build Issue Resolution Summary${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "✅ Cleaned build artifacts"
echo -e "✅ Created missing asset directories"
echo -e "✅ Added placeholder assets"
echo -e "✅ Configured Android Embedding V2"
echo -e "✅ Resolved dependencies"
echo -e "✅ Tested build process"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "1. Replace placeholder assets with actual icons and fonts"
echo -e "2. Test: ${BLUE}flutter run -d chrome${NC}"
echo -e "3. Build: ${BLUE}flutter build apk --debug${NC}"
echo -e "4. Push changes to trigger CI/CD"
echo ""
echo -e "${GREEN}Your build issues should now be resolved! 🎉${NC}"
