import 'package:flutter/foundation.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import 'infinite_scroll_pagination_utils.dart';

extension type UnifiedPagingControllerId(String value) {}

typedef PagingControllerLoadFunction<TModel> =
    Future<PagingControllerPageModel<TModel>> Function(int page);

abstract class PagingControllerRequestsBuilder<TModel> {
  PagingControllerRequestsBuilder({required this.onLoadData});
  final PagingControllerLoadFunction<TModel> onLoadData;
}

/// To initialize the class use [onLoad] and [loadFirstPage]
/// or call [addDataListener].
///
/// In case of [addDataListener]
/// don't forget to call [removeDataListener] in your class dispose method.
abstract base class BasePagingController<TItem> implements Disposable {
  BasePagingController({
    this.addEmptyFirstItem = false,
    this.emptyItemBuilder,
    final int firstPageKey = 1,
  }) : _firstPageKey = firstPageKey,
       assert(
         // ignore: avoid_bool_literals_in_conditional_expressions
         addEmptyFirstItem ? emptyItemBuilder != null : true,
         'emptyItemBuilder must not be null',
       ) {
    pager.addListener(_onPagerChanged);
  }
  late final int _firstPageKey;
  final bool addEmptyFirstItem;
  final ValueGetter<TItem>? emptyItemBuilder;
  late final pager = HashPagingController<int, TItem>(
    firstPageKey: _firstPageKey,
  );
  final id = UnifiedPagingControllerId(IdCreator.create());
  List<TItem> get items => pager.itemList ?? [];
  final _itemsCountListeners = <ValueChanged<int>>{};
  var _lastItemsCount = 0;

  PagingControllerRequestsBuilder<TItem> get requestBuilder;

  void onLoad() => addDataListener();

  /// ********************************************
  /// *      PAGER LISTENERS START
  /// ********************************************
  void _onPagerChanged() {
    // ignore: unnecessary_parenthesis
    final newCount = (pager.itemList?.length) ?? 0;
    if (newCount != _lastItemsCount) {
      _lastItemsCount = newCount;
      _itemsCountListeners.forEach(_onItemsCountChanged);
    }
  }

  void _onItemsCountChanged(final ValueChanged<int> listener) {
    listener(_lastItemsCount);
  }

  /// will be triggered when count changes
  void addItemsCountListener(final ValueChanged<int> listener) {
    _itemsCountListeners.add(listener);
  }

  void removeItemsCountListener(final ValueChanged<int> listener) {
    _itemsCountListeners.remove(listener);
  }

  /// ********************************************
  /// *      PAGER LISTENERS END
  /// ********************************************

  void addDataListener() => pager.addPageRequestListener(_onPageRequest);
  void removeDataListener() => pager.removePageRequestListener(_onPageRequest);

  Future<void> _onPageRequest(final int pageKey) async {
    final response = await requestBuilder.onLoadData(pageKey);
    final values = response.values;
    if (pager.value.nextPageKey == null) return;
    if (pageKey == pager.firstPageKey && addEmptyFirstItem) {
      values.insert(0, emptyItemBuilder!());
    }
    if (response.currentPage <
        (pager.value.nextPageKey ?? pager.firstPageKey)) {
      return;
    }
    if (response.pagesCount == 0 ||
        response.pagesCount == response.currentPage) {
      pager.appendLastPage(response.values);
    } else {
      pager.appendPage(response.values, response.currentPage + 1);
    }
  }

  void loadFirstPage() => pager.notifyPageRequestListeners(pager.firstPageKey);
  void refresh() => pager.refresh();
  void refreshWithoutNotify() => pager.refreshWithoutNotify();

  void insertItem(final TItem item, {final int at = 0}) =>
      pager.insertElements([item], at: at);
  void insertItems(final List<TItem> items, {final int at = 0}) =>
      pager.insertElements(items, at: at);
  void moveElementFirst({
    required final TItem element,
    final bool shouldAddOnNotFound = false,
  }) {
    final index = items.indexWhere((final e) => e == element);
    if (index >= 0) {
      moveElementByIndex(element: element, index: index);
    } else if (shouldAddOnNotFound) {
      insertItem(element);
    }
  }

  /// removes element from listing at given [index], then reinserts it
  /// at [moveToIndex]
  void moveElementByIndex({
    required final int index,
    required final TItem element,

    /// target index after element removal
    final int moveToIndex = 0,
  }) => pager.moveElementByIndex(
    element: element,
    newIndex: moveToIndex,
    oldIndex: index,
  );
  void replaceItem(
    final TItem item, {
    final bool shouldAddOnNotFound = false,
    final bool Function(TItem a, TItem b)? equals,
    final int? index,
  }) => pager.replaceElement(
    element: item,
    shouldAddOnNotFound: shouldAddOnNotFound,
    equals: equals,
    index: index,
  );

  void deleteItem(final TItem item) => pager.removeElement(element: item);
  TItem? deleteItemWhere(final bool Function(TItem element) test) =>
      pager.removeElementWhere(test: test);
  Iterable<TItem> deleteItemsWhere(final bool Function(TItem element) test) =>
      pager.removeElementsWhere(test: test);
  void deleteItems(final List<TItem> items) => items.forEach(deleteItem);
  ({TItem? item, int index}) getItem(final bool Function(TItem) test) {
    final index = items.indexWhere(test);
    if (index < 0) return (index: index, item: null);
    return (index: index, item: items[index]);
  }

  @override
  void dispose() {
    _itemsCountListeners.clear();
    pager.removeListener(_onPagerChanged);

    removeDataListener();
    pager.dispose();
  }
}
