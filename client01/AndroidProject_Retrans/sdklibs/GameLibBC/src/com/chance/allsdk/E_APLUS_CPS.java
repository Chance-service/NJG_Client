package com.chance.allsdk;

public enum E_APLUS_CPS {
    NONE(0),
    CPS1(1),
    CPS2(2);
    private int value;
    E_APLUS_CPS(int value) {
        this.value=value;
    }
    public int getValue(){
        return  value;
    }
    public static E_APLUS_CPS valueOf(int value) {
        switch (value) {
            case 0: return NONE;
            case 1: return CPS1;
            case 2: return CPS2;
            default: return null;
        }
    }
}