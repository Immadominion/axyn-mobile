import 'bootstrap.dart';
import 'core/config/environment_loader.dart';

/// Main entry point - always runs on mainnet
/// Debug mode is determined by Flutter's kDebugMode constant
Future<void> main() async {
  // Load environment variables from .env.prod (mainnet only)
  await EnvironmentLoader.load();

  // Create config from environment
  final config = EnvironmentLoader.createConfig();

  await bootstrap(config);
}
