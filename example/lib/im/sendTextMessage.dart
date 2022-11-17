import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:example/im/friendSelector.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_extension.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_extension_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SendTextMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendTextMessageState();
}

class SendTextMessageState extends State<SendTextMessage> {
  Map<String, dynamic>? resData;
  String text = '';
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  sendTextMessage() async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(text: text);
    String id = createMessage.data!.id!;

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id,
              receiver: receiver.isNotEmpty ? receiver.first : "",
              groupID: groupID.isNotEmpty ? groupID.first : "",
              priority: priority,
              onlineUserOnly: onlineUserOnly,
              isExcludedFromUnreadCount: isExcludedFromUnreadCount,
              localCustomData: imt("自定义localCustomData"),
              cloudCustomData: "",
              needReadReceipt: true,
              isSupportMessageExtension: true,
            );
    print(res.toJson());
    print("设置消息扩展");
    V2TimMessageExtension ext = V2TimMessageExtension(
        extensionKey: "test", extensionValue: "xingchenhe");
    V2TimValueCallback<List<V2TimMessageExtensionResult>> extreslres =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .setMessageExtensions(
              msgID: res.data?.msgID ?? "",
              extensions: List.from([ext]),
            );
    print(extreslres.toJson());
    ext.extensionValue = "new xingchenhe";
    V2TimValueCallback<List<V2TimMessageExtensionResult>> extreslres1 =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .setMessageExtensions(
              msgID: res.data?.msgID ?? "",
              extensions: List.from([ext]),
            );
    print(extreslres1.toJson());
    print("获取消息扩展");
    V2TimValueCallback<List<V2TimMessageExtension>> extlres =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .getMessageExtensions(
              msgID: res.data?.msgID ?? "",
            );
    print(extlres.toJson());
    print("删除消息扩展");
    V2TimValueCallback<List<V2TimMessageExtensionResult>> extdelres =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .deleteMessageExtensions(
      msgID: res.data?.msgID ?? "",
      keys: ["test"],
    );
    print(extdelres.toJson());
    setState(() {
      resData = res.toJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: imt("发送文本"),
                    hintText: imt("文本内容"),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      text = res;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    receiver = data;
                  });
                },
                switchSelectType: true,
                value: receiver,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      receiver.length > 0 ? receiver.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          Row(
            children: [
              GroupSelector(
                onSelect: (data) {
                  setState(() {
                    groupID = data;
                  });
                },
                switchSelectType: true,
                value: groupID,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      groupID.length > 0 ? groupID.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black45,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      showAdaptiveActionSheet(
                        context: context,
                        title: Text(imt("优先级")),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_HIGH'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_HIGH;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_DEFAULT'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_LOW'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_LOW;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_NORMAL'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_NORMAL;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        cancelAction: CancelAction(
                          title: const Text('Cancel'),
                        ), // onPressed parameter is optional by default will dismiss the ActionSheet
                      );
                    },
                    child: Text(imt("选择优先级")),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text("已选：$priority"),
                )
              ],
            ),
          ),
          Row(
            children: [
              Text(imt("是否仅在线用户接受到消息")),
              Switch(
                value: onlineUserOnly,
                onChanged: (res) {
                  setState(() {
                    onlineUserOnly = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("发送消息是否不计入未读数")),
              Switch(
                value: isExcludedFromUnreadCount,
                onChanged: (res) {
                  setState(() {
                    isExcludedFromUnreadCount = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendTextMessage,
                  child: Text(imt("发送文本消息")),
                ),
              )
            ],
          ),
          SDKResponse(resData),
        ],
      ),
    );
  }
}
