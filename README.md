# Projeto Forms + PL/SQL – Cadastro de Clientes

## 1. Descrição

Projeto de **CRUD de clientes** desenvolvido com **Oracle Forms 12c** e **Oracle Database (PL/SQL)**, como teste técnico.

A solução contempla:

* **Interface em Oracle Forms** (`.fmb` e `.fmx`)
* **Persistência em Oracle Database**
* **Scripts SQL versionados** para recriação do ambiente
* **Package PL/SQL** com regras/validações
* **Dados de teste** para carga inicial

---

## 2. Objetivo do Projeto

Implementar um cadastro de clientes com operações básicas de manutenção de dados:

* **Novo**
* **Salvar**
* **Excluir**
* **Cancelar**
* **Pesquisar**

Além disso, o projeto foi organizado para permitir:

* recriação do banco via scripts (`sql/`)
* manutenção futura por meio de extração de DDL (`scripts/extrair_ddls.sql`)
* execução local do formulário em ambiente Oracle Forms Services (`frmservlet`)

---

## 3. Tecnologias Utilizadas

### Banco de Dados

* **Oracle Database XE 21c** (reaproveitado de instalação já existente na máquina)

### Front-end (ERP/Desktop)

* **Oracle Forms Builder 12c (12.2.1.4.0)**

### Linguagem / Regras

* **PL/SQL**
* **SQL**

### Ferramentas de apoio

* **DBeaver** (consultas e exportação de DDL/dados)
* **VSCode** (organização do projeto/scripts)
* **SQL*Plus / SQLcl** (execução de scripts e extração de DDL, quando necessário)

---

## 4. Decisões Técnicas e Ambiente Utilizado

### 4.1 Ambiente efetivamente utilizado

O projeto foi desenvolvido e testado em ambiente local Windows, utilizando:

* **Oracle Database XE 21c** (PDB `XEPDB1`)
* **Schema/owner dedicado:** `TREINAMENTO`
* **Oracle Forms Builder 12c (12.2.1.4.0)**
* **JDK 8**
* **Execução via Forms Services (`frmservlet`)**, com servidor local de aplicações (WebLogic)

> **Observação:** a opção **“Executar em Standalone”** no Forms Builder foi mantida **desabilitada**.

### 4.2 Escolha do Oracle Forms 12c

Foi utilizada a versão **Oracle Forms 12c (12.2.1.4.0)** por apresentar **melhor estabilidade no ambiente local de desenvolvimento/testes** em comparação com tentativas em versões mais recentes (ex.: 14c), considerando o contexto da máquina e da configuração disponível.

### 4.3 Reaproveitamento do Oracle XE 21c

O **Oracle XE 21c** já estava instalado e funcional na máquina.
Para o projeto, foi criado apenas o **owner/schema `TREINAMENTO`**, isolando os objetos da aplicação.

---

## 5. Estrutura do Projeto

```text
projeto-forms-cliente/
├─ forms/
│  ├─ cliente.fmb
│  └─ cliente.fmx
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
└─ README.md
```

> **Observação:** backups locais (`cliente_backup*.fmb/.fmx`) podem existir durante o desenvolvimento, mas a entrega final prioriza os arquivos principais (`cliente.fmb` e `cliente.fmx`).

---

## 6. Objetos de Banco de Dados Criados

No schema **`TREINAMENTO`**, foram criados os seguintes objetos principais:

* **Tabela:** `TB_CLIENTE`
* **Sequence:** `SEQ_CLIENTE`
* **Trigger(s):** `TRG_CLIENTE_BI` *(e outros triggers do projeto, se aplicável)*
* **Package:** `PKG_CLIENTE`

  * **Spec**
  * **Body**

> Os objetos foram validados no schema `TREINAMENTO` e estavam em status **VALID** durante os testes.

---

## 7. Formulário Oracle Forms (Estrutura)

### Form

* `F_CLIENTE_CADASTRO`

### Bloco de Dados

* `BLK_CLIENTE`

### Canvas

* `CV_CLIENTE`

### Itens (campos)

* `CEP`
* `ID_CLIENTE`
* `NOME`
* `EMAIL_FIX`
* `LOGRADOURO`
* `BAIRRO`
* `CIDADE`
* `UF`
* `ATIVO`

### Botões

* `BTN_NOVO`
* `BTN_SALVAR`
* `BTN_EXCLUIR`
* `BTN_CANCELAR`
* `BTN_PESQUISAR`

### Triggers relevantes (Forms)

* `WHEN-NEW-FORM-INSTANCE`
* `ON-ERROR`
* `PRE-INSERT` (bloco)
* `PRE-UPDATE` (bloco)
* `WHEN-BUTTON-PRESSED` nos botões de ação

### Alerta

* `ALR_CONFIRMA_EXCLUIR` (confirmação de exclusão)

---

## 8. Funcionalidades Implementadas (CRUD)

### Novo

Prepara o formulário para inclusão de um novo registro.

### Salvar

Grava o registro atual no banco de dados (insert/update conforme contexto).

### Excluir

Solicita confirmação via alerta e remove o registro.

### Cancelar

Cancela alterações pendentes.

### Pesquisar

Permite localizar registros (conforme lógica implementada no Forms / bloco de dados).

---

## 9. Validações e Regras de Negócio (PL/SQL)

As validações foram concentradas na camada PL/SQL (package), e não apenas na UI.

Exemplos de validações/regras implementadas:

* campos obrigatórios
* validação de e-mail
* validação/normalização de CEP (quando aplicável)
* validação de UF
* operações encapsuladas em package (`PKG_CLIENTE`)

> Erros de validação podem ser tratados via `RAISE_APPLICATION_ERROR`, permitindo retorno consistente para a interface Forms.

---

## 10. Pré-requisitos para Execução

Para reproduzir o projeto localmente:

* Oracle Database (preferencialmente **XE 21c**, ou outro Oracle compatível)
* Schema/owner para criação dos objetos (neste projeto: `TREINAMENTO`)
* Oracle Forms Builder 12c (12.2.1.4.0)
* JDK 8
* Domínio Oracle Forms/WebLogic configurado
* Oracle Forms Services habilitado (execução via `frmservlet`)

---

## 11. Criação do Schema (Owner) – Exemplo

> Ajuste a senha conforme seu ambiente.

```sql
CREATE USER TREINAMENTO IDENTIFIED BY sua_senha
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

GRANT CONNECT, RESOURCE TO TREINAMENTO;
```

> Em alguns ambientes, privilégios adicionais podem ser necessários conforme política/local setup.

---

## 12. Ordem de Execução dos Scripts SQL

Executar no schema **`TREINAMENTO`** (ou ajustando owner conforme necessidade).

### Ordem recomendada

1. `00_drop_objetos.sql` *(opcional – limpeza do ambiente)*
2. `01_create_tb_cliente.sql`
3. `02_create_seq_cliente.sql`
4. `03_create_triggers_tb_cliente.sql`
5. `04_package_spec.sql`
6. `05_package_body.sql`
7. `06_dados_teste.sql`

### Exemplo (SQL*Plus / SQLcl)

```sql
@sql/00_drop_objetos.sql
@sql/01_create_tb_cliente.sql
@sql/02_create_seq_cliente.sql
@sql/03_create_triggers_tb_cliente.sql
@sql/04_package_spec.sql
@sql/05_package_body.sql
@sql/06_dados_teste.sql
```

---

## 13. Observações sobre o `00_drop_objetos.sql`

O script `00_drop_objetos.sql` foi montado para permitir **reexecução segura** do setup (script idempotente), utilizando blocos `BEGIN ... EXECUTE IMMEDIATE ... EXCEPTION ... END;` para evitar falha quando o objeto ainda não existe.

Isso facilita:

* testes repetidos
* rebuild do ambiente
* validação da ordem de criação dos objetos

---

## 14. Inicialização do Ambiente Oracle Forms (WebLogic)

Antes de executar o formulário via `frmservlet`, é necessário subir os servidores do domínio Oracle Forms/WebLogic **na ordem correta**.

### Ordem de inicialização

1. **NodeManager** *(quando aplicável / recomendado)*
2. **AdminServer (WebLogic)**
3. **Managed Server `WLS_FORMS`**

> Exemplo de pasta do domínio (Windows):
> `C:\Oracle\INFRA12\user_projects\domains\base_domain\bin`

### 14.1 Iniciar o NodeManager (opcional/recomendado)

Abra um **CMD** na pasta `...\domains\base_domain\bin` e execute:

```bat
startNodeManager.cmd
```

### 14.2 Iniciar o WebLogic (AdminServer)

No mesmo diretório (`...\bin`), execute:

```bat
startWebLogic.cmd
```

> Aguarde o **AdminServer** subir completamente antes de iniciar o `WLS_FORMS`.

### 14.3 Iniciar o Managed Server do Forms (`WLS_FORMS`)

Abra **outro CMD** (nova janela), na mesma pasta `...\domains\base_domain\bin`, e execute:

```bat
startManagedWebLogic.cmd WLS_FORMS http://localhost:7001
```

> Se a porta do AdminServer for diferente no seu ambiente, ajuste a URL (`7001` é a porta mais comum).

### 14.4 Verificações úteis (opcional)

* **Console WebLogic:** `http://localhost:7001/console`
* **Forms Runtime (`frmservlet`):** `http://localhost:9001/forms/frmservlet?config=default`

> As portas (`7001`, `9001`) podem variar conforme a configuração local do domínio.

---

## 15. Execução do Oracle Forms (sem Standalone)

O formulário foi executado via **Oracle Forms Services**, utilizando URL local do `frmservlet`, por exemplo:

```text
http://localhost:9001/forms/frmservlet?config=default
```

### Observações

* **Modo standalone não foi utilizado**
* O runtime foi configurado nas preferências do Forms Builder (aba **Runtime**)
* O formulário foi compilado com sucesso, gerando o binário `.fmx`

---

## 16. Como Abrir e Testar o Formulário

1. Abrir o arquivo:

   * `forms/cliente.fmb`

2. Compilar o módulo:

   * **Program > Compile Module** (ou equivalente no Builder)

3. Confirmar geração/atualização do binário:

   * `forms/cliente.fmx`

4. Subir o ambiente WebLogic/Forms (AdminServer + `WLS_FORMS`) conforme seção **14**

5. Executar via runtime (`frmservlet`)

6. Testar fluxo CRUD:

   * **Novo** → preencher → **Salvar**
   * **Pesquisar** → localizar registro
   * **Editar** → **Salvar**
   * **Excluir** → confirmar alerta
   * **Cancelar** → desfazer alterações pendentes

---

## 17. Extração de DDL e Organização dos Scripts

Foi incluído um script utilitário:

* `scripts/extrair_ddls.sql`

Objetivo:

* facilitar a extração de DDL dos objetos do schema
* manter a pasta `sql/` alinhada com os objetos efetivamente compilados/válidos no banco

### Observação importante

Durante a extração com `DBMS_METADATA`, é necessário garantir:

* conexão no **schema correto** (`TREINAMENTO`) ou
* informar o owner explicitamente nas consultas

Isso evita problemas como tentar extrair objetos a partir do schema `SYS`.

---

## 18. Dificuldades Encontradas (Resumo)

Durante a montagem do ambiente e execução do teste, os principais pontos de atenção foram:

* configuração do **Oracle Forms Builder 12c**
* execução via **Forms Services** (sem standalone)
* necessidade de subir corretamente o **WebLogic/AdminServer** e o **`WLS_FORMS`**
* ajustes de layout e organização dos componentes no canvas
* extração de scripts DDL a partir do schema correto (`TREINAMENTO`)
* cuidados com exportação de arquivos SQL em ferramentas de apoio (ex.: extensão duplicada `.sql.sql` em exportações automáticas)

Todos os pontos foram ajustados e o formulário foi compilado/testado sem erros.

---

## 19. Status da Entrega

✅ Formulário desenvolvido e compilado sem erros (`.fmb` + `.fmx`)
✅ Scripts SQL organizados e versionados
✅ Package PL/SQL (spec/body) incluído
✅ Dados de teste exportados
✅ Estrutura de projeto pronta para avaliação/reexecução

---

## 20. Autor(a)

**Walquiria de Avelar Mourão**
Projeto desenvolvido como teste técnico (Oracle Forms + PL/SQL).
