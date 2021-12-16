del %modname%.zip
cd %modname%
del /q *.lua
del /q *.luc
for %%I in (..\%srcdir%\*.lua) do call :loopbody "%%~fI"
tar -a -c -f ..\%modname%.zip *.*
cd ..
pause
goto :EOF

:loopbody
	echo %~n1
	copy /v /y ..\%srcdir%\%~n1.lua %~n1.lua
	goto :EOF

:loopbody_luc_17
	echo %~n1
	call c:\work\luapower-all-master\luajit -bg ..\%srcdir%\%~n1.lua %~n1.l32
	goto :EOF

:loopbody_luc
	echo %~n1
	call c:\work\luapower-all-master\luajit -bg ..\%srcdir%\%~n1.lua %~n1.luc
	ren %~n1.luc %~n1.lua
	goto :EOF

