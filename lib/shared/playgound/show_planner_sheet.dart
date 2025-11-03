import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Future<void> showPlannerSheet(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PlannerSheet(),
  );
}

class _PlannerSheet extends StatefulWidget {
  const _PlannerSheet({super.key});

  @override
  State<_PlannerSheet> createState() => _PlannerSheetState();
}

class _PlannerSheetState extends State<_PlannerSheet> with TickerProviderStateMixin {
  final _dragCtrl = DraggableScrollableController();
  final _pageCtrl = PageController();
  bool _canSwipe = false; // 初始仅展示第一页，不可横滑

  @override
  void dispose() {
    _dragCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _enableWizard() async {
    setState(() => _canSwipe = true);
    // 展开到底（需要 Flutter 3.13+ 支持 DraggableScrollableController）
    try { await _dragCtrl.animateTo(1.0, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = const Radius.circular(24);

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: DraggableScrollableSheet(
        controller: _dragCtrl,
        initialChildSize: 0.45,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.45, 0.95],
        builder: (context, scrollCtrl) {
          return Material(
            color: theme.colorScheme.surface,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Grabber
                  const SizedBox(height: 10),
                  Container(width: 44, height: 5, decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  )),
                  const SizedBox(height: 12),

                  // TabBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: EdgeInsets.symmetric(vertical: 10),
                        tabs: [
                          Tab(text: 'Connection'),
                          Tab(text: 'Station / Location'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 内容：用 PageView 承载表单向导
                  Expanded(
                    child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (n) { n.disallowIndicator(); return true; },
                      child: PageView(
                        controller: _pageCtrl,
                        physics: _canSwipe ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
                        children: [
                          // 第0页：与截图一致的列表态
                          _ConnectionStart(scrollCtrl: scrollCtrl, onContinue: _enableWizard),
                          // 第1页：更多信息（示例）
                          _FormScaffold(title: 'Time & Date', children: [
                            const SizedBox(height: 12),
                            TextField(decoration: const InputDecoration(labelText: 'Start time')),
                            const SizedBox(height: 12),
                            TextField(decoration: const InputDecoration(labelText: 'End time')),
                          ]),
                          // 第2页：示例
                          _FormScaffold(title: 'Preferences', children: [
                            SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Round trip')),
                            SwitchListTile(value: false, onChanged: (_) {}, title: const Text('Allow pets')),
                          ]),
                          // 第3页：示例
                          _FormScaffold(title: 'Requirements', children: [
                            TextField(decoration: const InputDecoration(labelText: 'Max participants (<=7)')),
                            const SizedBox(height: 12),
                            TextField(decoration: const InputDecoration(labelText: 'Languages')),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // 底部：指示器 + 向导按钮（仅在开启向导后显示）
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _canSwipe
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                              children: [
                                SmoothPageIndicator(
                                  controller: _pageCtrl,
                                  count: 4,
                                  effect: const WormEffect(dotHeight: 8, dotWidth: 8),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    final p = _pageCtrl.page!.round();
                                    if (p > 0) _pageCtrl.previousPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                                  },
                                  child: const Text('Back'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () {
                                    final p = _pageCtrl.page!.round();
                                    if (p < 3) {
                                      _pageCtrl.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                                    } else {
                                      Navigator.of(context).maybePop(); // Done
                                    }
                                  },
                                  child: Builder(builder: (_) {
                                    final p = _pageCtrl.hasClients ? _pageCtrl.page?.round() ?? 0 : 0;
                                    return Text(p < 3 ? 'Next' : 'Done');
                                  }),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _enableWizard,
                                child: const Text('Continue'),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionStart extends StatelessWidget {
  const _ConnectionStart({required this.scrollCtrl, required this.onContinue});
  final ScrollController scrollCtrl;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.list(children: [
            _CardTile(
              leading: const Icon(Icons.radio_button_checked),
              title: 'My Location',
              subtitle: 'Use current location',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _CardTile(
              leading: const Icon(Icons.place_outlined),
              title: 'Destination Address',
              subtitle: 'Search destination',
              onTap: () {},
            ),
            const SizedBox(height: 40),
            // 空态占位（用简单容器代替插画）
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                '附近的POI',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.leading, required this.title, this.subtitle, this.onTap});
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ]),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 200),
      ],
    );
  }
}
