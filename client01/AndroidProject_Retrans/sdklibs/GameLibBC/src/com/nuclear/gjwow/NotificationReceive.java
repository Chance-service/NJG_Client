package com.nuclear.gjwow;

import java.util.Date;
import java.util.List;
import java.util.Random;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;

public class NotificationReceive extends BroadcastReceiver {

	private Date date;
	private StringBuilder buf;
	private NotificationManager notif;

	@Override
	public void onReceive(Context context, Intent intent) {
		Log.e("GameActivity", "receive:-----------");
		Log.e("GameActivity", "receive:"+intent.getAction());
		System.out.println("*********receive:"+intent.getAction());
		String packageName = context.getPackageName();
		System.out.println("*********pakagetname:"+packageName);
		ActivityManager activityManager = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);
		List<RunningTaskInfo> tasksInfo = activityManager.getRunningTasks(1);
		if(tasksInfo.size() > 0){
			Log.e("GameActivity","--------------------------"+tasksInfo.get(0).topActivity.getPackageName());
			if(packageName.equals(tasksInfo.get(0).topActivity.getPackageName())){
				System.out.println("return task");
				return;
			}
		}
		if (notif == null){
			notif = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
			

					//manager.notify(1, notification);

		}
		String title = intent.getStringExtra("title");
		String msg = intent.getStringExtra("message");
		Log.e("GameActivity", "receive title:"+title);
		Log.e("GameActivity", "receive msg:"+msg);
		
		int iconId =0;
        if(iconId==0)
        {
            iconId = context.getApplicationInfo().icon;
        }
        if (iconId < 0) {
            iconId = android.R.drawable.sym_def_app_icon;
            
           // context.getPackageManager().getApplicationIcon("jp.co.school.battle").
        }
        
        
        
        

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
           // NotificationManager manager = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
        	System.out.println("sb++++++++++++++++++");
            NotificationChannel channel = new NotificationChannel(
                // 一意のチャンネルID
                // ここはどこかで定数にしておくのが良さそう
                "channel_id_sample",

                // 設定に表示されるチャンネル名
                // ここは実際にはリソースを指定するのが良さそう
                "プッシュ通知",

                // チャンネルの重要度
                // 重要度によって表示箇所が異なる
                NotificationManager.IMPORTANCE_HIGH
            );

            // 通知時にライトを有効にする
            channel.enableLights(true);
            // 通知時のライトの色
            channel.setLightColor(Color.WHITE);
            // ロック画面での表示レベル
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

            // チャンネルの登録
            notif.createNotificationChannel(channel);
        }
        
        
        


        int resId = context.getResources().getIdentifier("notification_icon", "drawable", context.getPackageName());
        System.out.println("resId:"+resId);
		Notification.Builder builder = new Notification.Builder(
				context);
				builder.setContentTitle(title);
				builder.setContentText(msg);
				builder.setSmallIcon(resId);
				builder.setLargeIcon(BitmapFactory.decodeResource(context.getResources(),iconId));

	  Notification notifica = builder.build();

	  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
		  builder.setChannelId("channel_id_sample");
		}
		//Notification notifica = new Notification(iconId, title,System.currentTimeMillis());
		notifica.flags = Notification.FLAG_AUTO_CANCEL;
		Intent mIntent = null;
		try {
			mIntent = new Intent(context, Class.forName("com.nuclear.gjwow.platform.PlatformSDKActivity"));
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		mIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP	| Intent.FLAG_ACTIVITY_NEW_TASK);
		mIntent.setAction("com.nuclear.gjwow.notificationservice");
		// intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_0TOP);
		Random random = new Random(); 
		int in = random.nextInt(1000);
		PendingIntent contentIntent = PendingIntent.getActivity(context, in, mIntent, PendingIntent.FLAG_ONE_SHOT);
		notifica.contentIntent = contentIntent;
		//notifica.setLatestEventInfo(context, title, msg, contentIntent);
		notifica.defaults = Notification.DEFAULT_ALL;
		date = new Date();
		buf = new StringBuilder();
		int seq = 0;
		int ROTATION = 99999;
		if (seq > ROTATION)
			seq = 0;
		buf.delete(0, buf.length());
		date.setTime(System.currentTimeMillis());
		String str = String.format("%1$tY%1$tm%1$td%1$tk%1$tM%1$tS%2$05d", date, seq++);
		notif.notify((int) Long.parseLong(str), notifica);
		return;
	}

	private void setNotificationChannelGroups(NotificationChannel channel) {
		// TODO Auto-generated method stub
		
	}

	private void createNotificationChannelGroups() {
		// TODO Auto-generated method stub
		
	}
	
}