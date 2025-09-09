// widgets/avatar_icon.dart
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';

class AvatarIcon extends StatefulWidget {
  final void Function(bool authed) onTap;
  const AvatarIcon({super.key, required this.onTap});

  @override
  State<AvatarIcon> createState() => _AvatarIconState();
}

class _AvatarIconState extends State<AvatarIcon> {
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

  // @override
  // Widget build(BuildContext context) {
  //   final photo = _user?.photoURL;
  //   final hasPhoto = photo != null && photo.isNotEmpty;

  //   return InkResponse(
  //     radius: 22,
  //     onTap: () => widget.onTap(_user != null),
  //     child: CircleAvatar(
  //       radius: 16,
  //       backgroundColor: Colors.grey.shade200,
  //       foregroundImage: hasPhoto ? NetworkImage(photo!) : null,
  //       onForegroundImageError: hasPhoto ? (_, __) {} : null,
  //       child: const Icon(Icons.person, size: 18),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 22,
      onTap: () => widget.onTap(_user != null),
      child: CircleAvatar(
        radius: 16,
        foregroundImage: (_user?.photoURL?.isNotEmpty ?? false)
            ? NetworkImage(_user!.photoURL!)
            : null,
        child: const Icon(Icons.person, size: 18, color: Colors.grey),
      ),
    );
  }
}
