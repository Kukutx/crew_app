# User Profile Page 优化建议

本文档基于 `lib/features/user/presentation/user_profile/user_profile_page.dart` 当前实现，提出若干可行的优化方向，涵盖性能、代码结构、可维护性以及用户体验。

## 1. 文案与本地化
- **提炼常量字符串至本地化资源**：页面内存在多处硬编码的中文文案（例如“拉黑”“复制链接”等）。建议将这些字符串迁移到 `AppLocalizations`，以便统一管理、支持多语言以及便于翻译更新。
- **复用已有文案键值**：优先检索是否已有相同语义的键，避免重复新增。

## 2. 状态与业务逻辑解耦
- **关注 follow 状态的来源**：当前 `_toggleFollow` 直接修改 `userProfileProvider` 的状态，缺乏对后端同步的处理。建议抽离为 `UserProfileController` 或使用 `AsyncNotifier`，在内部封装网络请求及错误处理，并提供 loading / error 状态。
- **事件刷新逻辑**：`_onRefresh` 同时 `invalidate` 与 `await future`，可以考虑封装为 Provider 中的 `refreshEvents` 方法，页面仅负责触发，提升复用性。

## 3. 组件拆分与可测试性
- **抽离底部操作 sheet**：`_showMoreActions` 包含多个 `ListTile`，可拆分为独立 Widget 或 `ActionSheet` 配置对象，方便在不同页面复用与测试。
- **TabBar 定义集中管理**：`_tabs` 使用硬编码文本，可考虑抽离到单独的 getter，或根据 `AppLocalizations` 动态生成，保持与语言切换一致。
- **确认弹窗组件化**：`_BlockUserConfirmationSheet` 可以与其他类似确认弹窗共享基础样式（如统一的标题、按钮风格），通过通用组件减少重复代码。

## 4. 性能优化
- **避免重复构建重组件**：`NestedScrollView` 的 `headerSliverBuilder` 每次重建都重新计算 `_buildSliverAppBar`，可将 `ProfileHeaderCard` 与 `CollapsedProfileAvatar` 包装在 `SliverPersistentHeaderDelegate` 中，或使用 `ValueListenableBuilder` 等减少 rebuild 范围。
- **缓存网络图片策略**：`CachedNetworkImage` 默认缓存策略可能不足，可结合用户数据更新时间设置 `cacheKey` 或使用 `imageUrl` 版本号，避免用户更换封面后仍显示旧图。

## 5. 动画与交互体验
- **Tab 切换动画控制**：通过 `AnimatedBuilder` 或 `TabController.animation`，在 AppBar 折叠时渐进显示 Tab 指示器或标题，增强动态体验。
- **操作反馈一致性**：拉黑、举报操作目前仅展示 `SnackBar` 示例。可在未来引入 Result 对象，根据成功/失败提供不同的 UI 反馈。

## 6. 可访问性与适配
- **无障碍标签**：为 IconButton 添加 `tooltip` 或 `semanticLabel`，提升 TalkBack/VoiceOver 可读性。
- **深色模式与高对比度**：确认 `SnackBar` 文案与按钮在深色主题下的对比度符合规范，必要时自定义 `SnackBarThemeData`。
- **横屏适配**：在横屏或大屏设备上，考虑使用 `SliverLayoutBuilder` 调整头像与卡片布局，避免内容挤压。

## 7. 代码规范与可维护性
- **lint 检查**：确保 `analysis_options.yaml` 中的 lint 规则在此文件遵守，例如避免过长方法，可通过拆分函数降低复杂度。
- **常量提取**：`_expandedHeight`、`_tabBarHeight` 外的 magic number（如 `16`, `72`, `0.92`）可提炼为具名常量，提升可读性。
- **Provider 监听优化**：如 `userProfileProvider` 返回 `AsyncValue<User>`，可用 `ref.watch(...).when` 处理加载/错误态，增强健壮性。

---
以上方案可按优先级逐步实施，可先处理低成本的文案和语义优化，再规划状态管理与性能方面的重构。
