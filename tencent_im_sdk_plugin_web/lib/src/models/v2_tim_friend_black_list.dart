class FriendBlackList {
  static formateBlackListItem(userID) {
    return {
      "userID": userID,
      "friendRemark": null,
      "friendGroups": [],
      "friendCustomInfo": {},
      "userProfile": {
        "userID": userID,
      },
    };
  }

  static List<dynamic> formateBlackList(list) {
    final resultArr = [];
    list.forEach((item) => resultArr.add(formateBlackListItem(item)));
    return resultArr;
  }

  static List<dynamic> formateDeleteBlackListRes(List list) {
    return list.map((e) => {"userID": e, "resultCode": 0}).toList();
  }
}
