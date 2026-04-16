{ pkgs, ... }:
let
  android-sdk = pkgs.android-sdk.compose ({
    buildToolsVersions = [ "34.0.0" ];
    platformVersions = [ "34" ];
    cmdlineToolsVersion = "11076708";
    emulator = true;
    platforms = [ "android-34" ];
    systemImages = [ "system-images;android-34;google_apis;x86_64" ];
  });
in
{
  channel = "stable-24.05";

  packages = [
    pkgs.flutter
    pkgs.jdk17
    pkgs.unzip
    pkgs.git
    pkgs.apt
    pkgs.curl
    android-sdk
  ];

  env = {
    ANDROID_SDK_ROOT = "${android-sdk}";
  };

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    preStart = {
      # Accept Android SDK licenses
      android-sdk-licenses = ''
        yes | ${android-sdk}/bin/sdkmanager --licenses
      '';
      # Create Android Virtual Device
      android-avd = ''
        echo "no" | ${android-sdk}/bin/avdmanager create avd -n "pixel_8_pro" -k "system-images;android-34;google_apis;x86_64" --force
      '';
    };

    start = {
      # Start the Android emulator
      emulator = {
        command = "${android-sdk}/bin/emulator -avd pixel_8_pro -no-snapshot -no-boot-anim -no-audio";
        name = "Android Emulator";
        description = "Starts the Android emulator with the 'pixel_8_pro' AVD.";
      };
    };
  };
}
