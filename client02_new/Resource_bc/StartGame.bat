@echo off
rem ��ʾ����
@echo ���ܣ�������Ϸ�ͻ��������°汾��������Ϸ
@echo
@echo
@echo ע �� �� ��
@echo ************************************************************************
@echo ���Ծ���ͨ���ƻ��������ƶ��Զ�ִ��,����ǰ��������Ŀ¼:
@echo
@echo 1.svn_bin Ϊ��װTortoiseSVN�ͻ��˵Ŀ�ִ�г���Ŀ¼
@echo  2.svn_work Ϊ������Ŀ�ļ���Ŀ¼
@echo.
@echo WIN7��WINVista��WIN2008���û����ù���Ա�������
@echo 
@echo ************************************************************************

rem ·������,���ڴ˴���ʵ���޸�,����治Ҫ��б��

@set svn_bin=D:\Program Files\TortoiseSVN\bin

::���������ļ�
TortoiseProc.exe/command:update /path:"%~dp0" /notempfile /closeonend:0

::�������ļ��������������������ļ�Ŀ¼
::copy %svn_work%\*.* %server_cfg_file_dir%\

cd /d %svn_work%

start Game.exe WinSize 720 1280 Scale 0.7f

::@echo finish update and copy xml file
::pause
