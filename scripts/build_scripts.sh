#!/bin/bash

# Baby Care App Build Script
# Usage: ./scripts/build.sh [platform] [build_type]
# Example: ./scripts/build.sh android release

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PLATFORM=${1:-"all"}
BUILD_TYPE=${2:-"release"}
OUTPUT_DIR="build_output"

echo -e "${BLUE}🍼 Baby Care App Build Script${NC}"
echo -e "${YELLOW}Platform: $PLATFORM${NC}"
echo -e "${YELLOW}Build Type: $BUILD_TYPE${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check Flutter doctor
echo -e "${BLUE}📋 Running Flutter doctor...${NC}"
flutter doctor

# Create output directory
mkdir -p $OUTPUT_DIR

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Run tests
echo -e "${BLUE}🧪 Running tests...${NC}"
flutter test

# Build function
build_android() {
    local build_type=$1
    echo -e "${GREEN}🤖 Building Android ($build_type)...${NC}"
    
    if [ "$build_type" = "release" ]; then
        # Build release APK (split per ABI)
        echo -e "${BLUE}📱 Building release APK...${NC}"
        flutter build apk --release --split-per-abi
        
        # Build release AAB
        echo -e "${BLUE}📦 Building release AAB...${NC}"
        flutter build appbundle --release
        
        # Copy files to output directory
        cp build/app/outputs/flutter-apk/*.apk $OUTPUT_DIR/
        cp build/app/outputs/bundle/release/*.aab $OUTPUT_DIR/
        
        echo -e "${GREEN}✅ Android release build completed${NC}"
        echo -e "${YELLOW}Files saved to: $OUTPUT_DIR/${NC}"
        ls -la $OUTPUT_DIR/
    else
        # Build debug APK
        echo -e "${BLUE}📱 Building debug APK...${NC}"
        flutter build apk --debug
        
        # Copy files to output directory
        cp build/app/outputs/flutter-apk/app-debug.apk $OUTPUT_DIR/
        
        echo -e "${GREEN}✅ Android debug build completed${NC}"
    fi
}

build_ios() {
    local build_type=$1
    echo -e "${GREEN}🍎 Building iOS ($build_type)...${NC}"
    
    if [ "$build_type" = "release" ]; then
        flutter build ios --release --no-codesign
        echo -e "${GREEN}✅ iOS release build completed (no codesign)${NC}"
        echo -e "${YELLOW}To create IPA, use Xcode or: flutter build ipa${NC}"
    else
        flutter build ios --debug --simulator
        echo -e "${GREEN}✅ iOS debug build completed${NC}"
    fi
}

build_web() {
    local build_type=$1
    echo -e "${GREEN}🌐 Building Web ($build_type)...${NC}"
    
    if [ "$build_type" = "release" ]; then
        flutter build web --release --base-href "/baby-care-app/"
    else
        flutter build web --debug
    fi
    
    # Create web archive
    cd build/web
    tar -czf ../../$OUTPUT_DIR/baby-care-web.tar.gz *
    cd ../../
    
    echo -e "${GREEN}✅ Web build completed${NC}"
    echo -e "${YELLOW}Web archive saved to: $OUTPUT_DIR/baby-care-web.tar.gz${NC}"
}

build_windows() {
    local build_type=$1
    echo -e "${GREEN}🪟 Building Windows ($build_type)...${NC}"
    
    if [ "$build_type" = "release" ]; then
        flutter build windows --release
    else
        flutter build windows --debug
    fi
    
    # Create Windows archive
    cd build/windows/runner
    zip -r ../../../$OUTPUT_DIR/baby-care-windows.zip Release/
    cd ../../../
    
    echo -e "${GREEN}✅ Windows build completed${NC}"
}

build_macos() {
    local build_type=$1
    echo -e "${GREEN}🖥️ Building macOS ($build_type)...${NC}"
    
    if [ "$build_type" = "release" ]; then
        flutter build macos --release
    else
        flutter build macos --debug
    fi
    
    echo -e "${GREEN}✅ macOS build completed${NC}"
}

build_linux() {
    local build_type=$1
    echo -e "${GREEN}🐧 Building Linux ($build_type)...${NC}"
    
    if [ "$build_type" = "release" ]; then
        flutter build linux --release
    else
        flutter build linux --debug
    fi
    
    # Create Linux archive
    cd build/linux
    tar -czf ../../$OUTPUT_DIR/baby-care-linux.tar.gz */
    cd ../../
    
    echo -e "${GREEN}✅ Linux build completed${NC}"
}

# Main build logic
case $PLATFORM in
    "android")
        build_android $BUILD_TYPE
        ;;
    "ios")
        build_ios $BUILD_TYPE
        ;;
    "web")
        build_web $BUILD_TYPE
        ;;
    "windows")
        build_windows $BUILD_TYPE
        ;;
    "macos")
        build_macos $BUILD_TYPE
        ;;
    "linux")
        build_linux $BUILD_TYPE
        ;;
    "all")
        echo -e "${BLUE}🚀 Building all platforms...${NC}"
        build_android $BUILD_TYPE
        build_web $BUILD_TYPE
        
        # Only build desktop platforms on appropriate OS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            build_ios $BUILD_TYPE
            build_macos $BUILD_TYPE
        elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
            build_windows $BUILD_TYPE
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            build_linux $BUILD_TYPE
        fi
        ;;
    *)
        echo -e "${RED}❌ Unknown platform: $PLATFORM${NC}"
        echo -e "${YELLOW}Available platforms: android, ios, web, windows, macos, linux, all${NC}"
        exit 1
        ;;
esac

# Generate build summary
echo ""
echo -e "${GREEN}🎉 Build Summary${NC}"
echo -e "${BLUE}=================${NC}"
echo -e "Platform: $PLATFORM"
echo -e "Build Type: $BUILD_TYPE"
echo -e "Output Directory: $OUTPUT_DIR"
echo ""

if [ -d "$OUTPUT_DIR" ]; then
    echo -e "${YELLOW}Generated files:${NC}"
    ls -la $OUTPUT_DIR/
    echo ""
    
    # Calculate total size
    TOTAL_SIZE=$(du -sh $OUTPUT_DIR | cut -f1)
    echo -e "${BLUE}Total size: $TOTAL_SIZE${NC}"
fi

echo -e "${GREEN}✅ Build completed successfully!${NC}"