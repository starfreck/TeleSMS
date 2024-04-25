import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider = Provider.autoDispose((ref) => Permission.sms);

class PermissionHandler extends HookConsumerWidget {
  const PermissionHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(permissionProvider);
    final permissionStatus = useState<PermissionStatus?>(null);

    useEffect(() {
      permission.status.then((status) => permissionStatus.value = status);
      return null;
    }, []);

    return permissionStatus.value == null
        ? const CircularProgressIndicator()
        : permissionStatus.value!.isGranted
            ? const Text(
                'Permission granted to read SMS...',
                style: TextStyle(fontSize: 20),
              )
            : ElevatedButton(
                onPressed: () async {
                  final status = await permission.request();
                  permissionStatus.value = status;
                  if (!status.isGranted) {
                    // Keep asking for permission
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Permission not granted'),
                        content: const Text(
                            'This app needs SMS permission to function.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Ask Again'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              final status = await permission.request();
                              permissionStatus.value = status;
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Request permission'),
              );
  }
}
