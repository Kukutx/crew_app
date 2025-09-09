import 'package:flutter/material.dart';

class TuotuoApp2 extends StatelessWidget {
  const TuotuoApp2({super.key});

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
      home: const TestProfilePage(),
    );
  }
}

class TestProfilePage extends StatelessWidget {
  const TestProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA000),
        title: const Text('个人主页', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Column(
        children: [
          _ProfileHeader(),
          const SizedBox(height: 10),
          _TabBar(),
          const Divider(height: 1),
          Expanded(child: _ActivitiesList()),
        ],
      ),
      bottomNavigationBar: const _BottomBar(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 36, backgroundColor: Colors.orange.shade100, child: const Text('👩')), 
          const SizedBox(height: 8),
          const Text('小魔仙e', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('热爱生活，乐于分享', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _StatItem(label: '关注', count: '20'),
              SizedBox(width: 20),
              _StatItem(label: '粉丝', count: '15'),
              SizedBox(width: 20),
              _StatItem(label: '已发起', count: '24'),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            ),
            child: const Text('关注', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String count;
  const _StatItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabButton(label: '我参加的活动', active: true),
          _TabButton(label: '我发布的帖子'),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  const _TabButton({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}

class _ActivitiesList extends StatelessWidget {
  final List<Map<String, String>> activities = const [
    {
      'title': '米兰市区City walk',
      'people': '3-5人',
      'time': '12月28日 20:00',
      'status': '正在报名中',
      'address': 'Piazza Duomo, 20121 Milano',
    },
    {
      'title': '春天一起去爬山吧',
      'people': '4-6人',
      'time': '12月16日 6:00',
      'status': '报名结束',
      'address': 'Piazza Duomo, 20121 Milano',
    },
    {
      'title': 'Bobbio新手滑雪小组',
      'people': '3-4人',
      'time': '12月17日 16:00',
      'status': '报名结束',
      'address': 'Piazza Duomo, 20121 Milano',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: activities.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = activities[index];
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                ),
                child: const Icon(Icons.image, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(item['address']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${item['people']}  |  ${item['time']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(item['status']!, style: const TextStyle(color: Colors.orange, fontSize: 12)),
              ),
            ],
          ),
        );
      },
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
              _NavItem(icon: Icons.home_rounded, label: '首页推荐'),
              _NavItem(icon: Icons.group_outlined, label: '发现同伴'),
              _NavItem(icon: Icons.add_circle_rounded, label: '发布活动'),
              _NavItem(icon: Icons.chat_bubble_outline, label: '我的消息'),
              _NavItem(icon: Icons.person_outline, label: '个人主页', active: true),
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
