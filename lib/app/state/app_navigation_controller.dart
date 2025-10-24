import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_overlay_provider.dart';

typedef SheetLauncher = Future<void> Function();

class AppNavigationController extends ChangeNotifier {
  AppNavigationController(this._ref) {
    _overlayIndexSubscription = _ref.listen<int>(
      appOverlayIndexProvider,
      (previous, next) {
        if (next == _index) {
          return;
        }
        _index = next;
        if (next == _mapIndex) {
          _isScrolling = false;
        }
        notifyListeners();
        _animateOverlayTo(next);
      },
    );
  }

  static const _mapIndex = 1;

  final Ref _ref;
  late final ProviderSubscription<int> _overlayIndexSubscription;
  final PageController overlayController = PageController(initialPage: _mapIndex);

  int _index = _mapIndex;
  int _navigationIndex = _mapIndex;
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;

  int get index => _index;
  int get navigationIndex => _navigationIndex;
  bool get isScrolling => _isScrolling;
  bool get isOverlayOpen => _index != _mapIndex;

  void handleScrollActivity(bool scrolling) {
    _scrollDebounceTimer?.cancel();
    if (scrolling) {
      if (!_isScrolling) {
        _isScrolling = true;
        notifyListeners();
      }
      return;
    }

    _scrollDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_isScrolling) {
        _isScrolling = false;
        notifyListeners();
      }
    });
  }

  Future<void> onDestinationSelected(
    int destinationIndex, {
    required SheetLauncher showEventsSheet,
    required SheetLauncher showChatSheet,
  }) async {
    if (destinationIndex == 0) {
      _setNavigationIndex(0);
      await showEventsSheet();
      _setNavigationIndex(_mapIndex);
      return;
    }

    if (destinationIndex == 2) {
      _setNavigationIndex(2);
      await showChatSheet();
      _setNavigationIndex(_mapIndex);
      return;
    }

    _setNavigationIndex(_mapIndex);
    if (_index != _mapIndex) {
      closeOverlay();
    }
  }

  void onOverlayPageChanged(int page) {
    final shouldUpdateIndex = _index != page;
    final shouldResetScroll = page == _mapIndex && _isScrolling;
    if (!shouldUpdateIndex && !shouldResetScroll) {
      return;
    }

    if (shouldUpdateIndex) {
      _index = page;
    }
    if (page == _mapIndex) {
      _isScrolling = false;
    }
    notifyListeners();

    final overlayNotifier = _ref.read(appOverlayIndexProvider.notifier);
    if (overlayNotifier.state != page) {
      overlayNotifier.state = page;
    }
  }

  void closeOverlay() {
    final overlayNotifier = _ref.read(appOverlayIndexProvider.notifier);
    if (overlayNotifier.state == _mapIndex) {
      return;
    }
    overlayNotifier.state = _mapIndex;
  }

  void _setNavigationIndex(int index) {
    if (_navigationIndex == index) {
      return;
    }
    _navigationIndex = index;
    notifyListeners();
  }

  void _animateOverlayTo(int page) {
    if (!overlayController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateOverlayTo(page);
      });
      return;
    }
    overlayController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    overlayController.dispose();
    _scrollDebounceTimer?.cancel();
    _overlayIndexSubscription.close();
    super.dispose();
  }
}

final appNavigationControllerProvider =
    AutoDisposeChangeNotifierProvider<AppNavigationController>(
  AppNavigationController.new,
);
