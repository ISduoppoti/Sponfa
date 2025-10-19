import 'package:equatable/equatable.dart';
import 'package:glovoapotheka/data/models/product.dart'; // Adjust import

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

// Initial state, before any search is performed
class SearchInitial extends SearchState {}

// State when we are actively fetching results
class SearchLoading extends SearchState {}

// State when search results are successfully loaded
class SearchLoaded extends SearchState {
  final List<ProductSearchItem> results;

  const SearchLoaded({required this.results});

  @override
  List<Object> get props => [results];
}

// State when an error occurs during search
class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object> get props => [message];
}