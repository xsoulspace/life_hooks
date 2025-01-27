# Infinite Scroll Pagination Utils

This module is designed to complement the `infinite_scroll_pagination` package by packing all required features to plug in and play with requests and design, and not worry about how pagination works.

## Key Components

- **PagingControllerRequestsBuilder**: Extend to define how data should be fetched.
- **BasePagingController**: Should be extended to classes to have strong types.
  Initializes HashPagingController which in its turn extended PagingController with additional functions.
  Also provides an easy way to write different requests builders (for filtering, different screens).
- **HashPagingController**: Extends PagingController with additional functions, to move, delete, insert items and append, prepend pages.
- **PagingControllerPageModel**: Use it for page data in request builders.

## How to Use

1. **Implement PagingControllerRequestsBuilder**:

For example, we have a `Todo` model and a `TodoApi` class.

```dart
class TodoPagingControllerRequestsBuilder extends PagingControllerRequestsBuilder<Todo> {
  TodoPagingControllerRequestsBuilder({
    required super.onLoadData,
  });

  factory TodoPagingControllerRequestsBuilder.mockRequest() async => TodoPagingControllerRequestsBuilder(
        onLoadData: (final pageKey) async => TodoPagingControllerPageModel(
          values: [Todo(id: '1', title: 'Todo 1', description: 'Description 1')],
          currentPage: 1,
          pagesCount: 1,
        ),
      );

  factory TodoPagingControllerRequestsBuilder.allTodos({
    required TodoApi todoApi,
  }) async => TodoPagingControllerRequestsBuilder(
        onLoadData: (final pageKey) async => todoApi.getPaginatedTodos(pageKey),
      );
}
```

2. Then extend `BasePagingController`

```dart
class TodoPagingController extends BasePagingController<Todo> {
  TodoPagingController({
    required this.requestBuilder,
  });
  @override
  final TodoPagingControllerRequestsBuilder requestBuilder;
}
```

3. Use it with any state management package.

```dart
class TodosNotifier with ChangeNotifier {
  TodosNotifier({
    required this.todoApi,
  });
  final TodoApi todoApi;
  late final todoPagingController = TodoPagingController(
    requestBuilder: TodoPagingControllerRequestsBuilder.allTodos(todoApi: todoApi),
  );

  /// Use this method to initialize the controller.
  void onLoad() {
    todoPagingController
      ..loadData()
      ..loadFirstPage();
  }

  /// Cleans data and loads the data from the first page.
  void reload() {
    todoPagingController
      ..refresh()
      ..loadFirstPage();
  }

  @override
  void dispose() {
    todoPagingController.dispose();
    super.dispose();
  }
}
```
