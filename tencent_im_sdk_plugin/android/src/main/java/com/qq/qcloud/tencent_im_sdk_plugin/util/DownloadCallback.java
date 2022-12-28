package com.qq.qcloud.tencent_im_sdk_plugin.util;

public abstract class DownloadCallback {
    public DownloadCallback(){};
    public void onProgress(boolean isFinish,boolean isError,long currentSize,long totalSize,String msgID,int type,boolean isSnapshot,String path,int error_code,String error_desc){};
}