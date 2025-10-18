import 'dart:async';

import 'package:crew_app/features/events/data/event_models.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/network/api_service.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:flutter_riverpod/legacy.dart';

class EventsMapSearchState {
  const EventsMapSearchState({
    this.query = '',
    this.showResults = false,
    this.isLoading = false,
    this.results = const <Event>[],
    this.errorText,
  });

  final String query;
  final bool showResults;
  final bool isLoading;
  final List<Event> results;
  final String? errorText;

  static const Object _sentinel = Object();

  EventsMapSearchState copyWith({
    String? query,
    bool? showResults,
    bool? isLoading,
    List<Event>? results,
    Object? errorText = _sentinel,
  }) {
    return EventsMapSearchState(
      query: query ?? this.query,
      showResults: showResults ?? this.showResults,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      errorText:
          identical(errorText, _sentinel) ? this.errorText : errorText as String?,
    );
  }
}

class EventsMapSearchController extends StateNotifier<EventsMapSearchState> {
  EventsMapSearchController(this._api) : super(const EventsMapSearchState());

  final ApiService _api;
  Timer? _debounce;

  void onFocusChanged(bool hasFocus) {
    if (hasFocus) {
      if (state.results.isNotEmpty || state.errorText != null) {
        state = state.copyWith(showResults: true);
      }
      return;
    }

    _debounce?.cancel();
    state = state.copyWith(showResults: false);
  }

  void onQueryChanged(String value) {
    _triggerSearch(value, immediate: false);
  }

  void onSubmitted(String value) {
    _triggerSearch(value, immediate: true);
  }

  void selectResult(Event event) {
    state = state.copyWith(
      query: event.title,
      showResults: false,
      isLoading: false,
      results: const <Event>[],
      errorText: null,
    );
  }

  void hideResults() {
    state = state.copyWith(showResults: false);
  }

  void clear() {
    _debounce?.cancel();
    state = const EventsMapSearchState();
  }

  void _triggerSearch(String keyword, {required bool immediate}) {
    _debounce?.cancel();

    final query = keyword.trim();
    if (query.isEmpty) {
      clear();
      return;
    }

    state = state.copyWith(
      query: query,
      showResults: true,
      isLoading: true,
      errorText: null,
    );

    if (immediate) {
      _performSearch(query);
    } else {
      _debounce = Timer(const Duration(milliseconds: 350), () {
        _performSearch(query);
      });
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      final data = await _api.searchEvents(query);
      if (mounted && state.query == query) {
        state = state.copyWith(
          results: data,
          errorText: null,
          isLoading: false,
        );
      }
    } on ApiException catch (error) {
      if (mounted && state.query == query) {
        state = state.copyWith(
          results: const <Event>[],
          errorText: error.message,
          isLoading: false,
        );
      }
    } catch (_) {
      if (mounted && state.query == query) {
        state = state.copyWith(
          results: const <Event>[],
          errorText: null,
          isLoading: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final eventsMapSearchControllerProvider =
    StateNotifierProvider.autoDispose<EventsMapSearchController, EventsMapSearchState>((ref) {
  final api = ref.read(apiServiceProvider);
  return EventsMapSearchController(api);
});
