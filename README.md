# crew_app


# lib 目录结构

```text
lib/
├── app/                  # 应用入口与全局配置
│   ├── main.dart         # 应用入口
│   ├── app.dart          # 初始化（runZonedGuarded、依赖注入、Firebase）
│   └── router/           # go_router 路由与守卫
│
├── core/                 # 跨 feature 的底层能力（无业务逻辑）
│   ├── config/           # 环境变量、常量、app info
│   ├── error/            # AppException、Failure、error mapper
│   ├── network/          # Dio/http 客户端、拦截器、API 常量
│   ├── storage/          # SharedPreferences/Hive/secure storage
│   ├── firebase/         # firebase_options、analytics、crashlytics
│   └── utils/            # 纯函数工具（时间、格式化等）
│
├── shared/               # 可复用 UI 和基础包裹
│   ├── widgets/          # Button、AppScaffold 等组件
│   ├── extensions/       # Dart 扩展方法
│
├── features/             # 业务功能模块（按功能域划分）
│   ├── home/
│   │   ├── data/         # 数据实现层（DTO、datasource、repo impl）
│   │   ├── domain/       # 实体、值对象、仓库接口、UseCases
│   │   └── presentation/ # UI、ViewModel/Controller、widgets
│   │
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── [other_feature]/  # 其他功能模块
│
├── l10n/                 # 国际化/多语言
│   ├── generated/        # flutter gen-l10n 自动生成文件
│   └── cn.arb            # 翻译源文件（app_en.arb, app_zh.arb）
│
└── playground/           # 实验区（不打包正式版）
    ├── new_ui/           # 测试新 UI 组件
    ├── test_package/     # 测试第三方包
    └── ideas/            # 各类实验想法与代码

```






```

features/events/presentation/map/
  events_map_page.dart                // 页面壳子（仅编排）
  widgets/search_appbar.dart          // 搜索框 + 头像
  widgets/tags_filter_bar.dart        // 快捷标签 + 筛选按钮
  widgets/map_canvas.dart             // FlutterMap 容器 + onMapReady
  widgets/markers_layer.dart          // 事件标记 + 用户定位标记
  widgets/avatar_icon.dart            // 头像按钮
  sheets/event_filter_sheet.dart      // 底部筛选面板
  sheets/event_bottom_sheet.dart      // 事件卡片（报名）
  dialogs/create_event_dialog.dart    // 创建事件对话框


```



































好的，直接把「搜索页」融进地图页的 SearchBar，做成“像谷歌地图那样”的下拉联想 + 点选定位 +（可选）查看全部结果面板。基于你当前 Flutter 3.35 / Material 3，用 **SearchBar + SearchAnchor** 最顺手。

下面给你**最小改动补丁**（只贴需要新增/替换的关键片段），逻辑点在注释里：

---

### 1) import & 成员变量

```dart
// 新增 import
import 'dart:async';
import '../../../core/network/api_service.dart';

// _EventsMapPageState 里新增成员
final SearchController _searchCtrl = SearchController();
final ApiService _api = ApiService();

Timer? _debounce;
List<Event> _suggestions = [];   // 下拉联想
bool _isSearching = false;

void _disposeDebounce() { _debounce?.cancel(); _debounce = null; }

@override
void dispose() {
  _disposeDebounce();
  _searchCtrl.dispose();
  super.dispose();
}
```

---

### 2) 复用搜索逻辑（“继承”SearchEventsPage 的搜索能力）

```dart
// 轻量防抖：输入 250ms 后请求
void _onQueryChanged(String q) {
  _disposeDebounce();
  if (q.trim().isEmpty) {
    setState(() => _suggestions = []);
    return;
  }
  _debounce = Timer(const Duration(milliseconds: 250), () async {
    await _fetchSuggestions(q);
  });
}

Future<void> _fetchSuggestions(String q) async {
  setState(() { _isSearching = true; });
  try {
    final data = await _api.searchEvents(q); // 直接沿用 SearchEventsPage 的 ApiService
    setState(() => _suggestions = data);
  } catch (_) {
    // 静默失败，保持上次联想
  } finally {
    if (mounted) setState(() { _isSearching = false; });
  }
}

Future<void> _goToEvent(Event e) async {
  _map.move(LatLng(e.latitude, e.longitude), 15);
  // 关闭联想面板与键盘
  _searchCtrl.closeView(e.title);
  FocusScope.of(context).unfocus();
  _showEventCard(e);
}

// 可选：打开“查看全部结果”的底部面板（不跳新页）
Future<void> _openFullSearchSheet(String q) async {
  setState(() {}); // 确保最新 suggestions
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) {
      return SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text('“$q” 的搜索结果'),
              trailing: _isSearching ? const SizedBox(
                width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2),
              ) : null,
            ),
            const Divider(height: 1),
            Expanded(
              child: _suggestions.isEmpty
                  ? const Center(child: Text('没有找到活动'))
                  : ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (_, i) {
                        final e = _suggestions[i];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(e.location, maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            Navigator.pop(context);
                            _goToEvent(e);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}
```

---

### 3) 替换 AppBar 里的原 TextField → SearchAnchor + SearchBar（谷歌地图风格）

把你 `AppBar` 里那段 `Material(... TextField ...)` **整段替换**为下面代码（其它布局保持不变）：

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
  child: SearchAnchor(
    isFullScreen: false, // 类似谷歌地图的锚定下拉
    viewHintText: '搜索活动',
    builder: (context, controller) {
      return SearchBar(
        controller: _searchCtrl,
        hintText: '搜索活动',
        elevation: const MaterialStatePropertyAll(3),
        padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
        leading: const Icon(Icons.my_location_outlined),
        trailing: [
          InkResponse(
            radius: 22,
            onTap: _onAvatarTap,
            child: _buildAvatar(),
          ),
        ],
        onChanged: _onQueryChanged,
        onSubmitted: (q) async {
          if (q.trim().isEmpty) return;
          await _fetchSuggestions(q);
          // 如果有结果，跳第一个；否则弹出“全部结果”面板
          if (_suggestions.isNotEmpty) {
            _goToEvent(_suggestions.first);
          } else {
            _openFullSearchSheet(q);
          }
        },
        onTap: () {
          // 点击输入框时，若已有文本则展开面板
          if (_searchCtrl.text.trim().isNotEmpty && !_searchCtrl.isOpen) {
            _searchCtrl.openView();
          }
        },
      );
    },
    suggestionsBuilder: (context, controller) {
      if (_isSearching) {
        return [
          const ListTile(
            leading: SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('搜索中...'),
          ),
        ];
      }
      if (_searchCtrl.text.trim().isEmpty) {
        return const [];
      }
      final tiles = _suggestions.map((e) => ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(e.location, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => _goToEvent(e),
      ));
      // 末尾给一个“查看全部结果”
      return [
        ...tiles,
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('查看全部结果'),
          onTap: () => _openFullSearchSheet(_searchCtrl.text),
        ),
      ];
    },
  ),
),
```

> 这样：
>
> * 输入即有**下拉联想**；
> * 点任一条 → **居中到该活动**并弹出你的**事件卡片**；
> * 回车若无结果 → 打开**底部“全部结果”面板**；
> * 继续沿用 `ApiService.searchEvents`，等价“继承”你原 `SearchEventsPage` 的搜索能力。

---

### 4) 可选：保留原 SearchEventsPage（跳页版）

如果你还想保留**整页搜索**，在“查看全部结果”里改为跳转原页面并传入初始关键字即可（给 `SearchEventsPage` 加一个可选 `initialQuery` 构造参数，并在 `initState` 里触发 `_search()`）。

---

### 5) 小贴士（Riverpod）

你之前遇到的 `ref.listen can only be used within the build method of a ConsumerWidget` 报错，通常是 **在 build 外**（比如 `initState`/异步回调）触发了 listen。你现在放在 `build` 里是对的；若还报，改用：

```dart
ref.listen<AsyncValue<LatLng?>>(userLocationProvider, (prev, next) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final loc = next.valueOrNull;
    if (!movedToSelected && widget.selectedEvent == null && loc != null) {
      _map.move(loc, 14);
    }
  });
});
```

把副作用延后到 frame 末尾，避免构建期副作用断言。

---

需要我把以上补丁合成完整文件给你，或者顺手加「最近搜索/热门搜索」胶囊，做成更像谷歌地图？
