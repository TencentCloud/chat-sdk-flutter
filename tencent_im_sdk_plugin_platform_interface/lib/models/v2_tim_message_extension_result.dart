import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_extension.dart';

/// V2TimMessageExtensionResult
///
/// {@category Models}
///
class V2TimMessageExtensionResult {
  late int resultCode;
  late String resultInfo;
  late V2TimMessageExtension? extension;

  V2TimMessageExtensionResult({
    required this.resultCode,
    required this.resultInfo,
    required this.extension,
  });

  V2TimMessageExtensionResult.fromJson(Map<String, dynamic> json) {
    resultCode = json["resultCode"] ?? -1;
    resultInfo = json["resultInfo"] ?? "";
    if (json["extension"] != null) {
      extension = V2TimMessageExtension.fromJson(json["extension"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["resultCode"] = resultCode;
    data["resultInfo"] = resultInfo;
    data["extension"] = extension?.toJson();
    return data;
  }
}
