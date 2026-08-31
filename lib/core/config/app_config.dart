class AppConfig {
  const AppConfig._();

  static const ownerId = String.fromEnvironment(
    'OWNER_ID',
    defaultValue: 'demo_store',
  );
}
