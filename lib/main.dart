import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:telesms/app/app.dart';
import 'package:telesms/services/background_service.dart';
import 'package:telesms/services/socket_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Get Provider Container
  final container = ProviderContainer();
  // Get the background service object and start the background service
  await container.read(backgroundServiceProvider).initializeService();
  // Initialize the socket service
  container.read(socketServiceProvider);
  // Start the application
  runApp(const ProviderScope(child: App()));
}
