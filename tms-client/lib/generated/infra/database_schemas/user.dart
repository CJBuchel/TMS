// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `fmt`

class User {
  final String username;
  final String password;
  final List<String> roles;

  const User({
    required this.username,
    required this.password,
    required this.roles,
  });

  static Future<User> default_() =>
      TmsRustLib.instance.api.crateInfraDatabaseSchemasUserUserDefault();

  static User fromJsonString({required String json}) => TmsRustLib.instance.api
      .crateInfraDatabaseSchemasUserUserFromJsonString(json: json);

  String toJsonString() =>
      TmsRustLib.instance.api.crateInfraDatabaseSchemasUserUserToJsonString(
        that: this,
      );

  static String toSchema() =>
      TmsRustLib.instance.api.crateInfraDatabaseSchemasUserUserToSchema();

  @override
  int get hashCode => username.hashCode ^ password.hashCode ^ roles.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password &&
          roles == other.roles;
}
