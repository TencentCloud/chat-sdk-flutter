/// 群信息变化类型
///
/// {@category Enums}
///
// ignore_for_file: constant_identifier_names

class GroupChangeInfoType {
  ///非法值
  ///
  static const int V2TIM_GROUP_INFO_INVALID = 0;

  ///群名修改
  ///
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_NAME = 1;

  ///群简介修改
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION = 2;

  ///群公告修改
  ///
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION = 3;

  ///群头像修改
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL = 4;

  ///群主变更
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER = 5;

  ///群自定义字段变更
  ///
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM = 6;

  ///全员禁言字段变更
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL = 8;

  ///消息接收选项变更
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_RECEIVE_MESSAGE_OPT = 10;

  ///加群选项变更
  static const int V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT = 11;
}
