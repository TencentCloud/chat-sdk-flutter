import 'dart:ffi';

import 'package:tencent_im_sdk_plugin_desktop/utils/tools.dart';

import 'ffi.dart';

class LoadDyLib {
  DynamicLibrary load() {
    // String p = resolveDylibPath(
    //   'libim_flutter_desktop_lib'
    // );
    // print(const String.fromEnvironment("IM_DESKTOP_LIB_PATH"));
    // print("当前路径");
    // print(p);
    // String p = Platform.script
    // .resolve(Tools.getDyLibNameByPlatform())
    // .toFilePath();
    final DynamicLibrary nativeAddLib =
        getDyLibModule(Tools.getDyLibNameByPlatform());
    // final DynamicLibrary nativeAddLib = DynamicLibrary.open(p);
    return nativeAddLib;
  }
}
