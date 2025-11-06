import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/features/events/presentation/pages/moment/widgets/create_moment_screen.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';

Future<void> showCreateContentOptionsSheet(BuildContext context) {
  final parentContext = context;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateContentOptionsSheet(parentContext: parentContext),
  );
}

class _CreateContentOptionsSheet extends ConsumerWidget {
  const _CreateContentOptionsSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
              bottom: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 抓取把手
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 选项内容 - 添加水平 padding
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 第一个选项：城市玩家
                    _CreateOptionCard(
                      title: '城市玩家',
                      subtitle: '创建当地城市的活动',
                      backgroundColor: isDark
                          ? colorScheme.tertiaryContainer
                          : const Color(0xFFFFF3E0), // 浅橙色
                      onTap: () {
                        Navigator.of(context).maybePop();
                        // TODO: 实现城市玩家创建活动页面
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(content: Text('城市玩家功能开发中...')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // 第二个选项：旅游
                    _CreateOptionCard(
                      title: '旅游',
                      subtitle: '规划您的旅行路线',
                      backgroundColor: isDark
                          ? colorScheme.primaryContainer
                          : const Color(0xFFE0F7F4), // 浅青色
                      onTap: () {
                        Navigator.of(context).maybePop();
                        // 弹出 CreateRoadTripSheet
                        ref.read(mapOverlaySheetProvider.notifier).state =
                            MapOverlaySheetType.createRoadTrip;
                      },
                    ),
                    const SizedBox(height: 12),
                    // 第三个选项：发表瞬间
                    _CreateOptionCard(
                      title: '发表瞬间',
                      subtitle: '分享您的精彩时刻',
                      backgroundColor: isDark
                          ? colorScheme.secondaryContainer
                          : const Color(0xFFF3E5F5), // 浅紫色
                      onTap: () {
                        Navigator.of(context).maybePop();
                        // 导航到创建瞬间页面
                        Navigator.of(parentContext).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateMomentScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateOptionCard extends StatelessWidget {
  const _CreateOptionCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

