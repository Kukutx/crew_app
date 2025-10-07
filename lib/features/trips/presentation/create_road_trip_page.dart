import 'package:flutter/material.dart';

class CreateRoadTripPage extends StatelessWidget {
  const CreateRoadTripPage({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建活动行程'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onClose,
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '在这里规划你的旅行或活动。\n稍后将补充具体内容。',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
