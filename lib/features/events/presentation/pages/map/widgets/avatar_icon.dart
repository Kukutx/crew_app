// widgets/avatar_icon.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/state/user/avatar/avatar_provider.dart';
import '../../../../../../core/state/auth/auth_providers.dart';

class AvatarIcon extends ConsumerWidget {
  final void Function(bool authed) onTap;
  const AvatarIcon({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customPath = ref.watch(avatarProvider);
    final authState = ref.watch(authStateProvider);
    final fa.User? user = authState.value ?? ref.watch(currentUserProvider);

    ImageProvider<Object>? img;
    if (customPath != null && user != null) {
      img = FileImage(File(customPath));
    } else if ((user?.photoURL?.isNotEmpty ?? false)) {
      img = NetworkImage(user!.photoURL!);
    }

    return InkResponse(
      radius: 22,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () => onTap(user != null),
      child: CrewAvatar(
        radius: 16,
        backgroundImage: img,
        backgroundColor: Colors.grey.withValues(alpha: .12),
        foregroundColor: Colors.grey,
        child: img == null
            ? const Icon(
                Icons.person,
                size: 18,
              )
            : null,
      ),
    );
  }
}
