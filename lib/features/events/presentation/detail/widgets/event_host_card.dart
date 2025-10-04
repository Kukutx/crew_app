import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EventHostCard extends StatelessWidget {
  final AppLocalizations loc;
  final String name;
  final String bio;
  final String? avatarUrl;
  final VoidCallback onTapProfile;
  final VoidCallback onToggleFollow;
  final bool isFollowing;

  const EventHostCard({
    super.key,
    required this.loc,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.onTapProfile,
    required this.onToggleFollow,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTapProfile,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange.shade50,
                backgroundImage: _buildAvatarImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: isFollowing
                    ? OutlinedButton.icon(
                        onPressed: onToggleFollow,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(loc.action_following),
                      )
                    : ElevatedButton.icon(
                        onPressed: onToggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_1, size: 18),
                        label: Text(loc.action_follow),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _buildAvatarImage() {
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImageProvider(url);
    }
    return const AssetImage('assets/images/icons/crew.png');
  }
}
