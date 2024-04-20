import 'package:flutter/material.dart';
import 'package:flutter_app/generated/sdk.dart';
import 'package:flutter_app/src/dev/mock_sdk.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Create a single instance of the service SDK and pass it to Widgets in a provider
  late final ExampleService service;
  const String serviceImplementation = String.fromEnvironment("SERVICE");
  if (serviceImplementation == "real") {
    const String hostName = String.fromEnvironment("SERVICE_HOSTNAME");
    service = ExampleServiceImpl(hostName);
  } else if (serviceImplementation == "mock") {
    // or use a mock implementation for development and testing
    service = MockExampleService();
  }

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(buildApp(settingsController, service));
}

Widget buildApp(SettingsController settingsController, ExampleService exampleService) {
  return MultiProvider(
    providers: [
      Provider<ExampleService>(create: (_) => exampleService),
    ],
    child: MyApp(settingsController: settingsController),
  );
}
