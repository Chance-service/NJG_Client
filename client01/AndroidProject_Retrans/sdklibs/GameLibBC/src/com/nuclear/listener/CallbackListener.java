package com.nuclear.listener;

public interface CallbackListener<T> {
	public void onResult(int code,T result);
}
