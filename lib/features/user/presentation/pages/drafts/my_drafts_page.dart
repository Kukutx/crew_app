import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/skeleton/skeleton_box.dart';
import 'package:flutter/material.dart';

class MyDraftsPage extends StatelessWidget {
  const MyDraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.my_drafts_title)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const _DraftCardSkeleton(),
                  childCount: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftCardSkeleton extends StatelessWidget {
  const _DraftCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: const SkeletonBox(borderRadius: BorderRadius.zero),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 16, width: 140, borderRadius: BorderRadius.all(Radius.circular(4))),
                SizedBox(height: 8),
                SkeletonBox(height: 14, width: 100, borderRadius: BorderRadius.all(Radius.circular(4))),
                SizedBox(height: 12),
                SkeletonBox(height: 32, borderRadius: BorderRadius.all(Radius.circular(16))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
