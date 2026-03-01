PROCEDURE PRC_ATUALIZAR_CLIENTE(
    p_id          IN  TB_CLIENTE.ID_CLIENTE%TYPE,
    p_nome        IN  TB_CLIENTE.NOME%TYPE,
    p_email       IN  TB_CLIENTE.EMAIL%TYPE,
    p_cep         IN  TB_CLIENTE.CEP%TYPE,
    p_logradouro  IN  TB_CLIENTE.LOGRADOURO%TYPE,
    p_bairro      IN  TB_CLIENTE.BAIRRO%TYPE,
    p_cidade      IN  TB_CLIENTE.CIDADE%TYPE,
    p_uf          IN  TB_CLIENTE.UF%TYPE,
    p_ativo       IN  TB_CLIENTE.ATIVO%TYPE
);
END PKG_CLIENTE;

CREATE OR REPLACE PACKAGE BODY TREINAMENTO.PKG_CLIENTE AS
  --------------------------------------------------------------------
  -- Função: valida e-mail (1 = válido / 0 = inválido)
  --------------------------------------------------------------------
  FUNCTION FN_VALIDAR_EMAIL(p_email VARCHAR2) RETURN NUMBER IS
    v_email VARCHAR2(320);
  BEGIN
    IF p_email IS NULL THEN
      RETURN 0;
    END IF;
    v_email := TRIM(p_email);
    IF LENGTH(v_email) < 6 OR LENGTH(v_email) > 320 THEN
      RETURN 0;
    END IF;
    IF REGEXP_LIKE(
         v_email,
         '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
       )
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END FN_VALIDAR_EMAIL;
  --------------------------------------------------------------------
  -- Função: normaliza CEP (remove máscara e retorna 8 dígitos)
  -- Retorna NULL se inválido
  --------------------------------------------------------------------
  FUNCTION FN_NORMALIZAR_CEP(p_cep VARCHAR2) RETURN VARCHAR2 IS
    v_cep VARCHAR2(20);
  BEGIN
    IF p_cep IS NULL THEN
      RETURN NULL;
    END IF;
    v_cep := REGEXP_REPLACE(TRIM(p_cep), '[^0-9]', '');
    IF LENGTH(v_cep) <> 8 THEN
      RETURN NULL;
    END IF;
    RETURN v_cep;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END FN_NORMALIZAR_CEP;
  --------------------------------------------------------------------
  -- Procedure: valida dados de cliente (sem DML / sem commit)
  -- Regras:
  -- - NOME obrigatório
  -- - EMAIL válido (se informado)
  -- - CEP com 8 dígitos (se informado)
  -- - UF em lista BR (se informada)
  --
  -- Códigos:
  -- -20020 Nome obrigatório
  -- -20021 E-mail inválido
  -- -20022 CEP inválido
  -- -20023 UF inválida
  --------------------------------------------------------------------
  PROCEDURE PRC_VALIDAR_CLIENTE(
    p_nome  IN VARCHAR2,
    p_email IN VARCHAR2,
    p_cep   IN VARCHAR2,
    p_uf    IN VARCHAR2
  ) IS
    v_nome  VARCHAR2(200);
    v_email VARCHAR2(320);
    v_cep   VARCHAR2(20);
    v_uf    VARCHAR2(2);
  BEGIN
    v_nome  := TRIM(p_nome);
    v_email := TRIM(p_email);
    v_uf    := UPPER(TRIM(p_uf));
    -- NOME obrigatório
    IF v_nome IS NULL THEN
      RAISE_APPLICATION_ERROR(-20020, 'NOME é obrigatório.');
    END IF;
    -- EMAIL válido (se informado)
    IF v_email IS NOT NULL THEN
      IF FN_VALIDAR_EMAIL(v_email) = 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'EMAIL inválido.');
      END IF;
    END IF;
    -- CEP com 8 dígitos (se informado)
    IF p_cep IS NOT NULL THEN
      v_cep := FN_NORMALIZAR_CEP(p_cep);
      IF v_cep IS NULL THEN
        RAISE_APPLICATION_ERROR(-20022, 'CEP inválido. Informe 8 dígitos.');
      END IF;
    END IF;
    -- UF em lista BR (se informada)
    IF v_uf IS NOT NULL THEN
      IF NOT REGEXP_LIKE(
               v_uf,
               '^(AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SC|SP|SE|TO)$'
             )
      THEN
        RAISE_APPLICATION_ERROR(-20023, 'UF inválida. Informe uma UF brasileira válida.');
      END IF;
    END IF;
  END PRC_VALIDAR_CLIENTE;
  --------------------------------------------------------------------
  -- Procedure: deletar cliente por ID (sem commit)
  --------------------------------------------------------------------
  PROCEDURE PRC_DELETAR_CLIENTE(p_id NUMBER) IS
  BEGIN
    IF p_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20010, 'ID_CLIENTE deve ser informado para exclusão.');
    END IF;
    DELETE FROM TB_CLIENTE
     WHERE ID_CLIENTE = p_id;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20011, 'Cliente não encontrado para exclusão. ID=' || p_id);
    END IF;
  END PRC_DELETAR_CLIENTE;
  --------------------------------------------------------------------
  -- Procedure: listar clientes com filtros opcionais
  -- p_nome  -> filtro parcial em NOME
  -- p_email -> filtro parcial em EMAIL
  -- retorna SYS_REFCURSOR
  --------------------------------------------------------------------
  PROCEDURE PRC_LISTAR_CLIENTES(
    p_nome  IN VARCHAR2,
    p_email IN VARCHAR2,
    p_rc    OUT SYS_REFCURSOR
  ) IS
    v_nome  VARCHAR2(200);
    v_email VARCHAR2(320);
  BEGIN
    v_nome  := NULLIF(TRIM(p_nome), '');
    v_email := NULLIF(TRIM(p_email), '');
    OPEN p_rc FOR
      SELECT ID_CLIENTE,
             NOME,
             EMAIL,
             CEP,
             LOGRADOURO,
             BAIRRO,
             CIDADE,
             UF,
             ATIVO,
             DT_CRIACAO,
             DT_ATUALIZACAO
        FROM TB_CLIENTE
       WHERE (v_nome IS NULL  OR UPPER(NOME)  LIKE '%' || UPPER(v_nome)  || '%')
         AND (v_email IS NULL OR UPPER(EMAIL) LIKE '%' || UPPER(v_email) || '%')
       ORDER BY NOME, ID_CLIENTE;
  END PRC_LISTAR_CLIENTES;
  --------------------------------------------------------------------
  -- Procedure: inserir cliente (sem commit)
  -- Retorna o ID gerado em p_id
  --------------------------------------------------------------------
  PROCEDURE PRC_INSERIR_CLIENTE(
    p_nome        IN  TB_CLIENTE.NOME%TYPE,
    p_email       IN  TB_CLIENTE.EMAIL%TYPE,
    p_cep         IN  TB_CLIENTE.CEP%TYPE,
    p_logradouro  IN  TB_CLIENTE.LOGRADOURO%TYPE,
    p_bairro      IN  TB_CLIENTE.BAIRRO%TYPE,
    p_cidade      IN  TB_CLIENTE.CIDADE%TYPE,
    p_uf          IN  TB_CLIENTE.UF%TYPE,
    p_ativo       IN  TB_CLIENTE.ATIVO%TYPE,
    p_id          OUT TB_CLIENTE.ID_CLIENTE%TYPE
  ) IS
    v_email TB_CLIENTE.EMAIL%TYPE;
    v_cep   TB_CLIENTE.CEP%TYPE;
    v_uf    TB_CLIENTE.UF%TYPE;
    v_ativo TB_CLIENTE.ATIVO%TYPE;
  BEGIN
    v_email := NULLIF(LOWER(TRIM(p_email)), '');
    v_cep   := CASE WHEN p_cep IS NOT NULL THEN FN_NORMALIZAR_CEP(p_cep) END;
    v_uf    := NULLIF(UPPER(TRIM(p_uf)), '');
    v_ativo := NVL(p_ativo, 1);

    -- Reutiliza validações centralizadas
    PRC_VALIDAR_CLIENTE(
      p_nome  => p_nome,
      p_email => v_email,
      p_cep   => v_cep,
      p_uf    => v_uf
    );

    IF v_ativo NOT IN (0,1) THEN
      RAISE_APPLICATION_ERROR(-20024, 'ATIVO deve ser 0 ou 1.');
    END IF;

    INSERT INTO TB_CLIENTE (
      NOME, EMAIL, CEP, LOGRADOURO, BAIRRO, CIDADE, UF, ATIVO
    )
    VALUES (
      TRIM(p_nome), v_email, v_cep, p_logradouro, p_bairro, p_cidade, v_uf, v_ativo
    )
    RETURNING ID_CLIENTE INTO p_id;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20002, 'EMAIL já cadastrado.');
  END PRC_INSERIR_CLIENTE;

  --------------------------------------------------------------------
  -- Procedure: atualizar cliente (sem commit)
  --------------------------------------------------------------------
  PROCEDURE PRC_ATUALIZAR_CLIENTE(
    p_id          IN  TB_CLIENTE.ID_CLIENTE%TYPE,
    p_nome        IN  TB_CLIENTE.NOME%TYPE,
    p_email       IN  TB_CLIENTE.EMAIL%TYPE,
    p_cep         IN  TB_CLIENTE.CEP%TYPE,
    p_logradouro  IN  TB_CLIENTE.LOGRADOURO%TYPE,
    p_bairro      IN  TB_CLIENTE.BAIRRO%TYPE,
    p_cidade      IN  TB_CLIENTE.CIDADE%TYPE,
    p_uf          IN  TB_CLIENTE.UF%TYPE,
    p_ativo       IN  TB_CLIENTE.ATIVO%TYPE
  ) IS
    v_email TB_CLIENTE.EMAIL%TYPE;
    v_cep   TB_CLIENTE.CEP%TYPE;
    v_uf    TB_CLIENTE.UF%TYPE;
    v_ativo TB_CLIENTE.ATIVO%TYPE;
  BEGIN
    IF p_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'ID_CLIENTE obrigatório para atualização.');
    END IF;

    v_email := NULLIF(LOWER(TRIM(p_email)), '');
    v_cep   := CASE WHEN p_cep IS NOT NULL THEN FN_NORMALIZAR_CEP(p_cep) END;
    v_uf    := NULLIF(UPPER(TRIM(p_uf)), '');
    v_ativo := NVL(p_ativo, 1);

    -- Reutiliza validações centralizadas
    PRC_VALIDAR_CLIENTE(
      p_nome  => p_nome,
      p_email => v_email,
      p_cep   => v_cep,
      p_uf    => v_uf
    );

    IF v_ativo NOT IN (0,1) THEN
      RAISE_APPLICATION_ERROR(-20024, 'ATIVO deve ser 0 ou 1.');
    END IF;

    UPDATE TB_CLIENTE
       SET NOME           = TRIM(p_nome),
           EMAIL          = v_email,
           CEP            = v_cep,
           LOGRADOURO     = p_logradouro,
           BAIRRO         = p_bairro,
           CIDADE         = p_cidade,
           UF             = v_uf,
           ATIVO          = v_ativo,
           DT_ATUALIZACAO = SYSTIMESTAMP
     WHERE ID_CLIENTE = p_id;

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Cliente não encontrado para atualização. ID=' || p_id);
    END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20002, 'EMAIL já cadastrado.');
  END PRC_ATUALIZAR_CLIENTE;
END PKG_CLIENTE;