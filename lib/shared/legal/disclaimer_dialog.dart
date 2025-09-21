import 'package:crew_app/shared/legal/data/disclaimer.dart';
import 'package:flutter/material.dart';

Future<void> showDisclaimerDialog({
  required BuildContext context,
  required Disclaimer d,
  required VoidCallback onAccept,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false, // 强制阅读同意
    builder: (_) => AlertDialog(
      title: Text('${d.title}（v${d.version}）'),
      content: SingleChildScrollView(child: Text(d.content)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // 可选：退出到登录页/退出App
          child: const Text('退出'),
        ),
        ElevatedButton(
          onPressed: () {
            onAccept();
            Navigator.of(context).pop();
          },
          child: const Text('同意'),
        ),
      ],
    ),
  );
}
