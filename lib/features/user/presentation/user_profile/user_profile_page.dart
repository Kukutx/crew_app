import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/user_profile/state/user_profile_provider.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/collapsed_profile_avatar.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_header_card.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_tab_view.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_guestbook_page.dart';

import 'dart:typed_data';

typedef ReportSubmission = ({
  String type,
  String description,
  String? imageName,
});

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
  static const List<String> _reportTypes = ['垃圾信息', '辱骂/仇恨', '违规内容', '其他'];

  late final TabController _tabController;
  late int _currentTabIndex;
  final List<Tab> _tabs = const [Tab(text: '活动'), Tab(text: '收藏')];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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

  void _showMoreActions(BuildContext context, User profile) {
    final messenger = ScaffoldMessenger.of(context);
    final link = 'https://crew.app/users/${profile.uid}';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                title: const Text('举报'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _showReportDialog(context, profile, messenger);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('复制链接'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Clipboard.setData(ClipboardData(text: link));
                  messenger.showSnackBar(
                    SnackBar(content: Text('已复制链接：$link')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmBlockUser(
    BuildContext context,
    User profile,
    ScaffoldMessengerState messenger,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('确认拉黑'),
          content: Text('确定要拉黑 ${profile.name} 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      messenger.showSnackBar(
        SnackBar(content: Text('已拉黑 ${profile.name}（示例）')),
      );
    }
  }

  Future<void> _showReportDialog(
    BuildContext context,
    User profile,
    ScaffoldMessengerState messenger,
  ) async {
    final descriptionController = TextEditingController();
    final picker = ImagePicker();
    String selectedType = _reportTypes.first;
    Uint8List? selectedImageBytes;
    String? selectedImageName;

    final ReportSubmission? submission = await showDialog<ReportSubmission>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Future<void> handlePickImage() async {
              final file = await picker.pickImage(source: ImageSource.gallery);
              if (file == null) return;
              final bytes = await file.readAsBytes();
              setState(() {
                selectedImageBytes = bytes;
                selectedImageName = file.name;
              });
            }

            return AlertDialog(
              title: const Text('举报'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: _reportTypes
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedType = value);
                      },
                      decoration: const InputDecoration(
                        labelText: '举报类型',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: '补充说明',
                        hintText: '请输入举报原因或补充说明',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('上传证据图片（可选）'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: handlePickImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('选择图片'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedImageName ?? '未选择文件',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (selectedImageBytes != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          selectedImageBytes!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: descriptionController.text.trim().isEmpty
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop((
                            type: selectedType,
                            description: descriptionController.text.trim(),
                            imageName: selectedImageName,
                          ));
                        },
                  child: const Text('提交'),
                ),
              ],
            );
          },
        );
      },
    );

    descriptionController.dispose();

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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            _buildSliverAppBar(context, profile, topPadding, theme),
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
          onPressed: () => _showMoreActions(context, profile),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
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
          final t = ((currentHeight - minExtent) / availableExtent).clamp(
            0.0,
            1.0,
          );
          final collapseProgress = 1 - t;

          return Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: profile.cover, fit: BoxFit.cover),
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
            tabs: _tabs,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
    );
  }
}
