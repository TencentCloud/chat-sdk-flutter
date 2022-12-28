// ignore_for_file: unused_import, library_prefixes, prefer_typing_uninitialized_variables, duplicate_ignore

import 'dart:convert';
import 'dart:html' as html;
import 'dart:js';
import 'package:path/path.dart' as Path;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/v2_signaling_action_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_list_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/event_enum.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/group_receive_message_opt.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/message_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/v2_tim_signaling_manager.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_create_message.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_group_member_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_message_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';
import 'package:tencent_im_sdk_plugin_web/tencent_im_sdk_plugin_web.dart';
import 'im_sdk_plugin_js.dart';
import 'package:mime_type/mime_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_msg_create_info_result.dart';

class V2TIMMessageManager {
  static late TIM? timeweb;
  static Map<String, V2TimAdvancedMsgListener> messageListener = {};
  static List<dynamic> mergerMsgList = [];

  static int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static late final V2TIMSignalingManager _v2timSignalingManager;
  Map<String, dynamic> messageIDMap = {}; // 和native那边略有区别，web在发送信息时才会创建消息

  V2TIMMessageManager(V2TIMSignalingManager signalingManager) {
    _v2timSignalingManager = signalingManager;
    timeweb = V2TIMManagerWeb.timWeb;
  }
  // 设置uuid，保证发送时可以直接拿到底层返回过来的messahe
  handleSetMessageMap(messageInfo) {
    String id = (currentTimeMillis()).toString();
    messageInfo["id"] = id;

    Map<String, dynamic> resultMap = {"messageInfo": messageInfo, "id": id};
    messageIDMap[id] = resultMap;

    return resultMap;
  }

  /*
      V2TIM_ELEM_TYPE_NONE                      = 0,  ///< 未知消息
    V2TIM_ELEM_TYPE_TEXT                      = 1,  ///< 文本消息
    V2TIM_ELEM_TYPE_CUSTOM                    = 2,  ///< 自定义消息
    V2TIM_ELEM_TYPE_IMAGE                     = 3,  ///< 图片消息
    V2TIM_ELEM_TYPE_SOUND                     = 4,  ///< 语音消息
    V2TIM_ELEM_TYPE_VIDEO                     = 5,  ///< 视频消息
    V2TIM_ELEM_TYPE_FILE                      = 6,  ///< 文件消息
    V2TIM_ELEM_TYPE_LOCATION                  = 7,  ///< 地理位置消息
    V2TIM_ELEM_TYPE_FACE                      = 8,  ///< 表情消息
    V2TIM_ELEM_TYPE_GROUP_TIPS                = 9,  ///< 群 Tips 消息
    V2TIM_ELEM_TYPE_MERGER                    = 10, ///< 合并消息
  */
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMessage<T, F>(
      {required String type, required Map<String, dynamic> params}) async {
    var messageSimpleElem = {};
    switch (type) {
      case "text":
        {
          var text = params['text'] ?? '';
          messageSimpleElem = CreateMessage.createSimpleTextMessage(text);
          break;
        }
      case "custom":
        {
          String data = params['data'] ?? '';
          String desc = params['desc'] ?? "";
          String extension = params['extension'];
          messageSimpleElem =
              CreateMessage.createSimpleCustomMessage(data, desc, extension);
          break;
        }
      case "face":
        {
          int index = params['index'] ?? '';
          String data = params['data'] ?? '';
          messageSimpleElem =
              CreateMessage.createSimpleFaceMessage(index: index, data: data);
          break;
        }
      case "image":
        {
          messageSimpleElem =
              await CreateMessage.createSimpleImageMessage(params);
          break;
        }
      case "textAt":
        {
          String text = params['text'] ?? '';
          List<String> atUserList = params['atUserList'] ?? [];
          messageSimpleElem = CreateMessage.createSimpleAtText(
              atUserList: atUserList, text: text);
          break;
        }
      case "location":
        {
          String desc = params['description'] ?? '';
          double longitude = params['longitude'] ?? 0;
          double latitude = params['latitude'] ?? 0;
          messageSimpleElem = CreateMessage.createSimpleLoaction(
              description: desc, longitude: longitude, latitude: latitude);
          break;
        }
      case "mergeMessage":
        {
          List<String> msgIDList = params['msgIDList'] ?? [];
          String title = params['title'] ?? "";
          List<String> abstractList = params['abstractList'] ?? '';
          String compatibleText = params['compatibleText'];
          messageSimpleElem = CreateMessage.createSimpleMergeMessage(
              msgIDList: msgIDList,
              title: title,
              abstractList: abstractList,
              compatibleText: compatibleText);
          break;
        }
      case "forwardMessage":
        {
          final webRawMessage = timeweb!.findMessage(params['msgID']);
          messageSimpleElem = await CreateMessage.createSimpleForwardMessage(
              webRawMessage: webRawMessage);
          break;
        }
      case "video":
        {
          String videoFilePath = params['videoFilePath'] ?? '';
          dynamic file = params['inputElement'];
          messageSimpleElem = await CreateMessage.createSimpleVideoMessage(
            videoFilePath,
            file,
          );
          break;
        }
      case "file":
        {
          messageSimpleElem = await CreateMessage.createSimpleFileMessage(
              filePath: params['filePath'] ?? '',
              fileName: params['fileName'] ?? "",
              file: params['inputElement']);
          break;
        }
    }
    var result = handleSetMessageMap(messageSimpleElem);
    return CommonUtils.returnSuccess<V2TimMsgCreateInfoResult>(result);
  }

  // 3.6.0后启用此函数
  Future<V2TimValueCallback<V2TimMessage>> sendMessageForNew<T, F>(
      {required Map<String, dynamic> params}) async {
    String? id = params['id'];
    var messageElem;
    try {
      final groupID = params['groupID'] ?? '';
      final recveiver = params['receiver'] ?? '';
      final haveTwoValues = groupID != '' && recveiver != '';

      final messageMap = messageIDMap[id];
      final messageInfo = messageMap["messageInfo"];
      final type = messageMap["messageInfo"]["type"];
      if (haveTwoValues) {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>({
          'code': 6017,
          'desc': "receiver and groupID cannot set at the same time",
          'data': V2TimMessage(elemType: 1).toJson()
        });
      }
      if (id == null || messageMap == null) {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>({
          'code': 6017,
          'desc': "id cannot be empty or message cannot find",
          'data': V2TimMessage(elemType: 1).toJson()
        });
      }
      final convType = groupID != '' ? 'GROUP' : 'C2C';
      final sendToUserID = convType == 'GROUP' ? groupID : recveiver;
      final needReadReceipt = params['needReadReceipt'];
      final cloudCustomData = params['cloudCustomData'] ?? "";
      switch (type) {
        case "text":
          {
            String text = messageInfo["textElem"]["text"];
            final createElemParams = CreateMessage.createTextMessage(
                userID: sendToUserID,
                text: text,
                cloudCustomData: cloudCustomData,
                convType: convType,
                needReadReceipt: needReadReceipt,
                priority: params['priority']);
            messageElem = timeweb!.createTextMessage(createElemParams);
            break;
          }
        case "custom":
          {
            final customMessage = CreateMessage.createCustomMessage(
                userID: sendToUserID,
                customData: messageInfo["customElem"]["data"],
                convType: convType,
                cloudCustomData: cloudCustomData,
                needReadReceipt: needReadReceipt,
                extension: messageInfo['customElem']['extension'],
                description: messageInfo['customElem']['desc'],
                priority: params['priority']);
            messageElem = timeweb!.createCustomMessage(customMessage);
            break;
          }
        case "face":
          {
            final faceMessage = CreateMessage.createFaceMessage(
                userID: sendToUserID,
                data: messageInfo["faceElem"]["data"],
                index: messageInfo["faceElem"]["index"],
                cloudCustomData: cloudCustomData,
                needReadReceipt: needReadReceipt,
                convType: convType,
                priority: params['priority']);
            messageElem = timeweb!.createFaceMessage(faceMessage);
            break;
          }
        case "image":
          {
            final progressCallback = allowInterop((double progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener.isNotEmpty) {
                messageInstance['id'] = id;
                for (var listener in messageListener.values) {
                  listener.onSendMessageProgress(
                      V2TimMessage.fromJson(messageInstance), progress.toInt());
                }
              }
            });
            final createElemParams = CreateMessage.createImageMessage(
                userID: sendToUserID,
                file: messageInfo["imageElem"]["file"],
                convType: convType,
                cloudCustomData: cloudCustomData,
                needReadReceipt: needReadReceipt,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createImageMessage(createElemParams);
            break;
          }
        case "textAt":
          {
            final createElemParams = CreateMessage.createTextAtMessage(
                groupID: sendToUserID,
                text: messageInfo["textElem"]['text'],
                priority: params['priority'],
                needReadReceipt: needReadReceipt,
                cloudCustomData: cloudCustomData,
                atList: messageInfo["textElem"]['atUserList']);
            messageElem = timeweb!.createTextAtMessage(createElemParams);
            break;
          }
        case "location":
          {
            final createElemParams = CreateMessage.createLocationMessage(
                description: messageInfo["locationElem"]['description'],
                longitude: messageInfo["locationElem"]['longitude'],
                latitude: messageInfo["locationElem"]['latitude'],
                cloudCustomData: cloudCustomData,
                needReadReceipt: needReadReceipt,
                priority: params['priority'],
                userID: sendToUserID);
            messageElem = timeweb!.createLocationMessage(createElemParams);
            break;
          }
        case "mergeMessage":
          {
            List<String> msgList = messageInfo["mergerElem"]['msgIDList'];
            List<dynamic> messageList =
                msgList.map((e) => timeweb!.findMessage(e)).toList();
            String titile = messageInfo["mergerElem"]['title'];
            List<String> abstractList =
                messageInfo["mergerElem"]['abstractList'];
            String compatibleText = messageInfo["mergerElem"]['compatibleText'];
            final createElemParams = CreateMessage.createMereMessage(
                userID: sendToUserID,
                messageList: messageList,
                title: titile,
                convType: convType,
                cloudCustomData: cloudCustomData,
                priority: params['priority'],
                abstractList: abstractList,
                needReadReceipt: needReadReceipt,
                compatibleText: compatibleText);
            messageElem = timeweb!.createMergerMessage(createElemParams);
            break;
          }
        case "forwardMessage":
          {
            final msgID = messageInfo['msgID'];
            final createElemParams = CreateMessage.createForwardMessage(
              message: timeweb!.findMessage(msgID),
              userID: sendToUserID,
              cloudCustomData: cloudCustomData,
              needReadReceipt: needReadReceipt,
              priority: params['priority'],
            );

            messageElem = timeweb!.createForwardMessage(createElemParams);
            break;
          }
        case "video":
          {
            final progressCallback = allowInterop((double progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener.isNotEmpty) {
                messageInstance['id'] = id;
                for (var listener in messageListener.values) {
                  listener.onSendMessageProgress(
                      V2TimMessage.fromJson(messageInstance), progress.toInt());
                }
              }
            });
            final createElemParams = CreateMessage.createVideoMessage(
                userID: sendToUserID,
                file: messageInfo['videoElem']['file'],
                convType: convType,
                cloudCustomData: cloudCustomData,
                needReadReceipt: needReadReceipt,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createVideoMessage(createElemParams);
            break;
          }
        case "file":
          {
            final progressCallback = allowInterop((double progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener.isNotEmpty) {
                messageInstance['id'] = id;
                for (var listener in messageListener.values) {
                  listener.onSendMessageProgress(
                      V2TimMessage.fromJson(messageInstance), progress.toInt());
                }
              }
            });
            final createElemParams = CreateMessage.createFileMessage(
                userID: sendToUserID,
                file: messageInfo['fileElem']['file'],
                convType: convType,
                cloudCustomData: cloudCustomData,
                needReadReceipt: needReadReceipt,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createFileMessage(createElemParams);
            break;
          }
      }
      final res = await wrappedPromiseToFuture(timeweb!.sendMessage(messageElem,
          mapToJSObj({"onlineUserOnly": params['onlineUserOnly']})));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)['message'];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        messageIDMap.remove(id);
        return CommonUtils.returnSuccess<V2TimMessage>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>('发送消息失败');
      }
    } catch (error) {
      messageIDMap.remove(id);
      final mapMessageElem = jsToMap(messageElem);
      mapMessageElem['status'] = "fail";
      final formatedMessage =
          await V2TIMMessage.convertMessageFromWebToDart(messageElem);
      return CommonUtils.returnErrorForValueCb<V2TimMessage>(error,
          resultData: formatedMessage);
    }
  }

  Future<dynamic> sendMessage<T, F>(
      {required String type, required Map<String, dynamic> params}) async {
    try {
      final groupID = params['groupID'] ?? '';
      final recveiver = params['receiver'] ?? '';
      final haveTwoValues = groupID != '' && recveiver != '';
      if (haveTwoValues) {
        return CommonUtils.returnErrorForValueCb<F>({
          'code': 6017,
          'desc': "receiver and groupID cannot set at the same time",
          'data': V2TimMessage(elemType: 1).toJson()
        });
      }
      final convType = groupID != '' ? 'GROUP' : 'C2C';
      final sendToUserID = convType == 'GROUP' ? groupID : recveiver;
      // ignore: prefer_typing_uninitialized_variables
      var messageElem;
      switch (type) {
        case "text":
          {
            final createElemParams = CreateMessage.createTextMessage(
                userID: sendToUserID,
                text: params["text"],
                convType: convType,
                priority: params['priority']);
            messageElem = timeweb!.createTextMessage(createElemParams);
            break;
          }
        case "custom":
          {
            final customMessage = CreateMessage.createCustomMessage(
                userID: sendToUserID,
                customData: params["data"],
                convType: convType,
                extension: params['extension'],
                description: params['desc'],
                priority: params['priority']);
            messageElem = timeweb!.createCustomMessage(customMessage);
            break;
          }
        case "face":
          {
            final faceMessage = CreateMessage.createFaceMessage(
                userID: sendToUserID,
                data: params["data"],
                index: params["index"],
                convType: convType,
                priority: params['priority']);
            messageElem = timeweb!.createFaceMessage(faceMessage);
            break;
          }
        case "image":
          {
            final progressCallback = allowInterop((double progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener.isNotEmpty) {
                for (var listener in messageListener.values) {
                  listener.onSendMessageProgress(
                      V2TimMessage.fromJson(messageInstance), progress.toInt());
                }
              }
            });
            final createElemParams = CreateMessage.createImageMessage(
                userID: sendToUserID,
                file: params['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createImageMessage(createElemParams);
            break;
          }
        case "textAt":
          {
            final createElemParams = CreateMessage.createTextAtMessage(
                groupID: sendToUserID,
                text: params['text'],
                priority: params['priority'],
                atList: params['atUserList']);
            messageElem = timeweb!.createTextAtMessage(createElemParams);
            break;
          }
        case "location":
          {
            final createElemParams = CreateMessage.createLocationMessage(
                description: params['desc'],
                longitude: params['longitude'],
                latitude: params['latitude'],
                priority: params['priority'],
                userID: sendToUserID);
            messageElem = timeweb!.createLocationMessage(createElemParams);
            break;
          }
        case "mergeMessage":
          {
            final createElemParams = CreateMessage.createMereMessage(
                userID: sendToUserID,
                messageList: params['webMessageInstanceList'],
                title: params['title'],
                convType: convType,
                priority: params['priority'],
                abstractList: params['abstractList'],
                compatibleText: params['compatibleText']);
            messageElem = timeweb!.createMergerMessage(createElemParams);
            break;
          }
        case "forwardMessage":
          {
            final createElemParams = CreateMessage.createForwardMessage(
              message: parse(params['webMessageInstance']),
              userID: sendToUserID,
              priority: params['priority'],
            );
            messageElem = timeweb!.createForwardMessage(createElemParams);
            break;
          }
        case "video":
          {
            final progressCallback = allowInterop((double progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener.isNotEmpty) {
                for (var listener in messageListener.values) {
                  listener.onSendMessageProgress(
                      V2TimMessage.fromJson(messageInstance), progress.toInt());
                }
              }
            });
            final createElemParams = CreateMessage.createVideoMessage(
                userID: sendToUserID,
                file: params['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createVideoMessage(createElemParams);
            break;
          }
        case "file":
          {
            final progressCallback = allowInterop((double progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener.isNotEmpty) {
                for (var listener in messageListener.values) {
                  listener.onSendMessageProgress(
                      V2TimMessage.fromJson(messageInstance), progress.toInt());
                }
              }
            });
            final createElemParams = CreateMessage.createFileMessage(
                userID: sendToUserID,
                file: params['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createFileMessage(createElemParams);
            break;
          }
      }
      final res = await wrappedPromiseToFuture(timeweb!.sendMessage(messageElem,
          mapToJSObj({"onlineUserOnly": params['onlineUserOnly']})));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)['message'];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<F>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<F>('发送消息失败');
      }
    } catch (error) {
      log(error);
      return CommonUtils.returnErrorForValueCb<F>(error);
    }
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage(
      {required String text}) async {
    return createMessage(type: "text", params: {"text": text});
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage(
      {required String data, String? desc, String? extension}) async {
    return createMessage(type: "custom", params: {
      "data": data,
      "desc": desc ?? "",
      "extension": extension ?? ""
    });
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage(
      Map<String, dynamic> params) async {
    try {
      return createMessage(type: "image", params: params);
    } catch (error) {
      throw const FormatException('fileName and fileContent cannot be empty.');
    }
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage(
      Map<String, dynamic> params) async {
    return createMessage(type: "video", params: params);
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    return createMessage(type: "face", params: {
      "index": index,
      "data": data,
    });
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage(
      Map<String, dynamic> params) async {
    return createMessage(type: "file", params: params);
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    return createMessage(type: "textAt", params: {
      "text": text,
      "atUserList": atUserList,
    });
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    return createMessage(
        type: "location",
        params: {"desc": desc, "longitude": longitude, "latitude": latitude});
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      List<String>? webMessageInstanceList}) async {
    return createMessage(type: "mergeMessage", params: {
      "msgIDList": msgIDList,
      "title": title,
      "abstractList": abstractList,
      "compatibleText": compatibleText,
      "webMessageInstanceList": webMessageInstanceList
    });
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage(
      {required String msgID}) async {
    return createMessage(type: "forwardMessage", params: {"msgID": msgID});
  }

  Future<T> sendTextMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'text', params: params);
  }

  Future<T> sendCustomMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'custom', params: params);
  }

  static List<Object> generateDartListObject(List<dynamic> params) =>
      List.from(params);

  Future<T> sendImageMessage<T, F>(Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);
    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});
    return await sendMessage<T, F>(type: 'image', params: params);
  }

  Future<T> sendVideoMessage<T, F>(Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);
    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});
    return await sendMessage<T, F>(type: 'video', params: params);
  }

  Future<T> sendFileMessage<T, F>(Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);
    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});
    return await sendMessage<T, F>(type: 'file', params: params);
  }

  // web不支持
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessage>(
        "getTotalUnreadMessageCount feature does not exist on the web");
  }

  Future<T> sendTextAtMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'textAt', params: params);
  }

  Future<T> sendFaceMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'face', params: params);
  }

  Future<T> sendLocationMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'location', params: params);
  }

  Future<T> sendMergerMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'mergeMessage', params: params);
  }

  Future<T> sendForwardMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'forwardMessage', params: params);
  }

  Future<dynamic> reSendMessage(Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.reSendMessage(parse(params['webMessageInstance'])));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)['message'];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<V2TimMessage>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>('重发失败!');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimMessage>(error);
    }
  }

  Future<V2TimCallback> setLocalCustomData() async {
    return CommonUtils.returnError(
        "setLocalCustomData feature does not exist on the web");
  }

  Future<V2TimCallback> setLocalCustomInt() async {
    return CommonUtils.returnError(
        "setLocalCustomInt feature does not exist on the web");
  }

  Future<V2TimCallback> setCloudCustomData() async {
    return CommonUtils.returnError(
        "setCloudCustomData feature does not exist on the web");
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getMessageList(
      dynamic getMsgListParams) async {
    // try {
    final res =
        await wrappedPromiseToFuture(timeweb!.getMessageList(getMsgListParams));
    final code = res.code;
    if (code == 0) {
      final List messageList = jsToMap(res.data)['messageList'];
      final historyMessageListPromises = messageList.reversed
          .skipWhile((value) => jsToMap(value)["isDeleted"])
          .map((element) async {
        final message = jsToMap(element);
        if (message['type'] == MsgType.MSG_MERGER) {
          mergerMsgList.add(element);
        }

        final responses =
            await V2TIMMessage.convertMessageFromWebToDart(element);
        return responses;
      }).toList();
      final historyMessageList = await Future.wait(historyMessageListPromises);
      return CommonUtils.returnSuccess<List<V2TimMessage>>(historyMessageList);
    } else {
      return CommonUtils.returnErrorForValueCb("获取历史消息失败");
    }
    // } catch (error) {
    //   return CommonUtils.returnError(error);
    // }
  }

  Future<V2TimValueCallback<V2TimMessageListResult>> getMessageListV2(
      dynamic getMsgListParams) async {
    // try {
    final res =
        await wrappedPromiseToFuture(timeweb!.getMessageList(getMsgListParams));
    final code = res.code;
    if (code == 0) {
      final resMap = jsToMap(res.data);
      final List messageList = List.from(resMap['messageList']);
      final bool isCompleted = resMap["isCompleted"];
      final historyMessageListPromises = messageList.reversed
          .skipWhile((value) => jsToMap(value)["isDeleted"])
          .map((element) async {
        final message = jsToMap(element);
        if (message['type'] == MsgType.MSG_MERGER) {
          mergerMsgList.add(element);
        }

        final responses =
            await V2TIMMessage.convertMessageFromWebToDart(element);
        return responses;
      }).toList();
      final historyMessageList = await Future.wait(historyMessageListPromises);
      final res2dart = Map<String, dynamic>.from({});
      res2dart["isFinished"] = isCompleted;
      res2dart["messageList"] = historyMessageList;
      return CommonUtils.returnSuccess<V2TimMessageListResult>(
        res2dart,
      );
    } else {
      return CommonUtils.returnErrorForValueCb("获取历史消息失败");
    }
    // } catch (error) {
    //   return CommonUtils.returnError(error);
    // }
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList(
      params) async {
    final getMessageListParams = GetMessageList.formateParams(params);
    return await getMessageList(getMessageListParams);
  }

  Future<V2TimValueCallback<V2TimMessageListResult>> getC2CHistoryMessageListV2(
      params) async {
    final getMessageListParams = GetMessageList.formateParams(params);
    return await getMessageListV2(getMessageListParams);
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList(
      params) async {
    final getMessageListParams = GetMessageList.formateParams(params);
    return await getMessageList(getMessageListParams);
  }

  Future<dynamic> getHistoryMessageListWithoutFormat() async {
    return {
      "code": 0,
      "desc":
          "getHistoryMessageListWithoutFormat feature does not exist on the web"
    };
    // return CommonUtils.returnErrorForValueCb<LinkedHashMap<dynamic, dynamic>>(
    //     "getHistoryMessageListWithoutFormat feature does not exist on the web");
  }

  Future<dynamic> revokeMessage(params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.revokeMessage(parse(params['webMessageInstatnce'])));
      final code = res.code;
      if (code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError("撤回消息失败");
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> markMsgReaded(markMsgReadedParams) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.setMessageRead(markMsgReadedParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError('设置已读失败');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<V2TimCallback> markC2CMessageAsRead(params) async {
    final markMsgReadedParams =
        mapToJSObj({"conversationID": 'C2C' + params['userID']});
    return await markMsgReaded(markMsgReadedParams);
  }

  Future<dynamic> markGroupMessageAsRead(params) async {
    final markMsgReadedParams =
        mapToJSObj({"conversationID": 'GROUP' + params['groupID']});
    return await markMsgReaded(markMsgReadedParams);
  }

  Future<V2TimCallback> deleteMessageFromLocalStorage() async {
    return CommonUtils.returnError(
        "deleteMessageFromLocalStorage feature does not exist on the web");
  }

  Future<dynamic> insertGroupMessageToLocalStorage() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessage>(
        "insertGroupMessageToLocalStorage feature does not exist on the web");
  }

  Future<dynamic> insertC2CMessageToLocalStorage() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessage>(
        "insertGroupMessageToLocalStorage feature does not exist on the web");
  }

  Future<V2TimCallback> clearC2CHistoryMessage() async {
    return CommonUtils.returnError(
        "clearC2CHistoryMessage feature does not exist on the web");
  }

  Future<V2TimCallback> clearGroupHistoryMessage() async {
    return CommonUtils.returnError(
        "clearGroupHistoryMessage feature does not exist on the web");
  }

  Future<dynamic> getC2CReceiveMessageOpt() async {
    return CommonUtils.returnErrorForValueCb<List<V2TimReceiveMessageOptInfo>>(
        "getC2CReceiveMessageOpt feature does not exist on the web");
  }

  Future<dynamic> searchLocalMessages() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessageSearchResult>(
        "searchLocalMessages feature does not exist on the web");
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    try {
      final rawMessageList = messageIDList.map((e) async {
        final jsMessage = timeweb!.findMessage(e);
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(jsMessage);
        return formatedMessage;
      }).toList();
      final formatedMessageList = await Future.wait(rawMessageList);
      return CommonUtils.returnSuccess<List<V2TimMessage>>(formatedMessageList);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb(error.toString());
    }
  }

  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    try {
      final remindTypeOpt = {
        'userIDList': userIDList,
        'messageRemindType': GroupRecvMsgOpt.convertMsgRecvOptToWeb(opt)
      };
      final res = await wrappedPromiseToFuture(
          timeweb!.setMessageRemindType(mapToJSObj(remindTypeOpt)));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError('set group recv msg opt failed');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  static parseWebMessageInstanceList(List<dynamic> webMessageInstanceList) {
    return webMessageInstanceList.map((e) => parse(e)).toList();
  }

  // webMessageInstanceList 这个参数web独有其中元素是web端的message实例
  Future<V2TimCallback> deleteMessages(params) async {
    try {
      final res = await wrappedPromiseToFuture(timeweb!.deleteMessage(
          parseWebMessageInstanceList(params['webMessageInstanceList'])));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError('delete msg failed');
      }
    } catch (error) {
      log(error);
      return CommonUtils.returnError(error);
    }
  }

  Future<V2TimCallback> setGroupReceiveMessageOpt(params) async {
    try {
      final remindTypeOpt = {
        'groupID': params['groupID'],
        'messageRemindType':
            GroupRecvMsgOpt.convertMsgRecvOptToWeb(params['opt'])
      };
      final res = await wrappedPromiseToFuture(
          timeweb!.setMessageRemindType(mapToJSObj(remindTypeOpt)));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError('set group recv msg opt failed');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  static final _messageReadReceiptHandler = allowInterop((dynamic responses) {
    final List messageData = jsToMap(responses)['data'];
    final readedList = messageData.map((item) {
      final formatedItem = jsToMap(item);
      final conversationID = formatedItem['conversationID'] as String;
      final conversationType = formatedItem['conversationType'] as String;
      return V2TimMessageReceipt(
          userID: conversationID.replaceAll(conversationType, ""),
          timestamp: formatedItem['time']);
    }).toList();
    for (var listener in messageListener.values) {
      listener.onRecvC2CReadReceipt(readedList);
    }
  });

  static final _messageReadReceiptReceivedHandler =
      allowInterop((dynamic responses) {
    final List messageData = jsToMap(responses)['data'];
    final readedList = messageData.map((item) {
      final formatedItem = jsToMap(item);
      return V2TimMessageReceipt(
          userID: formatedItem['userID'] ?? "",
          timestamp: formatedItem['time'] ?? 0,
          msgID: formatedItem['messageID'],
          unreadCount: formatedItem['unreadCount'],
          readCount: formatedItem['readCount'],
          groupID: formatedItem['groupID']);
    }).toList();
    for (var listener in messageListener.values) {
      listener.onRecvMessageReadReceipts(readedList);
    }
  });

  static final _messageRevokedHandler = allowInterop((dynamic responses) {
    final List messageData = jsToMap(responses)['data'];
    for (var element in messageData) {
      final msgID = jsToMap(element)['ID'];
      for (var listener in messageListener.values) {
        listener.onRecvMessageRevoked(msgID);
      }
    }
  });

  static final _reciveNewMesageHandler = allowInterop((dynamic responses) {
    final List messageList = jsToMap(responses)['data'];
    for (var messageItem in messageList) {
      loop() async {
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(messageItem);
        V2TimMessage msg = V2TimMessage.fromJson(formatedMessage);
        for (var listener in messageListener.values) {
          listener.onRecvNewMessage(msg);
        }
        // handle signal message
        _handleMessage(msg);
      }

      loop();
    }
  });
  // static bool _isGroupCall(Map<String, dynamic> callinfo){
  //   if(callinfo["groupID"]==null){
  //     return false;
  //   }else{
  //     if(callinfo["groupID"].isNotEmpty){
  //       return true;
  //     }
  //     return false;
  //   }
  // }
  static Future<bool> _includeSelf(List<String> inviteeList) async {
    V2TimValueCallback<String> user =
        await TencentImSDKPluginWeb().getLoginUser();
    List<String> list = List.castFrom(inviteeList);
    return list.contains(user.data ?? "");
  }

  static _handleMessage(V2TimMessage message) async {
    if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM &&
        message.customElem != null) {
      // this message is custom message
      try {
        if (message.customElem!.data != null) {
          if (message.customElem!.data!.isNotEmpty) {
            Map<String, dynamic> customMessageData =
                json.decode(message.customElem!.data!) ?? Map.from({});
            String? inviteID = customMessageData["inviteID"];
            int? actionType = customMessageData["actionType"];
            print("current signal data: $customMessageData");

            if (inviteID != null && actionType != null) {
              List<String> inviteeList = [];
              if (customMessageData["inviteeList"] != null &&
                  customMessageData["inviteeList"].isNotEmpty) {
                inviteeList =
                    List<String>.from(customMessageData["inviteeList"]);
              }
              bool includeSelf = await _includeSelf(inviteeList);
              if (!includeSelf) {
                return;
              }
              // print signal data
              try {
                await _v2timSignalingManager.beforeCallback(
                    actionType, customMessageData);
              } catch (err) {
                print("handle before life error");
              }

              switch (actionType) {
                case V2SignalingActionType.SIGNALING_ACTION_TYPE_ACCEPT_INVITE:
                  String invitee = customMessageData["invitee"] ?? "";
                  String data = customMessageData["data"] ?? "";

                  _onInviteeAccepted(inviteID, invitee, data);
                  break;
                case V2SignalingActionType.SIGNALING_ACTION_TYPE_CANCEL_INVITE:
                  String invitee = customMessageData["invitee"] ?? "";
                  String data = customMessageData["data"] ?? "";
                  _onInvitationCancelled(inviteID, invitee, data);
                  break;
                case V2SignalingActionType.SIGNALING_ACTION_TYPE_INVITE:
                  String inviter = message.sender!;
                  List<String> inviteeList =
                      List<String>.from(customMessageData["inviteeList"]);
                  String data = customMessageData["data"] ?? "";
                  String groupID = message.groupID ?? "";
                  _onReceiveNewInvitation(
                      inviteID, inviter, groupID, inviteeList, data);
                  break;
                case V2SignalingActionType.SIGNALING_ACTION_TYPE_INVITE_TIMEOUT:
                  List<String> inviteeList =
                      List<String>.from(customMessageData["inviteeList"]);
                  _onInvitationTimeout(inviteID, inviteeList);
                  break;
                case V2SignalingActionType.SIGNALING_ACTION_TYPE_REJECT_INVITE:
                  String invitee = customMessageData["invitee"] ?? "";
                  String data = customMessageData["data"] ?? "";
                  _onInviteeRejected(inviteID, invitee, data);
                  break;
              }
            }
          }
        }
      } catch (err) {
        // err
        print(err);
      }
    }
  }

  static final _messageModifiedHandler = allowInterop((dynamic responses) {
    final List messageList = jsToMap(responses)['data'];
    for (var messageItem in messageList) {
      loop() async {
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(messageItem);
        for (var listener in messageListener.values) {
          listener
              .onRecvMessageModified(V2TimMessage.fromJson(formatedMessage));
        }
      }

      loop();
    }
  });
  static _onReceiveNewInvitation(String inviteID, String inviter,
      String groupID, List<String> inviteeList, String data) {
    _v2timSignalingManager.signalingListenerList.forEach((key, value) {
      value.onReceiveNewInvitation(
          inviteID, inviter, groupID, inviteeList, data);
    });
  }

  static _onInviteeAccepted(String inviteID, String invitee, String data) {
    _v2timSignalingManager.signalingListenerList.forEach((key, value) {
      value.onInviteeAccepted(inviteID, invitee, data);
    });
  }

  static _onInviteeRejected(String inviteID, String invitee, String data) {
    _v2timSignalingManager.signalingListenerList.forEach((key, value) {
      value.onInviteeRejected(inviteID, invitee, data);
    });
  }

  static _onInvitationCancelled(String inviteID, String inviter, String data) {
    _v2timSignalingManager.signalingListenerList.forEach((key, value) {
      value.onInvitationCancelled(inviteID, inviter, data);
    });
  }

  static _onInvitationTimeout(String inviteID, List<String> inviteeList) {
    _v2timSignalingManager.signalingListenerList.forEach((key, value) {
      value.onInvitationTimeout(inviteID, inviteeList);
    });
  }

  void addAdvancedMsgListener(
      V2TimAdvancedMsgListener listener, String? listenerUuid) {
    if (messageListener.isNotEmpty) {
      messageListener[listenerUuid!] = (listener);
      return;
    }
    messageListener[listenerUuid!] = (listener);
    submitMessageReadReceipt();
    submitMessageRevoked();
    submitRecvNewMessage();
    submitMessageModified();
  }

  void removeAdvancedMsgListener(String? listenerUuid) {
    if (listenerUuid != null && listenerUuid.isNotEmpty) {
      messageListener.remove(listenerUuid);
      if (messageListener.isNotEmpty) {
        return;
      }
    }
    messageListener.clear();
    timeweb!.off(EventType.MESSAGE_READ_BY_PEER, _messageReadReceiptHandler);
    timeweb!.off(EventType.MESSAGE_REVOKED, _messageRevokedHandler);
    timeweb!.off(EventType.MESSAGE_RECEIVED, _reciveNewMesageHandler);
    timeweb!.off(EventType.MESSAGE_READ_RECEIPT_RECEIVED,
        _messageReadReceiptReceivedHandler);
    timeweb!.off(EventType.MESSAGE_MODIFIED, _messageModifiedHandler);
  }

  static void submitMessageReadReceipt() {
    timeweb!.on(EventType.MESSAGE_READ_BY_PEER, _messageReadReceiptHandler);
    timeweb!.on(EventType.MESSAGE_READ_RECEIPT_RECEIVED,
        _messageReadReceiptReceivedHandler);
  }

  static void submitMessageModified() {
    timeweb!.on(EventType.MESSAGE_MODIFIED, _messageModifiedHandler);
  }

  static void submitMessageRevoked() {
    timeweb!.on(EventType.MESSAGE_REVOKED, _messageRevokedHandler);
  }

  static void submitRecvNewMessage() {
    timeweb!.on(EventType.MESSAGE_RECEIVED, _reciveNewMesageHandler);
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.modifyMessage(parse(message.messageFromWeb!)));
      final code = res.code;
      if (code == 0) {
        final responses = await V2TIMMessage.convertMessageFromWebToDart(
            jsToMap(res.data)["message"]);
        return CommonUtils.returnSuccess<V2TimMessageChangeInfo>(
            {"message": responses, "code": res.code});
      } else {
        return CommonUtils.returnSuccess<V2TimMessageChangeInfo>(
            {"code": res.code, "desc": res.data});
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb(error.toString());
    }
  }

  _getDownLoadMergerList(messagePayLoad) async {
    final originalMsgList = messagePayLoad['messageList'] as List;
    final listResult = await Future.wait(originalMsgList.map((e) async {
      final item = jsToMap(e);
      final messageBody = jsToMap((item['messageBody'] as List).first);
      item['type'] = messageBody['type'];
      item['payload'] = messageBody['payload'];
      return await V2TIMMessage.convertMessageFromWebToDart(item,
          isFromDownloadMergerMessage: true);
    }).toList());
    return listResult;
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> downloadMergerMessage({
    required String msgID,
  }) async {
    try {
      dynamic mergerMsg = mergerMsgList.firstWhere(
          (element) => jsToMap(element)['ID'] == msgID,
          orElse: () => null);
      if (mergerMsg == null) {
        return CommonUtils.returnErrorForValueCb("未找到合并消息");
      }
      final parsedMessage = jsToMap(mergerMsg);
      final payload = jsToMap(parsedMessage['payload']);
      if ((payload['downloadKey'] as String).isEmpty) {
        final listResult = await _getDownLoadMergerList(payload);
        return CommonUtils.returnSuccess<List<V2TimMessage>>(listResult);
      }

      final res =
          await promiseToFuture(timeweb!.downloadMergerMessage(mergerMsg));
      final messagePayLoad = jsToMap(res)['payload'];
      final listResult = await _getDownLoadMergerList(jsToMap(messagePayLoad));
      return CommonUtils.returnSuccess<List<V2TimMessage>>(listResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb(error.toString());
    }
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    try {
      final originalMessageList =
          messageIDList.map((e) => timeweb!.findMessage(e)).toList();
      final res = await wrappedPromiseToFuture(
          timeweb!.getMessageReadReceiptList(originalMessageList));
      if (res.code == 0) {
        final resData = res.data;
        final messageList = jsToMap(resData)['messageList'] as List;
        final formatedList = messageList.map((item) {
          final itemMap = jsToMap(item);
          final readReceiptInfo = jsToMap(itemMap['readReceiptInfo']);
          final isGroup = itemMap['conversationType'] == "GROUP";
          return {
            "userID": isGroup ? '' : itemMap['to'],
            "timestamp": itemMap['time'],
            "msgID": itemMap['ID'],
            "readCount": readReceiptInfo['readCount'],
            "unreadCount": readReceiptInfo['unreadCount'],
            "groupID": isGroup ? itemMap['to'] : '',
          };
        }).toList();
        return CommonUtils.returnSuccess<List<V2TimMessageReceipt>>(
            formatedList);
      }
      return CommonUtils.returnSuccess<List<V2TimMessageReceipt>>([]);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb(error.toString());
    }
  }

  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    try {
      final originalMessageList =
          messageIDList.map((e) => timeweb!.findMessage(e)).toList();
      final res = await wrappedPromiseToFuture(
          timeweb!.sendMessageReadReceipt(originalMessageList));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(res.data);
      }
      return CommonUtils.returnSuccessForCb([]);
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) async {
    try {
      final originalMessage = timeweb!.findMessage(messageID);
      final messageMap = jsToMap(originalMessage);
      final conversationID = messageMap['conversationID'] as String;
      final conversationType = messageMap['conversationType'] as String;
      final groupID = conversationID.replaceAll(conversationType, "");
      final filterParam = filter.index;
      final params = mapToJSObj({
        "message": originalMessage,
        "filter": filterParam,
        "count": count,
        "cursor": nextSeq == 0 ? '' : nextSeq.toString(),
      });
      final res = await wrappedPromiseToFuture(
          timeweb!.getGroupMessageReadMemberList(params));
      if (res.code == 0) {
        final responseData = jsToMap(res.data);
        final userIDList = responseData[
            filterParam == 0 ? 'readUserIDList' : 'unreadUserIDList'] as List;
        var memberInfoList = [];
        if (userIDList.isNotEmpty) {
          final response = await wrappedPromiseToFuture(
              timeweb!.getGroupMemberProfile(mapToJSObj({
            "groupID": groupID,
            "userIDList": userIDList,
          })));
          final memberList = jsToMap(response.data)['memberList'] as List;
          memberInfoList = GetGroupMemberList.formateGroupResult(memberList);
        }

        final responseValue = {
          "nextSeq": int.parse(responseData['cursor']),
          "isFinished": responseData['isCompleted'],
          "memberInfoList": memberInfoList,
        };
        return CommonUtils.returnSuccess<V2TimGroupMessageReadMemberList>(
            responseValue);
      }
      return CommonUtils.returnSuccess<V2TimGroupMessageReadMemberList>([]);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimGroupMessageReadMemberList>(
          error.toString());
    }
  }
}
