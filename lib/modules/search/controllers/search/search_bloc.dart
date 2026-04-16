import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/remote_urls.dart';
import '../../../../utils/constants.dart';
import '../../../home/model/product_model.dart';
import '../../model/search_response_model.dart';
import '../search_repository.dart';

import 'package:stream_transform/stream_transform.dart';
part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;

  SearchResponseModel? _searchResponseModel;
  List<ProductModel> products = [];

  SearchBloc({
    required SearchRepository searchRepository,
  })  : _searchRepository = searchRepository,
        super(const SearchStateInitial()) {
    on<SearchEventSearch>(_search, transformer: debounce());
    on<SearchEventLoadMore>(_loadMore);
  }

  void _search(SearchEventSearch event, Emitter<SearchState> emit) async {
    emit(const SearchStateLoading());

    final queryParams = <String, String>{};
    if (event.search.isNotEmpty) {
      queryParams['search'] = event.search;
    }
    if (event.minPrice != null) {
      queryParams['min_price'] = event.minPrice!.toString();
    }
    if (event.maxPrice != null) {
      queryParams['max_price'] = event.maxPrice!.toString();
    }
    if (event.shortingId != null) {
      queryParams['shorting_id'] = event.shortingId.toString();
    }

    final variants = event.variantItems
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList();
    final queryParts = <String>[];
    queryParams.forEach((key, value) {
      queryParts.add(
        '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}',
      );
    });
    for (final item in variants) {
      queryParts.add(
        '${Uri.encodeQueryComponent('variantItems[]')}=${Uri.encodeQueryComponent(item)}',
      );
    }

    final uri = Uri.parse(RemoteUrls.searchProduct).replace(
      query: queryParts.isEmpty ? null : queryParts.join('&'),
    );

    final result = await _searchRepository.search(uri);

    result.fold((failure) {
      emit(SearchStateError(failure.message, failure.statusCode));
    }, (successData) {
      _searchResponseModel = successData;

      products = successData.products;

      emit(SearchStateLoaded(successData.products));
    });
  }

  void _loadMore(SearchEventLoadMore event, Emitter<SearchState> emit) async {
    if (state is SearchStateLoadMore) return;
    if (_searchResponseModel == null ||
        _searchResponseModel!.nextPageUrl == null) {
      return;
    }

    emit(const SearchStateLoadMore());

    final uri = Uri.parse(_searchResponseModel!.nextPageUrl!);

    final result = await _searchRepository.search(uri);

    result.fold(
      (failure) {
        emit(SearchStateMoreError(failure.message, failure.statusCode));
      },
      (successData) {
        _searchResponseModel = successData;
        products.addAll(successData.products);

        emit(SearchStateMoreLoaded(products.toSet().toList()));
      },
    );
  }
}

EventTransformer<Event> debounce<Event>() {
  return (events, mapper) => events.debounce(kDuration).switchMap(mapper);
}
