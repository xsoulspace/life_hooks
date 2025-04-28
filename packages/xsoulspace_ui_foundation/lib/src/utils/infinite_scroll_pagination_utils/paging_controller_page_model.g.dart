// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paging_controller_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagingControllerPageModel<E> _$PagingControllerPageModelFromJson<E>(
  Map<String, dynamic> json,
  E Function(Object? json) fromJsonE,
) =>
    PagingControllerPageModel<E>(
      values: (json['values'] as List<dynamic>).map(fromJsonE).toList(),
      currentPage: (json['currentPage'] as num).toInt(),
      pagesCount: (json['pagesCount'] as num).toInt(),
    );

Map<String, dynamic> _$PagingControllerPageModelToJson<E>(
  PagingControllerPageModel<E> instance,
  Object? Function(E value) toJsonE,
) =>
    <String, dynamic>{
      'values': instance.values.map(toJsonE).toList(),
      'pagesCount': instance.pagesCount,
      'currentPage': instance.currentPage,
    };
