@echo off
set "JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_202"
set "ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home_INFRA"
set "PATH=%ORACLE_HOME%\bin;%JAVA_HOME%\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"
set "FORMS_BUILDER_CLASSPATH=%ORACLE_HOME%\jlib\frmbld.jar;%ORACLE_HOME%\forms\java\frmall.jar;%ORACLE_HOME%\forms\java\frmwebutil.jar;%ORACLE_HOME%\jlib\debugger.jar;%ORACLE_HOME%\jlib\utj.jar"
cd /d %ORACLE_HOME%\bin
frmbld.exe