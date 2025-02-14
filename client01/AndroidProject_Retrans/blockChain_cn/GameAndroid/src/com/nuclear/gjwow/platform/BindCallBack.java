package com.nuclear.gjwow.platform;


public interface BindCallBack<T> {

	public void onSuccess(T success);

	public void onError(T error);
}
