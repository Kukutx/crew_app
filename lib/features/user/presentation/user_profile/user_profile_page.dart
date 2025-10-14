import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/user_profile/state/user_profile_provider.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/collapsed_profile_avatar.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_guestbook_page.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_header_card.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_tab_view.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/confirmation_sheet.dart';
import 'package:crew_app/shared/widgets/report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
  static const double _expandedHeight = 320;
  static const double _tabBarHeight = 48;
  static const double _headerBottomMin = 16;
  static const double _headerBottomMax = 72;
  static const double _headerScaleMin = 0.92;

  late final TabController _tabController;
  late int _currentTabIndex;

  List<String> _reportTypes(AppLocalizations localization) => [
        localization.report_user_type_harassment,
        localization.report_user_type_impersonation,
        localization.report_user_type_inappropriate,
        localization.report_user_type_spam,
        localization.report_user_type_other,
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    await Future.wait<void>([
      ref.read(userProfileProvider.notifier).refresh(),
      ref.read(eventsProvider.notifier).refresh(),
    ]);
  }

  Future<void> _toggleFollow() {
    return ref.read(userProfileProvider.notifier).toggleFollow();
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

  Future<void> _showMoreActions(BuildContext context, User profile) async {
    final localization = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final link = 'https://crew.app/users/${profile.uid}';

    final actions = <_SheetAction>[
      _SheetAction(
        icon: Icons.block,
        label: localization.profile_action_block,
        tooltip: localization.profile_action_block_tooltip,
        onSelected: () async {
          final confirmed = await _confirmBlockUser(context, profile);
          if (confirmed) {
            messenger.showSnackBar(
              SnackBar(
                content:
                    Text(localization.profile_block_success(profile.name)),
              ),
            );
          }
        },
      ),
      _SheetAction(
        icon: Icons.flag,
        label: localization.report_issue,
        tooltip: localization.report_issue,
        onSelected: () async {
          final submission =
              await _showReportSheet(context, profile, localization);
          if (submission != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(localization.profile_report_success(
                  profile.name,
                  submission.type,
                )),
              ),
            );
          }
        },
      ),
      _SheetAction(
        icon: Icons.link,
        label: localization.profile_action_copy_link,
        tooltip: localization.profile_action_copy_link_tooltip,
        onSelected: () async {
          await Clipboard.setData(ClipboardData(text: link));
          messenger.showSnackBar(
            SnackBar(
              content:
                  Text(localization.profile_action_link_copied(link)),
            ),
          );
        },
      ),
    ];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Tooltip(
                message: action.tooltip ?? action.label,
                child: ListTile(
                  leading: Icon(action.icon),
                  title: Text(action.label),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await action.onSelected();
                  },
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: actions.length,
          ),
        );
      },
    );
  }

  Future<bool> _confirmBlockUser(BuildContext context, User profile) async {
    final localization = AppLocalizations.of(context)!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return ConfirmationSheet(
          title: localization.profile_block_confirm_title,
          message: localization.profile_block_confirm_message(profile.name),
          confirmLabel: localization.action_confirm,
          cancelLabel: localization.action_cancel,
        );
      },
    );

    return confirmed ?? false;
  }

  Future<ReportSheetSubmission?> _showReportSheet(
    BuildContext context,
    User profile,
    AppLocalizations localization,
  ) {
    return ReportSheet.show(
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
  }

  void _startPrivateMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!
            .profile_action_message_unavailable),
      ),
    );
  }

  Future<void> _openGuestbookPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfileGuestbookPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: profileAsync.when(
          data: (profile) => NestedScrollView(
            headerSliverBuilder: (_, __) => [
              _buildSliverAppBar(
                context,
                profile,
                topPadding,
                theme,
                localization,
              ),
            ],
            body: ProfileTabView(controller: _tabController),
          ),
          loading: const _ProfileLoadingView(),
          error: (_, __) => _ProfileErrorView(
            message: localization.load_failed,
            onRetry: () =>
                ref.read(userProfileProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    User profile,
    double topPadding,
    ThemeData theme,
    AppLocalizations localization,
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
              tooltip: localization.profile_action_close_tooltip,
              onPressed: widget.onClose,
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: localization.profile_action_more_tooltip,
          onPressed: () => _showMoreActions(context, profile),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: localization.profile_action_settings_tooltip,
          onPressed: () => Navigator.of(context).pushNamed('/settings'),
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
          final t = ((currentHeight - minExtent) / availableExtent)
              .clamp(0.0, 1.0);
          final collapseProgress = 1 - t;

          return Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: profile.cover,
                cacheKey:
                    'profile_cover_${profile.uid}_${profile.cover.hashCode}',
                fit: BoxFit.cover,
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
                  left: _headerBottomMin,
                  right: _headerBottomMin,
                  bottom: lerpDouble(
                    _headerBottomMin,
                    _headerBottomMax,
                    t,
                  )!,
                  child: Opacity(
                    opacity: Curves.easeOut.transform(t),
                    child: Transform.scale(
                      scale: lerpDouble(
                        _headerScaleMin,
                        1,
                        t,
                      )!,
                      child: ProfileHeaderCard(
                        userProfile: profile,
                        localization: localization,
                        onFollowToggle: _toggleFollow,
                        onMessagePressed: () =>
                            _startPrivateMessage(context),
                        onGuestbookPressed: _openGuestbookPage,
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
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localization.profile_tab_activities),
              Tab(text: localization.profile_tab_favorites),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
    );
  }
}

class _SheetAction {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onSelected;
  final String? tooltip;
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text(localization.action_retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
