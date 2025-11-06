import 'dart:async';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker_map_page.dart';

/// 地址搜索页面
class LocationSearchPage extends ConsumerStatefulWidget {
  const LocationSearchPage({
    super.key,
    required this.onLocationSelected,
    this.initialQuery,
    this.initialLocation,
    this.title,
  });

  final ValueChanged<PlaceDetails> onLocationSelected;
  final String? initialQuery;
  final LatLng? initialLocation;
  final String? title;

  @override
  ConsumerState<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends ConsumerState<LocationSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  List<PlaceDetails> _searchResults = [];
  bool _isSearching = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorText = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorText = null;
    });

    try {
      final placesService = ref.read(placesServiceProvider);
      final results = await placesService.searchPlacesByText(
        query,
        locationBias: widget.initialLocation,
        maxResults: 10,
      );

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
        if (results.isEmpty) {
          _errorText = '未找到相关地址';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorText = '搜索失败，请重试';
      });
    }
  }

  void _onResultTap(PlaceDetails place) {
    widget.onLocationSelected(place);
    Navigator.of(context).pop();
  }

  void _onFindOnMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPickerMapPage(
          initialLocation: widget.initialLocation,
          onLocationSelected: (latLng, address) {
            // 创建一个临时的PlaceDetails
            final place = PlaceDetails(
              id: 'picked_${latLng.latitude}_${latLng.longitude}',
              displayName: address ?? '已选择的位置',
              formattedAddress: address,
              location: latLng,
            );
            widget.onLocationSelected(place);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? loc.map_select_location_title),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '输入地址或地点名称',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _focusNode.requestFocus();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // "在地图上查找"按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _onFindOnMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('在地图上查找'),
              ),
            ),
          ),
          const Divider(height: 1),
          // 搜索结果列表
          Expanded(
            child: _buildResultsList(theme, loc),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme, AppLocalizations loc) {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '输入地址或地点名称进行搜索',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        return ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(place.displayName.truncate(maxLength: 30)),
          subtitle: place.formattedAddress != null
              ? Text(
                  place.formattedAddress!.truncate(maxLength: 30),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          onTap: () => _onResultTap(place),
        );
      },
    );
  }
}

