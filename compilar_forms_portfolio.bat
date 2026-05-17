@echo off
set "JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_202"
set "ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home_INFRA"
set "TNS_ADMIN=C:\Oracle\domains\forms_domain\config\fmwconfig"
set "PATH=%ORACLE_HOME%\bin;C:\Oracle\product\21c\dbhomeXE\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"

"%ORACLE_HOME%\bin\frmcmp.exe" module="C:\Projetos\projeto-forms-cliente\forms\cliente_portfolio.fmb" userid=treinamento/<senha>@//127.0.0.1:1521/XEPDB1 module_type=form compile_all=yes batch=yes output_file="C:\Projetos\projeto-forms-cliente\forms\cliente_portfolio.fmx"

echo ERRORLEVEL=%ERRORLEVEL%
pause
