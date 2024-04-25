import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Message;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readsms/readsms.dart';
import 'package:telesms/models/message.dart';
import 'package:telesms/services/telegram_service.dart';

final backgroundServiceProvider =
    Provider<BackgroundService>((ref) => BackgroundService());

class BackgroundService {
  static final smsReader = Readsms();

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    final channel = _createNotificationChannel();
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await _initializePlatform(flutterLocalNotificationsPlugin);
    await _createNotification(flutterLocalNotificationsPlugin, channel);
    await _configureService(service, channel);
  }

  AndroidNotificationChannel _createNotificationChannel() {
    return const AndroidNotificationChannel(
      'telesms', // id
      'TeleSMS Service', // title
      description:
          'This channel is used for TeleSMS notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );
  }

  Future<void> _initializePlatform(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }
  }

  Future<void> _createNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      AndroidNotificationChannel channel) async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _configureService(FlutterBackgroundService service,
      AndroidNotificationChannel channel) async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: false,
        notificationChannelId: channel.id,
        initialNotificationTitle: 'TeleSMS Service',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    onUserStart(service);
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    onUserStart(service);
    return true;
  }

  // Write the code which you want to run in the background
  static void onUserStart(ServiceInstance service) {
    service.on('stopService').listen((event) {
      log("Stopping Service....");
      service.stopSelf();
    });

    // Listen to Incoming SMS messages
    smsReader.read();
    smsReader.smsStream.listen(handleNewSms);
    log("Starting Service....");
  }

  // Process the SMS message here...
  static void handleNewSms(SMS sms) async {
    log('Received new SMS from : ${sms.sender}');
    log('Received new SMS time : ${sms.timeReceived}');
    log('Received new SMS body : ${sms.body}');

    // Send to Telegram
    TelegramService.sendOnTelegram(Message.fromSMS(sms));
  }
}
