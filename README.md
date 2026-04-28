# Arquitetura
Arquitetura em camadas baseada seguindo conceitos do DDD adaptado, e a tese do TDD, com testes em primeiro lugar antes de qualquer linha de código.

## Estrutura
Seguindo conceitos do DDD tivemos a ideia de seguir a seguinte estruturação de pastas:
- domain
    Camada de domínio onde ficará o core da aplicação, como suas entidades/models.
    - services:
        Onde ficará a regra de negócio pesada referente aquele domínio respectivo.
    - repositories:
        Onde ficará as interfaces da aplicação e tratativas com bancos referente ao dominio.
    - entities:
        Onde fica a entidade/model específica (classe respectiva do domínio).
- infrastructure
    Camada de infraestrutura da aplicação, onde é responsável por todas as informações de infraestrutura, como por exemplo
    conexões ao banco, conexão ao firebase e serviços externos da aplicação e que são envolvidos há aplicação.
- presentation
    - view:
        Camada onde estará as telas.
    - components:
        Camada onde terá componetes visuais para auxílio como dialogs, modais, etc.