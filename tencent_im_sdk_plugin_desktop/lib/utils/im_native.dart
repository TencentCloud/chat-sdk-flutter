import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:shell/shell.dart';
import 'package:tencent_im_sdk_plugin_desktop/utils/ffi.dart';
import 'package:tencent_im_sdk_plugin_desktop/utils/generated_bindings_wrap.dart';
import 'package:tencent_im_sdk_plugin_desktop/utils/load_dylib.dart';
import 'package:tencent_im_sdk_plugin_desktop/utils/tools.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/V2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversationList_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_topic_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_status.dart';
// import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';

class IMNative {
  static final desktopSDK = NativeBindings(LoadDyLib().load());
  // static late TIMCommCallback cb;
  static final ReceivePort _receivePort = ReceivePort();
  static final Map<String, Map> catchNativeData = Map.from({});
  static final Map<String, V2TimAdvancedMsgListener> advanceMessageListenerMap =
      Map.from({});
  static final Map<String, V2TimSDKListener> timSDKListenerMap = Map.from({});
  static final Map<String, V2TimGroupListener> timGroupListenerMap =
      Map.from({});
  static final Map<String, V2TimConversationListener>
      timConversationListenerMap = Map.from({});

  static final Map<String, Map<String, dynamic>> createdMessage = Map.from({});
  static final Shell shell = Shell();
  static void _handleNativeMessage(dynamic message) {
    try {
      final String data = message;
      Map<String, dynamic> dataFromNative = json.decode(data);
      // print(dataFromNative);
      String callback = dataFromNative["callback"];

      _handleNativeCallback(callback, dataFromNative);
    } catch (err) {
      print("fatal error _handleNativeMessage error $message $err");
    }
    // desktopSDK.executeCallback(Pointer<Void>.fromAddress(address).cast());
  }

  static Future<void> _handleNativeCallback(
      String callbackName, Map<String, dynamic> dataFromNative) async {
    switch (callbackName) {
      case "tim_common_callback":
        String user_data = dataFromNative["user_data"];
        catchNativeData.addAll({
          user_data: dataFromNative,
        });
        break;
      case "tim_recv_new_msg_callback":
        // 这里需要解析一下群系统通知为群事件
        // try {
        String user_data = dataFromNative["user_data"];
        List<Map<String, dynamic>> messageList =
            List<Map<String, dynamic>>.from(
                json.decode(dataFromNative['json_param']));
        for (var element in messageList) {
          if (element["message_elem_array"] != null &&
              List.from(element["message_elem_array"]).isNotEmpty) {
            List<Map<String, dynamic>> elemList =
                List.from(element["message_elem_array"]);
            for (var elem in elemList) {
              if (elem["elem_type"] == 8) {
                int reportType = elem["group_report_elem_report_type"];
                switch (reportType) {
                  case 1:
                    String groupID = elem["group_report_elem_group_id"];
                    String msg = elem["group_report_elem_msg"];
                    V2TimGroupMemberInfo info =
                        Tools.converV2TimGroupMemberInfo(elem);
                    timGroupListenerMap.forEach((key, value) {
                      value.onReceiveJoinApplication(groupID, info, msg);
                    });
                    break;
                  case 2:
                    String groupID = elem["group_report_elem_group_id"];
                    String msg = elem["group_report_elem_msg"];
                    V2TimGroupMemberInfo info =
                        Tools.converV2TimGroupMemberInfo(elem);
                    timGroupListenerMap.forEach((key, value) {
                      value.onApplicationProcessed(groupID, info, true, msg);
                    });
                    break;
                  case 3:
                    String groupID = elem["group_report_elem_group_id"];
                    String msg = elem["group_report_elem_msg"];
                    V2TimGroupMemberInfo info =
                        Tools.converV2TimGroupMemberInfo(elem);
                    timGroupListenerMap.forEach((key, value) {
                      value.onApplicationProcessed(groupID, info, false, msg);
                    });
                    break;
                  case 4:
                    String groupID = elem["group_report_elem_group_id"];
                    V2TimGroupMemberInfo opUser =
                        Tools.converOpV2TimGroupMemberInfo(elem);
                    List<V2TimGroupMemberInfo> memberList =
                        List.empty(growable: true);
                    memberList.add(Tools.converV2TimGroupMemberInfo(elem));
                    timGroupListenerMap.forEach((key, value) {
                      value.onMemberKicked(groupID, opUser, memberList);
                    });
                    break;
                  case 5:
                    String groupID = elem["group_report_elem_group_id"];
                    V2TimGroupMemberInfo info =
                        Tools.converOpV2TimGroupMemberInfo(elem);
                    timGroupListenerMap.forEach((key, value) {
                      value.onGroupDismissed(groupID, info);
                    });
                    break;
                  case 6:
                    String groupID = elem["group_report_elem_group_id"];
                    timGroupListenerMap.forEach((key, value) {
                      value.onGroupCreated(groupID);
                    });
                    break;
                  case 7:
                    String groupID = elem["group_report_elem_group_id"];
                    V2TimGroupMemberInfo opUser =
                        Tools.converOpV2TimGroupMemberInfo(elem);
                    List<V2TimGroupMemberInfo> memberList =
                        List.empty(growable: true);
                    memberList.add(Tools.converV2TimGroupMemberInfo(elem));
                    timGroupListenerMap.forEach((key, value) {
                      value.onMemberInvited(groupID, opUser, memberList);
                    });
                    break;
                  case 8:
                    String groupID = elem["group_report_elem_group_id"];
                    timGroupListenerMap.forEach((key, value) {
                      value.onQuitFromGroup(groupID);
                    });
                    break;
                  case 9:
                    String groupID = elem["group_report_elem_group_id"];
                    V2TimGroupMemberInfo opUser =
                        Tools.converOpV2TimGroupMemberInfo(elem);
                    List<V2TimGroupMemberInfo> memberList =
                        List.empty(growable: true);
                    memberList.add(Tools.converV2TimGroupMemberInfo(elem));
                    timGroupListenerMap.forEach((key, value) {
                      value.onGrantAdministrator(groupID, opUser, memberList);
                    });
                    // 设置管理员
                    break;
                  case 10:
                    String groupID = elem["group_report_elem_group_id"];
                    V2TimGroupMemberInfo opUser =
                        Tools.converOpV2TimGroupMemberInfo(elem);
                    List<V2TimGroupMemberInfo> memberList =
                        List.empty(growable: true);
                    memberList.add(Tools.converV2TimGroupMemberInfo(elem));
                    timGroupListenerMap.forEach((key, value) {
                      value.onRevokeAdministrator(groupID, opUser, memberList);
                    });
                    // 取消管理员
                    break;
                  case 11:
                    String groupID = elem["group_report_elem_group_id"];
                    V2TimGroupMemberInfo opUser =
                        Tools.converOpV2TimGroupMemberInfo(elem);
                    timGroupListenerMap.forEach((key, value) {
                      value.onGroupRecycled(groupID, opUser);
                    });
                    // 取消管理员
                    break;
                  case 16:
                    String groupID = elem["group_report_elem_group_id"];
                    String customData = elem["group_report_elem_user_data"];
                    timGroupListenerMap.forEach((key, value) {
                      value.onReceiveRESTCustomData(groupID, customData);
                    });
                    // 取消管理员
                    break;
                }
                return;
              }
            }
          }
          V2TimMessage message = Tools.convertMessage2Dart(element);
          if (advanceMessageListenerMap[user_data] != null) {
            advanceMessageListenerMap[user_data]!.onRecvNewMessage(message);
          }
        }
        // } catch (err) {
        //   print(err);
        // }
        break;
      case "tim_msg_group_message_read_member_list_callback":
        String user_data = dataFromNative["user_data"];
        catchNativeData.addAll({
          user_data: dataFromNative,
        });
        break;
      case "tim_network_status_listener_callback":
        String user_data = dataFromNative["user_data"];
        int code = dataFromNative["code"];
        int status = dataFromNative["status"];
        String desc = dataFromNative["desc"];
        if (timSDKListenerMap.containsKey(user_data)) {
          if (status == 0) {
            timSDKListenerMap[user_data]!.onConnectSuccess();
          } else if (status == 1) {
            timSDKListenerMap[user_data]!.onConnectFailed(code, desc);
          } else if (status == 2) {
            timSDKListenerMap[user_data]!.onConnecting();
          } else if (status == 3) {
            timSDKListenerMap[user_data]!.onConnectFailed(code, desc);
          }
        }
        break;
      case "tim_kicked_offline_callback":
        String user_data = dataFromNative["user_data"];
        if (timSDKListenerMap[user_data] != null) {
          timSDKListenerMap[user_data]!.onKickedOffline();
        }
        break;
      case "tim_user_sig_expired_callback":
        String user_data = dataFromNative["user_data"];
        if (timSDKListenerMap[user_data] != null) {
          timSDKListenerMap[user_data]!.onUserSigExpired();
        }
        break;
      case "tim_self_info_updated_callback":
        String user_data = dataFromNative["user_data"];
        if (timSDKListenerMap[user_data] != null) {
          Map<String, dynamic> userProfile =
              Map.from(json.decode(dataFromNative["json_user_profile"]));
          timSDKListenerMap[user_data]!.onSelfInfoUpdated(
              Tools.userProfile2DartUserFullInfo(userProfile));
        }
        break;
      case "tim_user_status_changed_callback":
        String user_data = dataFromNative["user_data"];
        if (timSDKListenerMap[user_data] != null) {
          List<Map<String, dynamic>> userProfile =
              List.from(json.decode(dataFromNative["json_user_status_array"]));
          List<V2TimUserStatus> dartList = List.empty(growable: true);
          for (var element in userProfile) {
            dartList.add(V2TimUserStatus.fromJson({
              "userID": element["user_status_identifier"],
              "statusType": element["user_status_status_type"],
              "customStatus": element["user_status_custom_status"]
            }));
          }
          timSDKListenerMap[user_data]!.onUserStatusChanged(dartList);
        }
        break;
      case "tim_msg_revoke_callback":
        String user_data = dataFromNative["user_data"];
        if (advanceMessageListenerMap[user_data] != null) {
          List<Map<String, dynamic>> nativeMessageList =
              List.from(json.decode(dataFromNative["json_param"]));
          List<String> ids =
              await IMNative.TIMMsgFindByMsgLocatorList(nativeMessageList);
          for (var element in ids) {
            advanceMessageListenerMap[user_data]?.onRecvMessageRevoked(element);
          }
        }
        break;
      case "tim_msg_update_callback":
        String user_data = dataFromNative["user_data"];
        if (advanceMessageListenerMap[user_data] != null) {
          List<Map<String, dynamic>> nativeMessageList =
              List.from(json.decode(dataFromNative["json_msg_array"]));
          List<V2TimMessage> dartMessage = List.empty(growable: true);
          for (var element in nativeMessageList) {
            dartMessage.add(Tools.convertMessage2Dart(element));
          }
          for (V2TimMessage msg in dartMessage) {
            advanceMessageListenerMap[user_data]?.onRecvMessageModified(msg);
          }
        }
        break;
      case "tim_msg_readed_receipt_callback":
        String user_data = dataFromNative["user_data"];

        if (advanceMessageListenerMap[user_data] != null) {
          List<Map<String, dynamic>> nativeReceiptList =
              List.from(json.decode(dataFromNative["json_param"]));
          List<V2TimMessageReceipt> dartc2cList = List.empty(growable: true);
          List<V2TimMessageReceipt> dartgroupList = List.empty(growable: true);
          for (var element in nativeReceiptList) {
            if (element["msg_receipt_conv_type"] == 1) {
              dartc2cList.add(V2TimMessageReceipt.fromJson({
                "userID": element["msg_receipt_conv_id"],
                "msgID": element["msg_receipt_msg_id"],
                "timestamp": element["msg_receipt_time_stamp"],
                "readCount": element["msg_receipt_read_count"],
                "unreadCount": element["msg_receipt_unread_count"],
              }));
            } else {
              dartgroupList.add(V2TimMessageReceipt.fromJson({
                "groupID": element["msg_receipt_conv_id"],
                "msgID": element["msg_receipt_msg_id"],
                "timestamp": element["msg_receipt_time_stamp"] ??
                    (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
                "readCount": element["msg_receipt_read_count"],
                "unreadCount": element["msg_receipt_unread_count"],
              }));
            }
          }
          if (dartc2cList.isNotEmpty) {
            advanceMessageListenerMap[user_data]
                ?.onRecvC2CReadReceipt(dartc2cList);
          }
          if (dartgroupList.isNotEmpty) {
            advanceMessageListenerMap[user_data]
                ?.onRecvMessageReadReceipts(dartgroupList);
          }
        }
        break;
      case "tim_msg_elem_upload_progress_callback":
        String user_data = dataFromNative["user_data"];
        if (advanceMessageListenerMap[user_data] != null) {
          V2TimMessage message = Tools.convertMessage2Dart(
              Map<String, dynamic>.from(
                  json.decode(dataFromNative["json_param"])));
          int cur_size = dataFromNative["cur_size"];
          int total_size = dataFromNative["total_size"];
          int progress = (cur_size / total_size).floor();
          advanceMessageListenerMap[user_data]
              ?.onSendMessageProgress(message, progress);
        }
        break;
      case "tim_group_tips_event_callback":
        print(dataFromNative);
        String user_data = dataFromNative["user_data"];
        if (timGroupListenerMap.containsKey(user_data)) {
          Map<String, dynamic> tip =
              Map.from(json.decode(dataFromNative["json_param"]));
          int tipsType = tip["group_tips_elem_tip_type"];
          String groupID = tip["group_tips_elem_group_id"];
          switch (tipsType) {
            case 7:
              List<Map<String, dynamic>> changeMemberInfoList =
                  List.from(tip["group_tips_elem_member_change_info_array"]);
              List<V2TimGroupMemberChangeInfo> dartList =
                  List.empty(growable: true);
              for (var element in changeMemberInfoList) {
                dartList.add(V2TimGroupMemberChangeInfo.fromJson({
                  "userID": element["group_tips_member_change_info_identifier"],
                  "muteTime":
                      element["group_tips_member_change_info_shutupTime"]
                }));
              }
              timGroupListenerMap[user_data]
                  ?.onMemberInfoChanged(groupID, dartList);
              break;
            case 6:
              List<Map<String, dynamic>> changeMemberInfoList =
                  List.from(tip["group_tips_elem_group_change_info_array"]);
              List<V2TimGroupChangeInfo> dartList = List.empty(growable: true);
              for (var element in changeMemberInfoList) {
                dartList.add(V2TimGroupChangeInfo.fromJson({
                  "type": element["group_tips_group_change_info_flag"],
                  "value": element["group_tips_group_change_info_value"],
                  "key": element["group_tips_group_change_info_key"],
                  "boolValue":
                      element["group_tips_group_change_info_bool_value"]
                }));
              }
              timGroupListenerMap[user_data]
                  ?.onGroupInfoChanged(groupID, dartList);
              // timGroupListenerMap[user_data]?.onMemberEnter
              // timGroupListenerMap[user_data]?.onMemberLeave

              break;
            case 3:
              Map<String, dynamic> memberInfo =
                  tip["group_tips_elem_op_group_memberinfo"];

              timGroupListenerMap[user_data]?.onMemberLeave(
                  groupID,
                  V2TimGroupMemberInfo.fromJson({
                    "userID": memberInfo["group_member_info_identifier"],
                    "nickName": memberInfo["group_member_info_nick_name"],
                    "nameCard": memberInfo["group_member_info_name_card"],
                    "friendRemark": memberInfo["group_member_info_remark"],
                    "faceUrl": memberInfo["group_member_info_face_url"]
                  }));

              break;
          }
        }
        break;
      case "tim_group_attribute_changed_callback":
        String user_data = dataFromNative["user_data"];
        String groupID = dataFromNative["group_id"];
        if (timGroupListenerMap.containsKey(user_data)) {
          List<Map<String, dynamic>> nativeList =
              List.from(json.decode(dataFromNative["json_param"]));
          Map<String, String> customdata = Map.from({});
          for (var element in nativeList) {
            customdata.addAll({
              element["group_atrribute_key"]: element["group_atrribute_value"]
            });
          }
          timGroupListenerMap[user_data]
              ?.onGroupAttributeChanged(groupID, customdata);
        }
        break;
      case "tim_group_topic_created_callback":
        String user_data = dataFromNative["user_data"];
        String groupID = dataFromNative["group_id"];
        String topicID = dataFromNative["topic_id"];
        if (timGroupListenerMap.containsKey(user_data)) {
          timGroupListenerMap[user_data]?.onTopicCreated(groupID, topicID);
        }
        break;
      case "tim_group_topic_deleted_callback":
        String user_data = dataFromNative["user_data"];
        String groupID = dataFromNative["group_id"];
        List<String> topicIDs =
            List<String>.from(json.decode(dataFromNative["topic_id_array"]));
        if (timGroupListenerMap.containsKey(user_data)) {
          timGroupListenerMap[user_data]?.onTopicDeleted(groupID, topicIDs);
        }
        break;
      case "tim_group_topic_changed_callback":
        String user_data = dataFromNative["user_data"];
        String groupID = dataFromNative["group_id"];
        Map<String, dynamic> topicInfo =
            Map.from(json.decode(dataFromNative["topic_info"]));
        if (timGroupListenerMap.containsKey(user_data)) {
          timGroupListenerMap[user_data]?.onTopicInfoChanged(
              groupID, Tools.convert2DartTopicInfo(topicInfo));
        }
        break;
      case "tim_conv_event_callback":
        String user_data = dataFromNative["user_data"];
        int conv_event = dataFromNative["conv_event"];
        if (timConversationListenerMap.containsKey(user_data)) {
          List<Map<String, dynamic>> json_conv_array =
              List<Map<String, dynamic>>.from(json.decode(
                  dataFromNative["json_conv_array"].isEmpty
                      ? json.encode([])
                      : dataFromNative["json_conv_array"]));
          List<V2TimConversation> json_conv_array_dart =
              List.empty(growable: true);
          for (var element in json_conv_array) {
            json_conv_array_dart.add(Tools.convertConvInfo2Dart(element));
          }
          switch (conv_event) {
            case 0:
              // add
              timConversationListenerMap[user_data]
                  ?.onNewConversation(json_conv_array_dart);
              break;
            case 1:
              // del 不处理
              break;
            case 2:
              timConversationListenerMap[user_data]
                  ?.onConversationChanged(json_conv_array_dart);
              break;
            case 3:
              timConversationListenerMap[user_data]?.onSyncServerStart();
              // start
              break;
            case 4:
              timConversationListenerMap[user_data]?.onSyncServerFinish();
              // finish
              break;
          }
        }
        break;
      case "tim_conv_total_unread_message_count_changed_callback":
        String user_data = dataFromNative["user_data"];
        int conv_event = dataFromNative["conv_event"];
        if (timConversationListenerMap.containsKey(user_data)) {
          timConversationListenerMap[user_data]
              ?.onTotalUnreadMessageCountChanged(conv_event);
        }
        break;
      case "tim_conv_conversation_group_created_callback":
        String user_data = dataFromNative["user_data"];
        String group_name = dataFromNative["group_name"];

        if (timConversationListenerMap.containsKey(user_data)) {
          List<Map<String, dynamic>> json_conv_array =
              List<Map<String, dynamic>>.from(json.decode(
                  dataFromNative["conversation_array"].isEmpty
                      ? json.encode([])
                      : dataFromNative["conversation_array"]));
          List<V2TimConversation> json_conv_array_dart =
              List.empty(growable: true);
          for (var element in json_conv_array) {
            json_conv_array_dart.add(Tools.convertConvInfo2Dart(element));
          }
          timConversationListenerMap[user_data]
              ?.onConversationGroupCreated(group_name, json_conv_array_dart);
        }
        break;
      case "tim_conv_conversation_group_deleted_callback":
        String user_data = dataFromNative["user_data"];
        String group_name = dataFromNative["group_name"];

        if (timConversationListenerMap.containsKey(user_data)) {
          timConversationListenerMap[user_data]
              ?.onConversationGroupDeleted(group_name);
        }
        break;
      case "tim_conv_conversation_groupName_changed_callback":
        String user_data = dataFromNative["user_data"];
        String old_name = dataFromNative["old_name"];
        String new_name = dataFromNative["new_name"];
        if (timConversationListenerMap.containsKey(user_data)) {
          timConversationListenerMap[user_data]
              ?.onConversationGroupNameChanged(old_name, new_name);
        }
        break;
      case "tim_conv_conversations_added_to_group_callback":
        String user_data = dataFromNative["user_data"];
        String group_name = dataFromNative["group_name"];
        if (timConversationListenerMap.containsKey(user_data)) {
          List<Map<String, dynamic>> json_conv_array =
              List<Map<String, dynamic>>.from(json.decode(
                  dataFromNative["conversation_array"].isEmpty
                      ? json.encode([])
                      : dataFromNative["conversation_array"]));
          List<V2TimConversation> json_conv_array_dart =
              List.empty(growable: true);
          for (var element in json_conv_array) {
            json_conv_array_dart.add(Tools.convertConvInfo2Dart(element));
          }
          timConversationListenerMap[user_data]
              ?.onConversationsAddedToGroup(group_name, json_conv_array_dart);
        }
        break;
      case "tim_conv_conversations_deleted_from_group_callback":
        String user_data = dataFromNative["user_data"];
        String group_name = dataFromNative["group_name"];
        if (timConversationListenerMap.containsKey(user_data)) {
          List<Map<String, dynamic>> json_conv_array =
              List<Map<String, dynamic>>.from(json.decode(
                  dataFromNative["conversation_array"].isEmpty
                      ? json.encode([])
                      : dataFromNative["conversation_array"]));
          List<V2TimConversation> json_conv_array_dart =
              List.empty(growable: true);
          for (var element in json_conv_array) {
            json_conv_array_dart.add(Tools.convertConvInfo2Dart(element));
          }
          timConversationListenerMap[user_data]
              ?.onConversationsDeletedFromGroup(
                  group_name, json_conv_array_dart);
        }
        break;
    }
  }

  static Future<void> addConversationListener({
    required V2TimConversationListener listener,
    String? listenerUuid,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    desktopSDK.D_TIMSetConvEventCallback(user_data);
    desktopSDK.D_TIMSetConvTotalUnreadMessageCountChangedCallback(user_data);
    desktopSDK.D_TIMSetConvConversationGroupCreatedCallback(user_data);
    desktopSDK.D_TIMSetConvConversationGroupDeletedCallback(user_data);
    desktopSDK.D_TIMSetConvConversationGroupNameChangedCallback(user_data);
    desktopSDK.D_TIMSetConvConversationsAddedToGroupCallback(user_data);
    desktopSDK.D_TIMSetConvConversationsDeletedFromGroupCallback(user_data);
  }

  static Future<void> addGroupListener({
    required V2TimGroupListener listener,
    String? listenerUuid,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    desktopSDK.D_TIMSetGroupTipsEventCallback(user_data);
    desktopSDK.D_TIMSetGroupAttributeChangedCallback(user_data);
    desktopSDK.D_TIMSetGroupTopicCreatedCallback(user_data);
    desktopSDK.D_TIMSetGroupTopicDeletedCallback(user_data);
    desktopSDK.D_TIMSetGroupTopicChangedCallback(user_data);
    timGroupListenerMap.addAll({userData: listener});
  }

  static Future<List<String>> TIMMsgFindByMsgLocatorList(
      // TODO 这里不确定取第一个id为会话id对不对
      List<Map<String, dynamic>> nativelocatorList) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_msg_Locator_array =
        Tools.string2PointerInt8(json.encode(nativelocatorList));

    String? conv_id;
    int? conv_type;
    if (nativelocatorList.isNotEmpty) {
      conv_id = nativelocatorList.first["message_locator_conv_id"];
      conv_type = nativelocatorList.first["message_locator_conv_type"];
    }
    if (conv_id == null || conv_type == null) {
      return [];
    }
    Pointer<Int8> convid = Tools.string2PointerInt8(conv_id);
    int res = desktopSDK.D_TIMMsgFindByMsgLocatorList(
        convid, conv_type, json_msg_Locator_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return [];
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<String> list = List<String>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;

        list.add(json["message_msg_id"]);
      }

      return list;
    }
  }

  static Future<void> copydyliptoSysTempath() async {
    String path = getDylibPath();
    if (Platform.isMacOS) {
      await shell.start('cp', arguments: [
        "-f",
        path,
        "/usr/local/lib/",
      ]);
    } else if (Platform.isWindows) {
      await shell.start('copy', arguments: [
        path,
        "C:\\Windows\\System32\\",
        "/y",
      ]);
    }
  }

  static Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required int loglevel,
    String? listenerUuid,
    V2TimSDKListener? listener,
    required int uiPlatform,
    bool? showImLog,
  }) async {
    await copydyliptoSysTempath();

    int data = desktopSDK.InitDartApiDL(NativeApi.initializeApiDLData);

    desktopSDK.registerSendPort(_receivePort.sendPort.nativePort);

    _receivePort.listen(_handleNativeMessage);

    Pointer<Int8> json_sdk_config = Tools.string2PointerInt8(json.encode({
      "sdk_config_config_file_path": Directory.current.path,
      "sdk_config_log_file_path": Directory.current.path
    }));
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    if (listener != null) {
      timSDKListenerMap.addAll({userData: listener});
    }

    IMNative.callExperimentalAPI(
      api: "internal_operation_set_ui_platform",
      param: 22,
    );

    _TIMSetNetworkStatusListenerCallback(user_data);
    _TIMSetKickedOfflineCallback(user_data);
    _TIMSetUserSigExpiredCallback(user_data);
    _TIMSetSelfInfoUpdatedCallback(user_data);
    _TIMSetUserStatusChangedCallback(user_data);
    int res = desktopSDK.D_TIMInit(sdkAppID, json_sdk_config);

    return V2TimValueCallback<bool>.fromJson({
      "code": 0,
      "desc": res == 0 ? "success" : "error",
      "data": res == 0 ? true : false,
    });
  }

  static void _TIMSetNetworkStatusListenerCallback(Pointer<Int8> user_data) {
    desktopSDK.D_TIMSetNetworkStatusListenerCallback(user_data);
  }

  static void _TIMSetKickedOfflineCallback(Pointer<Int8> user_data) {
    desktopSDK.D_TIMSetKickedOfflineCallback(user_data);
  }

  static void _TIMSetUserSigExpiredCallback(Pointer<Int8> user_data) {
    desktopSDK.D_TIMSetUserSigExpiredCallback(user_data);
  }

  static void _TIMSetSelfInfoUpdatedCallback(Pointer<Int8> user_data) {
    desktopSDK.D_TIMSetSelfInfoUpdatedCallback(user_data);
  }

  static void _TIMSetUserStatusChangedCallback(Pointer<Int8> user_data) {
    desktopSDK.D_TIMSetUserStatusChangedCallback(user_data);
  }

  static Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    Pointer<Int8> user_id = Tools.string2PointerInt8(userID);
    Pointer<Int8> user_sig = Tools.string2PointerInt8(userSig);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);

    int res = desktopSDK.D_TIMLogin(user_id, user_sig, user_data);

    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<Map<String, dynamic>> countDown(
      int initTime, int timeout, String key) async {
    int ntimeout = timeout - initTime;
    Map<String, dynamic> defaultvalue =
        Map<String, dynamic>.from({"code": 0, "desc": "", "data": ""});
    if (ntimeout <= 0) {
      print("the method $key has timeout check the catchNativeData");
      return defaultvalue;
    }
    await Future.delayed(Duration(milliseconds: initTime));
    if (catchNativeData.containsKey(key)) {
      Map<String, dynamic> res =
          Map<String, dynamic>.from(catchNativeData.remove(key)!);

      return res;
    }
    return countDown(initTime, ntimeout, key);
  }

  static Future<Map<String, dynamic>> getAsyncData(String apiKey) async {
    int initTime =
        30; // the init delay time is 30, and the total timeout time is 1000ms
    int timeout = 3000;
    return await countDown(initTime, timeout, apiKey);
  }

  static void handleCppRequests(dynamic message) {}
  static void doWork(SendPort main) {
    ReceivePort childThread = ReceivePort();
    SendPort main = childThread.sendPort;
    childThread.listen((message) {
      //9.10 rp2收到消息
      print("rp2 收到消息: $message");
    });
  }

  static Future<V2TimValueCallback<String>> getLoginUser() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMGetLoginUserID(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<String>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic>? data = await getAsyncData(userData);
      return V2TimValueCallback<String>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": "${data['json_param']}"
      });
    }
  }

  static Future<V2TimValueCallback<int>> getServerTime() async {
    int time = desktopSDK.D_TIMGetServerTime();
    return V2TimValueCallback<int>.fromJson(
        {"code": 0, "desc": "success", "data": time});
  }

  static Future<V2TimValueCallback<String>> getVersion() async {
    Pointer<Int8> data = desktopSDK.D_TIMGetSDKVersion();

    return V2TimValueCallback<String>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Tools.pointerInt82String(data),
    });
  }

  static Future<V2TimValueCallback<int>> getLoginStatus() async {
    int res = desktopSDK.D_TIMGetLoginStatus();
    return V2TimValueCallback<int>.fromJson({
      "code": 0,
      "desc": "ok",
      "data": res,
    });
  }

  static Future<V2TimCallback> logout() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMLogout(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> filter = Tools.string2PointerInt8(json.encode(Map.from({
      "conversation_list_filter_next_seq": int.parse(nextSeq),
      "conversation_list_filter_count": count,
    })));
    int res =
        desktopSDK.D_TIMConvGetConversationListByFilter(filter, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimConversationResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);

      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        V2TimConversation converInfo = Tools.convertConvInfo2Dart(json);
        list.add(converInfo.toJson());
      }

      return V2TimValueCallback<V2TimConversationResult>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": {"nextSeq": "", "isFinished": true, "conversationList": list}
      });
    }
  }

  static Future<void> addAdvancedMsgListener(
    V2TimAdvancedMsgListener listener,
    String? listenerUuid,
  ) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    // 新消息回调
    desktopSDK.D_TIMAddRecvNewMsgCallback(user_data);
    // 消息撤回
    desktopSDK.D_TIMSetMsgRevokeCallback(user_data);
    // 消息变更
    desktopSDK.D_TIMSetMsgUpdateCallback(user_data);
    // 消息进度
    desktopSDK.D_TIMSetMsgElemUploadProgressCallback(user_data);
    // 消息回执
    desktopSDK.D_TIMSetMsgReadedReceiptCallback(user_data);

    advanceMessageListenerMap.addAll({userData: listener});
  }

  static Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Map<String, dynamic> param = Map.from({
      "friendship_getprofilelist_param_identifier_array": userIDList,
      "friendship_getprofilelist_param_force_update": false,
    });
    Pointer<Int8> paramPtr = Tools.string2PointerInt8(json.encode(param));
    int res = desktopSDK.D_TIMProfileGetUserProfileList(paramPtr, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimUserFullInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        V2TimUserFullInfo converInfo = Tools.userProfile2DartUserFullInfo(json);
        list.add(converInfo.toJson());
      }
      return V2TimValueCallback<List<V2TimUserFullInfo>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<String>> createGroup({
    String? groupID,
    required String groupType,
    required String groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    bool? isAllMuted,
    int? addOpt,
    List<V2TimGroupMember>? memberList,
    bool? isSupportTopic,
  }) async {
    String param = json.encode({
      "create_group_param_group_id": groupID,
      "create_group_param_group_name": groupName,
      "create_group_param_group_type": groupType,
      "create_group_param_is_support_topic": isSupportTopic,
      "create_group_param_group_member_array":
          Tools.generateNativeMemberListByDartParam(memberList ?? []),
      "create_group_param_add_option": addOpt,
      "create_group_param_notification": notification,
      "create_group_param_introduction": introduction,
      "create_group_param_face_url": faceUrl
    });
    Pointer<Int8> json_group_create_param = Tools.string2PointerInt8(param);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMGroupCreate(json_group_create_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<String>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      // 创建成功后，这里通过设置群资料单独设置全员禁言 TODO
      if (isAllMuted != null) {}
      return V2TimValueCallback<String>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": json.decode(data["json_param"])["create_group_result_groupid"]
      });
    }
  }

  static Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    Pointer<Int8> hello_msg = Tools.string2PointerInt8(message);

    int res = desktopSDK.D_TIMGroupJoin(group_id, hello_msg, user_data);

    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMGroupQuit(group_id, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMGroupDelete(group_id, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_modify_self_user_profile_param =
        Tools.string2PointerInt8(
            json.encode(Tools.generateNativeUserInfoByDartParam(userFullInfo)));
    int res = desktopSDK.D_TIMProfileModifySelfUserProfile(
        json_modify_self_user_profile_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    // TODO 这里要做一下其他实验性接口的是适配，目前仅支持设置ui_platform
    Pointer<Int8> json_param = Tools.string2PointerInt8(json.encode(Map.from({
      "request_internal_operation": api,
      "request_set_ui_platform_param": param
    })));
    int res = desktopSDK.D_callExperimentalAPI(json_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<Object>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimValueCallback<Object>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": data["json_param"]
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversaionIds({
    required List<String> conversationIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    List<Map<String, dynamic>> convIdList = List.empty(growable: true);
    for (String element in conversationIDList) {
      convIdList.add(Map.from({
        "get_conversation_list_param_conv_id": element,
        "get_conversation_list_param_conv_type":
            Tools.convertid2convType(element), // TODO，改造入参包含会话类型
      }));
    }
    Pointer<Int8> json_get_conv_list_param =
        Tools.string2PointerInt8(json.encode(convIdList));

    int res =
        desktopSDK.D_TIMConvGetConvInfo(json_get_conv_list_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimConversation>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        V2TimConversation converInfo = Tools.convertConvInfo2Dart(json);
        list.add(converInfo.toJson());
      }
      return V2TimValueCallback<List<V2TimConversation>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<V2TimConversation>> getConversation({
    /*required*/ required String conversationID,
  }) async {
    V2TimValueCallback<List<V2TimConversation>> list =
        await IMNative.getConversationListByConversaionIds(
            conversationIDList: [conversationID]);

    if (list.code == 0) {
      if (list.data!.isNotEmpty) {
        return V2TimValueCallback<V2TimConversation>.fromJson(
            {"code": 0, "desc": "", "data": list.data![0].toJson()});
      } else {
        return V2TimValueCallback<V2TimConversation>.fromJson(
            {"code": 0, "desc": "", "data": null});
      }
    } else {
      return V2TimValueCallback<V2TimConversation>.fromJson(
          {"code": list.code, "desc": list.desc, "data": null});
    }
  }

  static Future<V2TimCallback> deleteConversation({
    /*required*/ required String conversationID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(conversationID);
    int conv_type = Tools.convertid2convType(conversationID);

    int res = desktopSDK.D_TIMConvDelete(conv_id, conv_type, user_data);

    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(conversationID);
    int conv_type = Tools.convertid2convType(conversationID);
    int res = desktopSDK.D_TIMConvPinConversation(
        conv_id, conv_type, isPinned ? 1 : 0, user_data);

    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(conversationID);
    int conv_type = Tools.convertid2convType(conversationID);
    Pointer<Int8> json_draft_param =
        Tools.string2PointerInt8(json.encode(Map<String, dynamic>.from({
      "draft_edit_time": (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
      "draft_msg": draftText
    })));
    int res = desktopSDK.D_TIMConvSetDraft(
        conv_id, conv_type, json_draft_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> cancelConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(conversationID);
    int conv_type = Tools.convertid2convType(conversationID);
    int res = desktopSDK.D_TIMConvCancelDraft(conv_id, conv_type, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMConvGetTotalUnreadMessageCount(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<int>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimValueCallback<int>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": json.decode(data["json_param"].isEmpty
                ? json.encode({})
                : data["json_param"])[
            "conv_get_total_unread_message_count_result_unread_count"]
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendInfo>>>
      getFriendList() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMFriendshipGetFriendProfileList(user_data);

    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> listData = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> dartListData =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in listData) {
        Map<String, dynamic> nativeJson = Map<String, dynamic>.from(element);
        Map<String, dynamic> dartJson =
            Tools.friendProfile2DartFriendInfo(nativeJson).toJson();
        dartListData.add(dartJson);
      }

      return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartListData});
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendInfoResult>>>
      getFriendsInfo({
    required List<String> userIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_get_friends_info_param =
        Tools.string2PointerInt8(json.encode(userIDList));
    int res = desktopSDK.D_TIMFriendshipGetFriendsInfo(
        json_get_friends_info_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> listData = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> dartListData =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in listData) {
        Map<String, dynamic> nativeJson = Map<String, dynamic>.from(element);
        Map<String, dynamic> dartJson = Map<String, dynamic>.from({
          "resultCode":
              nativeJson["friendship_friend_info_get_result_error_code"],
          "resultInfo":
              nativeJson["friendship_friend_info_get_result_error_message"],
          "relation":
              nativeJson["friendship_friend_info_get_result_relation_type"],
          "friendInfo": Tools.friendProfile2DartFriendInfo(
                  nativeJson["friendship_friend_info_get_result_field_info"])
              .toJson()
        });
        dartListData.add(dartJson);
      }
      return V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartListData});
    }
  }

  static Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required int addType,
  }) async {
    String param = json.encode({
      "friendship_add_friend_param_identifier": userID,
      "friendship_add_friend_param_friend_type":
          addType - 1, // 这里有点神奇，和native不一样
      "friendship_add_friend_param_remark": remark,
      "friendship_add_friend_param_add_source": addSource,
      "friendship_add_friend_param_add_wording": addWording,
      "friendship_add_friend_param_group_name": friendGroup,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_add_friend_param = Tools.string2PointerInt8(param);
    int res =
        desktopSDK.D_TIMFriendshipAddFriend(json_add_friend_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimFriendOperationResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeJson = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      Map<String, dynamic> dartJson = Map<String, dynamic>.from({
        "resultCode": nativeJson["friend_result_code"],
        "resultInfo": nativeJson["friend_result_desc"],
        "userID": nativeJson["friend_result_identifier"],
      });

      return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartJson});
    }
  }

  static Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    List<Map<String, dynamic>> customArray = List.empty(growable: true);
    friendCustomInfo?.forEach((key, value) {
      customArray.add({
        "friend_profile_custom_string_info_key": key,
        "friend_profile_custom_string_info_value": value,
      });
    });
    String param = json.encode({
      "friendship_modify_friend_profile_param_identifier": userID,
      "friendship_modify_friend_profile_param_item": Map<String, dynamic>.from({
        "friend_profile_item_remark": friendRemark,
        "friend_profile_item_custom_string_array": customArray,
      }),
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_modify_friend_info_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipModifyFriendProfile(
        json_modify_friend_info_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromFriendList({
    required List<String> userIDList,
    required int deleteType,
  }) async {
    String param = json.encode({
      "friendship_delete_friend_param_friend_type":
          deleteType - 1, //这也是个神奇的地方，和native不一样
      "friendship_delete_friend_param_identifier_array": userIDList
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_delete_friend_param = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipDeleteFriend(
        json_delete_friend_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendOperationResult result =
            V2TimFriendOperationResult.fromJson({
          "userID": json["friend_result_identifier"],
          "resultCode": json["friend_result_code"],
          "resultInfo": json["friend_result_desc"],
          // "resultType":
        });
        list.add(result.toJson());
      }
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required int checkType,
  }) async {
    String param = json.encode({
      "friendship_check_friendtype_param_check_type":
          checkType - 1, //这也是个神奇的地方，和native不一样
      "friendship_check_friendtype_param_identifier_array": userIDList
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_check_friend_list_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipCheckFriendType(
        json_check_friend_list_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendCheckResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendCheckResult result = V2TimFriendCheckResult.fromJson({
          "userID": json["friendship_check_friendtype_result_identifier"],
          "resultCode": json["friendship_check_friendtype_result_code"],
          "resultInfo": json["friendship_check_friendtype_result_desc"],
          "resultType": json["friendship_check_friendtype_result_relation"],
        });
        list.add(result.toJson());
      }

      return V2TimValueCallback<List<V2TimFriendCheckResult>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<V2TimFriendApplicationResult>>
      getFriendApplicationList() async {
    String param = json.encode({
      "friendship_get_pendency_list_param_type": 2,
      "friendship_get_pendency_list_param_start_seq": 0,
      "friendship_get_pendency_list_param_limited_size": 1000,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_get_pendency_list_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipGetPendencyList(
        json_get_pendency_list_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimFriendApplicationResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeJson = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      List<Map<String, dynamic>> appList = List<Map<String, dynamic>>.from(
          nativeJson["pendency_page_pendency_info_array"]);
      List<Map<String, dynamic>> appListDart = List.empty(growable: true);
      for (Map<String, dynamic> element in appList) {
        appListDart.add(Map<String, dynamic>.from({
          "userID": element["friend_add_pendency_info_idenitifer"],
          "nickname": element["friend_add_pendency_info_nick_name"],
          "faceUrl": "",
          "addTime": element["friend_add_pendency_info_add_time"],
          "addSource": element["friend_add_pendency_info_add_source"],
          "addWording": element["friend_add_pendency_info_add_wording"],
          "type": element["friend_add_pendency_info_type"],
        }));
      }
      Map<String, dynamic> dartJson = Map<String, dynamic>.from({
        "unreadCount": nativeJson["pendency_page_unread_num"],
        "friendApplicationList": appListDart,
        "userID": nativeJson["friend_result_identifier"],
      });
      // V2TimFriendApplicationResult
      return V2TimValueCallback<V2TimFriendApplicationResult>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": dartJson,
      });
    }
  }

  static Future<V2TimValueCallback<V2TimFriendOperationResult>>
      acceptFriendApplication({
    required int responseType,
    required int type,
    required String userID,
  }) async {
    String param = json.encode({
      "friend_respone_identifier": userID,
      "friend_respone_action": 1,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_handle_friend_add_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipHandleFriendAddRequest(
        json_handle_friend_add_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimFriendOperationResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeJson = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      Map<String, dynamic> dartJson = Map<String, dynamic>.from({
        "resultCode": nativeJson["friend_result_code"],
        "resultInfo": nativeJson["friend_result_desc"],
        "userID": nativeJson["friend_result_identifier"],
      });

      return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartJson});
    }
  }

  static Future<V2TimValueCallback<V2TimFriendOperationResult>>
      refuseFriendApplication({
    required int type,
    required String userID,
  }) async {
    String param = json.encode({
      "friend_respone_identifier": userID,
      "friend_respone_action": 2,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_handle_friend_add_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipHandleFriendAddRequest(
        json_handle_friend_add_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimFriendOperationResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeJson = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      Map<String, dynamic> dartJson = Map<String, dynamic>.from({
        "resultCode": nativeJson["friend_result_code"],
        "resultInfo": nativeJson["friend_result_desc"],
        "userID": nativeJson["friend_result_identifier"],
      });

      return V2TimValueCallback<V2TimFriendOperationResult>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": dartJson,
      });
    }
  }

  static Future<V2TimCallback> deleteFriendApplication({
    required int type,
    required String userID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    String param = json.encode({
      "friendship_delete_pendency_param_type": type,
      "friendship_delete_pendency_param_identifier_array":
          List<String>.from([userID]),
    });
    Pointer<Int8> json_delete_pendency_param = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipDeletePendency(
        json_delete_pendency_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> setFriendApplicationRead() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);

    int res = desktopSDK.D_TIMFriendshipReportPendencyReaded(0, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendInfo>>>
      getBlackList() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMFriendshipGetBlackList(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        Map<String, dynamic> result =
            Tools.friendProfile2DartFriendInfo(json).toJson();
        list.add(result);
      }
      return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addToBlackList({
    required List<String> userIDList,
  }) async {
    String param = json.encode(userIDList);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_add_to_blacklist_param = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipAddToBlackList(
        json_add_to_blacklist_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendOperationResult result =
            V2TimFriendOperationResult.fromJson({
          "userID": json["friend_result_identifier"],
          "resultCode": json["friend_result_code"],
          "resultInfo": json["friend_result_desc"],
          // "resultType":
        });
        list.add(result.toJson());
      }
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    String param = json.encode(userIDList);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_delete_from_blacklist_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipDeleteFromBlackList(
        json_delete_from_blacklist_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendOperationResult result =
            V2TimFriendOperationResult.fromJson({
          "userID": json["friend_result_identifier"],
          "resultCode": json["friend_result_code"],
          "resultInfo": json["friend_result_desc"],
          // "resultType":
        });
        list.add(result.toJson());
      }
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    String param = json.encode({
      "friendship_create_friend_group_param_name_array":
          List<String>.from([groupName]),
      "friendship_create_friend_group_param_identifier_array": userIDList,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_create_friend_group_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipCreateFriendGroup(
        json_create_friend_group_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendOperationResult result =
            V2TimFriendOperationResult.fromJson({
          "userID": json["friend_result_identifier"],
          "resultCode": json["friend_result_code"],
          "resultInfo": json["friend_result_desc"],
          // "resultType":
        });
        list.add(result.toJson());
      }
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    String param = json.encode(List<String>.from(groupNameList ?? []));
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_get_friend_group_list_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipGetFriendGroupList(
        json_get_friend_group_list_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendGroup>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendGroup result = V2TimFriendGroup.fromJson({
          "name": json["friend_group_info_name"],
          "friendCount": json["friend_group_info_count"],
          "friendIDList": json["friend_group_info_identifier_array"],
        });
        list.add(result.toJson());
      }
      return V2TimValueCallback<List<V2TimFriendGroup>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    String param = json.encode(List<String>.from(groupNameList));
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_delete_friend_group_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipDeleteFriendGroup(
        json_delete_friend_group_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    String param = json.encode(Map<String, dynamic>.from({
      "friendship_modify_friend_group_param_name": oldName,
      "friendship_modify_friend_group_param_new_name": newName,
    }));
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_modify_friend_group_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipModifyFriendGroup(
        json_modify_friend_group_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    String param = json.encode(Map<String, dynamic>.from({
      "friendship_modify_friend_group_param_name": groupName,
      "friendship_modify_friend_group_param_add_identifier_array": userIDList,
    }));
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_modify_friend_group_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipModifyFriendGroup(
        json_modify_friend_group_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendOperationResult result =
            V2TimFriendOperationResult.fromJson({
          "userID": json["friend_result_identifier"],
          "resultCode": json["friend_result_code"],
          "resultInfo": json["friend_result_desc"],
          // "resultType":
        });
        list.add(result.toJson());
      }
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    String param = json.encode(Map<String, dynamic>.from({
      "friendship_modify_friend_group_param_name": groupName,
      "friendship_modify_friend_group_param_delete_identifier_array":
          userIDList,
    }));
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_modify_friend_group_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipModifyFriendGroup(
        json_modify_friend_group_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = Map.from(element);
        V2TimFriendOperationResult result =
            V2TimFriendOperationResult.fromJson({
          "userID": json["friend_result_identifier"],
          "resultCode": json["friend_result_code"],
          "resultInfo": json["friend_result_desc"],
          // "resultType":
        });
        list.add(result.toJson());
      }
      return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    List<int> search_field_list = List.empty(growable: true);
    if (searchParam.isSearchNickName) {
      search_field_list.add(0x01 << 1);
    }
    if (searchParam.isSearchRemark) {
      search_field_list.add(0x01 << 2);
    }
    if (searchParam.isSearchUserID) {
      search_field_list.add(0x01);
    }
    String param = json.encode(Map<String, dynamic>.from({
      "friendship_search_param_keyword_list": searchParam.keywordList,
      "friendship_search_param_search_field_list": search_field_list,
    }));
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_search_friends_param = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMFriendshipSearchFriends(
        json_search_friends_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> listData = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> dartListData =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in listData) {
        Map<String, dynamic> nativeJson = Map<String, dynamic>.from(element);
        Map<String, dynamic> dartJson = Map<String, dynamic>.from({
          "resultCode":
              nativeJson["friendship_friend_info_get_result_error_code"],
          "resultInfo":
              nativeJson["friendship_friend_info_get_result_error_message"],
          "relation":
              nativeJson["friendship_friend_info_get_result_relation_type"],
          "friendInfo": Tools.friendProfile2DartFriendInfo(
                  nativeJson["friendship_friend_info_get_result_field_info"])
              .toJson()
        });
        dartListData.add(dartJson);
      }
      return V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartListData});
    }
  }

  static Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedGroupList() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMGroupGetJoinedGroupList(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> listData = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> dartListData =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in listData) {
        Map<String, dynamic> nativeJson = Map<String, dynamic>.from(element);
        Map<String, dynamic> dartJson =
            Tools.groupDetail2DartGroupInfo(nativeJson).toJson();
        dartListData.add(dartJson);
      }
      return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartListData});
    }
  }

  static Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    String param = json.encode(groupIDList);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_getinfo_param = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupGetGroupInfoList(
        json_group_getinfo_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimGroupInfoResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> listData = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> dartListData =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in listData) {
        Map<String, dynamic> nativeJson = Map<String, dynamic>.from(element);
        Map<String, dynamic> dartJson = Map<String, dynamic>.from({
          "resultCode": nativeJson["get_groups_info_result_code"],
          "resultMessage": nativeJson["get_groups_info_result_desc"],
          "groupInfo": Tools.groupDetail2DartGroupInfo(
                  nativeJson["get_groups_info_result_info"])
              .toJson()
        });
        dartListData.add(dartJson);
      }
      return V2TimValueCallback<List<V2TimGroupInfoResult>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartListData});
    }
  }

  static Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) async {
    List<Map<String, dynamic>> custom_arr = List.empty(growable: true);
    int flag = 0x00;

    Map<String, dynamic> param = Map<String, dynamic>.from({
      "group_modify_info_param_group_id": info.groupID,
    });
    if (info.customInfo != null) {
      info.customInfo!.forEach((key, value) {
        custom_arr.add({
          "group_info_custom_string_info_key": key,
          "group_info_custom_string_info_value": value,
        });
      });
    }
    if (info.groupName != null) {
      flag = flag | 0x01;

      param["group_modify_info_param_group_name"] = info.groupName;
    }
    if (info.notification != null) {
      flag = flag | (0x01 << 1);

      param["group_modify_info_param_notification"] = info.notification;
    }
    if (info.introduction != null) {
      flag = flag | 0x01 << 2;

      param["group_modify_info_param_introduction"] = info.introduction;
    }
    if (info.faceUrl != null) {
      flag = flag | 0x01 << 3;

      param["group_modify_info_param_face_url"] = info.faceUrl;
    }
    if (info.groupAddOpt != null) {
      flag = flag | 0x01 << 4;

      param["group_modify_info_param_add_option"] = info.groupAddOpt;
    }
    if (info.memberCount != null) {
      flag = flag | 0x01 << 5;

      param["group_modify_info_param_max_member_num"] = info.memberCount;
    }
    if (info.isAllMuted != null) {
      flag = flag | 0x01 << 8;

      param["group_modify_info_param_is_shutup_all"] = info.isAllMuted;
    }
    if (info.customInfo != null && info.customInfo!.isNotEmpty) {
      flag = flag | 0x01 << 9;

      param["group_modify_info_param_custom_info"] = custom_arr;
    }
    if (info.owner != null) {
      flag = flag | 0x01 << 31;
      param["group_modify_info_param_owner"] = info.owner;
    }
    param["group_modify_info_param_modify_flag"] = flag;
    print(param);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_modifyinfo_param =
        Tools.string2PointerInt8(json.encode(param));
    int res = desktopSDK.D_TIMGroupModifyGroupInfo(
        json_group_modifyinfo_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    List<Map<String, dynamic>> arr = List.empty(growable: true);
    if (attributes.isNotEmpty) {
      attributes.forEach((key, value) {
        arr.add({
          "group_atrribute_key": key,
          "group_atrribute_value": value,
        });
      });
    }

    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_atrributes =
        Tools.string2PointerInt8(json.encode(arr));
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMGroupSetGroupAttributes(
        group_id, json_group_atrributes, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_keys = Tools.string2PointerInt8(json.encode(keys));
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMGroupDeleteGroupAttributes(
        group_id, json_keys, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_keys = Tools.string2PointerInt8(
        json.encode(keys ?? List.empty(growable: true)));
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res =
        desktopSDK.D_TIMGroupGetGroupAttributes(group_id, json_keys, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<Map<String, String>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, String>> list =
          List<Map<String, String>>.empty(growable: true);
      for (Map<String, dynamic> element in dataList) {
        list.add({
          element["group_atrribute_key"].toString():
              element["group_atrribute_value"].toString()
        });
      }
      return V2TimValueCallback<Map<String, String>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": list});
    }
  }

  static Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMGroupGetOnlineMemberCount(group_id, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<int>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeData = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));

      return V2TimValueCallback<int>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": nativeData["group_get_online_member_count_result"]
      });
    }
  }

  static Future<V2TimValueCallback<V2TimGroupMemberInfoResult>>
      getGroupMemberList({
    required String groupID,
    required int filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    String param = json.encode({
      "group_get_members_info_list_param_group_id": groupID,
      "group_get_members_info_list_param_option": json.encode({
        "group_member_get_info_option_role_flag": filter,
      }),
      "group_get_members_info_list_param_next_seq":
          int.parse(nextSeq.isEmpty ? "0" : nextSeq),
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_getmeminfos_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupGetMemberInfoList(
        json_group_getmeminfos_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimGroupMemberInfoResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeData = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      List<Map<String, dynamic>> dartList = List<Map<String, dynamic>>.from(
          nativeData["group_get_memeber_info_list_result_info_array"]);
      List<Map<String, dynamic>> memList = List.empty(growable: true);
      for (var element in dartList) {
        memList.add(Tools.memberInfo2DartFullInfo(element).toJson());
      }
      Map<String, dynamic> dartRes = Map<String, dynamic>.from({
        "nextSeq": nativeData["group_get_memeber_info_list_result_next_seq"]
            .toString(),
        "memberInfoList": memList,
      });

      return V2TimValueCallback<V2TimGroupMemberInfoResult>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartRes});
    }
  }

  static Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    String param = json.encode({
      "group_get_members_info_list_param_group_id": groupID,
      "group_get_members_info_list_param_identifier_array": memberList,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_getmeminfos_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupGetMemberInfoList(
        json_group_getmeminfos_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimGroupMemberFullInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeData = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      List<Map<String, dynamic>> dartList = List<Map<String, dynamic>>.from(
          nativeData["group_get_memeber_info_list_result_info_array"]);
      List<Map<String, dynamic>> memList = List.empty(growable: true);
      for (var element in dartList) {
        memList.add(Tools.memberInfo2DartFullInfo(element).toJson());
      }

      return V2TimValueCallback<List<V2TimGroupMemberFullInfo>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": memList});
    }
  }

  static Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    List<Map<String, dynamic>> arr = List.empty(growable: true);
    int flag = 0x00;
    if (nameCard != null) {
      flag = flag | 0x01 << 3;
    }

    if (customInfo != null && customInfo.isNotEmpty) {
      customInfo.forEach((key, value) {
        arr.add({
          "group_member_info_custom_string_info_key": key,
          "group_member_info_custom_string_info_value": value,
        });
      });
    }
    if (arr.isNotEmpty) {
      flag = flag | 0x01 << 4;
    }
    String param = json.encode({
      "group_modify_member_info_group_id": groupID,
      "group_modify_member_info_identifier": userID,
      "group_modify_member_info_name_card": nameCard,
      "group_modify_member_info_custom_info": arr,
      "group_modify_member_info_modify_flag": flag,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_modifymeminfo_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupModifyMemberInfo(
        json_group_modifymeminfo_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    int flag = 0x00;

    flag = flag | 0x01 << 2;

    String param = json.encode({
      "group_modify_member_info_group_id": groupID,
      "group_modify_member_info_identifier": userID,
      "group_modify_member_info_shutup_time": seconds,
      "group_modify_member_info_modify_flag": flag,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_modifymeminfo_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupModifyMemberInfo(
        json_group_modifymeminfo_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    String param = json.encode({
      "group_invite_member_param_group_id": groupID,
      "group_invite_member_param_identifier_array": userList,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_invite_param = Tools.string2PointerInt8(param);
    int res =
        desktopSDK.D_TIMGroupInviteMember(json_group_invite_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<
          List<V2TimGroupMemberOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> nativeData = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> memList = List.empty(growable: true);
      for (var element in nativeData) {
        memList.add({
          "memberID": element["group_invite_member_result_identifier"],
          "result": element["group_invite_member_result_result"]
        });
      }

      return V2TimValueCallback<List<V2TimGroupMemberOperationResult>>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": memList});
    }
  }

  static Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    String? reason,
  }) async {
    String param = json.encode({
      "group_delete_member_param_group_id": groupID,
      "group_delete_member_param_identifier_array": memberList,
      "group_delete_member_param_user_data": reason,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_delete_param = Tools.string2PointerInt8(param);
    int res =
        desktopSDK.D_TIMGroupDeleteMember(json_group_delete_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required int role,
  }) async {
    int flag = 0x00;
    flag = flag | 0x01 << 1;
    String param = json.encode({
      "group_modify_member_info_group_id": groupID,
      "group_modify_member_info_identifier": userID,
      "group_modify_member_info_member_role": role,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_modifymeminfo_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupModifyMemberInfo(
        json_group_modifymeminfo_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    int flag = 0x00;

    Map<String, dynamic> param = Map<String, dynamic>.from({
      "group_modify_info_param_group_id": groupID,
    });

    flag = flag | 0x01 << 31;
    param["group_modify_info_param_owner"] = userID;

    param["group_modify_info_param_modify_flag"] = flag;

    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_modifyinfo_param =
        Tools.string2PointerInt8(json.encode(param));
    int res = desktopSDK.D_TIMGroupModifyGroupInfo(
        json_group_modifyinfo_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    String param = json.encode({
      "group_pendency_option_start_time": 0,
      "group_pendency_option_max_limited": 1000
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_getpendence_list_param =
        Tools.string2PointerInt8(json.encode(param));
    int res = desktopSDK.D_TIMGroupGetPendencyList(
        json_group_getpendence_list_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimGroupApplicationResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeJson = json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]);
      List<Map<String, dynamic>> nativeList = List<Map<String, dynamic>>.from(
          nativeJson["group_pendency_result_pendency_array"]);
      List<Map<String, dynamic>> dartList = List.empty(growable: true);
      for (var element in nativeList) {
        dartList.add({
          "groupID": element["group_pendency_group_id"],
          "fromUser": element["group_pendency_form_identifier"],
          "toUser": element["group_pendency_to_identifier"],
          "addTime": element["group_pendency_add_time"],
          "requestMsg": element["group_pendency_form_user_defined_data"],
          "handledMsg": element["group_pendency_approval_msg"],
          "type": element["group_pendency_pendency_type"],
          "handleStatus": element["group_pendency_handled"],
          "handleResult": element["group_pendency_handle_result"],
        });
      }
      Map<String, dynamic> dartJson = Map<String, dynamic>.from({
        "unreadCount": nativeJson["group_pendency_result_unread_num"],
        "groupApplicationList": dartList
      });
      return V2TimValueCallback<V2TimGroupApplicationResult>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": dartJson,
      });
    }
  }

  static Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
    String? webMessageInstance,
  }) async {
    String param = json.encode({
      "group_handle_pendency_param_is_accept": true,
      "group_handle_pendency_param_handle_msg": reason,
      "group_handle_pendency_param_pendency": json.encode({
        "group_pendency_group_id": groupID,
        "group_pendency_form_identifier": fromUser,
        "group_pendency_to_identifier": toUser,
      })
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_handle_pendency_param =
        Tools.string2PointerInt8(json.encode(param));
    int res = desktopSDK.D_TIMGroupHandlePendency(
        json_group_handle_pendency_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
    String? webMessageInstance,
  }) async {
    String param = json.encode({
      "group_handle_pendency_param_is_accept": false,
      "group_handle_pendency_param_handle_msg": reason,
      "group_handle_pendency_param_pendency": json.encode({
        "group_pendency_group_id": groupID,
        "group_pendency_form_identifier": fromUser,
        "group_pendency_to_identifier": toUser,
      })
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_group_handle_pendency_param =
        Tools.string2PointerInt8(json.encode(param));
    int res = desktopSDK.D_TIMGroupHandlePendency(
        json_group_handle_pendency_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> setGroupApplicationRead() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMGroupReportPendencyReaded(
        DateTime.now().millisecondsSinceEpoch, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    String userData = Tools.generateUserData();

    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    List<int> fild = List.empty(growable: true);
    if (searchParam.isSearchGroupID) {
      fild.add(0x01);
    }
    if (searchParam.isSearchGroupName) {
      fild.add(0x01 << 1);
    }
    String param = json.encode({
      "group_search_params_keyword_list": searchParam.keywordList,
      "group_search_params_field_list": fild,
    });
    Pointer<Int8> json_group_search_groups_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupSearchGroups(
        json_group_search_groups_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> listData = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> dartListData =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in listData) {
        Map<String, dynamic> nativeJson = Map<String, dynamic>.from(element);
        Map<String, dynamic> dartJson =
            Tools.groupDetail2DartGroupInfo(nativeJson).toJson();
        dartListData.add(dartJson);
      }
      return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": dartListData,
      });
    }
  }

  static Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>>
      searchGroupMembers({
    required V2TimGroupMemberSearchParam searchParam,
  }) async {
    String userData = Tools.generateUserData();

    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    List<int> fild = List.empty(growable: true);
    if (searchParam.isSearchMemberUserID) {
      fild.add(0x01);
    }
    if (searchParam.isSearchMemberNickName) {
      fild.add(0x01 << 1);
    }
    if (searchParam.isSearchMemberRemark) {
      fild.add(0x01 << 2);
    }
    if (searchParam.isSearchMemberNameCard) {
      fild.add(0x01 << 3);
    }
    String param = json.encode({
      "group_search_member_params_keyword_list": searchParam.keywordList,
      "group_search_member_params_groupid_list": searchParam.groupIDList,
      "group_search_member_params_field_list": fild,
    });

    Pointer<Int8> json_group_search_group_members_param =
        Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupSearchGroupMembers(
        json_group_search_group_members_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2GroupMemberInfoSearchResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> nativeList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));

      Map<String, dynamic> itemMap = Map<String, dynamic>.from({});

      for (var element in nativeList) {
        List<Map<String, dynamic>> list =
            List.from(element["group_search_member_result_menber_info_list"]);
        List<Map<String, dynamic>> reslist = List.empty(growable: true);
        for (var el in list) {
          reslist.add(Tools.groupMemberInfo2dartGroupMemberInfo(el).toJson());
        }
        itemMap
            .addAll({element["group_search_member_result_groupid"]: reslist});
      }

      return V2TimValueCallback<V2GroupMemberInfoSearchResult>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": itemMap,
      });
    }
  }

  static Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    String userData = Tools.generateUserData();
    List<Map<String, String>> list = List.empty(growable: true);
    if (attributes.isNotEmpty) {
      attributes.forEach((key, value) {
        list.add({
          "group_atrribute_key": key,
          "group_atrribute_value": value,
        });
      });
    }
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_id = Tools.string2PointerInt8(json.encode(attributes));
    Pointer<Int8> json_group_atrributes = Tools.string2PointerInt8(groupID);

    int res = desktopSDK.D_TIMGroupInitGroupAttributes(
        group_id, json_group_atrributes, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createTextMessage({
    required String text,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type":
              Tools.dartElemTypeToNative(MessageElemType.V2TIM_ELEM_TYPE_TEXT),
          "text_elem_content": text,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMessage>> sendMessage({
    required String id,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
    bool? isSupportMessageExtension = false,
    bool needReadReceipt = false,
    Map<String, dynamic>? offlinePushInfo,
    // 自定义消息需要
    String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
    String? localCustomData,
  }) async {
    if (!createdMessage.containsKey(id)) {
      return V2TimValueCallback<V2TimMessage>.fromJson({
        "code": "-1",
        "desc": "id not exist please try create again",
      });
    } else {
      Map<String, dynamic> message = createdMessage.remove(id)!;
      Map<String, dynamic> fullmessage = Tools.createNativeSendMessage(
        createdMessage: message,
        groupId: groupID,
        userID: receiver,
        priority: priority,
        onlineUserOnly: onlineUserOnly,
        isExcludedFromLastMessage: isExcludedFromLastMessage,
        isExcludedFromUnreadCount: isExcludedFromLastMessage,
        needReadReceipt: needReadReceipt,
        offlinePushInfo: offlinePushInfo != null
            ? Tools.generateNativeOfflinePushInfoByDart(
                OfflinePushInfo.fromJson(offlinePushInfo))
            : null,
      );
      String userData = Tools.generateUserData();
      Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
      Pointer<Int8> json_msg_param =
          Tools.string2PointerInt8(json.encode(fullmessage));
      Pointer<Int8> conv_id =
          Tools.string2PointerInt8(groupID.isEmpty ? receiver : groupID);
      int res = desktopSDK.D_TIMMsgSendMessage(
          conv_id, groupID.isEmpty ? 1 : 2, json_msg_param, user_data);
      if (res != TIMResult.TIM_SUCC) {
        return V2TimValueCallback<V2TimMessage>.fromJson({
          "code": res,
          "desc": "",
        });
      } else {
        Map<String, dynamic> data = await getAsyncData(userData);
        Map<String, dynamic> nativeData = Map<String, dynamic>.from(json.decode(
            data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));

        Map<String, dynamic> DartData =
            Tools.convertMessage2Dart(nativeData).toJson();

        return V2TimValueCallback<V2TimMessage>.fromJson({
          "code": data["code"],
          "desc": data["desc"],
          "data": DartData,
        });
      }
    }
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createTargetedGroupMessage({
    required String id,
    required List<String> receiverList,
  }) async {
    if (!createdMessage.containsKey(id)) {
      return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
        "code": "-1",
        "desc": "id not exist please try create again",
      });
    }
    Map<String, dynamic> message = createdMessage[id]!;
    createdMessage[id]!["message_target_group_member_array"] = receiverList;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": id,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createCustomMessage({
    required String data,
    String desc = "",
    String extension = "",
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type": Tools.dartElemTypeToNative(
              MessageElemType.V2TIM_ELEM_TYPE_CUSTOM),
          "custom_elem_data": data,
          "custom_elem_desc": desc,
          "custom_elem_ext": extension,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createImageMessage({
    required String imagePath,
    dynamic inputElement,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type":
              Tools.dartElemTypeToNative(MessageElemType.V2TIM_ELEM_TYPE_IMAGE),
          "image_elem_orig_path": imagePath,
          "image_elem_level": 0,
          "image_elem_format": 1,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createSoundMessage({
    required String soundPath,
    required int duration,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type":
              Tools.dartElemTypeToNative(MessageElemType.V2TIM_ELEM_TYPE_SOUND),
          "sound_elem_file_path": soundPath,
          "sound_elem_file_size": 0,
          "sound_elem_file_time": duration,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createVideoMessage({
    required String videoFilePath,
    required String type,
    required int duration,
    required String snapshotPath,
    dynamic inputElement,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type":
              Tools.dartElemTypeToNative(MessageElemType.V2TIM_ELEM_TYPE_VIDEO),
          "video_elem_video_type": type,
          "video_elem_video_size": 0,
          "video_elem_video_duration": duration,
          "video_elem_video_path": videoFilePath,
          "video_elem_image_type": "jpg",
          "video_elem_image_size": 0,
          "video_elem_image_width": 0,
          "video_elem_image_height": 0,
          "video_elem_image_path": snapshotPath,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createFileMessage({
    required String filePath,
    required String fileName,
    dynamic inputElement,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type":
              Tools.dartElemTypeToNative(MessageElemType.V2TIM_ELEM_TYPE_FILE),
          "file_elem_file_path": filePath,
          "file_elem_file_name": fileName,
          "file_elem_file_size": 0,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type":
              Tools.dartElemTypeToNative(MessageElemType.V2TIM_ELEM_TYPE_TEXT),
          "text_elem_content": text
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    message["message_group_at_user_array"] = atUserList;

    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type": Tools.dartElemTypeToNative(
              MessageElemType.V2TIM_ELEM_TYPE_LOCATION),
          "location_elem_desc": desc,
          "location_elem_longitude": longitude,
          "location_elem_latitude": latitude,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createFaceMessage({
    required int index,
    required String data,
  }) async {
    Map<String, dynamic> message = Tools.createNativeMessage(
      elem: List<Map<String, dynamic>>.from([
        Map<String, dynamic>.from({
          "elem_type":
              Tools.dartElemTypeToNative(MessageElemType.V2TIM_ELEM_TYPE_FACE),
          "face_elem_index": index,
          "face_elem_buf": data,
        })
      ]),
    );
    String key = Tools.generateUniqueString();
    createdMessage[key] = message;

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
      "code": 0,
      "desc": "success",
      "data": Map<String, dynamic>.from({
        "id": key,
        "messageInfo": Tools.convertMessage2Dart(message).toJson()
      })
    });
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createMergerMessage({
    required List<String> msgIDList,
    required String title,
    required List<String> abstractList,
    required String compatibleText,
    List<String>? webMessageInstanceList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(msgIDList));
    int res = desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);

      if (data["code"] == 0) {
        Map<String, dynamic> message = Tools.createNativeMessage(
          elem: List<Map<String, dynamic>>.from([
            Map<String, dynamic>.from({
              "elem_type": Tools.dartElemTypeToNative(
                  MessageElemType.V2TIM_ELEM_TYPE_MERGER),
              "merge_elem_abstract_array": abstractList,
              "merge_elem_compatible_text": compatibleText,
              "merge_elem_message_array": List<Map<String, dynamic>>.from(
                  json.decode(data["json_param"].isEmpty
                      ? json.encode([])
                      : data["json_param"])),
            })
          ]),
        );
        String key = Tools.generateUniqueString();
        createdMessage[key] = message;

        return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
          "code": 0,
          "desc": "success",
          "data": Map<String, dynamic>.from({
            "id": key,
            "messageInfo": Tools.convertMessage2Dart(message).toJson()
          })
        });
      } else {
        return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
          "code": "-2",
          "desc": "find message error",
        });
      }
    }
  }

  static Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(messageIDList));
    int res = desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimMessage>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        V2TimMessage converInfo = Tools.convertMessage2Dart(json);
        list.add(converInfo.toJson());
      }
      return V2TimValueCallback<List<V2TimMessage>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createForwardMessage({
    required String msgID,
    String? webMessageInstance,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(List<String>.from([msgID])));
    int res = desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);

      if (data["code"] == 0) {
        List<Map<String, dynamic>> messageList =
            List<Map<String, dynamic>>.from(json.decode(
                data["json_param"].isEmpty
                    ? json.encode([])
                    : data["json_param"]));
        Map<String, dynamic> message = messageList.first;
        message["message_is_forward_message"] = true;
        String key = Tools.generateUniqueString();
        createdMessage[key] = message;
        return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
          "code": 0,
          "desc": "success",
          "data": Map<String, dynamic>.from({
            "id": key,
            "messageInfo": Tools.convertMessage2Dart(message).toJson()
          })
        });
      } else {
        return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson({
          "code": "-2",
          "desc": "find message error",
        });
      }
    }
  }

  static Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    return V2TimCallback.fromJson({"code": 0, "desc": ""});
  }

  static Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    return V2TimCallback.fromJson({"code": 0, "desc": ""});
  }

  static Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = 0,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
  }) async {
    Map<String, dynamic> message = Map.from({});
    if (lastMsgID != null) {
      String userDatafind = Tools.generateUserData();
      Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDatafind);
      Pointer<Int8> json_message_id_array =
          Tools.string2PointerInt8(json.encode(List<String>.from([lastMsgID])));
      int res = desktopSDK.D_TIMMsgFindMessages(
          json_message_id_array, user_data_find);
      if (res == TIMResult.TIM_SUCC) {
        Map<String, dynamic> data = await getAsyncData(userDatafind);
        if (data["code"] == 0) {
          List<Map<String, dynamic>> messageList =
              List<Map<String, dynamic>>.from(json.decode(
                  data["json_param"].isEmpty
                      ? json.encode([])
                      : data["json_param"]));
          if (messageList.isNotEmpty) {
            message = messageList.first;
          }
        }
      }
    }
    String param = json.encode({
      "msg_getmsglist_param_count": count,
      "msg_getmsglist_param_is_remble":
          getType == HistoryMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG ||
                  getType == HistoryMessageGetType.V2TIM_GET_CLOUD_NEWER_MSG
              ? true
              : false,
      "msg_getmsglist_param_message_type_array": messageTypeList != null
          ? messageTypeList.map((e) => Tools.dartElemTypeToNative(e)).toList()
          : [],
      "msg_getmsglist_param_last_msg_seq": lastMsgSeq == -1 ? 0 : lastMsgSeq,
      "msg_getmsglist_param_last_msg": message.isNotEmpty ? message : null
    });
    print(param);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(groupID ?? userID ?? "");
    Pointer<Int8> json_get_msg_param = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMMsgGetMsgList(
        conv_id,
        Tools.convertid2convType(groupID ?? userID ?? ""),
        json_get_msg_param,
        user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimMessage>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        V2TimMessage converInfo = Tools.convertMessage2Dart(json);
        list.add(converInfo.toJson());
      }
      return V2TimValueCallback<List<V2TimMessage>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimCallback> revokeMessage({
    required String msgID,
    Object? webMessageInstatnce,
  }) async {
    Map<String, dynamic> message = Map.from({});
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    String userDatafind = Tools.generateUserData();
    Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDatafind);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(List<String>.from([msgID])));
    int res =
        desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data_find);
    if (res == TIMResult.TIM_SUCC) {
      Map<String, dynamic> data = await getAsyncData(userDatafind);
      if (data["code"] == 0) {
        List<Map<String, dynamic>> messageList =
            List<Map<String, dynamic>>.from(json.decode(
                data["json_param"].isEmpty
                    ? json.encode([])
                    : data["json_param"]));
        if (messageList.isNotEmpty) {
          message = messageList.first;
        }
      }
    }
    if (message.isNotEmpty) {
      Pointer<Int8> conv_id =
          Tools.string2PointerInt8(message["message_conv_id"]);
      int conv_type = message["message_conv_type"];

      Pointer<Int8> json_msg_param =
          Tools.string2PointerInt8(json.encode(message));
      int res1 = desktopSDK.D_TIMMsgRevoke(
          conv_id, conv_type, json_msg_param, user_data);
      if (res1 != TIMResult.TIM_SUCC) {
        return V2TimCallback.fromJson({
          "code": res1,
          "desc": "",
        });
      } else {
        Map<String, dynamic> revoke = await getAsyncData(userData);
        return V2TimCallback.fromJson({
          "code": revoke["code"],
          "desc": revoke["desc"],
        });
      }
    } else {
      return V2TimCallback.fromJson({"code": -1, "desc": "message not found"});
    }
  }

  static Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(userID);

    int res = desktopSDK.D_TIMMsgReportReaded(
        conv_id, 1, Pointer<Int8>.fromAddress(0), user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> revoke = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": revoke["code"],
        "desc": revoke["desc"],
      });
    }
  }

  static Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_identifier_array =
        Tools.string2PointerInt8(json.encode(userIDList));
    int res = desktopSDK.D_TIMMsgSetC2CReceiveMessageOpt(
        json_identifier_array, opt, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> revoke = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": revoke["code"],
        "desc": revoke["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_identifier_array =
        Tools.string2PointerInt8(json.encode(userIDList));
    int res = desktopSDK.D_TIMMsgGetC2CReceiveMessageOpt(
        json_identifier_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add({
          "c2CReceiveMessageOpt": json["msg_recv_msg_opt_result_opt"],
          "userID": json["msg_recv_msg_opt_result_identifier"]
        });
      }
      return V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }

  static Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required int opt,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res =
        desktopSDK.D_TIMMsgSetGroupReceiveMessageOpt(group_id, opt, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> revoke = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": revoke["code"],
        "desc": revoke["desc"],
      });
    }
  }

  static Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(groupID);

    int res = desktopSDK.D_TIMMsgReportReaded(
        conv_id, 2, Pointer<Int8>.fromAddress(0), user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> revoke = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": revoke["code"],
        "desc": revoke["desc"],
      });
    }
  }

  static Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    Map<String, dynamic> message = Map.from({});
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    String userDatafind = Tools.generateUserData();
    Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDatafind);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(List<String>.from([msgID])));
    int res =
        desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data_find);
    if (res == TIMResult.TIM_SUCC) {
      Map<String, dynamic> data = await getAsyncData(userDatafind);
      if (data["code"] == 0) {
        List<Map<String, dynamic>> messageList =
            List<Map<String, dynamic>>.from(json.decode(
                data["json_param"].isEmpty
                    ? json.encode([])
                    : data["json_param"]));
        if (messageList.isNotEmpty) {
          message = messageList.first;
        }
      }
    }
    if (message.isNotEmpty) {
      Pointer<Int8> conv_id =
          Tools.string2PointerInt8(message["message_conv_id"]);
      int conv_type = message["message_conv_type"];

      Pointer<Int8> json_msgdel_param = Tools.string2PointerInt8(json.encode({
        "msg_delete_param_msg": message,
        "msg_delete_param_is_remble": false,
      }));
      int res1 = desktopSDK.D_TIMMsgDelete(
          conv_id, conv_type, json_msgdel_param, user_data);
      if (res1 != TIMResult.TIM_SUCC) {
        return V2TimCallback.fromJson({
          "code": res1,
          "desc": "",
        });
      } else {
        Map<String, dynamic> revoke = await getAsyncData(userData);
        return V2TimCallback.fromJson({
          "code": revoke["code"],
          "desc": revoke["desc"],
        });
      }
    } else {
      return V2TimCallback.fromJson({"code": -1, "desc": "message not found"});
    }
  }

  static Future<V2TimCallback> deleteMessages({
    required List<String> msgIDs,
    List<dynamic>? webMessageInstanceList,
  }) async {
    List<Map<String, dynamic>> messageList = List.empty(growable: true);
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    String userDatafind = Tools.generateUserData();
    Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDatafind);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(msgIDs));
    int res =
        desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data_find);
    if (res == TIMResult.TIM_SUCC) {
      Map<String, dynamic> data = await getAsyncData(userDatafind);
      if (data["code"] == 0) {
        messageList = List<Map<String, dynamic>>.from(json.decode(
            data["json_param"].isEmpty ? json.encode([]) : data["json_param"]));
      }
    }
    if (messageList.isNotEmpty) {
      Pointer<Int8> conv_id =
          Tools.string2PointerInt8(messageList.first["message_conv_id"]);
      int conv_type = messageList.first["message_conv_type"];

      Pointer<Int8> json_msg_array =
          Tools.string2PointerInt8(json.encode(messageList));
      int res1 = desktopSDK.D_TIMMsgListDelete(
          conv_id, conv_type, json_msg_array, user_data);
      if (res1 != TIMResult.TIM_SUCC) {
        return V2TimCallback.fromJson({
          "code": res1,
          "desc": "",
        });
      } else {
        Map<String, dynamic> revoke = await getAsyncData(userData);
        return V2TimCallback.fromJson({
          "code": revoke["code"],
          "desc": revoke["desc"],
        });
      }
    } else {
      return V2TimCallback.fromJson({"code": -1, "desc": "message not found"});
    }
  }

  static Future<V2TimValueCallback<V2TimMessage>>
      insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
        {"code": -1, "desc": "desktop not support this method"});
  }

  static Future<V2TimValueCallback<V2TimMessage>>
      insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
        {"code": -1, "desc": "desktop not support this method"});
  }

  static Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(userID);
    int res = desktopSDK.D_TIMMsgClearHistoryMessage(conv_id, 1, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    }
  }

  static Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conv_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMMsgClearHistoryMessage(conv_id, 2, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    }
  }

  static Future<V2TimValueCallback<V2TimMessageSearchResult>>
      searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    String param = json.encode({
      "msg_search_param_keyword_array": searchParam.keywordList,
      "msg_search_param_message_type_array": searchParam.messageTypeList,
      "msg_search_param_conv_id": searchParam.conversationID,
      "msg_search_param_keyword_list_match_type": searchParam.type,
      "msg_search_param_search_time_position": searchParam.searchTimePosition,
      "msg_search_param_search_time_period": searchParam.searchTimePeriod,
      "msg_search_param_page_index": searchParam.pageIndex,
      "msg_search_param_page_size": searchParam.pageSize,
      "msg_search_param_send_indentifier_array": searchParam.userIDList,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_search_message_param = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMMsgSearchLocalMessages(
        json_search_message_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimMessageSearchResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeJson = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      List<Map<String, dynamic>> nativeList =
          List.from(nativeJson["msg_search_result_item_array"] ?? []);
      List<Map<String, dynamic>> dartList =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in nativeList) {
        List<Map<String, dynamic>> messageList =
            List.from(element["msg_search_result_item_message_array"] ?? []);
        List<Map<String, dynamic>> dartMessageList =
            List<Map<String, dynamic>>.empty(growable: true);
        for (var msg in messageList) {
          dartMessageList.add(Tools.convertMessage2Dart(msg).toJson());
        }

        dartList.add({
          "conversationID": element["msg_search_result_item_conv_id"],
          "messageCount": element["msg_search_result_item_total_message_count"],
          "messageList": dartMessageList
        });
      }
      Map<String, dynamic> dartJson = Map<String, dynamic>.from({
        "totalCount": nativeJson["msg_search_result_total_count"],
        "messageSearchResultItems": dartList,
      });

      return V2TimValueCallback<V2TimMessageSearchResult>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartJson});
    }
  }

  static Future<V2TimCallback> markAllMessageAsRead() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMMsgMarkAllMessageAsRead(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    List<Map<String, dynamic>> originMessage =
        List<Map<String, dynamic>>.from([]);
    String userData = Tools.generateUserData();
    String userDataFind = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDataFind);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(messageIDList));
    int res =
        desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data_find);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    } else {
      Map<String, dynamic> messageData = await getAsyncData(userData);
      List<Map<String, dynamic>> nativeMessage =
          List<Map<String, dynamic>>.from(json.decode(
              messageData["json_param"].isEmpty
                  ? json.encode([])
                  : messageData["json_param"]));
      if (nativeMessage.isNotEmpty) {
        originMessage = nativeMessage;
      }
    }
    if (originMessage.isEmpty) {
      return V2TimCallback.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    }

    Pointer<Int8> json_msg_param =
        Tools.string2PointerInt8(json.encode(originMessage));

    int res2 =
        desktopSDK.D_TIMMsgSendMessageReadReceipts(json_msg_param, user_data);
    if (res2 != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res2,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": data["code"],
        "desc": data["desc"],
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimMessageReceipt>>>
      getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    List<Map<String, dynamic>> originMessage =
        List<Map<String, dynamic>>.from([]);
    String userData = Tools.generateUserData();
    String userDataFind = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDataFind);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(messageIDList));
    int res =
        desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data_find);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimMessageReceipt>>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    } else {
      Map<String, dynamic> messageData = await getAsyncData(userDataFind);
      List<Map<String, dynamic>> nativeMessage =
          List<Map<String, dynamic>>.from(json.decode(
              messageData["json_param"].isEmpty
                  ? json.encode([])
                  : messageData["json_param"]));
      if (nativeMessage.isNotEmpty) {
        originMessage = nativeMessage;
      }
    }
    if (originMessage.isEmpty) {
      return V2TimValueCallback<List<V2TimMessageReceipt>>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    }

    Pointer<Int8> json_msg_array =
        Tools.string2PointerInt8(json.encode(originMessage));

    int res2 =
        desktopSDK.D_TIMMsgGetMessageReadReceipts(json_msg_array, user_data);
    if (res2 != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimMessageReceipt>>.fromJson({
        "code": res2,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "userID": json["msg_receipt_conv_type"] == 1
              ? json["msg_receipt_conv_id"]
              : "",
          "timestamp": json["msg_receipt_time_stamp"] ??
              (DateTime.now().millisecondsSinceEpoch / 100).floor(),
          "groupID": json["msg_receipt_conv_type"] == 2
              ? json["msg_receipt_conv_id"]
              : "", // TODO
          "msgID": json["msg_receipt_msg_id"],
          "readCount": json["msg_receipt_read_count"],
          "unreadCount": json["msg_receipt_unread_count"]
        }));
      }
      return V2TimValueCallback<List<V2TimMessageReceipt>>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) async {
    Map<String, dynamic> originMessage = Map<String, dynamic>.from({});
    String userData = Tools.generateUserData();
    String userDataFind = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDataFind);
    Pointer<Int8> json_message_id_array =
        Tools.string2PointerInt8(json.encode(List.from([messageID])));
    int res =
        desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data_find);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimGroupMessageReadMemberList>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    } else {
      Map<String, dynamic> messageData = await getAsyncData(userDataFind);
      List<Map<String, dynamic>> nativeMessage =
          List<Map<String, dynamic>>.from(json.decode(
              messageData["json_param"].isEmpty
                  ? json.encode([])
                  : messageData["json_param"]));
      if (nativeMessage.isNotEmpty) {
        originMessage = nativeMessage.first;
      }
    }
    if (originMessage.isEmpty) {
      return V2TimValueCallback<V2TimGroupMessageReadMemberList>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    }

    Pointer<Int8> json_msg =
        Tools.string2PointerInt8(json.encode(originMessage));

    int res2 = desktopSDK.D_TIMMsgGetGroupMessageReadMemberList(
        json_msg, filter.index, nextSeq, count, user_data);
    if (res2 != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimGroupMessageReadMemberList>.fromJson({
        "code": res2,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> memberArray = List<Map<String, dynamic>>.from(
          json.decode(data["json_group_member_array"].isEmpty
              ? json.encode([])
              : data["json_group_member_array"]));
      List<Map<String, dynamic>> dartMemberList = List.from([]);
      for (var element in memberArray) {
        dartMemberList
            .add(Tools.groupMemberInfo2dartGroupMemberInfo(element).toJson());
      }
      Map<String, dynamic> dartData = Map<String, dynamic>.from({
        "nextSeq": data["next_seq"],
        "isFinished": data["is_finished"],
        "memberInfoList": dartMemberList,
      });
      return V2TimValueCallback<V2TimGroupMessageReadMemberList>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": dartData,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedCommunityList() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);

    int res = desktopSDK.D_TIMGroupGetJoinedCommunityList(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Tools.convert2DartTopicInfo(element).toJson());
      }
      return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson({
        "code": data['code'],
        "desc": data['desc'],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    String param = json.encode({
      "group_topic_info_topic_id": topicInfo.topicID,
      "group_topic_info_topic_name": topicInfo.topicName,
      "group_topic_info_introduction": topicInfo.introduction,
      "group_topic_info_notification": topicInfo.notification,
      "group_topic_info_topic_face_url": topicInfo.topicFaceUrl,
      "group_topic_info_is_all_muted": topicInfo.isAllMute,
      "group_topic_info_self_mute_time": topicInfo.selfMuteTime,
      "group_topic_info_custom_string": topicInfo.customString,
      "group_topic_info_recv_opt": topicInfo.recvOpt,
      "group_topic_info_draft_text": topicInfo.draftText,
    });
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);

    Pointer<Int8> json_topic_info = Tools.string2PointerInt8(param);
    int res = desktopSDK.D_TIMGroupCreateTopicInCommunity(
        group_id, json_topic_info, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<String>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeData = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode({}) : data["json_param"]));
      List<Map<String, dynamic>> dartList = List<Map<String, dynamic>>.from(
          nativeData["group_get_memeber_info_list_result_info_array"]);
      List<Map<String, dynamic>> memList = List.empty(growable: true);
      for (var element in dartList) {
        memList.add(Tools.memberInfo2DartFullInfo(element).toJson());
      }
      Map<String, dynamic> dartRes = Map<String, dynamic>.from({
        "nextSeq": nativeData["group_get_memeber_info_list_result_next_seq"]
            .toString(),
        "memberInfoList": memList,
      });

      return V2TimValueCallback<String>.fromJson(
          {"code": data["code"], "desc": data["desc"], "data": dartRes});
    }
  }

  static Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_topic_id_array =
        Tools.string2PointerInt8(json.encode(topicIDList));
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMGroupDeleteTopicFromCommunity(
        group_id, json_topic_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimTopicOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "errorCode": json["group_topic_info_result_error_code"],
          "errorMessage": json["group_topic_info_result_error_message"],
          "topicID": Tools.convert2DartTopicInfo(
                  json["group_topic_info_result_topic_info"])
              .topicID, // TODO
        }));
      }
      return V2TimValueCallback<List<V2TimTopicOperationResult>>.fromJson({
        "code": data['code'],
        "desc": data['desc'],
        "data": list,
      });
    }
  }

  static Future<V2TimCallback> setTopicInfo({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    String userData = Tools.generateUserData();
    int flag = 0x00;
    if (topicInfo.topicName != null) {
      flag = flag | 0x01;
    }
    if (topicInfo.introduction != null) {
      flag = flag | 0x01 << 2;
    }
    if (topicInfo.notification != null) {
      flag = flag | 0x01 << 1;
    }
    if (topicInfo.topicFaceUrl != null) {
      flag = flag | 0x01 << 3;
    }
    if (topicInfo.recvOpt != null) {
      flag = flag | 0x01 << 4;
    }
    if (topicInfo.isAllMute != null) {
      flag = flag | 0x01 << 8;
    }
    if (topicInfo.customString != null) {
      flag = flag | 0x01 << 11;
    }
    Map<String, dynamic> param = Map.from({
      "group_topic_info_topic_id": topicInfo.topicID,
      "group_topic_info_topic_name": topicInfo.topicName,
      "group_topic_info_introduction": topicInfo.introduction,
      "group_topic_info_notification": topicInfo.notification,
      "group_topic_info_topic_face_url": topicInfo.topicFaceUrl,
      "group_topic_info_is_all_muted": topicInfo.isAllMute,
      "group_topic_info_self_mute_time": topicInfo.selfMuteTime,
      "group_topic_info_custom_string": topicInfo.customString,
      "group_topic_info_recv_opt": topicInfo.recvOpt,
      "group_topic_info_draft_text": topicInfo.draftText,
      "group_modify_info_param_modify_flag": flag,
    });

    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_topic_info =
        Tools.string2PointerInt8(json.encode(param));
    int res = desktopSDK.D_TIMGroupSetTopicInfo(json_topic_info, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "errorCode": json["group_topic_info_result_error_code"],
          "errorMessage": json["group_topic_info_result_error_message"],
          "topicInfo": Tools.convert2DartTopicInfo(
                  json["group_topic_info_result_topic_info"])
              .toJson(),
        }));
      }
      return V2TimCallback.fromJson({
        "code": data['code'],
        "desc": data['desc'],
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimTopicInfoResult>>>
      getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_topic_id_array =
        Tools.string2PointerInt8(json.encode(topicIDList));
    Pointer<Int8> group_id = Tools.string2PointerInt8(groupID);
    int res = desktopSDK.D_TIMGroupGetTopicInfoList(
        group_id, json_topic_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimTopicInfoResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "errorCode": json["group_topic_info_result_error_code"],
          "errorMessage": json["group_topic_info_result_error_message"],
          "topicInfo": Tools.convert2DartTopicInfo(
                  json["group_topic_info_result_topic_info"])
              .toJson(),
        }));
      }
      return V2TimValueCallback<List<V2TimTopicInfoResult>>.fromJson({
        "code": data['code'],
        "desc": data['desc'],
        "data": list,
      });
    }
  }

  /// localCustomData
  /// localCustomInt
  /// cloudCustomData
  /// V2TIMTextElem
  /// V2TIMCustomElem
  static Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    Map<String, dynamic> originMessage = Map<String, dynamic>.from({});
    String userData = Tools.generateUserData();
    String userDataFind = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> user_data_find = Tools.string2PointerInt8(userDataFind);
    Pointer<Int8> json_message_id_array = Tools.string2PointerInt8(
        json.encode(List<String>.from([message.msgID])));
    int res =
        desktopSDK.D_TIMMsgFindMessages(json_message_id_array, user_data_find);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimMessageChangeInfo>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    } else {
      Map<String, dynamic> messageData = await getAsyncData(userData);
      List<Map<String, dynamic>> nativeMessage =
          List<Map<String, dynamic>>.from(json.decode(
              messageData["json_param"].isEmpty
                  ? json.encode([])
                  : messageData["json_param"]));
      if (nativeMessage.isNotEmpty) {
        originMessage = nativeMessage.first;
      }
    }
    if (originMessage.isEmpty) {
      return V2TimValueCallback<V2TimMessageChangeInfo>.fromJson({
        "code": "-2",
        "desc": "find message error",
      });
    }
    originMessage["message_custom_str"] = message.localCustomData;
    originMessage["message_custom_int"] = message.localCustomInt;
    originMessage["message_cloud_custom_str"] = message.cloudCustomData;
    if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      originMessage["message_elem_array"] = List.from([
        Map<String, dynamic>.from(
            {"elem_type": 0, "text_elem_content": message.textElem!.text})
      ]);
    }
    if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM) {
      originMessage["message_elem_array"] = List.from([
        Map<String, dynamic>.from({
          "elem_type": 3,
          "custom_elem_data": message.customElem!.data,
          "custom_elem_desc": message.customElem!.desc,
          "custom_elem_ext": message.customElem!.extension,
        })
      ]);
    }
    Pointer<Int8> json_msg_param =
        Tools.string2PointerInt8(json.encode(originMessage));

    int res2 = desktopSDK.D_TIMMsgModifyMessage(json_msg_param, user_data);
    if (res2 != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimMessageChangeInfo>.fromJson({
        "code": res2,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      Map<String, dynamic> nativeData = Map<String, dynamic>.from(json.decode(
          data["json_param"].isEmpty ? json.encode([]) : data["json_param"]));
      Map<String, dynamic> dartData =
          Map<String, dynamic>.from({"code": 0, "desc": "", "message": {}});

      return V2TimValueCallback<V2TimMessageChangeInfo>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": dartData,
      });
    }
  }

  static Future<V2TimValueCallback<V2TimMessage>> appendMessage({
    required String createMessageBaseId,
    required String createMessageAppendId,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
        {"code": -1, "desc": "desktop not suppport this methond"});
  }

  static Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_identifier_array =
        Tools.string2PointerInt8(json.encode(userIDList));
    int res = desktopSDK.D_TIMGetUserStatus(json_identifier_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<V2TimUserStatus>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "userID": json["user_status_identifier"],
          "statusType": json["user_status_status_type"],
          "customStatus": json["user_status_custom_status"]
        }));
      }
      return V2TimValueCallback<List<V2TimUserStatus>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }

  static Future<V2TimCallback> setSelfStatus({
    required String status,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_current_user_status =
        Tools.string2PointerInt8(json.encode({
      "user_status_custom_status": status,
    }));
    int res =
        desktopSDK.D_TIMSetSelfStatus(json_current_user_status, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    }
  }

  static Future<V2TimCallback> subscribeUserStatus({
    required List<String> userIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_identifier_array =
        Tools.string2PointerInt8(json.encode(userIDList));
    int res =
        desktopSDK.D_TIMSubscribeUserStatus(json_identifier_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    }
  }

  static Future<V2TimCallback> unsubscribeUserStatus({
    required List<String> userIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> json_identifier_array =
        Tools.string2PointerInt8(json.encode(userIDList));
    int res =
        desktopSDK.D_TIMUnsubscribeUserStatus(json_identifier_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      setConversationCustomData({
    required String customData,
    required List<String> conversationIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conversation_id_array =
        Tools.string2PointerInt8(json.encode(conversationIDList));
    Pointer<Int8> custom_data = Tools.string2PointerInt8(customData);
    int res = desktopSDK.D_TIMConvSetConversationCustomData(
        conversation_id_array, custom_data, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "conversationID":
              json["conversation_operation_result_conversation_id"],
          "resultCode": json["conversation_operation_result_result_code"],
          "resultInfo": json["conversation_operation_result_result_info"]
        }));
      }
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationListByFilter({
    required V2TimConversationListFilter filter,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> filter_param = Tools.string2PointerInt8(json.encode(Map.from({
      "conversation_list_filter_next_seq": filter.nextSeq,
      "conversation_list_filter_count": filter.count,
      "conversation_list_filter_conv_type": filter.conversationType,
      "conversation_list_filter_mark_type": filter.markType,
      "conversation_list_filter_group_name": filter.groupName,
    })));
    int res = desktopSDK.D_TIMConvGetConversationListByFilter(
        filter_param, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<V2TimConversationResult>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);

      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        V2TimConversation converInfo = Tools.convertConvInfo2Dart(json);
        list.add(converInfo.toJson());
      }

      return V2TimValueCallback<V2TimConversationResult>.fromJson({
        "code": data["code"],
        "desc": data["desc"],
        "data": {"nextSeq": "", "isFinished": true, "conversationList": list}
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      markConversation({
    required int markType,
    required bool enableMark,
    required List<String> conversationIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conversation_id_array =
        Tools.string2PointerInt8(json.encode(conversationIDList));
    int res = desktopSDK.D_TIMConvMarkConversation(
        conversation_id_array, markType, enableMark ? 1 : 0, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "conversationID":
              json["conversation_operation_result_conversation_id"],
          "resultCode": json["conversation_operation_result_result_code"],
          "resultInfo": json["conversation_operation_result_result_info"]
        }));
      }
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      createConversationGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conversation_id_array =
        Tools.string2PointerInt8(json.encode(conversationIDList));
    Pointer<Int8> group_name = Tools.string2PointerInt8(groupName);
    int res = desktopSDK.D_TIMConvCreateConversationGroup(
        group_name, conversation_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "conversationID":
              json["conversation_operation_result_conversation_id"],
          "resultCode": json["conversation_operation_result_result_code"],
          "resultInfo": json["conversation_operation_result_result_info"]
        }));
      }
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<String>>>
      getConversationGroupList() async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    int res = desktopSDK.D_TIMConvGetConversationGroupList(user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<List<String>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      return V2TimValueCallback<List<String>>.fromJson({
        "code": res,
        "desc": "",
        "data": dataList,
      });
    }
  }

  static Future<V2TimCallback> deleteConversationGroup({
    required String groupName,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> group_name = Tools.string2PointerInt8(groupName);
    int res =
        desktopSDK.D_TIMConvDeleteConversationGroup(group_name, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    }
  }

  static Future<V2TimCallback> renameConversationGroup({
    required String oldName,
    required String newName,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> old_name = Tools.string2PointerInt8(oldName);
    Pointer<Int8> new_name = Tools.string2PointerInt8(newName);
    int res = desktopSDK.D_TIMConvRenameConversationGroup(
        old_name, new_name, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      return V2TimCallback.fromJson({
        "code": res,
        "desc": "",
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      addConversationsToGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conversation_id_array =
        Tools.string2PointerInt8(json.encode(conversationIDList));
    Pointer<Int8> group_name = Tools.string2PointerInt8(groupName);
    int res = desktopSDK.D_TIMConvAddConversationsToGroup(
        group_name, conversation_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "conversationID":
              json["conversation_operation_result_conversation_id"],
          "resultCode": json["conversation_operation_result_result_code"],
          "resultInfo": json["conversation_operation_result_result_info"]
        }));
      }
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }

  static Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationsFromGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    String userData = Tools.generateUserData();
    Pointer<Int8> user_data = Tools.string2PointerInt8(userData);
    Pointer<Int8> conversation_id_array =
        Tools.string2PointerInt8(json.encode(conversationIDList));
    Pointer<Int8> group_name = Tools.string2PointerInt8(groupName);
    int res = desktopSDK.D_TIMConvDeleteConversationsFromGroup(
        group_name, conversation_id_array, user_data);
    if (res != TIMResult.TIM_SUCC) {
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
      });
    } else {
      Map<String, dynamic> data = await getAsyncData(userData);
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
          json.decode(data["json_param"].isEmpty
              ? json.encode([])
              : data["json_param"]));
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.empty(growable: true);
      for (var element in dataList) {
        Map<String, dynamic> json = element;
        list.add(Map<String, dynamic>.from({
          "conversationID":
              json["conversation_operation_result_conversation_id"],
          "resultCode": json["conversation_operation_result_result_code"],
          "resultInfo": json["conversation_operation_result_result_info"]
        }));
      }
      return V2TimValueCallback<
          List<V2TimConversationOperationResult>>.fromJson({
        "code": res,
        "desc": "",
        "data": list,
      });
    }
  }
}
