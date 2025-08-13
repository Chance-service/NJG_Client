package API;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.util.Log;

import com.chance.allsdk.SDKService;
import com.nuclear.bean.PayInfo;
import com.nuclear.gjwow.GameActivity;
//import com.xindong.tyrantdb.TyrantdbGameTracker;

//import com.gmpsykr.lsjonlinesdk.api.LSJBuyActivity;
//import com.gmpsykr.lsjonlinesdk.api.LSJLoginActivity;
//import com.gmpsykr.lsjonlinesdk.api.LSJOrder;
//import com.gmpsykr.lsjonlinesdk.api.LSJUser;
//import com.gmpsykr.lsjonlinesdk.api.LSJUserInfoActivity;
//import com.gmpsykr.lsjonlinesdk.callback.LSJBuyCallback;
//import com.gmpsykr.lsjonlinesdk.callback.LSJLoginCallback;
//import com.gmpsykr.lsjonlinesdk.callback.LSJUserInfoCallback;
//import com.gmpsykr.lsjonlinesdk.floating.LSJFloatingBtn;
//import com.gmpsykr.lsjonlinesdk.manager.LSJObjects;
//import com.gmpsykr.lsjonlinesdk.manager.MD5Encrypt;

import org.json.JSONException;

public class PlatformAPI extends SDKService {

	/**
	 * SDK單例
	 */
	private static PlatformAPI instance = null;

	public static PlatformAPI getInstance() {
		if (instance == null){
			instance = new PlatformAPI();
		}
		return instance;
	}

	// LSJ SDK 接口.
//	private LSJLoginCallback lsjLoginCallBack; // LSJ 登入接口.
//	private LSJBuyCallback lsjBuyCallback; // LSJ 購買商品接口.
//	private LSJUserInfoCallback lsjUserInfoCallback; // 玩家資訊接口.

	// LSJ SDK 浮標 (浮標請於登入後再顯示).
	//private LSJFloatingBtn lsjFloatingBtn = null; // LSJ 浮標物件.
	private boolean showLSJFloatingBtn = false; // [示範用] 控制是否顯示浮標.

	// [示範用] 儲存 LSJ token (計算 LSJ 訂單 sign 值用)
	private String tmpSaveLSJToken = "";

	private static int logincount = 0;

	@Override
	public void onCreateSDK(){
			// 設定 LSJ SDK 遊戲資訊.
			//LSJObjects.getLSJGame().setLSJGame("MNX", "V0001"); // 遊戲來源, 渠道來源.jsGameSDKManager = JsGameSDKManager.getInstance(home_activity);
			aTag = "TEST_LSJ";
			showlog("onCreate LSJ");
			isCreate = true ;

	}

	@Override
	public void initAdjustSDK(Context context){
		super.initAdjustSDK(context);
	}

    @Override
    public  void initTabDB()
    {
    	if (isSetTabDB)
    	{
    		showlog("LSJ Api repeat set");
    		return;
    	}

	    if (APP_DBG)
	    {
	    	tabDBId = "hskrojuyh6ysndd1"; // chance use
	    	channel = "quanta";
	    } else
	    {
			tabDBId = "kad6kdj4p1vjwuzg";
	    	channel = "R18";
	    }
		super.initTabDB();
    }

    public void toPay(PayInfo pay_info) throws JSONException{
		// [示範用] 購買商品.
		String gCode = "ABCDE"; // 遊戲唯一識別碼，需找LSJ平台取得.
		String productId = "id456"; // Developer區別道具的標示符，長度不得超過50個字符.
		int unitPrice = 50; // 道具單價(點數).
		int quantity = 1; // 道具購買個數.
		String orderNo = String.valueOf((Math.random()* 9000000 + 1000000)); // Developer訂單號，不能重複，長度不得超過50個字符.
		String productName = "不滅的法老王帽3"; // 商品名稱，會顯示在訂單上 (可為空字串)，長度不得超過50個字符.
		String productDesc = "增強防禦力3"; // 商品描述 (可為空字串)，長度不得超過100個字符.
		String cpExtend = "88888"; // 額外資訊 (可為空字串)，長度不得超過300個字符.

		String sdkKey = "kiefdke2"; // 禁止出現於軟體中，Developer Server計算sign值用，需找LSJ平台取得.
		//String sign = MD5Encrypt.multiMD5((gCode + tmpSaveLSJToken + productId +
		//		unitPrice + quantity + orderNo + productName + productDesc + cpExtend + sdkKey), 1);
		// tmpSaveLSJToken 為 LSJ token，登入成功後由「玩家資訊接口」取得.

		// 設定 LSJ SDK 訂單.
//		LSJOrder lsjOrder = new LSJOrder(gCode, productId, unitPrice, quantity, orderNo, productName, productDesc, cpExtend, sign);
//
//		lsjBuyCallback = new LSJBuyCallback() {
//			@Override
//			public void BuySuccess(LSJOrder _lsjOrder) {
//				// 玩家購買商品成功.
//				String productId = _lsjOrder.getProduceIdData();
//				int unitPrice = _lsjOrder.getUnitPriceData();
//				int quantity = _lsjOrder.getQuantityData();
//				String orderNo = _lsjOrder.getOrderNoData();
//				String productName = _lsjOrder.getProductNameData();
//				String productDesc = _lsjOrder.getProductDescData();
//				String cpExtend = _lsjOrder.getCpExtendData();
//
//				//Toast.makeText(MainActivity.this, "玩家購買商品成功：" + productId, Toast.LENGTH_SHORT).show();
//			}

//			@Override
//			public void BuyFail(String _errorCode, String _errorMsg) {
//				// 玩家購買商品失敗.
//				if (_errorCode.compareTo("991") == 0) {
//					//Toast.makeText(MainActivity.this, "儲值流程結束，請繼續購買流程", Toast.LENGTH_SHORT).show();
//				} else if (_errorCode.compareTo("992") == 0) {
//					//Toast.makeText(MainActivity.this, "玩家取消購買", Toast.LENGTH_SHORT).show();
//				} else if (_errorCode.compareTo("996") == 0) {
//					//Toast.makeText(MainActivity.this, "登入失敗，請重新登入", Toast.LENGTH_SHORT).show();
//					onDetachedFromWindow(); // 建議關閉浮標.
//				} else {
//					// 其他錯誤，建議重新登入.
//					//Toast.makeText(MainActivity.this, "錯誤代碼: " + _errorCode + "\n錯誤訊息: " + _errorMsg, Toast.LENGTH_SHORT).show();
//				}
//			}
//		};

//		LSJBuyActivity.setLSJButItem(home_activity, lsjOrder, lsjBuyCallback);
/*			double usd = Math.round(pay_info.price / 100);
			String imageurl = "https://s3-ap-northeast-1.amazonaws.com/file.idleparadise.com/idleparadise/icon/idleparadise.png";
			//PaymentItem aItem = new PaymentItem(pay_info.product_id, pay_info.product_name, usd, pay_info.count, imageurl, pay_info.description);
			JSONObject obj = new JSONObject();
			obj.put("puid", uuid);
			obj.put("orderSerial", pay_info.order_serial);
			obj.put("platform", "android_h365");
			obj.put("payMoney", Double.toString(pay_info.price)); // H.必
			obj.put("goodsId", pay_info.name);
			obj.put("goodsCount", pay_info.count);
			obj.put("serverId", Svrid);
			obj.put("test", "false");
			String callbackurl = "";
			showlog("callbackurl: " + callbackurl);

			callbackurl = payurl + escape(obj.toString()) + "&user='h365'";

			showlog("escape callbackurl: " + callbackurl);
			//PaymentData apayData = new PaymentData(pay_info.order_serial, callbackurl, "", aItem, "USD");
			//h365api.pay(apayData, h365token, PayCallback);
			showlog("toH365Pay");
*/
/*    	JSONObject jsonData = new JSONObject();
    	jsonData.put("ordid", pay_info.order_serial);
    	jsonData.put("callbackurl", callbackurl);
    	jsonData.put("message", "");

    	jsonData.put("ItemId", pay_info.product_id);
    	jsonData.put("ItemName", pay_info.product_name);
    	jsonData.put("unitPrice", usd);
    	jsonData.put("quantity", pay_info.count);
    	jsonData.put("imageUrl", imageurl);
    	jsonData.put("discription", pay_info.description);

    	jsonData.put("currency", "USD");
    	showlog("JsonData: "+ jsonData.toString());*/
    }

	public void onShowProfile(){

	}
	@Override
    public void sdkLogin() {
		if (isCreate) {
//			if (uuid.isEmpty()){
//				logincount++;
//			}
//			if (logincount > 1){
//				return ;
//			}
//			lsjLoginCallBack = new LSJLoginCallback() {
//				@Override
//				public void LoginSuccess(String _userId) {
//					// 登入成功.
//					uuid = _userId;
//					//Toast.makeText(MainActivity.this, "登入成功, userId: " + _userId, Toast.LENGTH_SHORT).show();
//
//					// [示範用] 顯示浮標.
//					showLSJFloatingBtn = true;
//					onAttachedToWindow();
//				}
//
//				@Override
//				public void LoginFail(String _errorCode, String _errorMsg) {
//
//					showlog("PlatformAPI LoginFail :"+"錯誤代碼: " + _errorCode+ "\n錯誤訊息: " + _errorMsg);
//					// 登入失敗.
//					//Toast.makeText(MainActivity.this, "錯誤代碼: " + _errorCode + "\n錯誤訊息: " + _errorMsg, Toast.LENGTH_SHORT).show();
//				}
//			};
//			LSJLoginActivity.showLSJLoginView(home_activity, lsjLoginCallBack);
		}
		else
		{
			showlog("sdkapi is null");
		}
	}



//    public static String convertMD5(String instr){
//    	char[] a = instr.toCharArray();
//    	for(int i = 0 ; i < a.length ; i++){
//    		a[i] = (char) (a[i] ^ 't');
//		}
//    	String s = new String(a);
//
//    	return s;
//	}
	@Override
    public void  sdkLogout() {
    	if (isCreate) {

    	}
		else
		{
			showlog("sdkapi is null");
		}
	}

	public void onAttachedToWindow() {
		//super.onAttachedToWindow();

		// [示範用] 顯示浮標.
//		if(showLSJFloatingBtn) {
//			if(lsjFloatingBtn == null)
//				lsjFloatingBtn = new LSJFloatingBtn(home_activity);
//			lsjFloatingBtn.showFloatingBtn();
//		}

		/**
		 // 顯示 LSJ SDK 浮標.
		 if(lsjFloatingBtn == null)
		 lsjFloatingBtn = new LSJFloatingBtn(this);
		 lsjFloatingBtn.showFloatingBtn(); // 顯示浮標.
		 */
	}

	public void onDetachedFromWindow() {
		//super.onDetachedFromWindow();

		// [示範用] 關閉浮標.
//		if(lsjFloatingBtn != null) {
//			lsjFloatingBtn.hideFloatingBtn();
//			showLSJFloatingBtn = false;
//		}
//		lsjFloatingBtn = null;

		/**
		 // 關閉 LSJ SDK 浮標.
		 if(lsjFloatingBtn != null)
		 lsjFloatingBtn.hideFloatingBtn();
		 lsjFloatingBtn = null; // 重置浮標.
		 */
	}

	private void getPlayerInfo(){
    	if (isCreate) {
//			lsjUserInfoCallback = new LSJUserInfoCallback() {
//				@Override
//				public void GetInfoSuccess(LSJUser _lsjUser) {
//					// 取得玩家資訊成功.
//					String userId = _lsjUser.getUserIdData();
//					String nickname = _lsjUser.getNicknameData();
//					String bindEmail = _lsjUser.getBindEmailData();
//					String visitorAccount = _lsjUser.getVisitorAccountData();
//					int payPoint = _lsjUser.getPayPointData();
//					int freePoint = _lsjUser.getFreePointData();
//					tmpSaveLSJToken = _lsjUser.getTokenData();
//
//					//Toast.makeText(MainActivity.this, "userId: " + userId + "\n" + "token: " + tmpSaveLSJToken, Toast.LENGTH_SHORT).show();
//				}
//
//				@Override
//				public void GetInfoFail(String _errorCode, String _errorMsg) {
//					// 取得玩家資訊失敗.
//					//Toast.makeText(MainActivity.this, "錯誤代碼: " + _errorCode + "\n錯誤訊息: " + _errorMsg, Toast.LENGTH_SHORT).show();
//
//					if (_errorCode.compareTo("996") == 0) {
//						//Toast.makeText(MainActivity.this, "登入失敗，請重新登入", Toast.LENGTH_SHORT).show();
//						onDetachedFromWindow(); // 建議關閉浮標.
//					} else {
//						// 其他錯誤，建議重新登入.
//						//Toast.makeText(MainActivity.this, "錯誤代碼: " + _errorCode + "\n錯誤訊息: " + _errorMsg, Toast.LENGTH_SHORT).show();
//					}
//				}
//			};
//			LSJUserInfoActivity.getLSJUserInfo(home_activity, lsjUserInfoCallback);
		}
	}

}