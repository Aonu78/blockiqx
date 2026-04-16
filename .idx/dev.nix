{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = [
    pkgs.flutter
    pkgs.jdk17
    pkgs.unzip
    pkgs.git
    pkgs.apt
    pkgs.curl
    pkgs.android-tools
  ];

  env = {
    ANDROID_SDK_ROOT = "/android-sdk";
  };

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    workspace = {
      onCreate = {
        flutter-precache = "flutter precache";
      };
    };
  };
}