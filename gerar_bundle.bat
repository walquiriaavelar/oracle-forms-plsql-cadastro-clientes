@echo off
cd /d C:\Projetos\projeto-forms-cliente

echo.
echo ==== Status atual ====
git status

echo.
echo ==== Adicionando arquivos ====
git add .

echo.
echo ==== Criando commit ====
git commit -m "Finaliza CRUD Oracle Forms e PL/SQL funcional"

echo.
echo ==== Gerando bundle ====
git bundle create walquiria-de-avelar-mourao-oracle-forms-plsql.bundle --all

echo.
echo ==== Validando bundle ====
git bundle verify walquiria-de-avelar-mourao-oracle-forms-plsql.bundle

echo.
echo Bundle gerado em:
echo C:\Projetos\projeto-forms-cliente\walquiria-de-avelar-mourao-oracle-forms-plsql.bundle

pause
