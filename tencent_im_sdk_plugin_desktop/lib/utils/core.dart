import 'dart:io' show Directory;
import 'package:path/path.dart' show join;

import './env.dart';

abstract class TargetPath {
  String getDebugPath();
  String getReleasePath() =>
      join(Directory.current.path, 'data', 'flutter_assets');
  String getCurrentPath() => isProduct() ? getReleasePath() : getDebugPath();
}

class Windows extends TargetPath {
  @override
  String getDebugPath() {
    String p = join(
      Directory.current.path,
      'build',
      'windows',
      'runner',
      'Debug',
      'data',
      'flutter_assets',
      "packages\\tencent_im_sdk_plugin_desktop\\assets",
    );
    if (!Directory(p).existsSync()) {
      print("dll not found");
    }
    return p;
  }
}

class Linux extends TargetPath {
  @override
  String getDebugPath() => join(Directory.current.path,
      'build/linux/debug/bundle', 'data', 'flutter_assets');
}

class Macos extends TargetPath {
  @override
  String getDebugPath() {
    String p = join(
      Directory.current.path,
      'build/macos/Build/Products/Debug/App.framework/Versions/Current',
      'Resources',
      'flutter_assets',
      "packages",
      "tencent_im_sdk_plugin_desktop",
      "assets",
    );
    if (!Directory(p).existsSync()) {
      print("dll not found");
    }
    return p;
  }
}
