// widgets/avatar_icon.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/state/avatar_provider.dart';

class AvatarIcon extends ConsumerStatefulWidget  {
  final void Function(bool authed) onTap;
  const AvatarIcon({super.key, required this.onTap});

  @override
  ConsumerState<AvatarIcon> createState() => _AvatarIconState();
}

class _AvatarIconState extends ConsumerState<AvatarIcon> {
  fa.User? _user;
  @override
  void initState() {
    super.initState();
    // 监听用户状态变化
    _user = fa.FirebaseAuth.instance.currentUser;
    fa.FirebaseAuth.instance.authStateChanges().listen((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customPath = ref.watch(avatarProvider);
    ImageProvider? img;
    if (customPath != null && _user != null) {
      img = FileImage(File(customPath));
    } else if ((_user?.photoURL?.isNotEmpty ?? false)) {
      img = NetworkImage(_user!.photoURL!);
    }

    return InkResponse(
      radius: 22,
      onTap: () => widget.onTap(_user != null),
      child: CircleAvatar(
        radius: 16,
        foregroundImage: img,
        child: const Icon(Icons.person, size: 18, color: Colors.grey),
      ),
    );
  }
}
