// lib/features/search/cubit/search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:glovoapotheka/features/search/cubit/search_state.dart'; // State
import 'package:glovoapotheka/domain/repositories/product_repository.dart'; // <--- IMPORT YOUR REPOSITORY INTERFACE

class SearchCubit extends Cubit<SearchState> {
  // 1. DEPENDENCY: The Cubit depends on the Repository
  final ProductRepository _productRepository;
  final _searchController = BehaviorSubject<String>();

  // 2. CONSTRUCTOR: Receive the repository as a dependency
  SearchCubit(this._productRepository) : super(SearchInitial()) {
    // Debounce to prevent querying on every keystroke
    _searchController
        .debounceTime(const Duration(milliseconds: 600))
        .distinct()
        .listen((query) {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        emit(SearchInitial()); 
      }
    });
  }

  void search(String query) {
    print('Search called with query: $query'); // Add this
    final trimmedQuery = query.trim();
    _searchController.add(trimmedQuery);
  }

  Future<void> _performSearch(String query) async {
    // 4. EMIT LOADING STATE
    emit(SearchLoading());
    try {
      // 5. CALL REPOSITORY: The Cubit's only job is to tell the repository to search.
      // It has no idea whether it's an API call, database query, etc.
      final results = await _productRepository.search(query: query);
      
      // 6. EMIT LOADED STATE
      emit(SearchLoaded(results: results));
    } catch (e) {
      // 7. EMIT ERROR STATE
      emit(SearchError(message: "Search failed: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _searchController.close();
    return super.close();
  }
}