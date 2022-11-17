import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class SetGroupMemberInfo {
  static Map<String, Object> formateParams(Map<String, dynamic> params) {
    final Map customInfo = params['customInfo'] ?? {};
    final formatedCustomInfo = customInfo.keys
        .map((e) => mapToJSObj({"key": e, "value": customInfo[e]}));
    return {
      "nameCardParams": mapToJSObj({
        "groupID": params['groupID'],
        "userID": params['userID'],
        "nameCard": params['nameCard'],
      }),
      "customInfoParams": mapToJSObj({
        "groupID": params['groupID'],
        "userID": params['userID'],
        "memberCustomField": formatedCustomInfo.toList()
      })
    };
  }
}
