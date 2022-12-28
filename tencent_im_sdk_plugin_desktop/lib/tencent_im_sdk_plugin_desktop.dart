library tencent_im_sdk_plugin_desktop;

import 'dart:collection';

import 'package:tencent_im_sdk_plugin_desktop/utils/im_native.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_list_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_topic_info.dart';
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
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_full_info.dart';
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
// import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';

class TencentImSDKPluginDesktop extends ImFlutterPlatform {
  static void registerWith() {
    ImFlutterPlatform.instance = TencentImSDKPluginDesktop();
  }

  @override
  Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required int loglevel,
    String? listenerUuid,
    V2TimSDKListener? listener,
    required int uiPlatform,
    bool? showImLog,
  }) async {
    return IMNative.initSDK(
      sdkAppID: sdkAppID,
      loglevel: loglevel,
      uiPlatform: uiPlatform,
      listener: listener,
      listenerUuid: listenerUuid,
    );
  }

  @override
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    print("macos login");
    return IMNative.login(userID: userID, userSig: userSig);

    // return V2TimCallback.fromJson({"code": 0, "desc": ''});
  }

  @override
  Future<V2TimCallback> unInitSDK() async {
    print("macos unInitSDK");
    // LoadDyLib().load().TIMUninit();
    return V2TimCallback.fromJson({
      "code": 0,
      "desc": "",
    });
  }

  @override
  Future<V2TimValueCallback<String>> getVersion() async {
    return IMNative.getVersion();
  }

  @override
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    return IMNative.getLoginStatus();
  }

  @override
  Future<V2TimValueCallback<String>> getLoginUser() async {
    return IMNative.getLoginUser();
  }

  @override
  Future<V2TimValueCallback<int>> getServerTime() async {
    return IMNative.getServerTime();
  }

  @override
  Future<V2TimCallback> logout() async {
    return IMNative.logout();
  }

  // testing result param
  @override
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    return IMNative.getConversationList(nextSeq: nextSeq, count: count);
  }

  @override
  Future<void> addAdvancedMsgListener({
    required V2TimAdvancedMsgListener listener,
    String? listenerUuid,
  }) async {
    IMNative.addAdvancedMsgListener(listener, listenerUuid);
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) {
    return IMNative.getUsersInfo(userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<String>> createGroup({
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
    return IMNative.createGroup(
      groupType: groupType,
      groupName: groupName,
      groupID: groupID,
      notification: notification,
      introduction: introduction,
      faceUrl: faceUrl,
      isAllMuted: isAllMuted,
      addOpt: addOpt,
      memberList: memberList,
      isSupportTopic: isSupportTopic,
    );
  }

  @override
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    return IMNative.joinGroup(
        groupID: groupID, message: message, groupType: groupType);
  }

  @override
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    return IMNative.quitGroup(groupID: groupID);
  }

  @override
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    return IMNative.dismissGroup(groupID: groupID);
  }

  @override
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    return IMNative.setSelfInfo(userFullInfo: userFullInfo);
  }

  @override
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    return IMNative.callExperimentalAPI(api: api, param: param);
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversaionIds({
    required List<String> conversationIDList,
  }) async {
    return IMNative.getConversationListByConversaionIds(
        conversationIDList: conversationIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    /*required*/ required String conversationID,
  }) async {
    return IMNative.getConversation(conversationID: conversationID);
  }

  @override
  Future<V2TimCallback> deleteConversation({
    /*required*/ required String conversationID,
  }) async {
    return IMNative.deleteConversation(conversationID: conversationID);
  }

  @override
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    return IMNative.pinConversation(
        conversationID: conversationID, isPinned: isPinned);
  }

  @override
  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    if (draftText != null) {
      return IMNative.setConversationDraft(
          conversationID: conversationID, draftText: draftText);
    } else {
      return IMNative.cancelConversationDraft(conversationID: conversationID);
    }
  }

  @override
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    return IMNative.getTotalUnreadMessageCount();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    return IMNative.getFriendList();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    return IMNative.getFriendsInfo(userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required int addType,
  }) async {
    return IMNative.addFriend(
      userID: userID,
      addType: addType,
      remark: remark,
      friendGroup: friendGroup,
      addWording: addWording,
      addSource: addSource,
    );
  }

  @override
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    return IMNative.setFriendInfo(
        userID: userID,
        friendRemark: friendRemark,
        friendCustomInfo: friendCustomInfo);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromFriendList({
    required List<String> userIDList,
    required int deleteType,
  }) async {
    return IMNative.deleteFromFriendList(
        userIDList: userIDList, deleteType: deleteType);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required int checkType,
  }) async {
    return IMNative.checkFriend(checkType: checkType, userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimFriendApplicationResult>>
      getFriendApplicationList() async {
    return IMNative.getFriendApplicationList();
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      acceptFriendApplication({
    required int responseType,
    required int type,
    required String userID,
  }) async {
    return IMNative.acceptFriendApplication(
        responseType: responseType, type: type, userID: userID);
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      refuseFriendApplication({
    required int type,
    required String userID,
  }) async {
    return IMNative.refuseFriendApplication(type: type, userID: userID);
  }

  @override
  Future<V2TimCallback> deleteFriendApplication({
    required int type,
    required String userID,
  }) async {
    return IMNative.deleteFriendApplication(type: type, userID: userID);
  }

  @override
  Future<V2TimCallback> setFriendApplicationRead() async {
    return IMNative.setFriendApplicationRead();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() async {
    return IMNative.getBlackList();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({
    required List<String> userIDList,
  }) async {
    return IMNative.addToBlackList(userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    return IMNative.deleteFromBlackList(userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    return IMNative.createFriendGroup(
        groupName: groupName, userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    return IMNative.getFriendGroups(groupNameList: groupNameList);
  }

  @override
  Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    return IMNative.deleteFriendGroup(groupNameList: groupNameList);
  }

  @override
  Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    return IMNative.renameFriendGroup(oldName: oldName, newName: newName);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return IMNative.addFriendsToFriendGroup(
        groupName: groupName, userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return IMNative.deleteFriendsFromFriendGroup(
        groupName: groupName, userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    return IMNative.searchFriends(searchParam: searchParam);
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() async {
    return IMNative.getJoinedGroupList();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    return IMNative.getGroupsInfo(groupIDList: groupIDList);
  }

  Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) async {
    return IMNative.setGroupInfo(info: info);
  }

  @override
  Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return IMNative.setGroupAttributes(
        groupID: groupID, attributes: attributes);
  }

  @override
  Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    return IMNative.deleteGroupAttributes(groupID: groupID, keys: keys);
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    return IMNative.getGroupAttributes(groupID: groupID, keys: keys);
  }

  @override
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    return IMNative.getGroupOnlineMemberCount(groupID: groupID);
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
    required String groupID,
    required int filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    return IMNative.getGroupMemberList(
        groupID: groupID, filter: filter, nextSeq: nextSeq);
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    return IMNative.getGroupMembersInfo(
        groupID: groupID, memberList: memberList);
  }

  @override
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    return IMNative.setGroupMemberInfo(
      groupID: groupID,
      userID: userID,
      nameCard: nameCard,
      customInfo: customInfo,
    );
  }

  @override
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    return IMNative.muteGroupMember(
        groupID: groupID, userID: userID, seconds: seconds);
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    return IMNative.inviteUserToGroup(groupID: groupID, userList: userList);
  }

  @override
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    String? reason,
  }) async {
    return IMNative.kickGroupMember(groupID: groupID, memberList: memberList);
  }

  @override
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required int role,
  }) async {
    return IMNative.setGroupMemberRole(
        groupID: groupID, userID: userID, role: role);
  }

  @override
  Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    return IMNative.transferGroupOwner(groupID: groupID, userID: userID);
  }

  @override
  Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    return IMNative.getGroupApplicationList();
  }

  @override
  Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
    String? webMessageInstance,
  }) async {
    return IMNative.acceptGroupApplication(
      groupID: groupID,
      fromUser: fromUser,
      toUser: toUser,
      reason: reason,
      addTime: addTime,
      type: type,
    );
  }

  @override
  Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    required int addTime,
    required int type,
    String? webMessageInstance,
  }) async {
    return IMNative.refuseGroupApplication(
      groupID: groupID,
      fromUser: fromUser,
      toUser: toUser,
      reason: reason,
      addTime: addTime,
      type: type,
    );
  }

  @override
  Future<V2TimCallback> setGroupApplicationRead() async {
    return IMNative.setGroupApplicationRead();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    return IMNative.searchGroups(searchParam: searchParam);
  }

  @override
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam param,
  }) async {
    return IMNative.searchGroupMembers(searchParam: param);
  }

  @override
  Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return IMNative.initGroupAttributes(
        groupID: groupID, attributes: attributes);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage({
    required String text,
  }) async {
    return IMNative.createTextMessage(text: text);
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMessage({
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
    return IMNative.sendMessage(
      id: id,
      receiver: receiver,
      groupID: groupID,
      priority: priority,
      onlineUserOnly: onlineUserOnly,
      isExcludedFromLastMessage: isExcludedFromLastMessage,
      isExcludedFromUnreadCount: isExcludedFromLastMessage,
      isSupportMessageExtension: isSupportMessageExtension,
      needReadReceipt: needReadReceipt,
      offlinePushInfo: offlinePushInfo,
      cloudCustomData: cloudCustomData,
      localCustomData: localCustomData,
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createTargetedGroupMessage({
    required String id,
    required List<String> receiverList,
  }) async {
    return IMNative.createTargetedGroupMessage(
        id: id, receiverList: receiverList);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage({
    required String data,
    String desc = "",
    String extension = "",
  }) async {
    return IMNative.createCustomMessage(
        data: data, desc: desc, extension: extension);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage({
    required String imagePath,
    dynamic inputElement,
    String? imageName,
  }) async {
    return IMNative.createImageMessage(imagePath: imagePath);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createSoundMessage({
    required String soundPath,
    required int duration,
  }) async {
    return IMNative.createSoundMessage(
        soundPath: soundPath, duration: duration);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage({
    required String videoFilePath,
    required String type,
    required int duration,
    required String snapshotPath,
    dynamic inputElement,
  }) async {
    return IMNative.createVideoMessage(
        videoFilePath: videoFilePath,
        type: type,
        duration: duration,
        snapshotPath: snapshotPath);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage({
    required String filePath,
    required String fileName,
    dynamic inputElement,
  }) async {
    return IMNative.createFileMessage(filePath: filePath, fileName: fileName);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    return IMNative.createTextAtMessage(text: text, atUserList: atUserList);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    return IMNative.createLocationMessage(
        desc: desc, longitude: longitude, latitude: latitude);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    return IMNative.createFaceMessage(index: index, data: data);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage({
    required List<String> msgIDList,
    required String title,
    required List<String> abstractList,
    required String compatibleText,
    List<String>? webMessageInstanceList,
  }) async {
    return IMNative.createMergerMessage(
        msgIDList: msgIDList,
        title: title,
        abstractList: abstractList,
        compatibleText: compatibleText);
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    return IMNative.findMessages(messageIDList: messageIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage({
    required String msgID,
    String? webMessageInstance,
  }) async {
    return IMNative.createForwardMessage(msgID: msgID);
  }

  @override
  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    // TODO 这个方法没实现
    return IMNative.setLocalCustomData(
        msgID: msgID, localCustomData: localCustomData);
  }

  @override
  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    // TODO 这个方法没实现
    return IMNative.setLocalCustomInt(
        msgID: msgID, localCustomInt: localCustomInt);
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson({
      "code": -1,
      "desc":
          "getC2CHistoryMessageList is never remove please use getHistoryMessageList to get history message list"
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson({
      "code": -1,
      "desc":
          "getGroupHistoryMessageList is never remove please use getHistoryMessageList to get history message list"
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
  }) async {
    return IMNative.getHistoryMessageList(
      count: count,
      getType: getType,
      userID: userID,
      groupID: groupID,
      lastMsgID: lastMsgID,
      lastMsgSeq: lastMsgSeq,
      messageTypeList: messageTypeList,
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessageListResult>> getHistoryMessageListV2({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
  }) async {
    return V2TimValueCallback<V2TimMessageListResult>.fromJson({
      "code": -1,
      "desc": "desktop is not support this api now",
      "data": V2TimMessageListResult.fromJson({
        "isFinished": true,
        "messageList": List.empty(),
      }).toJson(),
    });
  }

  @override
  Future<LinkedHashMap<dynamic, dynamic>> getHistoryMessageListWithoutFormat({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    return LinkedHashMap<dynamic, dynamic>.from({
      "code": -1,
      "desc": "getHistoryMessageListWithoutFormat is removed at desktop"
    });
  }

  @override
  Future<V2TimCallback> revokeMessage({
    required String msgID,
    Object? webMessageInstatnce,
  }) async {
    return IMNative.revokeMessage(msgID: msgID);
  }

  @override
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    return IMNative.markC2CMessageAsRead(userID: userID);
  }

  @override
  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    return IMNative.setC2CReceiveMessageOpt(userIDList: userIDList, opt: opt);
  }

  @override
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    return IMNative.getC2CReceiveMessageOpt(userIDList: userIDList);
  }

  @override
  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required int opt,
  }) async {
    return IMNative.setGroupReceiveMessageOpt(groupID: groupID, opt: opt);
  }

  @override
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    return IMNative.markGroupMessageAsRead(groupID: groupID);
  }

  @override
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    return IMNative.deleteMessageFromLocalStorage(msgID: msgID);
  }

  @override
  Future<V2TimCallback> deleteMessages({
    required List<String> msgIDs,
    List<dynamic>? webMessageInstanceList,
  }) async {
    return IMNative.deleteMessages(msgIDs: msgIDs);
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    return IMNative.insertGroupMessageToLocalStorage(
        data: data, groupID: groupID, sender: sender);
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    return IMNative.insertC2CMessageToLocalStorage(
        data: data, userID: userID, sender: sender);
  }

  @override
  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    return IMNative.clearC2CHistoryMessage(userID: userID);
  }

  @override
  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    return IMNative.clearGroupHistoryMessage(groupID: groupID);
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    return IMNative.searchLocalMessages(searchParam: searchParam);
  }

  @override
  Future<V2TimCallback> markAllMessageAsRead() async {
    return IMNative.markAllMessageAsRead();
  }

  @override
  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return IMNative.sendMessageReadReceipts(messageIDList: messageIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return IMNative.getMessageReadReceipts(messageIDList: messageIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) async {
    return IMNative.getGroupMessageReadMemberList(
      messageID: messageID,
      filter: filter,
      nextSeq: nextSeq,
      count: count,
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedCommunityList() async {
    return IMNative.getJoinedCommunityList();
  }

  @override
  Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return IMNative.createTopicInCommunity(
        groupID: groupID, topicInfo: topicInfo);
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return IMNative.deleteTopicFromCommunity(
        groupID: groupID, topicIDList: topicIDList);
  }

  @override
  Future<V2TimCallback> setTopicInfo({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return IMNative.setTopicInfo(groupID: groupID, topicInfo: topicInfo);
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return IMNative.getTopicInfoList(
        groupID: groupID, topicIDList: topicIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    return IMNative.modifyMessage(message: message);
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> appendMessage({
    required String createMessageBaseId,
    required String createMessageAppendId,
  }) async {
    return IMNative.appendMessage(
        createMessageBaseId: createMessageBaseId,
        createMessageAppendId: createMessageAppendId);
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) async {
    return IMNative.getUserStatus(userIDList: userIDList);
  }

  @override
  Future<V2TimCallback> setSelfStatus({
    required String status,
  }) async {
    return IMNative.setSelfStatus(status: status);
  }

  @override
  Future<V2TimCallback> subscribeUserStatus({
    required List<String> userIDList,
  }) async {
    return IMNative.subscribeUserStatus(userIDList: userIDList);
  }

  @override
  Future<V2TimCallback> unsubscribeUserStatus({
    required List<String> userIDList,
  }) async {
    return IMNative.unsubscribeUserStatus(userIDList: userIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      setConversationCustomData({
    required String customData,
    required List<String> conversationIDList,
  }) async {
    return IMNative.setConversationCustomData(
        customData: customData, conversationIDList: conversationIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationListByFilter({
    required V2TimConversationListFilter filter,
  }) async {
    return IMNative.getConversationListByFilter(filter: filter);
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      markConversation({
    required int markType,
    required bool enableMark,
    required List<String> conversationIDList,
  }) async {
    return IMNative.markConversation(
        markType: markType,
        enableMark: enableMark,
        conversationIDList: conversationIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      createConversationGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return IMNative.createConversationGroup(
        groupName: groupName, conversationIDList: conversationIDList);
  }

  @override
  Future<V2TimValueCallback<List<String>>> getConversationGroupList() async {
    return IMNative.getConversationGroupList();
  }

  @override
  Future<V2TimCallback> deleteConversationGroup({
    required String groupName,
  }) async {
    return IMNative.deleteConversationGroup(groupName: groupName);
  }

  @override
  Future<V2TimCallback> renameConversationGroup({
    required String oldName,
    required String newName,
  }) async {
    return IMNative.renameConversationGroup(oldName: oldName, newName: newName);
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      addConversationsToGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return IMNative.addConversationsToGroup(
        groupName: groupName, conversationIDList: conversationIDList);
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationsFromGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return IMNative.deleteConversationsFromGroup(
        groupName: groupName, conversationIDList: conversationIDList);
  }

  @override
  Future<void> addGroupListener({
    required V2TimGroupListener listener,
    String? listenerUuid,
  }) async {
    return IMNative.addGroupListener(listener: listener);
  }

  @override
  Future<void> addConversationListener({
    required V2TimConversationListener listener,
    String? listenerUuid,
  }) async {
    return IMNative.addConversationListener(listener: listener);
  }

  @override
  Future<void> removeAdvancedMsgListener({String? listenerUuid}) async {}
}
