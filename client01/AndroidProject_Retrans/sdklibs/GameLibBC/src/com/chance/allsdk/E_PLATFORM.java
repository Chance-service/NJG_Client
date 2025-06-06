package com.chance.allsdk;

public enum E_PLATFORM {
    NONE(0),
    H365(1),
    EROR18(2),
    JSG(3),
    LSJ(4),
    MURA(5),
    KUSO(6),
    EROLABS(7),
    OP(8),
    APLUS(9);
    private int value;
    E_PLATFORM(int value) {
        this.value = value;
    }
    public int getValue(){
        return  value;
    }
    public static E_PLATFORM valueOf(int value) {
        switch (value) {
            case 0: return NONE;
            case 1: return H365;
            case 2: return EROR18;
            case 3: return JSG;
            case 4: return LSJ;
            case 5: return MURA;
            case 6: return KUSO;
            case 7: return EROLABS;
            case 8: return OP;
            case 9: return APLUS;
            default: return null;
        }
    }
}
