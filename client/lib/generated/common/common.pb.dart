// This is a generated file - do not edit.
//
// Generated from common/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'common.pbenum.dart';

class Timestamp extends $pb.GeneratedMessage {
  factory Timestamp({
    $fixnum.Int64? seconds,
    $core.int? nanos,
  }) {
    final result = create();
    if (seconds != null) result.seconds = seconds;
    if (nanos != null) result.nanos = nanos;
    return result;
  }

  Timestamp._();

  factory Timestamp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Timestamp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Timestamp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.common'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seconds')
    ..aI(2, _omitFieldNames ? '' : 'nanos')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Timestamp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Timestamp copyWith(void Function(Timestamp) updates) =>
      super.copyWith((message) => updates(message as Timestamp)) as Timestamp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Timestamp create() => Timestamp._();
  @$core.override
  Timestamp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Timestamp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Timestamp>(create);
  static Timestamp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seconds => $_getI64(0);
  @$pb.TagNumber(1)
  set seconds($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeconds() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeconds() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get nanos => $_getIZ(1);
  @$pb.TagNumber(2)
  set nanos($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNanos() => $_has(1);
  @$pb.TagNumber(2)
  void clearNanos() => $_clearField(2);
}

/// Represents a date (year, month, day)
class TmsDate extends $pb.GeneratedMessage {
  factory TmsDate({
    $core.int? year,
    $core.int? month,
    $core.int? day,
  }) {
    final result = create();
    if (year != null) result.year = year;
    if (month != null) result.month = month;
    if (day != null) result.day = day;
    return result;
  }

  TmsDate._();

  factory TmsDate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TmsDate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TmsDate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.common'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'year')
    ..aI(2, _omitFieldNames ? '' : 'month')
    ..aI(3, _omitFieldNames ? '' : 'day')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TmsDate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TmsDate copyWith(void Function(TmsDate) updates) =>
      super.copyWith((message) => updates(message as TmsDate)) as TmsDate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TmsDate create() => TmsDate._();
  @$core.override
  TmsDate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TmsDate getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TmsDate>(create);
  static TmsDate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get year => $_getIZ(0);
  @$pb.TagNumber(1)
  set year($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasYear() => $_has(0);
  @$pb.TagNumber(1)
  void clearYear() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get month => $_getIZ(1);
  @$pb.TagNumber(2)
  set month($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get day => $_getIZ(2);
  @$pb.TagNumber(3)
  set day($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDay() => $_has(2);
  @$pb.TagNumber(3)
  void clearDay() => $_clearField(3);
}

/// Represents a time of day
class TmsTime extends $pb.GeneratedMessage {
  factory TmsTime({
    $core.int? hour,
    $core.int? minute,
    $core.int? second,
  }) {
    final result = create();
    if (hour != null) result.hour = hour;
    if (minute != null) result.minute = minute;
    if (second != null) result.second = second;
    return result;
  }

  TmsTime._();

  factory TmsTime.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TmsTime.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TmsTime',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.common'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'hour', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'minute', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'second', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TmsTime clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TmsTime copyWith(void Function(TmsTime) updates) =>
      super.copyWith((message) => updates(message as TmsTime)) as TmsTime;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TmsTime create() => TmsTime._();
  @$core.override
  TmsTime createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TmsTime getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TmsTime>(create);
  static TmsTime? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get hour => $_getIZ(0);
  @$pb.TagNumber(1)
  set hour($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHour() => $_has(0);
  @$pb.TagNumber(1)
  void clearHour() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minute => $_getIZ(1);
  @$pb.TagNumber(2)
  set minute($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinute() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinute() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get second => $_getIZ(2);
  @$pb.TagNumber(3)
  set second($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSecond() => $_has(2);
  @$pb.TagNumber(3)
  void clearSecond() => $_clearField(3);
}

/// Represents a date and/or time
/// Can contain just date, just time, or both
class TmsDateTime extends $pb.GeneratedMessage {
  factory TmsDateTime({
    TmsDate? date,
    TmsTime? time,
  }) {
    final result = create();
    if (date != null) result.date = date;
    if (time != null) result.time = time;
    return result;
  }

  TmsDateTime._();

  factory TmsDateTime.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TmsDateTime.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TmsDateTime',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tms.common'),
      createEmptyInstance: create)
    ..aOM<TmsDate>(1, _omitFieldNames ? '' : 'date', subBuilder: TmsDate.create)
    ..aOM<TmsTime>(2, _omitFieldNames ? '' : 'time', subBuilder: TmsTime.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TmsDateTime clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TmsDateTime copyWith(void Function(TmsDateTime) updates) =>
      super.copyWith((message) => updates(message as TmsDateTime))
          as TmsDateTime;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TmsDateTime create() => TmsDateTime._();
  @$core.override
  TmsDateTime createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TmsDateTime getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TmsDateTime>(create);
  static TmsDateTime? _defaultInstance;

  @$pb.TagNumber(1)
  TmsDate get date => $_getN(0);
  @$pb.TagNumber(1)
  set date(TmsDate value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);
  @$pb.TagNumber(1)
  TmsDate ensureDate() => $_ensure(0);

  @$pb.TagNumber(2)
  TmsTime get time => $_getN(1);
  @$pb.TagNumber(2)
  set time(TmsTime value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => $_clearField(2);
  @$pb.TagNumber(2)
  TmsTime ensureTime() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
