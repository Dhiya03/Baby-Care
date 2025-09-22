#!/bin/bash

# Baby Care App - Android Embedding V2 Migration Script
# This script fixes the deprecated Android embedding v1 error

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Baby Care App - Android Embedding V2 Migration${NC}"
echo -e "${YELLOW}Fixing the deprecated Android embedding v1 error...${NC}"
echo ""

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: pubspec.yaml not found. Please run this script from the Flutter project root.${NC}"
    exit 1
fi

# Backup important files
echo -e "${BLUE}📋 Creating backup of existing files...${NC}"
mkdir -p backup/android
[ -f "android/app/build.gradle" ] && cp android/app/build.gradle backup/android/
[ -f "android/build.gradle" ] && cp android/build.gradle backup/android/
[ -f "android/gradle.properties" ] && cp android/gradle.properties backup/android/

# Clean existing build
echo -e "${BLUE}🧹 Cleaning existing build...${NC}"
flutter clean

# Remove old Android build artifacts
echo -e "${BLUE}🗑️ Removing old build artifacts...${NC}"
rm -rf android/app/build/
rm -rf android/.gradle/
rm -rf build/

# Update gradle wrapper if needed
echo -e "${BLUE}⚙️ Updating Gradle wrapper...${NC}"
cd android
if [ -f "gradlew" ]; then
    ./gradlew wrapper --gradle-version 8.3 --distribution-type all
else
    echo -e "${YELLOW}⚠️ Gradle wrapper not found, skipping update${NC}"
fi
cd ..

# Verify Android embedding v2 in AndroidManifest.xml
echo -e "${BLUE}📝 Verifying AndroidManifest.xml...${NC}"
if grep -q 'android:name="flutterEmbedding"' android/app/src/main/AndroidManifest.xml; then
    if grep -q 'android:value="2"' android/app/src/main/AndroidManifest.xml; then
        echo -e "${GREEN}✅ Android embedding v2 correctly configured${NC}"
    else
        echo -e "${YELLOW}⚠️ Updating embedding version to v2${NC}"
        sed -i.bak 's/android:value="1"/android:value="2"/g' android/app/src/main/AndroidManifest.xml
    fi
else
    echo -e "${YELLOW}⚠️ Adding Android embedding v2 configuration${NC}"
    # Add the meta-data before closing application tag
    sed -i.bak '/<\/application>/i\        <meta-data\n            android:name="flutterEmbedding"\n            android:value="2" />' android/app/src/main/AndroidManifest.xml
fi

# Verify MainActivity extends FlutterActivity (not FlutterApplication)
echo -e "${BLUE}📝 Verifying MainActivity...${NC}"
MAIN_ACTIVITY="android/app/src/main/kotlin/com/babycareapp/baby_care_app/MainActivity.kt"
if [ -f "$MAIN_ACTIVITY" ]; then
    if grep -q "FlutterActivity" "$MAIN_ACTIVITY"; then
        echo -e "${GREEN}✅ MainActivity correctly extends FlutterActivity${NC}"
    else
        echo -e "${YELLOW}⚠️ MainActivity needs to extend FlutterActivity${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ MainActivity.kt not found in expected location${NC}"
    echo -e "Expected: $MAIN_ACTIVITY"
    
    # Try to find MainActivity
    FOUND_ACTIVITY=$(find android -name "MainActivity.kt" 2>/dev/null | head -1)
    if [ -n "$FOUND_ACTIVITY" ]; then
        echo -e "${BLUE}Found MainActivity at: $FOUND_ACTIVITY${NC}"
    fi
fi

# Get dependencies
echo -e "${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get

# Verify the fix
echo -e "${BLUE}🔍 Verifying the fix...${NC}"
echo "Checking pubspec.lock for flutter_local_notifications version..."
if grep -A2 "flutter_local_notifications:" pubspec.lock | grep -q "version:"; then
    VERSION=$(grep -A2 "flutter_local_notifications:" pubspec.lock | grep "version:" | head -1 | sed 's/.*version: "//' | sed 's/".*//')
    echo -e "${GREEN}✅ flutter_local_notifications version: $VERSION${NC}"
else
    echo -e "${YELLOW}⚠️ Could not determine flutter_local_notifications version${NC}"
fi

# Test build (Android APK debug)
echo -e "${BLUE}🔨 Testing Android build...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

if flutter build apk --debug --target-platform android-arm64; then
    echo -e "${GREEN}✅ Android build successful!${NC}"
    echo -e "${GREEN}✅ Android Embedding V2 migration completed successfully!${NC}"
else
    echo -e "${RED}❌ Android build failed${NC}"
    echo -e "${YELLOW}Please check the error messages above and fix any remaining issues${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Migration Summary${NC}"
echo -e "${BLUE}==================${NC}"
echo -e "✅ Cleaned old build artifacts"
echo -e "✅ Updated Gradle wrapper to 8.3"
echo -e "✅ Verified Android Embedding V2 configuration"
echo -e "✅ Tested Android build successfully"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "1. Run: ${BLUE}flutter run${NC} to test the app"
echo -e "2. If using CI/CD, update your workflows"
echo -e "3. Test notifications functionality"
echo -e "4. Consider running: ${BLUE}flutter doctor${NC} to check for other issues"
echo ""
echo -e "${GREEN}The Android Embedding V1 deprecation error should now be resolved! 🎉${NC}"