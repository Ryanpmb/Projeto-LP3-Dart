import 'package:integration_test/integration_test_driver.dart';

// Driver usado pelo `flutter drive` para executar os testes de
// integration_test/ em um navegador (necessário para rodar no CI via web).
Future<void> main() => integrationDriver();
