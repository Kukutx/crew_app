import 'package:flutter/material.dart';

class GridMinePage extends StatelessWidget {
  const GridMinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _ProfileHeader(),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('我的收藏'),
                trailing: Icon(Icons.chevron_right),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('浏览记录'),
                trailing: Icon(Icons.chevron_right),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('设置'),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '版本 1.0.0',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              child: Icon(Icons.person, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('未登录', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '点击上方按钮登录体验更多功能',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}
