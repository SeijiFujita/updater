@echo off
rem path=C:\Dev\D\dmd.2.072.1\windows\bin;C:\D\bin;

@echo on

dmd -wi updater.d config.d debuglog.d
@if ERRORLEVEL 1 goto :eof
del *.obj

rem zip -9 updater.zip updater.exe updater.conf

echo done...
goto :eof
-----------------------------------
