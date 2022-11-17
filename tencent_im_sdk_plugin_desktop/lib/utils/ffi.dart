import 'dart:ffi' as ffi;
import 'dart:io' show Directory, Platform;
import 'package:path/path.dart' show join;
import 'package:tencent_im_sdk_plugin_desktop/utils/tools.dart';

import './core.dart';

/// You can use the [getDyLibModule] function to open the dylib defined in the `assets` field of `pubsepc.yaml`.
///
/// For example:
/// clang code
/// ```
/// int add(int a, int b) {
///   return a + b;
/// }
///
/// // gcc -shared -fPIC -o libadd.dll main.c     (Windows)
/// // gcc -shared -fPIC -o libadd.so main.c      (Linux)
/// // clang -shared -fPIC -o libadd.dylib main.c (MacOS)
///
/// // Finally: {PROJECT_ROOT}/assets/libadd.dll (must be declared in `pubsepc.yaml` file)
/// ```
///
///
///Dart code
/// ```
/// import 'dart:ffi' as ffi;
/// import 'package:call/call.dart';
///
/// typedef FuncNative = ffi.Int32 Function(ffi.Int32, ffi.Int32);
/// typedef FuncDart = int Function(int, int);
///
/// var dll = getDyLibModule('assets/libadd.dll');
/// var add = dll.lookupFunction<FuncNative, FuncDart>('add');
///
/// print(add(999, 54639));     // Output: 55638
/// ```
ffi.DynamicLibrary getDyLibModule(List<String> module) {
  String path = '';
  if (Platform.isWindows) {
    path = Windows().getCurrentPath();
  } else if (Platform.isLinux) {
    path = Linux().getCurrentPath();
  } else if (Platform.isMacOS) {
    path = Macos().getCurrentPath();
  } else {
    throw 'The version lib doesn\'t support the platform';
  }
  for (String element in module) {
    path = join(path, element);
  }
  return ffi.DynamicLibrary.open(path);
}

String getDylibPath() {
  String path = '';
  if (Platform.isWindows) {
    path = Windows().getCurrentPath();
  } else if (Platform.isLinux) {
    path = Linux().getCurrentPath();
  } else if (Platform.isMacOS) {
    path = Macos().getCurrentPath();
  } else {
    throw 'The version lib doesn\'t support the platform';
  }
  for (String element in Tools.getDyLibNameByPlatform(isOrigin: true)) {
    path = join(path, element);
  }
  return path;
}
