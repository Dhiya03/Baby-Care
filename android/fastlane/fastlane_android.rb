default_platform(:android)

platform :android do
  # Build debug APK
  desc "Build debug APK"
  lane :debug do
    gradle(task: "clean assembleDebug")
  end

  # Build release APK
  desc "Build release APK"
  lane :build_apk do
    gradle(task: "clean assembleRelease")
  end

  # Build release AAB (App Bundle)
  desc "Build release AAB"
  lane :build_aab do
    gradle(task: "clean bundleRelease")
  end

  # Build both APK and AAB
  desc "Build both APK and AAB for release"
  lane :build_release do
    build_apk
    build_aab
  end

  # Deploy to Google Play Internal Testing
  desc "Deploy to Google Play Internal Testing"
  lane :internal do
    build_aab
    upload_to_play_store(
      track: 'internal',
      aab: 'app/build/outputs/bundle/release/app-release.aab',
      skip_upload_apk: true,
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  # Deploy to Google Play Alpha (Closed Testing)
  desc "Deploy to Google Play Alpha"
  lane :alpha do
    build_aab
    upload_to_play_store(
      track: 'alpha',
      aab: 'app/build/outputs/bundle/release/app-release.aab',
      skip_upload_apk: true
    )
  end

  # Deploy to Google Play Beta (Open Testing)
  desc "Deploy to Google Play Beta"
  lane :beta do
    build_aab
    upload_to_play_store(
      track: 'beta',
      aab: 'app/build/outputs/bundle/release/app-release.aab',
      skip_upload_apk: true
    )
  end

  # Deploy to Google Play Production
  desc "Deploy to Google Play Production"
  lane :production do
    build_aab
    upload_to_play_store(
      track: 'production',
      aab: 'app/build/outputs/bundle/release/app-release.aab',
      skip_upload_apk: true
    )
  end

  # Increment version and build
  desc "Increment version and build release"
  lane :bump_and_build do
    increment_version_code
    increment_version_name(
      bump_type: "patch" # or "minor" or "major"
    )
    build_release
  end

  # Error handling
  error do |lane, exception, options|
    slack(
      message: "❌ Build failed in lane #{lane}: #{exception}",
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    ) if ENV["SLACK_WEBHOOK_URL"]
  end
end