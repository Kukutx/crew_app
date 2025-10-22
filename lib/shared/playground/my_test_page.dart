import 'package:flutter/material.dart';

class MyTestPage extends StatefulWidget {
  const MyTestPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<MyTestPage> createState() => _MyTestPageState();
}

class _MyTestPageState extends State<MyTestPage> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("test page"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: Text("Test Page"),
    );
  }
}