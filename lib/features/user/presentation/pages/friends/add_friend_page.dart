import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/skeleton/skeleton_box.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.add_friend_title),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: const SliverToBoxAdapter(
                child: _AddFriendSkeletonContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFriendSkeletonContent extends StatelessWidget {
  const _AddFriendSkeletonContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SearchBarSkeleton(),
        SizedBox(height: 24),
        _QuickActionsSkeleton(),
        SizedBox(height: 24),
        _InterestChipsSkeleton(),
        SizedBox(height: 32),
        SkeletonBox(width: 140, height: 20, borderRadius: BorderRadius.all(Radius.circular(6))),
        SizedBox(height: 16),
        _SuggestionGridSkeleton(),
        SizedBox(height: 32),
        SkeletonBox(width: 160, height: 20, borderRadius: BorderRadius.all(Radius.circular(6))),
        SizedBox(height: 16),
        _ContactListSkeleton(),
      ],
    );
  }
}

class _SearchBarSkeleton extends StatelessWidget {
  const _SearchBarSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: SkeletonBox(height: 16, borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 60, height: 16, borderRadius: BorderRadius.all(Radius.circular(4))),
        ],
      ),
    );
  }
}

class _QuickActionsSkeleton extends StatelessWidget {
  const _QuickActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _QuickActionCardSkeleton()),
        SizedBox(width: 12),
        Expanded(child: _QuickActionCardSkeleton()),
      ],
    );
  }
}

class _QuickActionCardSkeleton extends StatelessWidget {
  const _QuickActionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          SizedBox(height: 16),
          SkeletonBox(width: 110, height: 16, borderRadius: BorderRadius.all(Radius.circular(4))),
          SizedBox(height: 8),
          SkeletonBox(width: 150, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
        ],
      ),
    );
  }
}

class _InterestChipsSkeleton extends StatelessWidget {
  const _InterestChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        6,
        (index) => const _ChipSkeleton(),
      ),
    );
  }
}

class _ChipSkeleton extends StatelessWidget {
  const _ChipSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: const SkeletonBox(
        width: 64,
        height: 14,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}

class _SuggestionGridSkeleton extends StatelessWidget {
  const _SuggestionGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => const _SuggestionCardSkeleton(),
    );
  }
}

class _SuggestionCardSkeleton extends StatelessWidget {
  const _SuggestionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Center(
            child: SkeletonBox(
              width: 72,
              height: 72,
              borderRadius: BorderRadius.all(Radius.circular(36)),
            ),
          ),
          SizedBox(height: 16),
          SkeletonBox(height: 16, width: 120, borderRadius: BorderRadius.all(Radius.circular(4))),
          SizedBox(height: 8),
          SkeletonBox(height: 14, width: 160, borderRadius: BorderRadius.all(Radius.circular(4))),
          SizedBox(height: 16),
          SkeletonBox(height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
        ],
      ),
    );
  }
}

class _ContactListSkeleton extends StatelessWidget {
  const _ContactListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: _ContactTileSkeleton(),
        ),
      ),
    );
  }
}

class _ContactTileSkeleton extends StatelessWidget {
  const _ContactTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SkeletonBox(
          width: 48,
          height: 48,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 16, borderRadius: BorderRadius.all(Radius.circular(4))),
              SizedBox(height: 8),
              SkeletonBox(width: 140, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
            ],
          ),
        ),
        SizedBox(width: 16),
        SkeletonBox(width: 72, height: 32, borderRadius: BorderRadius.all(Radius.circular(16))),
      ],
    );
  }
}
