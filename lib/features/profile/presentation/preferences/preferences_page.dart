import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // 标签列表
  final List<String> _tags = [
    'Museums',
    'Art Galleries',
    'Coffee',
    'Hiking',
    'Nightlife',
    'Board Games',
    'Live Music',
    'Adventure Sports',
    'Technology',
    'Photography',
    'Travel',
    'Food',
    'Fitness',
    'Movies',
    'Books',
  ];

  @override
  void dispose() {
    _schoolController.dispose();
    _industryController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  // 选中的标签
  final Set<String> _selectedTags = {};

  // 是否学生认证
  bool _isStudentVerified = false;

  // 搜索过滤
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // 过滤后的标签
    final filteredTags = _tags
        .where((tag) => tag.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.preferences_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 学校/行业输入
            TextField(
              controller: _schoolController,
              decoration: InputDecoration(
                labelText: loc.school_label_optional,
                suffixIcon: _isStudentVerified
                    ? const Icon(Icons.verified, color: Colors.blue)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _industryController,
              decoration: InputDecoration(
                labelText: loc.industry_label_optional,
              ),
            ),
            const SizedBox(height: 24),

            // 兴趣标签
            Text(
              loc.interest_tags_title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.search_tags_hint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedTags.length < 5) {
                          _selectedTags.add(tag);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.max_interest_selection),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 模拟学生认证按钮
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isStudentVerified = true;
                });
              },
              child: Text(loc.student_verification),
            ),
          ],
        ),
      ),
    );
  }
}
