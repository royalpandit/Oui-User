part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchEventSearch extends SearchEvent {
  final String search;
  final List<String> variantItems;
  final double? minPrice;
  final double? maxPrice;
  final int? shortingId;

  const SearchEventSearch(
    this.search, {
    this.variantItems = const [],
    this.minPrice,
    this.maxPrice,
    this.shortingId,
  });

  @override
  List<Object> get props => [search, variantItems, minPrice ?? -1, maxPrice ?? -1, shortingId ?? -1];
}

class SearchEventLoadMore extends SearchEvent {
  const SearchEventLoadMore();
}
