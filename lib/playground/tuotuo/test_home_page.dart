import 'package:flutter/material.dart';

class TuotuoApp extends StatelessWidget {
  const TuotuoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tuòtuo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFA000)),
        fontFamily: 'sans-serif',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: const Color(0xFFFFA000),
          elevation: 0,
          centerTitle: false,
          titleSpacing: 16,
          title: Row(
            children: [
              const _LogoWordmark(),
              const Spacer(),
              _TopIcon(
                icon: Icons.wallet_giftcard_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _TopIcon(
                icon: Icons.qr_code_scanner_outlined,
                onTap: () {},
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFA000),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
              ),
              child: Row(
                children: const [
                  _TabChip(label: '活动地图'),
                  SizedBox(width: 8),
                  _TabChip(label: '发起活动', highlighted: true),
                  SizedBox(width: 8),
                  _TabChip(label: '活动路线'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: const _CardArea(),
      bottomNavigationBar: const _BottomBar(),
    );
  }
}

class _LogoWordmark extends StatelessWidget {
  const _LogoWordmark();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.hiking, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 8),
        const Text(
          'tuòtuo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopIcon({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  const _TabChip({required this.label, this.highlighted = false});
  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? Colors.white : Colors.black.withValues(alpha:0.12);
    final fg = highlighted ? Colors.black : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _CardArea extends StatelessWidget {
  const _CardArea();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1523731407965-2430cd12f5e4?w=1200',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 顶部渐变与信息
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54, Colors.black87],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place, color: Colors.white70, size: 18),
                              const SizedBox(width: 6),
                              const Text('科莫湖附近', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const Spacer(),
                              const Icon(Icons.people_alt_outlined, color: Colors.white70, size: 18),
                              const SizedBox(width: 6),
                              const Text('4-6', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '春天一起去爬山吧！',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 56),
                        ],
                      ),
                    ),
                  ),
                  // 中间顶部的小操作栏（返回、收藏等）
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 12,
                    child: Row(
                      children: [
                        _CircleBtn(icon: Icons.close, onTap: () {}),
                        const SizedBox(width: 8),
                        _CircleBtn(icon: Icons.replay, onTap: () {}),
                        const Spacer(),
                        _CircleBtn(
                          icon: Icons.favorite,
                          onTap: () {},
                          filled: true,
                          fillColor: Colors.orange.shade400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 下方小页签提示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 2 ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == 2 ? Colors.black87 : Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final Color? fillColor;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.fillColor,
  });
  @override
  Widget build(BuildContext context) {
    final bg = filled ? (fillColor ?? Colors.black) : Colors.white;
    final fg = filled ? Colors.white : Colors.black87;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          width: 44,
          height: 44,
          child: Icon(icon, color: fg, size: 22),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
      ]),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _NavItem(icon: Icons.home_rounded, label: '首页推荐', active: true),
              _NavItem(icon: Icons.group_outlined, label: '发现同伴'),
              _NavItem(icon: Icons.add_circle_rounded, label: '发布活动'),
              _NavItem(icon: Icons.chat_bubble_outline, label: '我的消息'),
              _NavItem(icon: Icons.person_outline, label: '个人主页'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem({required this.icon, required this.label, this.active = false});
  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.black : Colors.black54;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: active ? FontWeight.w700 : FontWeight.w500),
        ),
      ],
    );
  }
}
