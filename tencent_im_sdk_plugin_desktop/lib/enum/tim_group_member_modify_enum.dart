class CGroupMemberModifyFlag {
  // setGroupMemeberInfo
  static const kTIMGroupMemberModifyFlag_None = 0x00; //
  static const kTIMGroupMemberModifyFlag_MsgFlag = 0x01; // 修改消息接收选项
  static const kTIMGroupMemberModifyFlag_MemberRole = 0x01 << 1; // 修改成员角色
  static const kTIMGroupMemberModifyFlag_ShutupTime = 0x01 << 2; // 修改禁言时间
  static const kTIMGroupMemberModifyFlag_NameCard = 0x01 << 3; // 修改群名片
  static const kTIMGroupMemberModifyFlag_Custom = 0x01 << 4; // 修改群成员自定义信息
}
