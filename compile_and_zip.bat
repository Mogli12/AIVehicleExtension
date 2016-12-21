del %modname%.zip
cd %modname%
del /q *.lua
del /q *.luc
for %%I in (..\src\*.lua) do call :loopbody "%%~fI"
"C:\Program Files\WinRAR\winrar" A -r ..\%modname%.zip *.*
cd ..
pause
goto :EOF

:loopbody
	echo %~n1
	call c:\work\luapower-all-master\luajit -bg ..\src\%~n1.lua c:\temp\%~n1.luc
	copy /v /y ..\src\%~n1.lua %~n1.lua
	goto :EOF

:loopbody_luc_17
	echo %~n1
	call c:\work\luapower-all-master\luajit -bg ..\src\%~n1.lua %~n1.l32
	goto :EOF

:loopbody_luc
	echo %~n1
	call c:\work\luapower-all-master\luajit -bg ..\src\%~n1.lua %~n1.luc
	ren %~n1.luc %~n1.lua
	goto :EOF

