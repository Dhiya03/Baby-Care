# 🎨 Baby Care App Assets

This folder contains all the visual assets for the Baby Care app.

## 📁 Folder Structure

```
assets/
├── icons/
│   ├── bottle.png          # Feeding/bottle icon (64x64, 128x128)
│   ├── droplet.png         # Urination/water drop icon
│   ├── poop.png            # Stool icon
│   ├── clock.png           # Timer icon
│   ├── history.png         # History icon
│   ├── settings.png        # Settings icon
│   ├── export.png          # Export/share icon
│   └── notification.png    # Notification icon
├── fonts/
│   ├── Nunito/
│   │   ├── Nunito-Regular.ttf
│   │   ├── Nunito-Bold.ttf
│   │   ├── Nunito-Light.ttf
│   │   └── OFL.txt         # Open Font License
├── images/
│   ├── splash/
│   │   ├── splash_logo.png # App logo for splash screen
│   │   └── baby_care_bg.png # Background pattern
│   ├── illustrations/
│   │   ├── empty_history.png # Empty state illustration
│   │   ├── welcome_baby.png  # Welcome screen illustration
│   │   └── feeding_time.png  # Feeding reminder illustration
│   └── app_icon/
│       ├── icon.png        # Main app icon (1024x1024)
│       ├── icon_rounded.png # Rounded version
│       └── icon_adaptive/  # Android adaptive icon
└── animations/
    ├── feeding_timer.json  # Lottie animation for feeding timer
    ├── success_check.json  # Success animation
    └── loading_baby.json   # Loading animation
```

## 🎨 Design Guidelines

### Color Scheme
- **Primary Pink**: #FFC0CB
- **Light Pink**: #FFEFF2  
- **Accent Pink**: #FFD6E8
- **White**: #FFFFFF
- **Dark Grey**: #333333
- **Light Grey**: #F5F5F5

### Icon Style
- **Size**: 64x64px primary, 32x32px secondary
- **Style**: Rounded, cartoon-like, friendly
- **Colors**: Pink theme with white backgrounds
- **Format**: PNG with transparency

### Font Usage
- **Primary**: Nunito (Google Font)
- **Headers**: Nunito Bold
- **Body**: Nunito Regular
- **Light**: Nunito Light (for secondary text)

## 📝 Icon Descriptions

1. **bottle.png** - Baby bottle for feeding tracking
2. **droplet.png** - Water drop for urination logging  
3. **poop.png** - Stylized brown circle for stool logging
4. **clock.png** - Timer/clock for feeding duration
5. **history.png** - Calendar/list icon for history view
6. **settings.png** - Gear icon for app settings
7. **export.png** - Share/export icon for data sharing
8. **notification.png** - Bell icon for reminders

## 🚀 How to Add Assets

1. **Icons**: Add PNG files to `assets/icons/`
2. **Update pubspec.yaml**:
```yaml
flutter:
  assets:
    - assets/icons/
    - assets/fonts/
    - assets/images/
```

3. **Use in Flutter**:
```dart
// For icons
Image.asset('assets/icons/bottle.png', width: 32, height: 32)

// For fonts (already configured in theme)
TextStyle(fontFamily: 'Nunito')
```

## 📱 Platform-Specific Icons

### Android
- Add icons to `android/app/src/main/res/`
- Multiple sizes: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi

### iOS  
- Add to `ios/Runner/Assets.xcassets/`
- Multiple sizes for different devices and contexts

### Web
- Add to `web/icons/` for PWA manifest
- Sizes: 192x192, 512x512 for PWA

## 🎯 Missing Assets (TO DO)

The following assets need to be created or downloaded:

### High Priority
- [ ] **App icon** (1024x1024) - main app icon
- [ ] **bottle.png** - feeding icon
- [ ] **droplet.png** - urination icon  
- [ ] **poop.png** - stool icon
- [ ] **Nunito fonts** - download from Google Fonts

### Medium Priority
- [ ] **Splash screen assets**
- [ ] **Empty state illustrations**
- [ ] **Platform-specific icons**
- [ ] **Notification icons**

### Low Priority  
- [ ] **Lottie animations**
- [ ] **Welcome illustrations**
- [ ] **Background patterns**

## 📖 Resources

### Free Icon Sources
- **Flaticon**: https://flaticon.com (baby-themed icons)
- **Icons8**: https://icons8.com (consistent style)
- **Feather Icons**: https://feathericons.com (simple icons)
- **Material Icons**: https://fonts.google.com/icons

### Free Font Sources
- **Google Fonts**: https://fonts.google.com/specimen/Nunito
- **Font Squirrel**: https://fontsquirrel.com

### Free Illustrations
- **unDraw**: https://undraw.co (customizable illustrations)
- **Storyset**: https://storyset.com (baby/family themes)
- **Freepik**: https://freepik.com (premium/free options)

## 🛠️ Asset Optimization

Before adding assets:
1. **Optimize images** with TinyPNG or ImageOptim
2. **Use appropriate sizes** (don't use 1024px icons for 32px display)
3. **Consider vector formats** (SVG) where possible
4. **Test on different densities** (1x, 2x, 3x)

## 📋 Checklist

- [ ] Download Nunito font files
- [ ] Create or find baby care icons (bottle, droplet, etc.)
- [ ] Create app icon in multiple sizes
- [ ] Optimize all images for mobile
- [ ] Test assets on different screen densities
- [ ] Update pubspec.yaml with asset paths