class KeyDerivationParamsEntity {
  final String salt;
  final int iterations;
  final int memory;
  final int parallelism;

  KeyDerivationParamsEntity({
    required this.salt,
    required this.iterations,
    required this.memory,
    required this.parallelism,
  });
}