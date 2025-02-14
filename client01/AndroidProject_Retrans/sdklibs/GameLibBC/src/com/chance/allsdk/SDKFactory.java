package com.chance.allsdk;

import API.PlatformAPI;

public class SDKFactory {
    /**
     * 工廠單例
     */
    private static final SDKFactory instance = new SDKFactory();

    public static SDKFactory getInstance() {
        return instance;
    }

    /**
     * 獲取服務實力對象
     *
     * @return
     */
    public SDKService getSDKHandler() {
        // 交給gradle去切換版本
        return PlatformAPI.getInstance();
    }
}
