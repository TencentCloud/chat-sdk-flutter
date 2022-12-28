import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';

/// V2TimConversationResult
///
/// {@category Models}
///
class V2TimMessageListResult {
  bool isFinished = false;
  List<V2TimMessage> messageList = List.empty(growable: true);

  V2TimMessageListResult({
    required this.isFinished,
    required this.messageList,
  });

  V2TimMessageListResult.fromJson(Map<String, dynamic> json) {
    isFinished = json['isFinished'] ?? false;
    if (json['messageList'] != null) {
      messageList = List.empty(growable: true);
      for (var v in List.from(json['messageList'])) {
        messageList.add(V2TimMessage.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isFinished'] = isFinished;
    if (messageList.isNotEmpty) {
      data['messageList'] = messageList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
