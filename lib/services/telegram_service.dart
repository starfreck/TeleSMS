import 'dart:convert';
import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:telesms/models/message.dart';
import 'package:telesms/providers/telegram_data_provider.dart';

class TelegramService {
  static late String chatId;
  static late String telegramBotToken;

  static init() async {
    final container = ProviderContainer();
    // get the container and get values from the storage service
    await container.read(chatIdNotifierProvider.notifier).init();
    await container.refresh(telegramBotTokenNotifierProvider.notifier).init();
    // Assing values from the storage service
    chatId = container.read(chatIdNotifierProvider);
    telegramBotToken = container.read(telegramBotTokenNotifierProvider);
    // Disposing the container
    container.dispose();
  }

  static Future<bool> sendOnTelegram(Message message) async {
    // Load Token and chat id from the storage
    await init();

    log(chatId);
    log(telegramBotToken);

    if (chatId.isEmpty || telegramBotToken.isEmpty) {
      return false;
    }

    String url =
        "https://api.telegram.org/bot$telegramBotToken/sendMessage?chat_id=$chatId&text=${message.toString()}";

    log(url);
    final response = await http.get(Uri.parse(url), headers: {
      'Content-type': 'text/plain; charset=utf-8',
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      log(response.body);
      return responseData['ok'];
    } else {
      log(response.body);
      throw Exception('Failed to send message');
    }
  }
}
