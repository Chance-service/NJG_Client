
#include "stdafx.h"

#include "main.h"
#include "../Classes/AppDelegate.h"
#include "CCEGLView.h"
#include "resource.h"
#include "GamePrecedure.h"
#include <atlconv.h>
#include <atlstr.h>
//#include "vld.h"


USING_NS_CC;
#if defined WIN32 

const std::string g_Resource[20] = {
	"android_gNetop -1",
	"android_Entermate -1",
	"android_R2Game_en 0",
	"android_R2Game_en 2",
	"android_R2Game_en 4",
	"android_R2Game_en 5",
	"android_R2Game_en 7",
	"android_R2Game_en 11",
	"android_R2Game_en 14",
	"android_R2Game_en 15"
};
void reLoginGame(std::string cmd)
{
	std::string commandLine = cmd;
	TCHAR moduleName[MAX_PATH];
	ZeroMemory(moduleName, sizeof(moduleName));
	GetModuleFileName(NULL, moduleName, MAX_PATH);

	std::wstring ws;
    std::wstring moduleWstr = (LPCWSTR)CStringW(moduleName);
	ws.append(moduleWstr);
	ws.append(L" Resource ");
	ws.append(commandLine.begin(), commandLine.end());

	STARTUPINFO si = { 0 };
	PROCESS_INFORMATION pi = { 0 };
	lstrcpyW((LPWSTR)moduleName, ws.c_str());
	if (CreateProcess(NULL, moduleName, NULL, NULL, FALSE, NORMAL_PRIORITY_CLASS, NULL, NULL, &si, &pi))
	{
		ExitProcess(0);
	}
}

LRESULT WindowProc(UINT message, WPARAM wParam, LPARAM lParam, BOOL* pProcessed)
{
	int wmId, wmEvent;
	std::string strSelCfg;
	switch (message)
	{
	case WM_COMMAND:
		wmId = LOWORD(wParam);
		wmEvent = HIWORD(wParam);
		switch (wmId)
		{
		case ID_40004:
		case ID_40005:
		case ID_R2GAMES_40006:
		case ID_R2GAMES_40007:
		case ID_R2GAMES_40008:
		case ID_R2GAMES_40009:
		case ID_R2GAMES_40010:
		case ID_R2GAMES_40011:
		case ID_R2GAMES_40012:
		case ID_R2GAMES_40013:
		case ID_R2GAMES_40014:
			strSelCfg = g_Resource[wmId - USER_MENU - 1];
			reLoginGame(strSelCfg);
			break;
		}
		break;
	default:
		return 0;
	}

	*pProcessed = TRUE;
	return 0;
}
#endif

int APIENTRY _tWinMain(HINSTANCE hInstance,
                       HINSTANCE hPrevInstance,
                       LPTSTR    lpCmdLine,
                       int       nCmdShow)
{

    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);
	//
	WM_DEBUG
		//
	int w = 720;
	int h = 1280;
	float fZoomFactor = 0.7f;
#if defined WIN32 

	LPWSTR *szArgList;  
	int argCount;  
	szArgList = CommandLineToArgvW((LPWSTR)GetCommandLine(), &argCount);
	CCLOG("argCount = %d", argCount);
	for(int i = 1; i < argCount; i++)  
	{
		wchar_t* ext = L"WinSize";
		if (wcsstr(szArgList[i], ext))
		{
			w = _wtoi(szArgList[++i]);
			h = _wtoi(szArgList[++i]);
			if ((++i) >= argCount)
			{
				break;
			}
		}

		wchar_t* extScale = L"Scale";
		if (wcsstr(szArgList[i], extScale))
		{
			fZoomFactor = (float)_wtof(szArgList[++i]);
			if ((++i) >= argCount)
			{
				break;
			}
		}

		wchar_t* extR = L"Resource";
		if (!wcsicmp(szArgList[i], extR))
		{
			LPWSTR reourcePath = szArgList[++i];
			int languageType = _wtoi(szArgList[++i]);
			ResourceConfigItem *item = new ResourceConfigItem;
			item->languageType = languageType;
			USES_CONVERSION;
			std::string reource(W2A(reourcePath));
			item->reourcePath = reource;
			item->platform = "win32";
			item->id = 1;
			GamePrecedure::getInstance()->setWin32ResourceConfigItem(item);
			if ((++i) >= argCount)
			{
				break;
			}
			break;
		}
		
	}
	LocalFree(szArgList);

	AllocConsole();
	freopen("CONIN$", "r", stdin);
	freopen("CONOUT$", "w", stdout);
	freopen("CONOUT$", "w", stderr);
#endif
    // create the application instance
    AppDelegate app;
    CCEGLView* eglView = CCEGLView::sharedOpenGLView();
	SetMenu(eglView->getHWnd(),LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENU1)));
	eglView->setWndProc(WindowProc);
	/*w = 1125;
	h = 2436;
	fZoomFactor = 0.4f;*/
	eglView->setFrameSize(w, h);
	eglView->setFrameZoomFactor(fZoomFactor);
    //eglView->setFrameSize(480, 854 );//xiaomi1
	//eglView->setFrameSize(320, 480 );//iphone3Gs	2:3
	//eglView->setFrameSize(640, 960);//ipnone4
	//eglView->setFrameSize(640, 1136 );//ipnone5
	//eglView->setFrameSize(768, 1024 );//iPad		3:4
	//eglView->setFrameSize(800, 1280 );//			5:8
	//eglView->setFrameSize(480, 800 );	//			3:5
	//eglView->setFrameSize(720, 1280 );//			9:16
	//
	WM_DEBUG_TEST
	WM_NEW_TEST
	//
    int ret =  CCApplication::sharedApplication()->run();


#if defined WIN32
	FreeConsole();
#endif

	//
	WM_DEBUG_TEST
	WM_NEW_TEST
	//
	return ret;
	/*
	3:4		1.333	768*1024(ipad2)		
					1536*2048(Ipad3/4)
	2:3		1.5		320*480(iphone3GS)											100+//all£ºSAMSUNG£¬ Motorola£¬HTC£¬Lenovo£¬jingli£¬ZTE£¬kupai£¬huawei 
					640*960(Iphone4(s) Meizu)
	5:8		1.6		800*1280(Galaxy Note I9220)
	3:5		1.666	480*800(SAMSUNG I9100G)										200+//all
			1.775	640*1136(iphone5)
	9:16	1.777	540*960(HTC Z715e)											40+//Motorola£¬HTC£¬ZTE£¬SONY£¬huawei£¬Lenovo
					720*1280(Motorola XT928,M2,Galaxy SIII I9300,HTC ONE XT)	50+//SAMSUNG, Motorola, HTC Lenovo ZTE
			1.779	480*854(Motorola XT681, M1)									30+//Motorola, Xiaomi M1, huawei

	Motorola	480*854 540*960 320*480 480*800
	SAMSUNG		720*1280 480*800	320*480
	Lenovo		480*800 320*480
	huawei		480*800
	ZTE			480*800 320*480 540*960
	kupai		480*800 320*480
	HTC			480*800 320*480 540*960 720*1280
	meizu		640*960
	Xiaomi		480*854 720*1280
	*/
}
