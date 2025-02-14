package com.nuclear.state;

import com.nuclear.manager.StateManager;

public class UpdateSOState extends BaseState{

	@Override
	public boolean needChangeView() {
		return false;
	}
	public void create() {
		copySO();
		loadSO();
		StateManager.getInstance().changeState(GameContextState.class);
	}
	private void copySO() {
		
	}
	private void loadSO() {
		//System.loadLibrary("Gjwow");
	};
	

}
