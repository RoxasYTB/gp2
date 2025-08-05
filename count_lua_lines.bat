@echo off
setlocal enabledelayedexpansion

set "total=0"
for /r %%f in (*.lua) do (
    for /f %%c in ('find /v /c "" ^< "%%f"') do (
        set /a total+=%%c
    )
)
echo Nombre total de lignes de code Lua : !total!
pause
