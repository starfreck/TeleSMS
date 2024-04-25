import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InputBox extends HookWidget {
  final bool readOnly;
  final bool isPasswordInputBox;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextEditingController controller;

  const InputBox({
    super.key,
    required this.labelText,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.isPasswordInputBox = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPasswordVisibleState = useState(true);

    return TextFormField(
      readOnly: readOnly,
      controller: controller,
      obscureText: isPasswordInputBox ? isPasswordVisibleState.value : false,
      decoration: InputDecoration(
        labelText: (!readOnly) ? labelText : null,
        hintText: hintText ?? labelText,
        contentPadding: const EdgeInsets.all(15),
        border: InputBorder.none,
        focusedBorder: (!readOnly)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              )
            : null,
        enabledBorder: (!readOnly)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  width: 1.0,
                ),
              )
            : null,
        prefixIcon: Icon(
          prefixIcon,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: isPasswordInputBox
            ? IconButton(
                icon: Icon(
                  isPasswordVisibleState.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  isPasswordVisibleState.value = !isPasswordVisibleState.value;
                },
              )
            : null,
      ),
    );
  }
}
