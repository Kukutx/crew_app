import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/app/router/app_router.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/state/user_profile_provider.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/widgets/collapsed_profile_avatar.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/widgets/profile_header_card.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/widgets/profile_tab_view.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/widgets/profile_guestbook_page.dart';
import 'package:crew_app/shared/widgets/sheets/report_sheet.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key, this.uid, this.onClose});

  final String? uid;
  final VoidCallback? onClose;

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
  static const double _expandedHeight = 380;
  static const double _tabBarHeight = 48;
  List<String> _reportTypes(AppLocalizations localization) => [
    localization.report_user_type_harassment,
    localization.report_user_type_impersonation,
    localization.report_user_type_inappropriate,
    localization.report_user_type_spam,
    localization.report_user_type_other,
  ];

  late final TabController _tabController;
  late int _currentTabIndex;
  static const List<String> _tabLabels = ['活动', '收藏'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _currentTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(eventsProvider);
    await ref.read(eventsProvider.future);
  }

  void _toggleFollow() {
    final current = ref.read(userProfileProvider);
    ref.read(userProfileProvider.notifier).state = current.copyWith(
      followed: !current.followed,
      followers: current.followed
          ? current.followers - 1
          : current.followers + 1,
    );
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final nextIndex = _tabController.index;
    if (nextIndex != _currentTabIndex) {
      setState(() {
        _currentTabIndex = nextIndex;
      });
    }
  }

  void _showMoreActions(
    BuildContext context,
    User profile,
    bool isViewingSelf,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    final link = 'https://crew.app/users/${profile.uid}';
    final localization = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final actions = <Widget>[];

        if (isViewingSelf) {
          actions.add(
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑主页'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openEditProfile();
              },
            ),
          );
        } else {
          actions.addAll([
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('拉黑'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _confirmBlockUser(context, profile, messenger);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(localization.report_issue),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _showReportSheet(context, profile, messenger);
              },
            ),
          ]);
        }

        actions.add(
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('复制链接'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await Clipboard.setData(ClipboardData(text: link));
              messenger.showSnackBar(SnackBar(content: Text('已复制链接：$link')));
            },
          ),
        );

        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: actions),
        );
      },
    );
  }

  Future<void> _confirmBlockUser(
    BuildContext context,
    User profile,
    ScaffoldMessengerState messenger,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return _BlockUserConfirmationSheet(name: profile.name);
      },
    );

    if (confirmed == true) {
      messenger.showSnackBar(
        SnackBar(content: Text('已拉黑 ${profile.name}（示例）')),
      );
    }
  }

  Future<void> _showReportSheet(
    BuildContext context,
    User profile,
    ScaffoldMessengerState messenger,
  ) async {
    final localization = AppLocalizations.of(context)!;
    final ReportSheetSubmission? submission = await ReportSheet.show(
      context: context,
      title: localization.report_issue,
      description: localization.report_issue_description,
      typeLabel: localization.report_event_type_label,
      typeEmptyHint: localization.report_event_type_required,
      contentLabel: localization.report_event_content_label,
      contentHint: localization.report_event_content_hint,
      attachmentLabel: localization.report_event_attachment_label,
      attachmentOptional: localization.report_event_attachment_optional,
      attachmentAddLabel: localization.report_event_attachment_add,
      attachmentReplaceLabel: localization.report_event_attachment_replace,
      attachmentEmptyLabel: localization.report_event_attachment_empty,
      submitLabel: localization.report_event_submit,
      cancelLabel: localization.action_cancel,
      reportTypes: _reportTypes(localization),
      imagePicker: ImagePicker(),
    );

    if (submission != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('已收到对 ${profile.name} 的举报：${submission.type}（示例）'),
        ),
      );
    }
  }

  void _startPrivateMessage(BuildContext context, User profile) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => const DirectMessagesPage(),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '私信功能尚未开放，敬请期待！',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }

  Future<void> _openGuestbookPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfileGuestbookPage()),
    );
  }

  void _openEditProfile() {
    if (!mounted) {
      return;
    }
    context.push(AppRoutePaths.editProfile);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isViewingSelf = widget.uid != null && widget.uid == currentUser?.uid;
    final theme = Theme.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            _buildSliverAppBar(
              context,
              profile,
              topPadding,
              theme,
              isViewingSelf,
            ),
          ],
          body: ProfileTabView(controller: _tabController),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    User profile,
    double topPadding,
    ThemeData theme,
    bool isViewingSelf,
  ) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: _expandedHeight,
      automaticallyImplyLeading: widget.onClose == null,
      leading: widget.onClose == null
          ? null
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreActions(context, profile, isViewingSelf),
        ),
        if (isViewingSelf)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (!mounted) {
                return;
              }
              context.push(AppRoutePaths.settings);
            },
          ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.biggest.height;
          final minExtent = topPadding + kToolbarHeight + _tabBarHeight;
          final maxExtent = topPadding + _expandedHeight;
          final availableExtent = maxExtent - minExtent <= 0
              ? 1.0
              : maxExtent - minExtent;
          final t = ((currentHeight - minExtent) / availableExtent).clamp(
            0.0,
            1.0,
          );
          final collapseProgress = 1 - t;

          final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
          final coverHeight = (_expandedHeight * devicePixelRatio).round();

          return Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: profile.cover,
                fit: BoxFit.cover,
                memCacheHeight: coverHeight,
                maxHeightDiskCache: coverHeight,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 150),
                placeholder: (_, __) => const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2B2B2E),
                        Color(0xFF202024),
                      ],
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF2B2B2E)),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
              if (t > 0.05)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: lerpDouble(16, 72, t)!,
                  child: Opacity(
                    opacity: Curves.easeOut.transform(t),
                    child: Transform.scale(
                      scale: lerpDouble(0.92, 1, t)!,
                      child: ProfileHeaderCard(
                        userProfile: profile,
                        onFollowToggle: _toggleFollow,
                        onMessagePressed: () =>
                            _startPrivateMessage(context, profile),
                        onGuestbookPressed: _openGuestbookPage,
                        showUserActions: !isViewingSelf,
                      ),
                    ),
                  ),
                ),
              if (collapseProgress > 0)
                Positioned(
                  top: topPadding + (kToolbarHeight - 48) / 2,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: collapseProgress < 0.6,
                    child: Opacity(
                      opacity: Curves.easeIn.transform(collapseProgress),
                      child: Center(
                        child: CollapsedProfileAvatar(user: profile),
                      ),
                    ),
                  ),
                ),
              // 保持状态栏占位
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(height: topPadding),
              ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_tabBarHeight),
        child: Material(
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ToggleTabBar(
              selectedIndex: _currentTabIndex,
              firstLabel: _tabLabels[0],
              secondLabel: _tabLabels[1],
              firstIcon: Icons.event,
              secondIcon: Icons.bookmark,
              onChanged: (index) {
                if (index != _currentTabIndex) {
                  _tabController.animateTo(index);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BlockUserConfirmationSheet extends StatelessWidget {
  const _BlockUserConfirmationSheet({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '确认拉黑',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text('确定要拉黑 $name 吗？', style: textTheme.bodyMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('确认'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
