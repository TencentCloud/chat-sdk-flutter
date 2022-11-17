import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:flutter/services.dart';

/// TencentImSDKPlugin entry
///
class TencentImSDKPlugin {
  static const MethodChannel _channel =
      const MethodChannel('tencent_im_sdk_plugin');

  static V2TIMManager? manager;

  static V2TIMManager managerInstance() {
    if (manager == null) {
      manager = V2TIMManager(_channel);
    }

    return manager!;
  }

  static V2TIMManager v2TIMManager = TencentImSDKPlugin.managerInstance();
}
