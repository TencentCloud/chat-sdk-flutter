// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'package:system_info2/system_info2.dart';
import 'package:tencent_im_sdk_plugin_desktop/utils/generated_bindings_wrap.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/V2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_at_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_result.dart';

import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result_item.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_offline_push_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_status.dart';

import '../enum/tim_group_member_role_enum.dart';

class Tools {
  static List<String> getDyLibNameByPlatform({isOrigin = false}) {
    if (Platform.isWindows) {
      // return ["libtestWindowsLib.dll"];
      return [isOrigin ? "ImSDK.dll" : "libim_flutter_desktop_lib.dll"];
    } else if (Platform.isMacOS) {
      if (SysInfo.kernelArchitecture == "arm64") {
        return [
          isOrigin
              ? "libImSDKForMac.dylib"
              : "libim_flutter_desktop_lib_arm64.dylib",
        ];
      } else {
        return [
          isOrigin ? "libImSDKForMac.dylib" : "libim_flutter_desktop_lib.dylib",
        ];
      }
    }
    return [];
  }

  static Pointer<Int8> string2PointerInt8(String data) {
    return data.toNativeUtf8().cast<Int8>();
  }

  static Pointer<Int8> num2PointerInt8(int data) {
    return data.toString().toNativeUtf8().cast<Int8>();
  }

  static Pointer<UnsignedChar> intToUnsignedInt8(int data) {
    return data.toString().toNativeUtf8().cast<UnsignedChar>();
  }

  static Pointer<Void> string2PointerVoid(String data) {
    return data.toNativeUtf8().cast<Void>();
  }

  static String pointerInt82String(Pointer<Int8> data) {
    return data.cast<Utf8>().toDartString();
  }

  static Map<String, String>? convert2DartMap(
      objectArray, String key, String value) {
    Map<String, String> map = {};
    if (objectArray != null) {
      for (dynamic item in objectArray) {
        map[item[key] ?? ""] = item[value] ?? "";
      }
    }
    return map;
  }

  static String generateUserData() {
    String trace = StackTrace.current.toString();
    RegExp exp = RegExp(r'IMNative.[a-zA-Z_0-9]+\s');
    Iterable<Match> matches = exp.allMatches(trace);
    String apiName = "";
    String userdata = "";
    for (final Match m in matches) {
      String match = m[0]!;
      if (match.isNotEmpty) {
        apiName = match.replaceAll("IMNative.", "").replaceAll(" ", "");
        break;
      }
    }

    if (apiName.isNotEmpty) {
      int now = DateTime.now().microsecondsSinceEpoch;
      userdata = "$apiName-$now";
    } else {
      throw "get userData error trace: $trace";
    }
    return userdata;
  }

  // userstatus
  static V2TimUserStatus userStatus2DartUserStatus(jsonUserStatus) {
    return V2TimUserStatus.fromJson({
      "userID": jsonUserStatus["user_status_identifier"],
      // type赋值相同
      "statusType": jsonUserStatus["user_status_status_type"],
      "customStatus": jsonUserStatus["user_status_custom_status"],
    });
  }

  // group
  static V2TimGroupMemberInfo userProfile2dartGroupMemberInfo(jsonUserInfo) {
    // var jsonUserInfo = json.decode(userInfo);
    return V2TimGroupMemberInfo.fromJson({
      "userID": jsonUserInfo["user_profile_identifier"],
      "nickName": jsonUserInfo["user_profile_nick_name"],
      "nameCard": jsonUserInfo["user_profile_self_signature"],
      "faceUrl": jsonUserInfo["user_profile_face_url"],
    });
  }

  static V2TimGroupMemberInfo groupMemberInfo2dartGroupMemberInfo(
      jsonGroupMemberInfo) {
    return V2TimGroupMemberInfo.fromJson({
      "userID": jsonGroupMemberInfo["group_member_info_identifier"],
      "nickName": jsonGroupMemberInfo["group_member_info_nick_name"],
      "nameCard": jsonGroupMemberInfo["group_member_info_name_card"],
      "friendRemark": jsonGroupMemberInfo["group_member_info_remark"],
      "faceUrl": jsonGroupMemberInfo["group_member_info_face_url"],
    });
  }

  static V2TimGroupChangeInfo groupChangeInfo2dartGroupChangeInfo(
      jsonGroupChangeInfo) {
    return V2TimGroupChangeInfo.fromJson({
      "type": jsonGroupChangeInfo["group_tips_group_change_info_flag"],
      "value": jsonGroupChangeInfo["group_tips_group_change_info_value"],
      "key": jsonGroupChangeInfo["group_tips_group_change_info_key"],
      "boolValue":
          jsonGroupChangeInfo["group_tips_group_change_info_bool_value"],
    });
  }

  static V2TimGroupAtInfo convertGroupAtInfo(jsonGroupAtInfo) {
    // var jsonGroupAtInfo = json.decode(groupAtInfo);
    return V2TimGroupAtInfo.fromJson({
      "seq": jsonGroupAtInfo["conv_group_at_info_seq"],
      "atType": jsonGroupAtInfo["conv_group_at_info_at_type"],
    });
  }

  static V2TimGroupMemberChangeInfo dartMemberChange2MemberChangeInfo(
      jsonMemberChangeInfo) {
    return V2TimGroupMemberChangeInfo.fromJson({
      "userID":
          jsonMemberChangeInfo["group_tips_member_change_info_identifier"],
      "muteTime":
          jsonMemberChangeInfo["group_tips_member_change_info_shutupTime"],
    });
  }

  // messageElemType 转换
  static int messageElemType2DartMessageElemType(int type) {
    int res = 0;
    switch (type) {
      case 0:
        res = MessageElemType.V2TIM_ELEM_TYPE_TEXT;
        break;
      case 1:
        res = MessageElemType.V2TIM_ELEM_TYPE_IMAGE;
        break;
      case 2:
        res = MessageElemType.V2TIM_ELEM_TYPE_SOUND;
        break;
      case 3:
        res = MessageElemType.V2TIM_ELEM_TYPE_CUSTOM;
        break;
      case 4:
        res = MessageElemType.V2TIM_ELEM_TYPE_FILE;
        break;
      case 5:
        res = MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS;
        break;
      case 6:
        res = MessageElemType.V2TIM_ELEM_TYPE_FACE;
        break;
      case 7:
        res = MessageElemType.V2TIM_ELEM_TYPE_LOCATION;
        break;
      case 8:
        break;
      case 9:
        res = MessageElemType.V2TIM_ELEM_TYPE_VIDEO;
        break;
      case 12:
        res = MessageElemType.V2TIM_ELEM_TYPE_MERGER;
        break;
      default:
        res = 0;
        break;
    }
    return res;
  }

  // MessagePriority 转换
  static int messagePriority2Dart(int priority) {
    int res = 0;
    switch (priority) {
      case 0:
        res = MessagePriority.V2TIM_PRIORITY_HIGH;
        break;
      case 1:
        res = MessagePriority.V2TIM_PRIORITY_NORMAL;
        break;
      case 2:
        res = MessagePriority.V2TIM_PRIORITY_LOW;
        break;
      case 3:
        res = MessagePriority.V2TIM_PRIORITY_LOW;
        break;
      default:
        break;
    }
    return res;
  }

  static V2TimOfflinePushInfo offLinePushConfig2Dart(jsonPushInfo) {
    return V2TimOfflinePushInfo.fromJson({
      "title": jsonPushInfo["ios_offline_push_config_title"],
      "iOSSound": jsonPushInfo["ios_offline_push_config_sound"],
      "ignoreIOSBadge": jsonPushInfo["ios_offline_push_config_ignore_badge"],
    });
  }

  static Map<String, dynamic> convertElemMsg2Dart(jsonMessage) {
    // var jsonMessage = json.decode(message);
    int type = messageElemType2DartMessageElemType(jsonMessage["elem_type"]);
    // dynamic res;
    Map<String, dynamic> res = Map.from({});
    String key = "";
    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        {
          key = "textElem";
          res = {"text": jsonMessage["text_elem_content"]};
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        {
          key = "customElem";
          res = {
            "data": jsonMessage["custom_elem_data"],
            "desc": jsonMessage["custom_elem_desc"],
            "extension": jsonMessage["custom_elem_ext"],
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        {
          key = "imageElem";
          res = {
            "path": jsonMessage["image_elem_orig_path"],
            "imageList": [
              {
                "size": jsonMessage["image_elem_orig_pic_size"],
                "width": jsonMessage["image_elem_orig_pic_width"],
                "height": jsonMessage["image_elem_orig_pic_height"],
                "url": jsonMessage["image_elem_orig_url"],
              }
            ]
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        {
          key = "soundElem";
          res = {
            "path": jsonMessage["sound_elem_file_path"],
            "UUID": jsonMessage["sound_elem_file_id"],
            "dataSize": jsonMessage["sound_elem_file_size"],
            "url": jsonMessage["sound_elem_url"],
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        {
          key = "videoElem";
          res = {
            "videoPath": jsonMessage["video_elem_video_path"],
            "UUID": jsonMessage["video_elem_video_id"],
            "videoSize": jsonMessage["video_elem_video_size"],
            "duration": jsonMessage["video_elem_video_duration"],
            "snapshotPath": jsonMessage["video_elem_image_path"],
            "snapshotUUID": jsonMessage["video_elem_image_id"],
            "snapshotSize": jsonMessage["video_elem_image_size"],
            "snapshotWidth": jsonMessage["video_elem_image_width"],
            "snapshotHeight": jsonMessage["video_elem_image_height"],
            "videoUrl": jsonMessage["video_elem_video_url"],
            "snapshotUrl": jsonMessage["video_elem_image_url"],
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        {
          key = "fileElem";
          res = {
            "path": jsonMessage["file_elem_file_path"],
            "fileName": jsonMessage["file_elem_file_name"],
            "UUID": jsonMessage["file_elem_file_id"],
            "url": jsonMessage["file_elem_url"],
            "fileSize": jsonMessage["file_elem_file_size"],
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        {
          key = "locationElem";
          res = {
            "desc": jsonMessage["location_elem_desc"],
            "longitude": jsonMessage["location_elem_longitude"],
            "latitude": jsonMessage["location_elem_latitude"],
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        {
          key = "faceElem";
          res = {
            "index": jsonMessage["face_elem_index"],
            "data": jsonMessage["face_elem_buf"],
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        {
          key = "groupTipsElem";
          List groupChange = List.empty(growable: true);
          if (jsonMessage["group_tips_elem_group_change_info_array"] != null) {
            for (Map<String, dynamic> info
                in jsonMessage["group_tips_elem_group_change_info_array"]) {
              groupChange.add(groupChangeInfo2dartGroupChangeInfo(info));
            }
          }
          List memberChange = List.empty(growable: true);
          if (jsonMessage["group_tips_elem_member_change_info_array"] != null) {
            for (Map<String, dynamic> info
                in jsonMessage["group_tips_elem_member_change_info_array"]) {
              memberChange.add(dartMemberChange2MemberChangeInfo(info));
            }
          }
          res = {
            "groupID": jsonMessage["group_tips_elem_group_id"] ?? "",
            "type": jsonMessage["group_tips_elem_tip_type"] ?? 0,
            "opMember":
                jsonMessage["group_tips_elem_changed_user_info_array"] != null
                    ? userProfile2dartGroupMemberInfo(jsonMessage[
                            "group_tips_elem_changed_user_info_array"][0])
                        .toJson()
                    : null,
            // "memberList": groupMemberInfo2dartGroupMemberInfo(
            //     jsonMessage["group_tips_elem_op_group_memberinfo"]).toJson(),//TODO 这里解析有错
            "groupChangeInfoList": groupChange,
            "memberChangeInfoList": memberChange,
            "memberCount": jsonMessage["group_tips_elem_member_num"] ?? 0,
          };
        }
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        {
          key = "mergerElem";
          res = {
            "isLayersOverLimit": jsonMessage["merge_elem_layer_over_limit"],
            "title": jsonMessage["merge_elem_title"],
            "abstractList": jsonMessage["merge_elem_abstract_array"],
          };
        }
        break;
      default:
        break;
    }
    return {key: res};
  }

  static V2TimMessage convertMessage2Dart(jsonMessage) {
    print("convertMessage2Dart start ");
    // var jsonMessage = json.decode(message);
    Map<String, dynamic> map = Map.from({
      "msgID": jsonMessage["message_msg_id"],
      "timestamp": jsonMessage["message_server_time"],
      "sender": jsonMessage["message_sender"],
      "groupID": jsonMessage["message_conv_type"] == 2
          ? jsonMessage["message_conv_id"]
          : r"",
      "userID": jsonMessage["message_conv_type"] == 1
          ? jsonMessage["message_conv_id"]
          : "",
      "status": jsonMessage["message_status"],
      "elemType": jsonMessage["message_elem_array"] != null
          ? jsonMessage["message_elem_array"][0] != null
              ? messageElemType2DartMessageElemType(
                  jsonMessage["message_elem_array"][0]["elem_type"])
              : null
          : 0,
      "localCustomData": jsonMessage["message_custom_str"],
      "localCustomInt": jsonMessage["message_custom_int"],
      "cloudCustomData": jsonMessage["message_cloud_custom_str"],
      "isSelf": jsonMessage["message_is_from_self"],
      "isRead": jsonMessage["message_is_read"],
      "isPeerRead": jsonMessage["message_is_peer_read"],
      "priority": jsonMessage["message_priority"] != null
          ? messagePriority2Dart(jsonMessage["message_priority"])
          : null,
      "groupAtUserList": jsonMessage["message_group_at_user_array"],
      "seq": jsonMessage["message_seq"].toString(),
      "random": jsonMessage["message_rand"],
      "isExcludedFromUnreadCount":
          jsonMessage["message_is_excluded_from_unread_count"],
      "needReadReceipt": jsonMessage["message_need_read_receipt"],
      "offlinePushInfo": jsonMessage["message_offlie_push_config"] != null
          ? offLinePushConfig2Dart(jsonMessage["message_offlie_push_config"])
              .toJson()
          : null,
    });
    if (jsonMessage["message_elem_array"] != null) {
      map.addAll(convertElemMsg2Dart(jsonMessage["message_elem_array"][0]));
    }
    return V2TimMessage.fromJson(map);
  }

  static V2TimConversation convertConvInfo2Dart(jsonConvInfo) {
    var groupAtList = [];
    if (jsonConvInfo["conv_group_at_info_array"] != null) {
      for (Map<String, dynamic> groupinfo
          in jsonConvInfo["conv_group_at_info_array"]) {
        groupAtList.add(convertGroupAtInfo(groupinfo).toJson());
      }
    }

    print("in function Tools.convertconvinfo2dart");
    return V2TimConversation.fromJson({
      "conversationID": jsonConvInfo["conv_id"],
      "type": jsonConvInfo["conv_type"],
      "userID": jsonConvInfo["conv_type"] == 1 ? jsonConvInfo["conv_id"] : null,
      "groupID":
          jsonConvInfo["conv_type"] == 2 ? jsonConvInfo["conv_id"] : null,
      "unreadCount": jsonConvInfo["conv_unread_num"],
      "showname": jsonConvInfo["conv_show_name"],
      "isPinned": jsonConvInfo["conv_is_pinned"],
      "recvOpt": jsonConvInfo["conv_recv_opt"],
      "lastMessage": jsonConvInfo["conv_last_msg"] != null
          ? convertMessage2Dart(jsonConvInfo["conv_last_msg"]).toJson()
          : null,
      "draftText": jsonConvInfo["conv_draft"],
      "customData": jsonConvInfo["conv_custom_data"],
      "markList": jsonConvInfo["conv_mark_array"],
      "conversationGroupList": jsonConvInfo["conv_conversation_group_array"],
      "groupAtInfoList": groupAtList,
    });
  }

  // message
  static V2TimReceiveMessageOptInfo
      getC2CRecvMsgOptResult2DartReceiveMessageOptInfo(jsonOpt) {
    return V2TimReceiveMessageOptInfo.fromJson({
      "userID": jsonOpt["msg_recv_msg_opt_result_identifier"],
      // enum ReceiveMsgOptEnum相同
      "c2CReceiveMessageOpt": jsonOpt["msg_recv_msg_opt_result_opt"],
    });
  }

  static V2TimMessageSearchResultItem searchResultItem2DartSearchResultItem(
      jsonItem) {
    List list = List.empty(growable: true);
    if (jsonItem["msg_search_result_item_message_array"] != null) {
      for (Map<String, dynamic> item
          in jsonItem["msg_search_result_item_message_array"]) {
        list.add(convertMessage2Dart(item).toJson());
      }
    }
    return V2TimMessageSearchResultItem.fromJson({
      "conversationID": jsonItem["msg_search_result_item_conv_id"],
      "messageCount": jsonItem["msg_search_result_item_total_message_count"],
      "messageList": list,
    });
  }

  static V2TimMessageSearchResult searchResult2DartMessageSearchResult(
      jsonResult) {
    List list = List.empty(growable: true);
    if (jsonResult["msg_search_result_item_array"] != null) {
      for (Map<String, dynamic> item
          in jsonResult["msg_search_result_item_array"]) {
        list.add(searchResult2DartMessageSearchResult(item).toJson());
      }
    }
    return V2TimMessageSearchResult.fromJson({
      "totalCount": jsonResult["msg_search_result_total_count"],
      "messageSearchResultItems": list,
    });
  }

  // 好友关系链 friend
  static V2TimUserFullInfo userProfile2DartUserFullInfo(jsonInfo) {
    return V2TimUserFullInfo.fromJson({
      "userID": jsonInfo["user_profile_identifier"],
      "nickName": jsonInfo["user_profile_nick_name"],
      "faceUrl": jsonInfo["user_profile_face_url"],
      "selfSignature": jsonInfo["user_profile_self_signature"],
      "gender": jsonInfo["user_profile_gender"],
      "allowType": jsonInfo["user_profile_add_permission"],
      "role": jsonInfo["user_profile_role"],
      "level": jsonInfo["user_profile_level"],
      "birthday": jsonInfo["user_profile_birthday"],
      "customInfo": convert2DartMap(
          jsonInfo["user_profile_custom_string_array"],
          "user_profile_custom_string_info_key",
          "user_profile_custom_string_info_value"),
    });
  }

  static V2TimFriendInfo friendProfile2DartFriendInfo(jsonInfo) {
    return V2TimFriendInfo.fromJson({
      "userID": jsonInfo["friend_profile_identifier"],
      "friendRemark": jsonInfo["friend_profile_remark"],
      "friendGroups": jsonInfo["friend_profile_group_name_array"],
      "friendCustomInfo": convert2DartMap(
          jsonInfo["friend_profile_custom_string_array"],
          "friend_profile_custom_string_info_key",
          "friend_profile_custom_string_info_value"),
      "userProfile":
          userProfile2DartUserFullInfo(jsonInfo["friend_profile_user_profile"])
              .toJson(),
    });
  }

  static V2TimFriendInfo userProfile2DartFriendInfo(jsonInfo) {
    return V2TimFriendInfo.fromJson({
      "userID": jsonInfo["user_profile_identifier"],
      "friendCustomInfo": convert2DartMap(
          jsonInfo["user_profile_custom_string_array"],
          "user_profile_custom_string_info_key",
          "user_profile_custom_string_info_value"),
      "userProfile": userProfile2DartUserFullInfo(jsonInfo).toJson(),
    });
  }

  static V2TimFriendInfoResult friendProfile2DartFriendResult(jsonInfo) {
    return V2TimFriendInfoResult.fromJson({
      "resultCode": 0,
      "resultInfo": jsonInfo["friend_profile_identifier"],
      "friendInfo":
          userProfile2DartFriendInfo(jsonInfo["friend_profile_user_profile"])
              .toJson(),
    });
  }

  static String groupType2Dart(int type) {
    String res = "";
    switch (type) {
      case 0:
        res = GroupType.Public;
        break;
      case 1:
        res = GroupType.Work;
        break;
      case 2:
        res = GroupType.Meeting;
        break;
      case 3:
        res = GroupType.AVChatRoom;
        break;
      case 4:
        res = GroupType.AVChatRoom;
        break;
      case 5:
        res = GroupType.Community;
        break;
      default:
        res = GroupType.Public;
        break;
    }
    return res;
  }

  static V2TimGroupInfo groupBaseInfo2DartGroupInfo(jsonInfo) {
    return V2TimGroupInfo.fromJson({
      "groupID": jsonInfo["group_base_info_group_id"],
      "groupType": groupType2Dart(jsonInfo["group_base_info_group_type"]),
      "groupName": jsonInfo["group_base_info_group_name"],
      "faceUrl": jsonInfo["group_base_info_face_url"],
      "isAllMuted": jsonInfo["group_base_info_is_shutup_all"],
      "role": jsonInfo["group_base_info_self_info"]["group_self_info_role"],
      "joinTime": jsonInfo["group_base_info_self_info"]
          ["group_self_info_join_time"],
    });
  }

  static V2TimGroupInfo groupDetail2DartGroupInfo(jsonInfo) {
    return V2TimGroupInfo.fromJson({
      "groupID": jsonInfo["group_detial_info_group_id"],
      "groupType": groupType2Dart(jsonInfo["group_detial_info_group_type"]),
      "groupName": jsonInfo["group_detial_info_group_name"],
      "notification": jsonInfo["group_detial_info_notification"],
      "introduction": jsonInfo["group_detial_info_introduction"],
      "faceUrl": jsonInfo["group_detial_info_face_url"],
      "isAllMuted": jsonInfo["group_detial_info_is_shutup_all"],
      "isSupportTopic": jsonInfo["group_detial_info_is_support_topic"],
      "owner": jsonInfo["group_detial_info_owener_identifier"],
      "createTime": jsonInfo["group_detial_info_create_time"],
      // "gropuAddOpt" type  相同，无需转换
      "lastInfoTime": jsonInfo["group_detial_info_last_info_time"],
      "lastMessageTime": jsonInfo["group_detial_info_last_msg_time"],
      "memberCount": jsonInfo["group_detial_info_member_num"],
      "onlineCount": jsonInfo["group_detial_info_online_member_num"],
      "customInfo": convert2DartMap(
          jsonInfo["group_detial_info_custom_info"],
          "group_info_custom_string_info_key",
          "group_info_custom_string_info_value"),
    });
  }

  static V2TimGroupInfoResult groupInfoResult2DartInfoResult(jsonInfo) {
    return V2TimGroupInfoResult.fromJson({
      "resultCode": jsonInfo["get_groups_info_result_code"],
      "resultMessage": jsonInfo["get_groups_info_result_desc"],
      "groupInfo":
          groupDetail2DartGroupInfo(jsonInfo["get_groups_info_result_info"])
              .toJson(),
    });
  }

  static int groupMemberRole2Dart(int type) {
    int res = 0;
    switch (type) {
      case CGroupMemberRole.kTIMMemberRole_None:
        res = GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED;
        break;
      case CGroupMemberRole.kTIMMemberRole_Normal:
        res = GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
        break;
      case CGroupMemberRole.kTIMMemberRole_Admin:
        res = GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
        break;
      case CGroupMemberRole.kTIMMemberRole_Owner:
        res = GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER;
        break;
      default:
        res = GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED;
        break;
    }
    return res;
  }

  static V2TimGroupMemberFullInfo memberInfo2DartFullInfo(jsonInfo) {
    return V2TimGroupMemberFullInfo.fromJson({
      "userID": jsonInfo["group_member_info_identifier"],
      "role": groupMemberRole2Dart(jsonInfo["group_member_info_member_role"]),
      "muteUntil": jsonInfo["group_member_info_shutup_time"],
      "joinTime": jsonInfo["group_member_info_join_time"],
      "nickName": jsonInfo["group_member_info_nick_name"],
      "nameCard": jsonInfo["group_member_info_name_card"],
      "friendRemark": jsonInfo["group_member_info_remark"],
      "faceUrl": jsonInfo["group_member_info_face_url"],
      "customInfo": convert2DartMap(
          jsonInfo["group_member_info_custom_info"],
          "group_info_custom_string_info_key",
          "group_info_custom_string_info_value"),
    });
  }

  static V2TimGroupMemberInfoResult memberInfoListResult2DartInfoResult(
      jsonInfo) {
    List list = List.empty(growable: true);
    for (dynamic item
        in jsonInfo["group_get_memeber_info_list_result_info_array"]) {
      list.add(memberInfo2DartFullInfo(item).toJson());
    }
    return V2TimGroupMemberInfoResult.fromJson({
      "nextSeq":
          jsonInfo["group_get_memeber_info_list_result_next_seq"].toString(),
      "memberInfoList": list,
    });
  }

  static V2TimGroupMemberOperationResult inviteMemberResult2DartOpResult(
      jsonResult) {
    return V2TimGroupMemberOperationResult.fromJson({
      "memberID": jsonResult["group_invite_member_result_identifier"],
      "result": jsonResult["group_invite_member_result_result"],
    });
  }

  static V2GroupMemberInfoSearchResult membersResult2DartSearchResult(
      jsonResult) {
    Map<String, dynamic> map = {};
    if (jsonResult != null) {
      for (dynamic item in jsonResult) {
        List list = List.empty(growable: true);
        for (dynamic info
            in item["group_search_member_result_menber_info_list"]) {
          list.add(memberInfo2DartFullInfo(item));
        }
        map.addAll({item["group_search_member_result_groupid"]: list});
      }
    }
    return V2GroupMemberInfoSearchResult.fromJson({
      "groupMemberSearchResultItems": map,
    });
  }

  // ccccccccccc

  static Map<String, dynamic> groupMemberInfo2CUserProfile(
      V2TimGroupMemberInfo? member) {
    Map<String, dynamic> map = {
      "user_profile_identifier": member!.userID,
      "user_profile_nick_name": member.nickName,
      "user_profile_face_url": member.faceUrl,
    };
    return map;
  }

  static Map<String, dynamic> groupMemberInfo2CGroupMemberInfo(
      V2TimGroupMemberInfo? memberList) {
    Map<String, dynamic> map = {
      "group_member_info_identifier": memberList!.userID,
      "group_member_info_nick_name": memberList.nickName,
      "group_member_info_face_url": memberList.faceUrl,
      "group_member_info_name_card": memberList.nameCard,
      "group_member_info_remark": memberList.friendRemark,
    };
    return map;
  }

  static Map<String, dynamic> memberChangeInfo2CMemberChange(
      V2TimGroupMemberChangeInfo? member) {
    Map<String, dynamic> map = {
      "group_tips_member_change_info_identifier": member!.userID,
      "group_tips_member_change_info_shutupTime": member.muteTime,
    };
    return map;
  }

  static Map<String, dynamic> groupChangeInfo2CGroupChange(
      V2TimGroupChangeInfo? group) {
    Map<String, dynamic> map = {
      "group_tips_group_change_info_flag": group!.type,
      "group_tips_group_change_info_value": group.value,
      "group_tips_group_change_info_key": group.key,
      "group_tips_group_change_info_bool_value": group.boolValue,
    };
    return map;
  }

  static Map<String, dynamic> v2TimMessageElem2CElem(
      int type, V2TimMessage message) {
    Map<String, dynamic> map = {};
    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Text,
          "text_elem_content": message.textElem?.text,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Custom,
          "custom_elem_data": message.customElem?.data,
          "custom_elem_desc": message.customElem?.desc,
          "custom_elem_ext": message.customElem?.extension,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Image,
          "image_elem_orig_path": message.imageElem?.path,
          "image_elem_orig_id": message.imageElem?.imageList![0]?.uuid,
          "image_elem_orig_pic_height":
              message.imageElem?.imageList![0]?.height,
          "image_elem_orig_pic_width": message.imageElem?.imageList![0]?.width,
          "image_elem_orig_url": message.imageElem?.imageList![0]?.url,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Sound,
          "sound_elem_file_path": message.soundElem?.path,
          "sound_elem_file_id": message.soundElem?.UUID,
          "sound_elem_file_size": message.soundElem?.dataSize,
          "sound_elem_file_time": message.soundElem?.duration,
          "sound_elem_url": message.soundElem?.url,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Video,
          "video_elem_video_path": message.videoElem?.videoPath,
          "video_elem_video_id": message.videoElem?.UUID,
          "video_elem_video_size": message.videoElem?.videoSize,
          "video_elem_video_duration": message.videoElem?.duration,
          "video_elem_image_path": message.videoElem?.snapshotPath,
          "video_elem_image_id": message.videoElem?.snapshotUUID,
          "video_elem_image_size": message.videoElem?.snapshotSize,
          "video_elem_image_width": message.videoElem?.snapshotWidth,
          "video_elem_image_height": message.videoElem?.snapshotHeight,
          "video_elem_video_url": message.videoElem?.videoUrl,
          "video_elem_image_url": message.videoElem?.snapshotUrl,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_File,
          "file_elem_file_path": message.fileElem?.path,
          "file_elem_file_name": message.fileElem?.fileName,
          "file_elem_file_id": message.fileElem?.UUID,
          "file_elem_url": message.fileElem?.url,
          "file_elem_file_size": message.fileElem?.fileSize
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Location,
          "location_elem_desc": message.locationElem?.desc,
          "location_elem_longitude": message.locationElem?.longitude,
          "location_elem_latitude": message.locationElem?.latitude,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Face,
          "face_elem_index": message.faceElem?.index,
          "face_elem_buf": message.faceElem?.data,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        List memberInfo = List.empty(growable: true);
        if (message.groupTipsElem?.memberList != null) {
          message.groupTipsElem?.memberList?.forEach((element) {
            memberInfo.add(groupMemberInfo2CGroupMemberInfo(element));
          });
        }
        List memberchange = List.empty(growable: true);
        if (message.groupTipsElem?.memberChangeInfoList != null) {
          message.groupTipsElem?.memberChangeInfoList?.forEach((element) {
            memberchange.add(memberChangeInfo2CMemberChange(element));
          });
        }
        List groupchange = List.empty(growable: true);
        if (message.groupTipsElem?.groupChangeInfoList != null) {
          message.groupTipsElem?.groupChangeInfoList?.forEach((element) {
            groupchange.add(groupChangeInfo2CGroupChange(element));
          });
        }
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_GroupTips,
          "group_tips_elem_group_id": message.groupTipsElem?.groupID,
          "group_tips_elem_tip_type": message.groupTipsElem?.type,
          "group_tips_elem_op_user_info":
              groupMemberInfo2CUserProfile(message.groupTipsElem?.opMember),
          // memberInfo = object[groupMemberInfo]??
          "group_tips_elem_op_group_memberinfo": memberInfo,
          "group_tips_elem_member_change_info_array": memberchange,
          "group_tips_elem_group_change_info_array": groupchange,
          "group_tips_elem_member_num": message.groupTipsElem?.memberCount,
        });
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        map.addAll({
          "elem_type": TIMElemType.kTIMElem_Merge,
          "merge_elem_layer_over_limit": message.mergerElem?.isLayersOverLimit,
          "merge_elem_title": message.mergerElem?.title,
          "merge_elem_abstract_array": message.mergerElem?.abstractList,
        });
        break;
      default:
    }
    return map;
  }

  static Pointer<Int8> v2TimMessage2CMessage(V2TimMessage message) {
    return string2PointerInt8(json.encode({
      "message_elem_array": message.elemType,
      "message_msg_id": message.msgID,
      "message_sender": message.sender,
      "message_conv_id":
          message.groupID != null ? message.groupID : message.userID,
      "message_status": message.status,
      "message_custom_str": message.localCustomData,
      "message_custom_int": message.localCustomInt,
      "message_cloud_custom_str": message.cloudCustomData,
      "message_is_from_self": message.isSelf,
      "message_is_read": message.isRead,
      "message_is_peer_read": message.isPeerRead,
      "message_priority": message.priority,
      "message_group_at_user_array": message.groupAtUserList,
      "message_seq": message.seq,
      "message_rand": message.random,
      "message_is_excluded_from_unread_count":
          message.isExcludedFromUnreadCount,
      "message_excluded_from_last_message": message.isExcludedFromLastMessage,
      "message_need_read_receipt": message.needReadReceipt,
    }));
  }

  static List<Map<String, dynamic>> generateNativeMemberListByDartParam(
      List<V2TimGroupMember> memberList) {
    List<Map<String, dynamic>> res =
        List<Map<String, dynamic>>.empty(growable: true);
    for (V2TimGroupMember element in memberList) {
      Map<String, dynamic> nativeMap = Map.from({
        "group_member_info_identifier": element.userID,
        "group_member_info_member_role": element.role.index,
      });
      res.add(nativeMap);
    }
    return res;
  }

  static Map<String, dynamic> generateNativeUserInfoByDartParam(
      V2TimUserFullInfo info) {
    List<Map<String, dynamic>> user_profile_item_custom_string_array =
        List.empty(growable: true);
    if (info.customInfo != null) {
      info.customInfo!.forEach((key, value) {
        user_profile_item_custom_string_array.add(Map<String, dynamic>.from({
          "user_profile_custom_string_info_key": key,
          "user_profile_custom_string_info_value": value,
        }));
      });
    }
    Map<String, dynamic> res = Map<String, dynamic>.from({
      "user_profile_item_nick_name": info.nickName,
      "user_profile_item_gender": info.gender,
      "user_profile_item_face_url": info.faceUrl ?? "",
      "user_profile_item_self_signature": info.selfSignature,
      "user_profile_item_add_permission": info.allowType,
      "user_profile_item_birthday": info.birthday ?? 0,
      "user_profile_item_level": info.level ?? 0,
      "user_profile_item_role": info.role ?? 0,
      "user_profile_item_custom_string_array":
          user_profile_item_custom_string_array.isNotEmpty
              ? user_profile_item_custom_string_array
              : null,
    });
    return res;
  }

  static int convertid2convType(String convid) {
    return convid.contains("@TGS") ? 2 : 1;
  }

  static Map<String, dynamic> createNativeMessage({
    required List<Map<String, dynamic>> elem,
  }) {
    return Map<String, dynamic>.from({"message_elem_array": elem});
  }

  static Map<String, dynamic> createNativeSendMessage({
    required Map<String, dynamic> createdMessage,
    required String groupId,
    required String userID,
    int? priority,
    bool? onlineUserOnly,
    bool? isExcludedFromUnreadCount,
    bool? isExcludedFromLastMessage,
    bool? needReadReceipt,
    Map<String, dynamic>? offlinePushInfo,
    String? cloudCustomData,
    String? localCustomData,
  }) {
    createdMessage['message_conv_type'] = groupId.isEmpty ? 2 : 1;
    createdMessage["message_conv_id"] = groupId.isEmpty ? userID : groupId;
    createdMessage["message_priority"] = priority;
    createdMessage["message_need_read_receipt"] = needReadReceipt ?? false;
    createdMessage["message_is_online_msg"] = onlineUserOnly ?? true;
    createdMessage["message_is_excluded_from_unread_count"] =
        isExcludedFromUnreadCount ?? false;
    createdMessage["message_excluded_from_last_message"] =
        isExcludedFromLastMessage ?? false;
    createdMessage["message_cloud_custom_str"] = cloudCustomData ?? "";
    createdMessage["message_custom_str"] = localCustomData ?? "";
    createdMessage["message_offlie_push_config"] = offlinePushInfo;
    return createdMessage;
  }

  static String generateUniqueString() {
    int now = DateTime.now().microsecondsSinceEpoch;
    return "$now-${generateRandomString(10)}";
  }

  static String generateRandomString(int length) {
    final _random = Random();
    const _availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length,
            (index) => _availableChars[_random.nextInt(_availableChars.length)])
        .join();

    return randomString;
  }

  static Map<String, dynamic>? generateNativeOfflinePushInfoByDart(
      OfflinePushInfo? info) {
    if (info == null) {
      return null;
    }
    return Map<String, dynamic>.from({
      "offline_push_config_desc": info.desc,
      "offline_push_config_ext": info.ext,
      "offline_push_config_flag": info.disablePush == null
          ? 0
          : info.disablePush == true
              ? 1
              : 0,
      "offline_push_config_ios_config": Map<String, dynamic>.from({
        "ios_offline_push_config_title": info.title,
        "ios_offline_push_config_sound": info.iOSSound,
        "ios_offline_push_config_ignore_badge": info.ignoreIOSBadge,
      }),
      "offline_push_config_android_config": Map<String, dynamic>.from({
        "android_offline_push_config_title": info.title,
        "android_offline_push_config_sound": info.androidSound,
        "android_offline_push_config_notify_mode": 1,
        "android_offline_push_config_vivo_classification":
            info.androidVIVOClassification != null
                ? int.parse(info.androidVIVOClassification!)
                : null,
        "android_offline_push_config_oppo_channel_id":
            info.androidOPPOChannelID,
      })
    });
  }

  static int dartElemTypeToNative(int type) {
    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return 0;
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return 3;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return 6;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return 4;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return 5;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return 1;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return 7;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return 12;
      case MessageElemType.V2TIM_ELEM_TYPE_NONE:
        return -1;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return 2;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return 9;
      default:
        return -1;
    }
  }

  static V2TimTopicInfo convert2DartTopicInfo(Map<String, dynamic> json) {
    List<Map<String, dynamic>> atList = List.empty(growable: true);
    if (json["group_topic_info_group_at_info_array"] != null) {
      List<Map<String, dynamic>> nativeLits = List<Map<String, dynamic>>.from(
          json["group_topic_info_group_at_info_array"]);
      for (var element in nativeLits) {
        atList.add(Tools.convert2GroupAtInfo(element).toJson());
      }
    }
    return V2TimTopicInfo.fromJson({
      "topicID": json["group_topic_info_topic_id"],
      "topicName": json["group_topic_info_topic_name"],
      "topicFaceUrl": json["group_topic_info_topic_face_url"],
      "introduction": json["group_topic_info_introduction"],
      "notification": json["group_topic_info_notification"],
      "isAllMute": json["group_topic_info_is_all_muted"],
      "selfMuteTime": json["group_topic_info_self_mute_time"],
      "customString": json["group_topic_info_custom_string"],
      "recvOpt": json["group_topic_info_recv_opt"],
      "draftText": json["group_topic_info_draft_text"],
      "unreadCount": json["group_topic_info_unread_count"],
      "lastMessage":
          Tools.convertMessage2Dart(json["group_topic_info_last_message"])
              .toJson(),
      "groupAtInfoList": atList,
    });
  }

  static V2TimGroupAtInfo convert2GroupAtInfo(json) {
    return V2TimGroupAtInfo.fromJson({
      "seq": json["conv_group_at_info_seq"],
      "atType": json["conv_group_at_info_at_type"]
    });
  }

  static V2TimGroupMemberInfo converV2TimGroupMemberInfo(
      Map<String, dynamic> elem) {
    return V2TimGroupMemberInfo.fromJson({
      "userID": elem["group_report_elem_op_group_memberinfo"]
          ["group_member_info_identifier"],
      "nickName": elem["group_report_elem_op_group_memberinfo"]
          ["group_member_info_nick_name"],
      "nameCard": elem["group_report_elem_op_group_memberinfo"]
          ["group_member_info_name_card"],
      "friendRemark": elem["group_report_elem_op_group_memberinfo"]
          ["group_member_info_remark"],
      "faceUrl": elem["group_report_elem_op_group_memberinfo"]
          ["group_member_info_face_url"]
    });
  }

  static V2TimGroupMemberInfo converOpV2TimGroupMemberInfo(
      Map<String, dynamic> elem) {
    return V2TimGroupMemberInfo.fromJson({
      "userID": elem["group_report_elem_op_user_info"]
          ["user_profile_identifier"],
      "nickName": elem["group_report_elem_op_user_info"]
          ["user_profile_nick_name"],
      "nameCard": "",
      "friendRemark": "",
      "faceUrl": elem["group_report_elem_op_user_info"]["user_profile_face_url"]
    });
  }
}
