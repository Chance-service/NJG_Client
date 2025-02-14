package com.nuclear.manager;

import android.util.Log;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

public class MessageManager {
	static String tag = "MessageManager";
	//private List<MessageListener> listenerList = new ArrayList<MessageListener>();
	private HashMap<String, MessageListener> listenerList = new HashMap<String, MessageListener>();
	private MessageManager(){};
	private static MessageManager instance = new MessageManager();
	public static MessageManager getInstance(){
		return instance;
	}
	
	public void setMsgHandler(String msgTag, MessageListener listener) {
		if (listener != null)
			listenerList.put(msgTag,listener);
	}
	public void removeMsgHandler(String msgTag) {
		listenerList.remove(msgTag);
	}
	public void removeMsgHandler(MessageListener listener) {
		listener.unregisterMsg();
//		Set<String> msgTags = listenerList.keySet();
//		for (String msgTag : msgTags) {
//			if(listener == listenerList.get(msgTag)){
//				listenerList.remove(msgTag);
//			}
//		}
	}

	@SuppressWarnings("unchecked")
	public String sendMessageG2P(String tag, String msg) {

		MessageListener listener = listenerList.get(tag);
		if(listener != null){
			//return listener.onReceiveMsg(tag, msg);
			Class classObject = listener.getClass();
			Method methodObject;
			try {
				methodObject = classObject.getMethod(tag, new Class[] {String.class});
				try {
					return (String)methodObject.invoke(listener, msg);
				} catch (IllegalArgumentException e) {
					Log.e(tag, "sendMessageG2P,IllegalArgumentException,tag="+tag+",msg="+msg);
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					Log.e(tag, "sendMessageG2P,IllegalAccessException,tag="+tag+",msg="+msg);
					e.printStackTrace();
				} catch (InvocationTargetException e) {
					Log.e(tag, "sendMessageG2P,InvocationTargetException,tag="+tag+",msg="+msg);
					e.printStackTrace();
				}
			} catch (NoSuchMethodException e) {
				// TODO Auto-generated catch block
				Log.e(tag, "sendMessageG2P,NoSuchMethodException,tag="+tag+",msg="+msg);
				e.printStackTrace();
			}
		}
		else{
			Log.e(tag, "sendMessageG2P:invaild Msg,tag="+tag+",msg="+msg);
		}

		return null;
	}

	
	public interface MessageListener {
		void registerMsg();
		void unregisterMsg();
	}

}
