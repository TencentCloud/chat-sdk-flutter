//
//  SDKListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import ImSDK_Plus

public class SDKLogListener: NSObject {
    let listenerUuid:String;
    init(listenerUid:String) {
        listenerUuid = listenerUid;
    }
	
	
    public func onLog(_ level:V2TIMLogLevel, logContent:String) {
        var data:[String:Any] = [:];

        data["level"] = level.rawValue;
        data["content"] = logContent;

        TencentImSDKPlugin.invokeListener(type: ListenerType.onLog, method: "initSDKListener", data: data, listenerUuid: listenerUuid)
    }
	
}
