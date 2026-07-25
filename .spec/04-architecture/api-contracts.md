# API Contracts

## Convenções gerais
<!-- Base URL, versionamento, autenticação, formato de resposta -->

## Erros padrão
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Descrição legível",
    "details": {}
  }
}
```

## Endpoints

### Template

```
#### [METHOD] /path
- **@spec:** TASK-ID
- **Descrição:** o que faz
- **Auth:** required | public
- **Request body:** schema
- **Response 200:** schema
- **Erros:** lista de códigos possíveis
```

---

<!-- Documente os endpoints abaixo -->
