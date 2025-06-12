import 'package:flutter/foundation.dart';

@immutable
class PagingControllerPageModel<E> {
  const PagingControllerPageModel({
    required this.values,
    required this.currentPage,
    required this.pagesCount,
  });
  factory PagingControllerPageModel.fromJson(
    final Map<String, dynamic> json,
    final E Function(Object? json) fromJsonT,
  ) => _$PagingControllerPageModelFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(final Map<String, dynamic> Function(E) toJsonT) =>
      _$PagingControllerPageModelToJson(this, toJsonT);

  final List<E> values;
  final int pagesCount;
  final int currentPage;

  PagingControllerPageModel<E> copyWith({
    final List<E>? values,
    final int? pagesCount,
    final int? currentPage,
  }) => PagingControllerPageModel<E>(
    values: values ?? this.values,
    pagesCount: pagesCount ?? this.pagesCount,
    currentPage: currentPage ?? this.currentPage,
  );
}

PagingControllerPageModel<E> _$PagingControllerPageModelFromJson<E>(
  final Map<String, dynamic> json,
  final E Function(Object? json) fromJsonE,
) => PagingControllerPageModel<E>(
  values: (json['values'] as List<dynamic>).map(fromJsonE).toList(),
  currentPage: (json['currentPage'] as num).toInt(),
  pagesCount: (json['pagesCount'] as num).toInt(),
);

Map<String, dynamic> _$PagingControllerPageModelToJson<E>(
  final PagingControllerPageModel<E> instance,
  final Object? Function(E value) toJsonE,
) => <String, dynamic>{
  'values': instance.values.map(toJsonE).toList(),
  'pagesCount': instance.pagesCount,
  'currentPage': instance.currentPage,
};
