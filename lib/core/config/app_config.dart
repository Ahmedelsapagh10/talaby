class AppConfig {
  const AppConfig._();

  static const ownerId = String.fromEnvironment(
    'OWNER_ID',
    defaultValue: 'qmxG99t1LAfLbikszDWWoqnxYPA3',
  );
}
