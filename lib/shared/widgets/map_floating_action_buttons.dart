import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_stage_provider.dart';
import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 地图悬浮按钮配置
class MapFloatingButtonConfig {
  const MapFloatingButtonConfig({
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.visible = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool visible;
}

/// 通用多功能地图悬浮按钮组件
class MapFloatingActionButtons extends StatelessWidget {
  const MapFloatingActionButtons({
    super.key,
    required this.mapSheetType,
    required this.mapSheetStage,
    required this.mapSheetSize,
    required this.bottomPadding,
    required this.safeBottom,
    this.startLatLng,
    this.destinationLatLng,
    this.canSwipe = false,
    this.onAddWaypoint,
    this.onEdit,
    this.onAddPressed,
    this.onLocationPressed,
    this.showCompass = false,
  });

  final MapOverlaySheetType mapSheetType;
  final MapOverlaySheetStage mapSheetStage;
  final double mapSheetSize;
  final double bottomPadding;
  final double safeBottom;
  final LatLng? startLatLng;
  final LatLng? destinationLatLng;
  final bool canSwipe;
  final VoidCallback? onAddWaypoint;
  final VoidCallback? onEdit;
  final VoidCallback? onAddPressed;
  final VoidCallback? onLocationPressed;
  final bool showCompass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // 计算按钮的底部偏移
    double bottomOffset;
    double opacity;

    if (mapSheetType != MapOverlaySheetType.none) {
      if (mapSheetStage != MapOverlaySheetStage.expanded) {
        // 阶段一、二（collapsed, middle）：根据 sheet 高度平滑上移
        final sheetHeight = screenHeight * mapSheetSize;
        // 按钮需要上移到 sheet 上方，加上一些间距
        bottomOffset = sheetHeight + 16 + safeBottom;
        opacity = 1.0;
      } else {
        // 阶段三（expanded）：直接隐藏
        bottomOffset = bottomPadding;
        opacity = 0.0;
      }
    } else {
      // 没有 sheet，使用默认位置
      bottomOffset = bottomPadding;
      opacity = 1.0;
    }

    // 根据 sheet 类型获取按钮配置
    final buttonConfigs = _getButtonConfigs(context, theme);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 16,
      bottom: bottomOffset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: opacity,
        child: IgnorePointer(
          ignoring: opacity == 0.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: buttonConfigs
                .where((config) => config.visible)
                .map((config) {
              final index = buttonConfigs.indexOf(config);
              return Padding(
                padding: EdgeInsets.only(
                  top: index > 0 ? 8 : 0,
                  right: 0,
                ),
                child: AppFloatingActionButton(
                  heroTag: config.heroTag,
                  backgroundColor: config.backgroundColor,
                  foregroundColor: config.foregroundColor,
                  onPressed: config.onPressed,
                  tooltip: config.tooltip,
                  child: Icon(config.icon),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// 根据 sheet 类型获取按钮配置
  List<MapFloatingButtonConfig> _getButtonConfigs(
    BuildContext context,
    ThemeData theme,
  ) {
    // 创建活动模式（自驾游/城市活动）：显示编辑按钮
    if (mapSheetType == MapOverlaySheetType.createRoadTrip || 
        mapSheetType == MapOverlaySheetType.createCityEvent) {
      final hasLocation = startLatLng != null || destinationLatLng != null;

      return [
        MapFloatingButtonConfig(
          icon: Icons.edit,
          heroTag: 'events_map_edit_fab',
          backgroundColor: theme.colorScheme.tertiary,
          foregroundColor: theme.colorScheme.onTertiary,
          onPressed: onEdit ?? () {},
          tooltip: '编辑',
          visible: hasLocation,
        ),
      ];
    }

    // 默认模式：显示添加和定位按钮
    return [
      MapFloatingButtonConfig(
        icon: Icons.add,
        heroTag: 'events_map_add_fab',
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        onPressed: onAddPressed ?? () {},
        tooltip: '添加',
      ),
      MapFloatingButtonConfig(
        icon: showCompass ? Icons.explore : Icons.my_location,
        heroTag: 'events_map_my_location_fab',
        onPressed: onLocationPressed ?? () {},
        tooltip: showCompass ? '回正' : '定位',
      ),
    ];
  }
}

