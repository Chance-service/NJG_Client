package com.chance.allsdk;

import com.nuclear.bean.PayInfo;
import com.nuclear.gjwow.GameActivity;

import org.json.JSONException;

public interface ISDKService {
    /**
     * sdk登入
     */
    public void sdkLogin();

    /**
     * sdk登出
     */
    public void sdkLogout();
    /**
     * 恢復運行
     */
    public void onResume();

    /**
     * sdk初始
     */
    public void init(GameActivity activity);

    /**
     * sdk建立
     */
    public void onCreateSDK();
    /**
     * TAPdb初始
     */
    public void initTabDB();

    /**
     * 付款購買
     * @param pay_info
     * @throws JSONException
     */
    public void toPay(PayInfo pay_info) throws JSONException;
    /**
     * 顯示平台帳號資訊(kuso)
     */
    public void onShowProfile();
    /**
     * 回傳平台報告(註冊)
     */
    public void Report_Handler(int eventId);

}
