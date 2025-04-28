import 'package:freezed_annotation/freezed_annotation.dart';

part 'paging_controller_page_model.g.dart';

@immutable
@JsonSerializable(
  explicitToJson: true,
  genericArgumentFactories: true,
)
class PagingControllerPageModel<E> {
  const PagingControllerPageModel({
    required this.values,
    required this.currentPage,
    required this.pagesCount,
  });
  factory PagingControllerPageModel.fromJson(
    final Map<String, dynamic> json,
    final E Function(Object? json) fromJsonT,
  ) =>
      _$PagingControllerPageModelFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(
    final Map<String, dynamic> Function(E) toJsonT,
  ) =>
      _$PagingControllerPageModelToJson(this, toJsonT);

  final List<E> values;
  final int pagesCount;
  final int currentPage;

  PagingControllerPageModel<E> copyWith({
    final List<E>? values,
    final int? pagesCount,
    final int? currentPage,
  }) =>
      PagingControllerPageModel<E>(
        values: values ?? this.values,
        pagesCount: pagesCount ?? this.pagesCount,
        currentPage: currentPage ?? this.currentPage,
      );
}
