// ignore_for_file: avoid_print

import 'dart:js';

import 'package:js/js_util.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/event_enum.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/im_sdk_plugin_js.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_add_friend.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_check_friend.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_friend_black_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_friend_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class V2TIMFriendshipManager {
  static late TIM? timeWeb;
  late List<dynamic> friendList;
  static final Map<String, V2TimFriendshipListener> _friendshipListenerList =
      {};

  V2TIMFriendshipManager() {
    timeWeb = V2TIMManagerWeb.timWeb;
  }

  static getUserIDlist(List<dynamic> list) =>
      list.map((e) => e["userID"]).toList();

  static getUserIDlistFromJS(List<dynamic> list) =>
      list.map((e) => e.userID).toList();

// ?????????
  static getDiffsFromTwoArr(List<dynamic> listA, List<dynamic> listB) {
    var tempArr = [];
    tempArr.addAll(listA);
    tempArr.addAll(listB);
    List<dynamic> difference = tempArr
        .where(
            (element) => !listA.contains(element) || !listB.contains(element))
        .toList();

    return difference;
  }

  static final _friendListUpdatedHandler = allowInterop((res) {
    print("??????????????????????????????");
    final formateList = FriendList.formatedFriendListRes(jsToMap(res)['data']);
    final oldFriendList = V2TIMManager.getFriendList();
    if (oldFriendList.length == 1 && oldFriendList[0] == "init") {
      return;
    }

    int formateListCount = formateList.length;
    int oldFriendListCount = oldFriendList.length;
    List<dynamic> formateUserIDList = getUserIDlist(formateList);
    List<dynamic> oldFriendUserIDList = getUserIDlist(oldFriendList);

    print("formateListCount:$formateListCount");
    print("oldFriendListCount:$oldFriendListCount");
    if (formateListCount > oldFriendListCount) {
      print("????????????ADD????????????");
      final addedList =
          formateList.map((e) => V2TimFriendInfo.fromJson(e)).toList();
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendListAdded(addedList);
      }
    } else if (formateListCount < oldFriendListCount) {
      print("????????????Delete????????????");
      List<dynamic> difference =
          getDiffsFromTwoArr(formateUserIDList, oldFriendUserIDList);
      List<String> userList = List.from(difference);

      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendListDeleted(userList);
      }
    } else {
      List<dynamic> difference = getDiffsFromTwoArr(formateList, oldFriendList);
      log(difference);
      // final differences = formateUserIDList
    }
    V2TIMManager.updtateFriendList(formateList);
  });

  static final _blackListUpdatedHandler = allowInterop((res) {
    print("???????????????????????????");
    final formateList = FriendBlackList.formateBlackList(jsToMap(res)['data']);
    final oldBlackList = V2TIMManager.getBlackList();
    if (oldBlackList.length == 1 && oldBlackList[0] == "init") {
      return;
    }

    int formateListCount = formateList.length;
    int oldBlackListCount = oldBlackList.length;
    List<dynamic> formateUserIDList = getUserIDlist(formateList);
    List<dynamic> oldBlackUserIDList = getUserIDlist(oldBlackList);

    print("formateListCount:$formateListCount");
    print("oldFriendListCount:$oldBlackListCount");
    if (formateListCount >= oldBlackListCount) {
      print("??????BlackList Add????????????");
      final infoListMap =
          formateList.map((e) => V2TimFriendInfo.fromJson(e)).toList();
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onBlackListAdd(infoListMap);
      }
    } else {
      print("??????BlackList Delete????????????");
      List<dynamic> difference =
          getDiffsFromTwoArr(formateUserIDList, oldBlackUserIDList);
      List<String> userList = List.from(difference);
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onBlackListDeleted(userList);
      }
    }
    V2TIMManager.updateBlackList(formateList);
  });

  static final _friendApplicationListUpdatedHandler = allowInterop((res) {
    final resData = jsToMap(res)['data'];
    final List formateList = FriendApplication.formateResult(
        jsToMap(resData))["friendApplicationList"];
    final oldApplicationList = V2TIMManager.getFriendApplicationList();
    if (oldApplicationList.length == 1 && oldApplicationList[0] == "init") {
      return;
    }

    int formateListCount = formateList.length;
    int oldApplicationListCount = oldApplicationList.length;
    List<dynamic> formateUserIDList = getUserIDlist(formateList);
    List<dynamic> oldApplicationIDList = getUserIDlist(oldApplicationList);

    print("formateListCount:$formateListCount");
    print("oldFriendListCount:$oldApplicationListCount");
    if (formateListCount >= oldApplicationListCount) {
      print("??????Application ADD????????????");
      final addedList =
          formateList.map((e) => V2TimFriendApplication.fromJson(e)).toList();
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendApplicationListAdded(addedList);
      }
    } else {
      print("??????Application Delete????????????");
      List<dynamic> difference =
          getDiffsFromTwoArr(formateUserIDList, oldApplicationIDList);
      List<String> userIDList = List.from(difference);
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendApplicationListDeleted(userIDList);
      }
    }
    V2TIMManager.updateFriendApplicationList(formateList);
  });

  static final _profileUpdatedHanlder = allowInterop((res) async {
    List<dynamic> userIDList = getUserIDlistFromJS(jsToMap(res)['data']);
    print("??????????????????????????????");
    // ????????????????????????????????????
    if (userIDList.length == 1 && userIDList[0] == V2TIMManager.getUserID()) {
      return null;
    }

    final result = await wrappedPromiseToFuture(timeWeb!.getFriendProfile(
        FriendInfo.formateGetInfoParams({"userIDList": userIDList})));

    List<dynamic> formateList =
        FriendInfo.formateFriendInfoToList(jsToMap(result.data)['friendList']);
    final infoList =
        formateList.map((e) => V2TimFriendInfo.fromJson(e)).toList();

    for (var listener in _friendshipListenerList.values) {
      listener.onFriendInfoChanged(infoList);
    }
  });

/*
  ????????????web add Friend ????????????update
*/
  void setFriendListener(
      V2TimFriendshipListener listener, String? listenerUuid) {
    if (_friendshipListenerList.isNotEmpty) {
      _friendshipListenerList[listenerUuid!] = (listener);
      return;
    }
    _friendshipListenerList[listenerUuid!] = (listener);
    // FriendList update linstener
    timeWeb!.on(EventType.FRIEND_LIST_UPDATED, _friendListUpdatedHandler);

    // BlackList update Listenet
    timeWeb!.on(EventType.BLACKLIST_UPDATED, _blackListUpdatedHandler);

    // ApplicationList update Listenet
    timeWeb!.on(EventType.FRIEND_APPLICATION_LIST_UPDATED,
        _friendApplicationListUpdatedHandler);

    // FriendIinfo update Listenet, res ????????????
    timeWeb!.on(EventType.PROFILE_UPDATED, _profileUpdatedHanlder);
  }

  void removeFriendListener(String? listenerUuid) {
    if (listenerUuid != null && listenerUuid.isNotEmpty) {
      _friendshipListenerList.remove(listenerUuid);
      if (_friendshipListenerList.isNotEmpty) {
        return;
      }
    }
    _friendshipListenerList.clear();
    timeWeb!.off(EventType.FRIEND_LIST_UPDATED, _friendListUpdatedHandler);

    // BlackList update Listenet
    timeWeb!.off(EventType.BLACKLIST_UPDATED, _blackListUpdatedHandler);

    // ApplicationList update Listenet
    timeWeb!.off(
        EventType.FRIEND_APPLICATION_LIST_UPDATED, _blackListUpdatedHandler);

    // FriendIinfo update Listenet, res ????????????
    timeWeb!.off(EventType.PROFILE_UPDATED, _profileUpdatedHanlder);
  }

  void makeConversationListenerEventData(_channel, String type, data) {
    CommonUtils.emitEvent(_channel, "friendListener", type, data);
  }

  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    try {
      final res = await wrappedPromiseToFuture(timeWeb!.getFriendList());

      final code = res.code;
      final friendList = res.data as List;
      if (code == 0) {
        final formateList = FriendList.formatedFriendListRes(friendList);
        return CommonUtils.returnSuccess<List<V2TimFriendInfo>>(formateList);
      } else {
        return CommonUtils.returnErrorForValueCb('get friend list failed');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb(error);
    }
  }

  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo(
      Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeWeb!.getFriendProfile(FriendInfo.formateGetInfoParams(params)));
      final resultData = jsToMap(res.data);
      final successFriendList = resultData['friendList'] as List;
      final failureFriendList = resultData['failureUserIDList'] as List;
      var formatedFailureFriendList = [];
      if (failureFriendList.isNotEmpty) {
        final failedUserIDList =
            failureFriendList.map((e) => jsToMap(e)["userID"]).toList();
        final userProfileListResult = await wrappedPromiseToFuture(timeWeb!
            .getUserProfile(mapToJSObj({"userIDList": failedUserIDList})));
        formatedFailureFriendList = failureFriendList.map((e) {
          final item = jsToMap(e);
          final userID = item["userID"];
          final userProfileList = userProfileListResult.data as List;
          final result = userProfileList
              .firstWhere((element) => jsToMap(element)["userID"] == userID);
          item['profile'] = result;
          return mapToJSObj(item);
        }).toList();
      }
      final result = await FriendInfo.formateFriendInfoResult(
          successFriendList, formatedFailureFriendList);

      return CommonUtils.returnSuccess<List<V2TimFriendInfoResult>>(result);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendInfoResult>>(
          error);
    }
  }

  Future<dynamic> addFriend(Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeWeb!.addFriend(AddFriend.formateParams(params)));
      final result = AddFriend.formateResult(jsToMap(res.data));

      return CommonUtils.returnSuccess<V2TimFriendOperationResult>(result);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendOperationResult>(
          error);
    }
  }

  /*
    web?????????remark??????????????????????????????
    /????????? Tag_SNS_Custom????????????????????????????????????????????????????????????
  */
  Future<dynamic> setFriendInfo(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({
        "userID": params["userID"],
        "remark": params["friendRemark"],
        "friendCustomField":
            FriendInfo.formateFriendCustomInfo(params["friendCustomInfo"])
      });
      final res =
          await wrappedPromiseToFuture(timeWeb!.updateFriend(formateParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(null);
      } else {
        return CommonUtils.returnError(
            "getFriendsInfo faile code:${res.code}, data:${res.data}");
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> deleteFromFriendList(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({
        "userIDList": params["userIDList"],
        "type": FriendTypeWeb.convertWebFriendType(params["deleteType"]),
      });

      final res =
          await wrappedPromiseToFuture(timeWeb!.deleteFriend(formateParams));

      final successUserIDList = jsToMap(res.data)['successUserIDList'];
      final formateArr = [];
      successUserIDList.forEach((element) =>
          formateArr.add(AddFriend.formateResult(jsToMap(element))));

      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateArr);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<dynamic> checkFriend(Map<String, dynamic> params) async {
    try {
      final formateParams = CheckFriend.formateParams(params);
      final res =
          await wrappedPromiseToFuture(timeWeb!.checkFriend(formateParams));
      final formateResult = CheckFriend.formateResult(jsToMap(res.data));
      return CommonUtils.returnSuccess<List<V2TimFriendCheckResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendCheckResult>>(
          error);
    }
  }

  Future<dynamic> getFriendApplicationList() async {
    try {
      final res =
          await wrappedPromiseToFuture(timeWeb!.getFriendApplicationList());
      final formateResult = FriendApplication.formateResult(jsToMap(res.data));
      return CommonUtils.returnSuccess<V2TimFriendApplicationResult>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendApplicationResult>(
          error);
    }
  }

  // ?????????????????????????????????????????????
  Future<dynamic> acceptFriendApplication(Map<String, dynamic> params) async {
    try {
      final formateParams = AcceptFriendApplication.formateParams(params);
      final res = await promiseToFuture(
          timeWeb!.acceptFriendApplication(formateParams));
      if (res != null) {
        log(res);
      }

      return CommonUtils.returnSuccess<V2TimFriendOperationResult>(null);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendOperationResult>(
          error);
    }
  }

  // ?????????????????????????????????????????????
  Future<dynamic> refuseFriendApplication(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({"userID": params["userID"]});
      final result = await promiseToFuture(
          timeWeb!.refuseFriendApplication(formateParams));
      if (result != null) {
        log(result);
      }
      return CommonUtils.returnSuccess<V2TimFriendOperationResult>(null);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendOperationResult>(
          error);
    }
  }

  Future<dynamic> deleteFriendApplication(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({
        "userID": params["userID"],
        "type": FriendTypeWeb.convertToApplicationFriendType(params["type"])
      });
      final res = await wrappedPromiseToFuture(
          timeWeb!.deleteFriendApplication(formateParams));
      return CommonUtils.returnSuccessForCb(jsToMap(res.data));
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  // ???????????????????????????????????????????????????
  Future<dynamic> setFriendApplicationRead() async {
    try {
      await promiseToFuture(timeWeb!.setFriendApplicationRead());

      return CommonUtils.returnSuccess(null);
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList(
      params) async {
    try {
      final formateParams = mapToJSObj({
        "userIDList": params["userIDList"],
      });
      final res =
          await wrappedPromiseToFuture(timeWeb!.addToBlacklist(formateParams));
      List<dynamic> resultArr = [];
      res.data.forEach((userID) =>
          resultArr.add({"userID": userID, "resultCode": res.code}));

      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          resultArr);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList(params) async {
    try {
      final formateParams = mapToJSObj({
        "userIDList": params["userIDList"],
      });
      await wrappedPromiseToFuture(timeWeb!.removeFromBlacklist(formateParams));
      final formateResult =
          FriendBlackList.formateDeleteBlackListRes(params["userIDList"]);
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  // ???????????????????????????userID???????????????????????????
  Future<dynamic> getBlackList() async {
    try {
      final res = await wrappedPromiseToFuture(timeWeb!.getBlacklist());
      final formateResult = FriendBlackList.formateBlackList(res.data);
      log(res);
      return CommonUtils.returnSuccess<List<V2TimFriendInfo>>(formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendInfo>>(error);
    }
  }

  Future<dynamic> createFriendGroup(Map<String, dynamic> params) async {
    try {
      var formateParams = FriendGroup.formateParams(params);
      final res = await wrappedPromiseToFuture(
          timeWeb!.createFriendGroup(formateParams));
      log(res);
      final formateResult = FriendGroup.formateResult(jsToMap(res.data));
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<dynamic> getFriendGroups(Map<String, dynamic> params) async {
    try {
      if (params["groupNameList"] != null) {
        print(" web getFriendGroupList ????????????????????????");
      }
      final res = await wrappedPromiseToFuture(timeWeb!.getFriendGroupList());
      final formateResult = FriendGroup.formateGroupResult(res.data);
      return CommonUtils.returnSuccess<List<V2TimFriendGroup>>(formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendGroup>>(error);
    }
  }

  // ?????????????????????????????????
  Future<dynamic> deleteFriendGroup(Map<String, dynamic> params) async {
    try {
      print(" web deleteFriendGroup ?????????????????????????????????");
      final formateParams = mapToJSObj({"name": params["groupNameList"][0]});
      final res =
          await promiseToFuture(timeWeb!.deleteFriendGroup(formateParams));
      log(res);
      return CommonUtils.returnSuccessForCb(null);
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> renameFriendGroup(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj(
          {"oldName": params["oldName"], "newName": params["newName"]});
      final res =
          await promiseToFuture(timeWeb!.renameFriendGroup(formateParams));
      log(res);
      return CommonUtils.returnSuccessForCb(null);
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> addFriendsToFriendGroup(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj(
          {"name": params["groupName"], "userIDList": params["userIDList"]});
      final res = await wrappedPromiseToFuture(
          timeWeb!.addToFriendGroup(formateParams));
      log(res);
      final formateResult = FriendBlackList.formateDeleteBlackListRes(
          jsToMap(jsToMap(res.data)['friendGroup'])['userIDList']);
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  //???????????????????????? ???????????????????????????????????????????????????natvie??????????????????
  Future<dynamic> deleteFriendsFromFriendGroup(
      Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj(
          {"name": params["groupName"], "userIDList": params["userIDList"]});
      final res = await wrappedPromiseToFuture(
          timeWeb!.removeFromFriendGroup(formateParams));
      log(res);
      final formateResult = FriendBlackList.formateDeleteBlackListRes(
          jsToMap(jsToMap(res.data)['friendGroup'])['userIDList']);
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<dynamic> searchFriends() async {
    return CommonUtils.returnErrorForValueCb<List<V2TimFriendInfoResult>>(
        'searchFriends Not support for web');
  }
}
