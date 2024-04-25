import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:telesms/services/storage_service.dart';

class ChatIdNotifier extends StateNotifier<String> {
  final StorageService storageService;

  ChatIdNotifier(this.storageService) : super('') {
    init();
  }

  Future<void> init() async {
    String value = await storageService.read(key: 'chatId') ?? "";
    state = value;
  }

  void updateChatId(String value) {
    state = value;
    storageService.write(key: 'chatId', value: value);
  }
}

class TelegramBotTokenNotifier extends StateNotifier<String> {
  final StorageService storageService;

  TelegramBotTokenNotifier(this.storageService) : super('') {
    init();
  }

  Future<void> init() async {
    String value = await storageService.read(key: 'telegramBotToken') ?? "";
    state = value;
  }

  void updateTelegramBotToken(String value) {
    state = value;
    storageService.write(key: 'telegramBotToken', value: value);
  }
}

final chatIdNotifierProvider =
    StateNotifierProvider<ChatIdNotifier, String>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ChatIdNotifier(storageService);
});

final telegramBotTokenNotifierProvider =
    StateNotifierProvider<TelegramBotTokenNotifier, String>((ref) {
  final storageService = ref.watch(storageServiceProvider);

  return TelegramBotTokenNotifier(storageService);
});
