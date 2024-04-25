import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:telesms/app/app.dart';
import 'package:telesms/services/background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get Provider Container
  final container = ProviderContainer();
  // Get the background service object and start the background service
  await container.read(backgroundServiceProvider).initializeService();
  // Start the application
  runApp(const ProviderScope(child: App()));
}
