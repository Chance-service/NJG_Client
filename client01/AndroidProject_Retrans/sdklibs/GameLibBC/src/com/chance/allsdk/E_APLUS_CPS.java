package com.chance.allsdk;

public enum E_APLUS_CPS {
    NONE(-1),
    CPS0(0), CPS1(1), CPS9(9),
    CPS12(12), CPS13(13), CPS18(18), CPS19(19),
    CPS20(20), CPS25(25),
    CPS39(39),
    CPS42(42), CPS49(49),
    CPS61(61),
    CPS75(75), CPS76(76),
    CPS85(85), CPS89(89),
    CPS96(96), CPS98(98),
    CPS114(114), CPS115(115), CPS116(116), CPS117(117),
    CPS120(120), CPS126(126), CPS129(129),
    CPS143(143), CPS147(147),
    CPS152(152), CPS155(155),
    CPS163(163), CPS167(167), CPS168(168), CPS169(169),
    CPS170(170), CPS174(174), CPS175(175), CPS176(176),
    CPS184(184), CPS186(186),
    CPS195(195), CPS196(196), CPS197(197), CPS198(198), CPS199(199),
    CPS200(200), CPS201(201), CPS202(202), CPS203(203), CPS204(204), CPS205(205), CPS206(206), CPS207(207), CPS208(208), CPS209(209),
    CPS210(210), CPS211(211), CPS212(212), CPS213(213), CPS214(214), CPS218(218),
    CPS220(220), CPS226(226), CPS229(229),
    CPS230(230), CPS232(232), CPS234(234), CPS237(237),
    CPS243(243), CPS248(248), CPS249(249),
    CPS250(250), CPS251(251), CPS252(252), CPS253(253), CPS254(254), CPS255(255), CPS256(256), CPS257(257), CPS258(258), CPS259(259),
    CPS260(260), CPS261(261), CPS262(262), CPS263(263), CPS264(264), CPS265(265), CPS266(266), CPS267(267), CPS268(268), CPS269(269),
    CPS270(270), CPS271(271), CPS272(272), CPS274(274), CPS275(275), CPS276(276), CPS277(277), CPS278(278), CPS279(279),
    CPS280(280), CPS281(281), CPS282(282), CPS283(283), CPS284(284), CPS285(285), CPS286(286), CPS287(287), CPS288(288), CPS289(289),
    CPS290(290), CPS291(291), CPS292(292), CPS293(293), CPS294(294), CPS295(295), CPS296(296), CPS297(297), CPS298(298), CPS299(299),
    ;
    private final int value;
    E_APLUS_CPS(int value) {
        this.value = value;
    }
    public int getValue(){
        return  value;
    }
    public static E_APLUS_CPS valueOf(int value) {
        switch (value) {
            case -1: return NONE;
            case 0: return CPS0;
            case 1: return CPS1;
            case 9: return CPS9;
            case 12: return CPS12;
            case 13: return CPS13;
            case 18: return CPS18;
            case 19: return CPS19;
            case 20: return CPS20;
            case 25: return CPS25;
            case 39: return CPS39;
            case 42: return CPS42;
            case 49: return CPS49;
            case 61: return CPS61;
            case 75: return CPS75;
            case 76: return CPS76;
            case 85: return CPS85;
            case 89: return CPS89;
            case 96: return CPS96;
            case 98: return CPS98;
            case 114: return CPS114;
            case 115: return CPS115;
            case 116: return CPS116;
            case 117: return CPS117;
            case 120: return CPS120;
            case 126: return CPS126;
            case 129: return CPS129;
            case 143: return CPS143;
            case 147: return CPS147;
            case 152: return CPS152;
            case 155: return CPS155;
            case 163: return CPS163;
            case 167: return CPS167;
            case 168: return CPS168;
            case 169: return CPS169;
            case 170: return CPS170;
            case 174: return CPS174;
            case 175: return CPS175;
            case 176: return CPS176;
            case 184: return CPS184;
            case 186: return CPS186;
            case 195: return CPS195;
            case 196: return CPS196;
            case 197: return CPS197;
            case 198: return CPS198;
            case 199: return CPS199;
            case 200: return CPS200;
            case 201: return CPS201;
            case 202: return CPS202;
            case 203: return CPS203;
            case 204: return CPS204;
            case 205: return CPS205;
            case 206: return CPS206;
            case 207: return CPS207;
            case 208: return CPS208;
            case 209: return CPS209;
            case 210: return CPS210;
            case 211: return CPS211;
            case 212: return CPS212;
            case 213: return CPS213;
            case 214: return CPS214;
            case 218: return CPS218;
            case 220: return CPS220;
            case 226: return CPS226;
            case 229: return CPS229;
            case 230: return CPS230;
            case 232: return CPS232;
            case 234: return CPS234;
            case 237: return CPS237;
            case 243: return CPS243;
            case 248: return CPS248;
            case 249: return CPS249;
            case 250: return CPS250;
            case 251: return CPS251;
            case 252: return CPS252;
            case 253: return CPS253;
            case 254: return CPS254;
            case 255: return CPS255;
            case 256: return CPS256;
            case 257: return CPS257;
            case 258: return CPS258;
            case 259: return CPS259;
            case 260: return CPS260;
            case 261: return CPS261;
            case 262: return CPS262;
            case 263: return CPS263;
            case 264: return CPS264;
            case 265: return CPS265;
            case 266: return CPS266;
            case 267: return CPS267;
            case 268: return CPS268;
            case 269: return CPS269;
            case 270: return CPS270;
            case 271: return CPS271;
            case 272: return CPS272;
            case 274: return CPS274;
            case 275: return CPS275;
            case 276: return CPS276;
            case 277: return CPS277;
            case 278: return CPS278;
            case 279: return CPS279;
            case 280: return CPS280;
            case 281: return CPS281;
            case 282: return CPS282;
            case 283: return CPS283;
            case 284: return CPS284;
            case 285: return CPS285;
            case 286: return CPS286;
            case 287: return CPS287;
            case 288: return CPS288;
            case 289: return CPS289;
            case 290: return CPS290;
            case 291: return CPS291;
            case 292: return CPS292;
            case 293: return CPS293;
            case 294: return CPS294;
            case 295: return CPS295;
            case 296: return CPS296;
            case 297: return CPS297;
            case 298: return CPS298;
            case 299: return CPS299;
            default: return null;
        }
    }
}