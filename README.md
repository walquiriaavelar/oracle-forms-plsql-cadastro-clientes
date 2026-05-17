# Projeto Oracle Forms + PL/SQL – Cadastro de Clientes

![Oracle Forms](https://img.shields.io/badge/Oracle%20Forms-12c-red)
![PLSQL](https://img.shields.io/badge/PL%2FSQL-Oracle-blue)
![Database](https://img.shields.io/badge/Oracle%20XE-21c-red)
![Status](https://img.shields.io/badge/status-funcional-brightgreen)

## 1. Visão geral

Este projeto implementa um **CRUD de Clientes em Oracle Forms + PL/SQL**, utilizando **Oracle Forms Services/WebLogic**, **Oracle Database XE 21c** e uma **package PL/SQL** para centralizar regras de negócio.

O formulário permite:

- Cadastrar clientes.
- Alterar clientes existentes.
- Excluir clientes com confirmação.
- Pesquisar clientes por filtros.
- Validar e-mail, CEP, UF e status ativo.
- Executar o formulário via **Oracle Forms Services** usando **FSAL**.

Projeto desenvolvido como prova técnica/portfólio para demonstrar domínio em:

- Oracle Forms 12c.
- PL/SQL.
- Packages, functions, procedures, triggers e sequence.
- Oracle Database XE.
- WebLogic Server / AdminServer / WLS_FORMS.
- Configuração de `formsweb.cfg`, `default.env` e execução via `frmservlet`.

---

## 2. Status atual

✅ Banco Oracle XE 21c funcionando  
✅ Schema `TREINAMENTO` criado e validado  
✅ Tabela, sequence, trigger e package criados  
✅ Formulário `.fmb` funcional  
✅ Binário `.fmx` funcional  
✅ Execução via **Oracle Forms Services / FSAL**  
✅ Insert funcionando com retorno de ID  
✅ Update funcionando  
✅ Delete funcionando via package  
✅ Pesquisa funcionando  
✅ LOV de UF funcionando  
✅ Validação de `ATIVO` com valores `0` ou `1`  
✅ Validações de negócio no PL/SQL  

---

## 3. Tecnologias utilizadas

| Camada | Tecnologia |
|---|---|
| Interface | Oracle Forms Builder 12c / Oracle Forms Services |
| Backend | PL/SQL |
| Banco | Oracle Database XE 21c |
| Servidor de aplicação | Oracle WebLogic Server / Fusion Middleware |
| Execução | FSAL / `frmservlet` |
| Sistema operacional | Windows |
| Java | JDK 8 |
| Versionamento | Git / Git Bundle |

---

## 4. Estrutura do projeto

```text
projeto-forms-cliente/
├─ forms/
│  ├─ cliente.fmb
│  ├─ cliente.fmx
│  ├─ cliente_portfolio.fmb
│  └─ cliente_portfolio.fmx
│
├─ sql/
│  ├─ 00_drop_objetos.sql
│  ├─ 01_create_tb_cliente.sql
│  ├─ 02_create_seq_cliente.sql
│  ├─ 03_create_triggers_tb_cliente.sql
│  ├─ 04_package_spec.sql
│  ├─ 05_package_body.sql
│  └─ 06_dados_teste.sql
│
├─ scripts/
│  └─ extrair_ddls.sql
│
├─ docs/
│  └─ evidencias/
│
├─ abrir_builder_infra.bat
├─ compilar_forms_portfolio.bat
├─ abrir_forms_fsal.bat
├─ gerar_bundle.bat
└─ README.md
```

> Observação: o arquivo `cliente_portfolio.fmb` representa a versão final revisada para portfólio. O runtime usado pelo `formsweb.cfg` pode apontar para `cliente_portfolio.fmx`.

---

## 5. Objetos de banco

Os objetos principais ficam no schema:

```text
TREINAMENTO
```

Objetos criados:

| Objeto | Tipo | Finalidade |
|---|---|---|
| `TB_CLIENTE` | Tabela | Armazena os clientes |
| `SEQ_CLIENTE` | Sequence | Geração do ID |
| `TRG_CLIENTE_BI` | Trigger | Preenche ID/data de criação |
| `PKG_CLIENTE` | Package | Regras de negócio e CRUD |

### 5.1 Tabela `TB_CLIENTE`

Campos esperados:

```text
ID_CLIENTE
NOME
EMAIL
CEP
LOGRADOURO
BAIRRO
CIDADE
UF
ATIVO
DT_CRIACAO
DT_ATUALIZACAO
```

### 5.2 Regras implementadas

- `NOME` obrigatório.
- `EMAIL` válido.
- `EMAIL` único.
- `CEP` opcional, mas quando informado deve conter 8 dígitos.
- `UF` deve estar na lista de estados brasileiros.
- `ATIVO` deve ser `0` ou `1`.
- Erros de negócio tratados com `RAISE_APPLICATION_ERROR`.

---

## 6. Package PL/SQL

A package `PKG_CLIENTE` centraliza a regra de negócio.

Principais rotinas:

```plsql
FN_VALIDAR_EMAIL(p_email VARCHAR2) RETURN NUMBER;
FN_NORMALIZAR_CEP(p_cep VARCHAR2) RETURN VARCHAR2;

PRC_INSERIR_CLIENTE(...);
PRC_ATUALIZAR_CLIENTE(...);
PRC_DELETAR_CLIENTE(p_id NUMBER);
PRC_LISTAR_CLIENTES(p_nome VARCHAR2, p_email VARCHAR2, p_rc OUT SYS_REFCURSOR);
```

Decisão técnica: as transações principais são confirmadas pela camada Forms, evitando `COMMIT`/`ROLLBACK` dentro da package quando a UI precisa orquestrar o fluxo.

---

## 7. Formulário Oracle Forms

### 7.1 Módulo

```text
F_CLIENTE_CADASTRO
```

### 7.2 Bloco

```text
BLK_CLIENTE
```

### 7.3 Canvas

```text
CV_CLIENTE
```

### 7.4 Janela

```text
WIN_CLIENTE
```

### 7.5 Campos

| Campo Forms | Descrição |
|---|---|
| `ID_CLIENTE` | ID gerado automaticamente |
| `NOME` | Nome do cliente |
| `IEMAIL_FIX` | E-mail |
| `CEP` | CEP |
| `LOGRADOURO` | Endereço |
| `BAIRRO` | Bairro |
| `CIDADE` | Cidade |
| `UF` | UF com LOV |
| `ATIVO` | 1 ativo / 0 inativo |

### 7.6 Botões

| Botão | Trigger |
|---|---|
| `BTN_NOVO` | Limpa tela e posiciona em Nome |
| `BTN_SALVAR` | Insere/atualiza cliente |
| `BTN_EXCLUIR` | Confirma e exclui cliente |
| `BTN_CANCELAR` | Cancela alterações |
| `BTN_PESQUISAR` | Pesquisa registros |

---

## 8. Fluxo funcional

### 8.1 Novo

1. Limpa o bloco.
2. Cria novo registro.
3. Posiciona o cursor no campo `NOME`.

### 8.2 Salvar

1. Valida campos.
2. Se `ID_CLIENTE` estiver nulo, insere.
3. Se `ID_CLIENTE` estiver preenchido, atualiza.
4. Efetua `COMMIT`.
5. Retorna mensagem amigável.

### 8.3 Pesquisar

1. Usuário informa filtro, como `NOME` ou `EMAIL`.
2. O Forms aplica a pesquisa.
3. O registro é carregado no bloco.

### 8.4 Excluir

1. Usuário pesquisa ou seleciona o cliente.
2. Clica em **Excluir**.
3. O Forms exibe alerta de confirmação.
4. A procedure `PKG_CLIENTE.PRC_DELETAR_CLIENTE` é executada.
5. O Forms executa `COMMIT`.
6. A tela é limpa.

### 8.5 Cancelar

1. Executa `ROLLBACK`.
2. Limpa o bloco.
3. Retorna mensagem amigável.

---

## 9. Pré-requisitos

- Windows.
- Oracle Database XE 21c.
- Oracle Forms Builder 12c.
- Oracle Fusion Middleware / WebLogic com domínio Forms configurado.
- JDK 8.
- Git instalado.
- Schema `TREINAMENTO` com objetos criados.

Caminhos usados neste ambiente local:

```text
Oracle Database:
C:\Oracle\product\21c\dbhomeXE

Oracle Forms / Infra:
C:\Oracle\Middleware\Oracle_Home_INFRA

Domínio Forms:
C:\Oracle\domains\forms_domain

Projeto:
C:\Projetos\projeto-forms-cliente
```

> Ajuste os caminhos conforme o ambiente local.

---

## 10. Criar ou recriar o banco

Conectar no PDB:

```bat
set "PATH=C:\Oracle\product\21c\dbhomeXE\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"

sqlplus treinamento/<senha>@//127.0.0.1:1521/XEPDB1
```

Executar scripts:

```sql
@sql/00_drop_objetos.sql
@sql/01_create_tb_cliente.sql
@sql/02_create_seq_cliente.sql
@sql/03_create_triggers_tb_cliente.sql
@sql/04_package_spec.sql
@sql/05_package_body.sql
@sql/06_dados_teste.sql
```

Validar objetos:

```sql
SELECT owner, object_name, object_type, status
FROM all_objects
WHERE owner = 'TREINAMENTO'
  AND object_name IN ('TB_CLIENTE', 'SEQ_CLIENTE', 'TRG_CLIENTE_BI', 'PKG_CLIENTE')
ORDER BY object_type, object_name;
```

Consultar clientes:

```sql
SELECT id_cliente, nome, email, cep, cidade, uf, ativo
FROM treinamento.tb_cliente
ORDER BY id_cliente;
```

---

## 11. Verificar serviços Oracle no Windows

```bat
sc query OracleServiceXE
sc query OracleOraDB21Home1TNSListener
```

Ambos devem estar como:

```text
RUNNING
```

---

## 12. Atenção ao erro ORA-12557

Durante os testes, o erro abaixo ocorreu quando o Windows carregou DLL de outro Oracle Home:

```text
ORA-12557: TNS:adaptador de protocolo não carregável
```

Solução usada: limpar a sessão e deixar primeiro o Oracle XE no `PATH`.

```bat
set ORACLE_HOME=
set TNS_ADMIN=
set TWO_TASK=
set LOCAL=
set "PATH=C:\Oracle\product\21c\dbhomeXE\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"

where sqlplus
where oci.dll
sqlplus treinamento/<senha>@//127.0.0.1:1521/XEPDB1
```

O esperado é:

```text
C:\Oracle\product\21c\dbhomeXE\bin\sqlplus.exe
C:\Oracle\product\21c\dbhomeXE\bin\oci.dll
```

---

## 13. Configuração do `tnsnames.ora`

Arquivo usado pelo Forms:

```text
C:\Oracle\domains\forms_domain\config\fmwconfig\tnsnames.ora
```

Exemplo:

```ora
XEPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = XEPDB1)
    )
  )

XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = XE)
    )
  )
```

---

## 14. Configuração do `formsweb.cfg`

Arquivo:

```text
C:\Oracle\domains\forms_domain\config\fmwconfig\servers\WLS_FORMS\applications\formsapp_12.2.1\config\formsweb.cfg
```

Configuração usada:

```ini
[cliente]
form=C:/Projetos/projeto-forms-cliente/forms/cliente_portfolio.fmx
envFile=default.env
separateFrame=true
lookAndFeel=oracle
width=100%
height=100%
baseSAAfile=basesaa.txt
fsalcheck=true
```

> Neste ambiente, a configuração executada é `config=cliente`, apontando para o binário final `cliente_portfolio.fmx`.

---

## 15. Configuração do `default.env`

Arquivo:

```text
C:\Oracle\domains\forms_domain\config\fmwconfig\servers\WLS_FORMS\applications\formsapp_12.2.1\config\default.env
```

Pontos relevantes:

```ini
ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home_INFRA
FORMS_INSTANCE=C:\Oracle\domains\forms_domain\config\fmwconfig\components\FORMS\instances\forms1
TNS_ADMIN=C:\Oracle\domains\forms_domain\config\fmwconfig
ORACLE_TERM=frmweb
NLS_LANG=AMERICAN_AMERICA.AL32UTF8
```

O `TNS_ADMIN` precisa apontar para o local onde está o `tnsnames.ora`.

---

## 16. Subir o WebLogic / Forms Services

### 16.1 Abrir CMD como Administrador

Antes de iniciar, garantir que comandos básicos do Windows estejam no `PATH`:

```bat
set "PATH=C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;%PATH%"
```

### 16.2 Iniciar AdminServer

```bat
cd /d C:\Oracle\domains\forms_domain\bin
startWebLogic.cmd
```

Aguardar mensagens de servidor em execução.

Console WebLogic:

```text
http://localhost:7001/console
```

### 16.3 Iniciar WLS_FORMS

Em outro CMD como Administrador:

```bat
cd /d C:\Oracle\domains\forms_domain\bin
startManagedWebLogic.cmd WLS_FORMS http://localhost:7001
```

Aguardar:

```text
Server state changed to RUNNING
```

Forms Servlet:

```text
http://localhost:9001/forms/frmservlet
```

---

## 17. Abrir Oracle Forms Builder corretamente

Não abrir o `.fmb` por duplo clique, pois pode chamar o Oracle Home errado.

Usar o arquivo:

```text
abrir_builder_infra.bat
```

Conteúdo sugerido:

```bat
@echo off
set "JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_202"
set "ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home_INFRA"
set "PATH=%ORACLE_HOME%\bin;%JAVA_HOME%\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"
set "FORMS_BUILDER_CLASSPATH=%ORACLE_HOME%\jlib\frmbld.jar;%ORACLE_HOME%\forms\java\frmall.jar;%ORACLE_HOME%\forms\java\frmwebutil.jar;%ORACLE_HOME%\jlib\debugger.jar;%ORACLE_HOME%\jlib\utj.jar"

cd /d %ORACLE_HOME%\bin
frmbld.exe
```

Abrir no Builder:

```text
C:\Projetos\projeto-forms-cliente\forms\cliente_portfolio.fmb
```

---

## 18. Compilar o Forms

Usar o script:

```text
compilar_forms_portfolio.bat
```

Ou executar manualmente:

```bat
set "JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_202"
set "ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home_INFRA"
set "TNS_ADMIN=C:\Oracle\domains\forms_domain\config\fmwconfig"
set "PATH=%ORACLE_HOME%\bin;C:\Oracle\product\21c\dbhomeXE\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"

"C:\Oracle\Middleware\Oracle_Home_INFRA\bin\frmcmp.exe" module="C:\Projetos\projeto-forms-cliente\forms\cliente_portfolio.fmb" userid=treinamento/<senha>@//127.0.0.1:1521/XEPDB1 module_type=form compile_all=yes batch=yes output_file="C:\Projetos\projeto-forms-cliente\forms\cliente_portfolio.fmx"

echo %ERRORLEVEL%
```

Resultado esperado:

```text
0
```

> Se o `.fmx` estiver aberto no runtime, feche a janela do Forms Services antes de compilar.

---

## 19. Executar o formulário via FSAL

Com `AdminServer` e `WLS_FORMS` rodando:

```bat
"C:\Program Files\Java\jdk1.8.0_202\bin\java.exe" -jar "C:\Oracle\Middleware\Oracle_Home_INFRA\forms\java\frmsal.jar" -url "http://localhost:9001/forms/frmservlet?config=cliente"
```

Login:

```text
Username: TREINAMENTO
Password: <senha>
Database: XEPDB1
```

Se necessário, usar conexão direta:

```text
Database: //127.0.0.1:1521/XEPDB1
```

---

## 20. Execução via navegador / Web

O projeto usa **Oracle Forms Services**, portanto a aplicação é servida pelo `frmservlet`.

URL base:

```text
http://localhost:9001/forms/frmservlet?config=cliente
```

Em navegadores modernos, a execução de applets Java tradicionais não é mais suportada da mesma forma que em versões antigas de Forms/Java. Por isso, neste projeto a execução validada foi via **FSAL**, que continua usando o Forms Services/WebLogic, mas abre a aplicação em uma janela desktop controlada pelo launcher Java.

Para portfólio, isso demonstra:

- Configuração de domínio Oracle Forms.
- Publicação via `frmservlet`.
- Configuração de `formsweb.cfg`.
- Execução com `WLS_FORMS`.
- Cliente Forms acessando banco Oracle XE.

### Diferencial visual para o portfólio

Sugestão: incluir prints em `docs/evidencias/`:

```text
docs/evidencias/01_adminserver_running.png
docs/evidencias/02_wls_forms_running.png
docs/evidencias/03_formsweb_cfg_cliente.png
docs/evidencias/04_tela_cadastro.png
docs/evidencias/05_insert_sucesso.png
docs/evidencias/06_pesquisa_sucesso.png
docs/evidencias/07_exclusao_sucesso.png
```

E referenciar esses prints no README.

---

## 21. Testes realizados

### 21.1 Insert

Cadastro realizado com sucesso, retornando ID gerado pela sequence.

Mensagem esperada:

```text
Cliente incluido com sucesso. ID=<id>
```

ou:

```text
FRM-40400: Transaction complete: 1 records applied and saved.
```

### 21.2 Update

Alteração de cadastro existente realizada com sucesso.

### 21.3 Pesquisa

Pesquisa por filtro de nome/e-mail executada com sucesso.

Mensagem:

```text
Consulta executada.
```

### 21.4 Delete

Exclusão com confirmação.

Mensagem:

```text
Cliente excluido com sucesso.
```

### 21.5 Validações

- Email duplicado retorna mensagem amigável.
- UF usa lista de valores.
- Ativo aceita apenas `0` ou `1`.
- CEP é opcional, mas quando informado deve ter 8 dígitos.

---

## 22. Troubleshooting

### 22.1 `findstr` não reconhecido

Erro ao iniciar WebLogic:

```text
'findstr' não é reconhecido como um comando interno ou externo
```

Correção:

```bat
set "PATH=C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;%PATH%"
```

### 22.2 `FRM-93136`

Erro:

```text
Não foi especificado nenhum ficheiro TXT de base
```

Verificar no `formsweb.cfg`:

```ini
baseSAAfile=basesaa.txt
```

E confirmar que a seção usada na URL existe:

```text
config=cliente
```

### 22.3 `FRM-30087`

Erro ao criar `.fmx`.

Causa comum: arquivo aberto/em uso pelo runtime.

Solução:

1. Fechar Oracle Fusion Middleware Forms Services.
2. Apagar `.fmx` antigo se necessário.
3. Compilar novamente.

### 22.4 `FRM-18131`

Erro de versão incompatível ao abrir `.fmb`.

Solução: abrir sempre com o Forms Builder do mesmo Oracle Home usado no projeto:

```text
C:\Oracle\Middleware\Oracle_Home_INFRA\bin\frmbld.exe
```

### 22.5 `ORA-12557`

Causa comum: `PATH` misturando DLLs de Oracle Homes diferentes.

Solução: limpar variáveis e priorizar `dbhomeXE\bin`.

---

## 23. Scripts auxiliares recomendados

### 23.1 `abrir_forms_fsal.bat`

```bat
@echo off
"C:\Program Files\Java\jdk1.8.0_202\bin\java.exe" -jar "C:\Oracle\Middleware\Oracle_Home_INFRA\forms\java\frmsal.jar" -url "http://localhost:9001/forms/frmservlet?config=cliente"
pause
```

### 23.2 `compilar_forms_portfolio.bat`

```bat
@echo off
set "JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_202"
set "ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home_INFRA"
set "TNS_ADMIN=C:\Oracle\domains\forms_domain\config\fmwconfig"
set "PATH=%ORACLE_HOME%\bin;C:\Oracle\product\21c\dbhomeXE\bin;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"

"%ORACLE_HOME%\bin\frmcmp.exe" module="C:\Projetos\projeto-forms-cliente\forms\cliente_portfolio.fmb" userid=treinamento/<senha>@//127.0.0.1:1521/XEPDB1 module_type=form compile_all=yes batch=yes output_file="C:\Projetos\projeto-forms-cliente\forms\cliente_portfolio.fmx"

echo ERRORLEVEL=%ERRORLEVEL%
pause
```

### 23.3 `gerar_bundle.bat`

```bat
@echo off
cd /d C:\Projetos\projeto-forms-cliente

git status
git add .

git commit -m "Finaliza CRUD Oracle Forms e PL/SQL funcional"

git bundle create walquiria-de-avelar-mourao-oracle-forms-plsql.bundle --all

git bundle verify walquiria-de-avelar-mourao-oracle-forms-plsql.bundle

pause
```

---

## 24. Gerar novo arquivo `.bundle`

Para gerar um novo bundle do projeto funcionando:

```bat
cd /d C:\Projetos\projeto-forms-cliente

git status
git add .
git commit -m "Finaliza Oracle Forms CRUD funcional com WebLogic e FSAL"

git bundle create walquiria-de-avelar-mourao-oracle-forms-plsql.bundle --all
git bundle verify walquiria-de-avelar-mourao-oracle-forms-plsql.bundle
```

O arquivo será criado em:

```text
C:\Projetos\projeto-forms-cliente\walquiria-de-avelar-mourao-oracle-forms-plsql.bundle
```

### 24.1 Testar o bundle

Em uma pasta temporária:

```bat
cd /d C:\Projetos
git clone C:\Projetos\projeto-forms-cliente\walquiria-de-avelar-mourao-oracle-forms-plsql.bundle teste-bundle-forms
cd teste-bundle-forms
git log --oneline
```

Se clonar, o bundle está válido.

---

## 25. Observações de segurança

Este projeto é local e de portfólio. Para publicação pública:

- Não versionar senhas reais.
- Usar `<senha>` nos comandos do README.
- Não versionar arquivos temporários.
- Não versionar logs com dados sensíveis.
- Não versionar dumps de produção.

Sugestão de `.gitignore`:

```gitignore
*.log
*.tmp
*.bak
*.lck
*.err
DiagOutputDir/
.vscode/
```

> Não ignorar `.fmb` nem `.fmx`, pois a entrega do teste técnico solicita o fonte e o binário do Forms.

---

## 26. Evidências recomendadas para GitHub

Incluir prints demonstrando:

1. WebLogic AdminServer em execução.
2. `WLS_FORMS` em execução.
3. Forms carregado via FSAL.
4. Tela de cadastro com layout final.
5. Insert com ID gerado.
6. Pesquisa retornando registro.
7. Exclusão com sucesso.
8. Objetos `PKG_CLIENTE`, tabela e sequence válidos no banco.

---

## 27. Autor

**Walquiria de Avelar Mourão**

Projeto desenvolvido para demonstrar conhecimentos em Oracle Forms, PL/SQL, Oracle Database, WebLogic, Forms Services e organização de entrega técnica em GitHub.
