import 'package:example/im/topicSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

import '../i18n/i18n_utils.dart';
import 'communitySelector.dart';

class SetTopicInfo extends StatefulWidget {
  const SetTopicInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetTopicInfoState();
}

class _SetTopicInfoState extends State<SetTopicInfo> {
  String groupID = "";
  String topicID = "";
  String topicName = "";
  String topicFaceUrl = "";
  Map<String, dynamic>? resData;

  setTopicInfo() async {
    // final res = await TencentImSDKPlugin.v2TIMManager
    //     .getGroupManager()
    //     .setTopicInfo(
    //         groupID: groupID,
    //         topicInfo: V2TimTopicInfo(
    //             topicID: topicID,
    //             topicFaceUrl: topicFaceUrl,
    //             topicName: topicName.isNotEmpty ? topicName : null));
    final res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupInfo(
            info: V2TimGroupInfo(
                groupID: groupID,
                notification: "",
                introduction: "",
                groupType: "Community",
                groupAddOpt: GroupAddOptType.V2TIM_GROUP_ADD_ANY,
                faceUrl:
                    "https://qcloudimg.tencent-cloud.cn/raw/0e6016322916215535ebde7440ddf67f.svg"));
    resData = res.toJson();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CommunityGroupSelector(
              onSelect: (data) {
                setState(() {
                  groupID = data.first;
                });
              },
              switchSelectType: true,
              value: groupID.isNotEmpty ? [groupID] : [],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(groupID.isNotEmpty ? groupID : imt("未选择")),
              ),
            )
          ],
        ),
        Row(
          children: [
            TopicSelector(
              onSelect: (data) {
                setState(() {
                  topicID = data.first;
                });
              },
              groupID: groupID,
              switchSelectType: true,
              value: topicID.isNotEmpty ? [topicID] : [],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(topicID.isNotEmpty ? topicID : imt("未选择")),
              ),
            )
          ],
        ),
        TextField(
          decoration: InputDecoration(
            labelText: imt("话题名称"),
            hintText: imt("话题名称"),
            prefixIcon: const Icon(Icons.person),
          ),
          onChanged: (res) {
            setState(() {
              topicName = res;
            });
          },
        ),
        TextField(
          decoration: InputDecoration(
            labelText: imt("话题头像"),
            hintText: imt("话题头像"),
            prefixIcon: const Icon(Icons.person),
          ),
          onChanged: (res) {
            setState(() {
              topicFaceUrl = res;
            });
          },
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: setTopicInfo,
                child: Text(imt("设置话题信息")),
              ),
            )
          ],
        ),
        SDKResponse(resData),
      ],
    );
  }
}
