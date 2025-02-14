
set work_path=./../Resource_Client/lua/
set current_path=./../../Code_Client/ 
cd %work_path% 
mkdir ..\..\lua_debug
for /R %%s in (.,*) do ( 
copy /y %%s ..\..\lua_debug\
) 
cd current_path
pause