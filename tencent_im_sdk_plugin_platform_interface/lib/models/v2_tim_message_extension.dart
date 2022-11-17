/// V2TimMessageExtension
///
/// {@category Models}
///
class V2TimMessageExtension {
  String extensionKey = "";
  String extensionValue = "";

  V2TimMessageExtension({
    required this.extensionKey,
    required this.extensionValue,
  });

  V2TimMessageExtension.fromJson(Map<String, dynamic> json) {
    extensionKey = json["extensionKey"] ?? "";
    extensionValue = json["extensionValue"] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["extensionKey"] = extensionKey;
    data["extensionValue"] = extensionValue;
    return data;
  }
}
