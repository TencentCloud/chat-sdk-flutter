/// V2TimMessageDownloadProgress
///
/// {@category Models}
///
class V2TimMessageDownloadProgress {
  late bool isFinish;
  late bool isError;
  late String msgID;
  late int currentSize;
  late int totalSize;
  late int type;
  late bool isSnapshot;
  late String path;
  late int errorCode;
  late String errorDesc;

  V2TimMessageDownloadProgress({
    required this.isFinish,
    required this.isError,
    required this.msgID,
    required this.totalSize,
    required this.currentSize,
    required this.type,
    required this.isSnapshot,
    required this.path,
    required this.errorCode,
    required this.errorDesc,
  });

  V2TimMessageDownloadProgress.fromJson(Map<String, dynamic> json) {
    isFinish = json["isFinish"];
    isError = json["isError"];
    msgID = json["msgID"];
    currentSize = json["currentSize"];
    totalSize = json["totalSize"];
    type = json["type"];
    isSnapshot = json["isSnapshot"];
    path = json["path"];
    errorCode = json["errorCode"];
    errorDesc = json["errorDesc"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["isFinish"] = isFinish;
    data["isError"] = isError;
    data["msgID"] = msgID;
    data["currentSize"] = currentSize;
    data["totalSize"] = totalSize;
    data["type"] = type;
    data["isSnapshot"] = isSnapshot;
    data["path"] = path;
    data["errorCode"] = errorCode;
    data["errorDesc"] = errorDesc;
    return data;
  }
}
