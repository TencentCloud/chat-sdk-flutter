import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_file_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_image_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_sound_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_video_elem.dart';

/// V2TimMessageOnlineUrl
///
/// {@category Models}
///
class V2TimMessageOnlineUrl {
  V2TimImageElem? imageElem;
  V2TimSoundElem? soundElem;
  V2TimVideoElem? videoElem;
  V2TimFileElem? fileElem;

  V2TimMessageOnlineUrl({
    this.imageElem,
    this.soundElem,
    this.videoElem,
    this.fileElem,
  });

  V2TimMessageOnlineUrl.fromJson(Map<String, dynamic> json) {
    imageElem = json['imageElem'] != null
        ? V2TimImageElem.fromJson(json['imageElem'])
        : null;
    soundElem = json['soundElem'] != null
        ? V2TimSoundElem.fromJson(json['soundElem'])
        : null;
    videoElem = json['videoElem'] != null
        ? V2TimVideoElem.fromJson(json['videoElem'])
        : null;
    fileElem = json['fileElem'] != null
        ? V2TimFileElem.fromJson(json['fileElem'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imageElem'] = imageElem?.toJson();
    data['soundElem'] = soundElem?.toJson();
    data['videoElem'] = videoElem?.toJson();
    data['fileElem'] = fileElem?.toJson();
    return data;
  }
}

// {
//   "userID":"",
//   "timestamp":0
// }
