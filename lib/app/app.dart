import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:telesms/providers/permission_provider.dart';
import 'package:telesms/providers/telegram_data_provider.dart';
import 'package:telesms/widgets/input_box.dart';

class App extends HookConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String chatIdState = ref.watch(chatIdNotifierProvider);
    final String telegramBotTokenState =
        ref.watch(telegramBotTokenNotifierProvider);

    ValueNotifier<bool> isRunning = useState(true);
    ValueNotifier<bool> isEditing = useState(false);
    TextEditingController controller1 =
        useTextEditingController(text: chatIdState);
    TextEditingController controller2 =
        useTextEditingController(text: telegramBotTokenState);

    useEffect(() {
      controller1.text = chatIdState;
      controller2.text = telegramBotTokenState;
      return null;
    }, [chatIdState, telegramBotTokenState]);

    void cancleChanges() {
      controller1.text = chatIdState;
      controller2.text = telegramBotTokenState;
      isEditing.value = !isEditing.value;
    }

    void saveAndEdit() async {
      if (isEditing.value) {
        // Save the changes
        ref
            .read(chatIdNotifierProvider.notifier)
            .updateChatId(controller1.text);

        ref
            .read(telegramBotTokenNotifierProvider.notifier)
            .updateTelegramBotToken(controller2.text);
      }
      isEditing.value = !isEditing.value;
      // Start and stop service here
    }

    Future<void> startAndStopBackgroudService() async {
      final service = FlutterBackgroundService();
      var status = await service.isRunning();
      if (status) {
        service.invoke("stopService");
      } else {
        service.startService();
      }
      isRunning.value = status;
    }

    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TeleSMS'),
        ),
        body: Column(
          children: [
            Card(
              color: Theme.of(context).primaryColor,
              margin: const EdgeInsets.all(30),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    InputBox(
                      readOnly: !isEditing.value,
                      labelText: "Telegram ID",
                      controller: controller1,
                      prefixIcon: Icons.perm_identity,
                    ),
                    const SizedBox(height: 10),
                    InputBox(
                      readOnly: !isEditing.value,
                      labelText: "Telegram Bot Token",
                      controller: controller2,
                      prefixIcon: Icons.telegram_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const PermissionHandler(),
          ],
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 18, right: 5),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                (isEditing.value)
                    ? FloatingActionButton(
                        onPressed: cancleChanges,
                        child: const Icon(Icons.close),
                      )
                    : const SizedBox(),
                const SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: saveAndEdit,
                  child: Icon(isEditing.value ? Icons.save : Icons.edit),
                ),
                const SizedBox(height: 20),
                (chatIdState.isNotEmpty &&
                        telegramBotTokenState.isNotEmpty &&
                        !isEditing.value)
                    ? FloatingActionButton(
                        onPressed: startAndStopBackgroudService,
                        child: Icon(
                            isRunning.value ? Icons.play_arrow : Icons.stop),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
