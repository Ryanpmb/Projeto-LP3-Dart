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
    - components
        Camada onde terá componetes visuais para auxílio como dialogs, modais, etc.
### Domains
#### Identidade
- Entities
    - User
    - Session
    - Credentials
#### Cofre
- Entities
    - Vault
    - ValutItem
    - ItemType
#### Crypto
- Entities
    - EncriptionKey
    - KeyDerivation
    - EncryptedData
#### Devices
- Entities
    - Device
#### Security
- Entitites
    - TFM
    - SecurityPolicy

# Testes

A suíte segue a pirâmide de testes, do mais isolado ao mais integrado:

| Camada | Pasta | O que cobre | Firebase |
|---|---|---|---|
| Unitário | `test/services/` | Métodos isolados dos serviços (`AuthService`, `GuardiaoService`) | Mockado |
| Widget | `test/views/` | Telas isoladas (`Login`, `Register`, `Home`) | Mockado |
| Fluxo/feature | `test/flows/` | Jornada entre as telas reais ligadas por rotas | Mockado |
| Integração | `integration_test/` | Serviços reais contra o Firebase Emulator | Emulador |

Os mocks usam `mockito` e são gerados por código. Os arquivos `*.mocks.dart`
ficam no `.gitignore`, então precisam ser (re)gerados após clonar o projeto.

## Rodando os testes unitários, de widget e de fluxo

```bash
# 1. Instalar as dependências
flutter pub get

# 2. Gerar os mocks (cria os arquivos *.mocks.dart)
dart run build_runner build

# 3. Rodar toda a suíte (test/)
flutter test
```

## Rodando os testes de integração (Firebase Emulator)

Os testes em `integration_test/` usam as instâncias **reais** de `FirebaseAuth`
e `FirebaseFirestore` apontadas para o Firebase Emulator Suite — nenhum dado
toca o projeto de produção (`guardians-app-br`).

Pré-requisitos: **Node.js**, **Java JDK** (exigido pelo emulador do Firestore),
o Firebase CLI e o **chromedriver** (para rodar na web).

```bash
# 1. Instalar o Firebase CLI (uma única vez)
npm install -g firebase-tools

# 2. Subir os emuladores em modo "demo" (offline, sem credenciais reais)
firebase emulators:start --project demo-guardians --only auth,firestore

# 3. Em outro terminal, subir o chromedriver (necessário para a web)
chromedriver --port=4444

# 4. Em outro terminal, rodar o teste de integração com flutter drive
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/guardiao_flow_test.dart \
  -d chrome
```

Detalhes da configuração:
- O `projectId: demo-guardians` faz o emulador rodar offline; por isso não é
  necessário o `firebase_options.dart` de produção (que está no `.gitignore`).
- As portas dos emuladores (`auth: 9099`, `firestore: 8080`) e as regras
  (`firestore.rules`) estão declaradas no `firebase.json`.
- O `firestore.rules` é permissivo de propósito — vale **apenas** para o
  emulador e os testes locais, nunca para produção.
- Use `flutter drive` (não `flutter test`) para a web: o Flutter não suporta
  integration tests via `flutter test -d chrome` (erro "Web devices are not
  supported for integration tests yet"). O `flutter drive` + chromedriver é o
  caminho oficial e é o mesmo que a pipeline executa.
- Para rodar headless (como no CI), troque `-d chrome` por
  `-d web-server --browser-name=chrome`.
- Em mobile/desktop (Android, `-d windows`, etc.) o `flutter test
  integration_test/...` funciona normalmente — a restrição é só para a web.