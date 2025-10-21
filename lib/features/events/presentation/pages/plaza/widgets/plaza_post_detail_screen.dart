import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crew_app/features/events/presentation/widgets/plaza_post_card.dart';

import '../edit_moment_page.dart';

import '../sheets/plaza_post_comments_sheet.dart';

class PlazaPostDetailScreen extends StatefulWidget {
  const PlazaPostDetailScreen({
    super.key,
    required this.post,
    this.initialPage = 0,
    this.heroTag,
  });

  final PlazaPost post;
  final int initialPage;
  final String? heroTag;

  static PageRoute<int> route({
    required PlazaPost post,
    int initialPage = 0,
    String? heroTag,
  }) {
    return PageRouteBuilder<int>(
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: PlazaPostDetailScreen(
          post: post,
          initialPage: initialPage,
          heroTag: heroTag,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 220),
    );
  }

  @override
  State<PlazaPostDetailScreen> createState() => _PlazaPostDetailPageState();
}

class _PlazaPostDetailPageState extends State<PlazaPostDetailScreen> {
  late final List<String> _mediaAssets;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _mediaAssets = widget.post.mediaAssets
        .map((asset) => asset.trim())
        .where((asset) => asset.isNotEmpty)
        .toList(growable: false);
    if (_mediaAssets.isEmpty) {
      _currentPage = 0;
    } else {
      final maxIndex = _mediaAssets.length - 1;
      _currentPage = widget.initialPage.clamp(0, maxIndex);
    }
    _pageController = PageController(initialPage: _currentPage);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 650) {
      HapticFeedback.mediumImpact();
      _popWithResult();
    }
  }

  void _handlePageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _popWithResult() {
    Navigator.of(context).pop(_currentPage);
  }

  void _showComments() {
    showPlazaPostCommentsSheet(context, widget.post);
  }

  Future<void> _showMomentActions() async {
    HapticFeedback.selectionClick();
    final action = await showModalBottomSheet<_MomentAction>(
      context: context,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('编辑瞬间'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_MomentAction.edit),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                ),
                title: Text(
                  '删除瞬间',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_MomentAction.delete),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _MomentAction.edit:
        await _openEditMoment();
        break;
      case _MomentAction.delete:
        await _confirmDeleteMoment();
        break;
    }
  }

  Future<void> _openEditMoment() async {
    final updated = await Navigator.of(context).push<bool>(
      EditMomentPage.route(post: widget.post),
    );

    if (!mounted || updated != true) {
      return;
    }

    _showActionFeedback('瞬间已更新');
  }

  Future<void> _confirmDeleteMoment() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('删除瞬间'),
            content: const Text('确定要删除这条瞬间吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !confirmed) {
      return;
    }

    HapticFeedback.mediumImpact();
    _showActionFeedback('瞬间已删除');
    _popWithResult();
  }

  void _showActionFeedback(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final mediaAssets = _mediaAssets;

    final viewer = mediaAssets.isEmpty
        ? _EmptyPlazaMediaPlaceholder(post: widget.post)
        : PageView.builder(
            controller: _pageController,
            onPageChanged: _handlePageChanged,
            itemCount: mediaAssets.length,
            itemBuilder: (context, index) {
              final asset = mediaAssets[index];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          );

    final heroTag = widget.heroTag;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _popWithResult();
        }
      },
      child: GestureDetector(
        onVerticalDragEnd: _handleVerticalDragEnd,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: heroTag == null
                      ? Material(color: Colors.black, child: viewer)
                      : Hero(
                          tag: heroTag,
                          child: Material(
                            color: Colors.black,
                            child: viewer,
                          ),
                        ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _popWithResult,
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      tooltip: '更多操作',
                      onPressed: _showMomentActions,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.post.previewLabel ?? widget.post.content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      if (mediaAssets.length > 1)
                        _PlazaFullscreenPageIndicator(
                          current: _currentPage,
                          total: mediaAssets.length,
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 28,
                  right: 20,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    onPressed: _showComments,
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _MomentAction { edit, delete }

class _PlazaFullscreenPageIndicator extends StatelessWidget {
  const _PlazaFullscreenPageIndicator({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 14 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _EmptyPlazaMediaPlaceholder extends StatelessWidget {
  const _EmptyPlazaMediaPlaceholder({required this.post});

  final PlazaPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            post.accentColor.withValues(alpha: 0.9),
            post.accentColor.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          post.previewLabel ?? post.content,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
