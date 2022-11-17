class CGroupModifyFlag {
  static const kTIMGroupModifyInfoFlag_None = 0x00;
  static const kTIMGroupModifyInfoFlag_Name = 0x01; // 修改群组名称
  static const kTIMGroupModifyInfoFlag_Notification = 0x01 << 1; // 修改群公告
  static const kTIMGroupModifyInfoFlag_Introduction = 0x01 << 2; // 修改群简介
  static const kTIMGroupModifyInfoFlag_FaceUrl = 0x01 << 3; // 修改群头像URL
  static const kTIMGroupModifyInfoFlag_AddOption = 0x01 << 4; // 修改群组添加选项
  static const kTIMGroupModifyInfoFlag_MaxMmeberNum = 0x01 << 5; // 修改群最大成员数
  static const kTIMGroupModifyInfoFlag_Visible = 0x01 << 6; // 修改群是否可见
  static const kTIMGroupModifyInfoFlag_Searchable = 0x01 << 7; // 修改群是否允许被搜索
  static const kTIMGroupModifyInfoFlag_ShutupAll = 0x01 << 8; // 修改群是否全体禁言
  static const kTIMGroupModifyInfoFlag_Custom = 0x01 << 9; // 修改群自定义信息
  static const kTIMGroupTopicModifyInfoFlag_CustomString =
      0x01 << 11; // 话题自定义字段
  static const kTIMGroupModifyInfoFlag_Owner = 0x01 << 31; // 修改群主
}
