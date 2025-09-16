import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/state/di/providers.dart';
import '../../data/event.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const <Event>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final List<Event> results;
  final bool isLoading;
  final String? errorMessage;

  bool get hasQuery => query.trim().isNotEmpty;

  SearchState copyWith({
    String? query,
    List<Event>? results,
    bool? isLoading,
    bool clearError = false,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SearchController extends StateNotifier<SearchState> {
  SearchController(this._api) : super(const SearchState());

  final ApiService _api;

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      query: query,
      isLoading: true,
      clearError: true,
    );

    try {
      final events = await _api.searchEvents(query);
      state = state.copyWith(
        results: events,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        results: const <Event>[],
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        results: const <Event>[],
        errorMessage: e.toString(),
      );
    }
  }

  void updateQuery(String query) {
    if (query.isEmpty) {
      state = const SearchState();
    } else {
      state = state.copyWith(
        query: query,
        clearError: true,
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return SearchController(api);
});
