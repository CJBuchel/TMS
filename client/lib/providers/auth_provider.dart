import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/user.pbgrpc.dart';
import 'package:tms_client/generated/common/common.pbenum.dart';
import 'package:tms_client/helpers/grpc_call_wrapper.dart';
import 'package:tms_client/helpers/local_storage.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';
import 'package:tms_client/utils/grpc_result.dart';

part 'auth_provider.g.dart';

@riverpod
class Token extends _$Token {
  final _tokenKey = 'jwt_token';

  Future<void> set(String token) async {
    await localStorage.setString(_tokenKey, token);
    state = token;
  }

  void clear() async {
    await localStorage.remove(_tokenKey);
    state = null;
  }

  @override
  String? build() {
    return localStorage.getString(_tokenKey) ?? '';
  }
}

@riverpod
class Username extends _$Username {
  final _usernameKey = 'username';

  Future<void> set(String username) async {
    await localStorage.setString(_usernameKey, username);
    state = username;
  }

  Future<void> clear() async {
    await localStorage.remove(_usernameKey);
    state = null;
  }

  @override
  String? build() {
    return localStorage.getString(_usernameKey) ?? '';
  }
}

@riverpod
class Roles extends _$Roles {
  final _rolesKey = 'user_roles';

  Future<void> set(List<Role> roles) async {
    await localStorage.setStringList(
      _rolesKey,
      roles.map((role) => role.value.toString()).toList(),
    );
    state = roles;
  }

  Future<void> clear() async {
    await localStorage.remove(_rolesKey);
    state = [];
  }

  @override
  List<Role> build() {
    final roleStrings = localStorage.getStringList(_rolesKey) ?? [];
    return roleStrings
        .map((str) => int.tryParse(str))
        .whereType<int>()
        .map((value) => Role.valueOf(value))
        .whereType<Role>()
        .toList();
  }
}

@Riverpod(keepAlive: true)
class UserService extends _$UserService {
  Future<GrpcResult<LoginResponse>> login(
    String username,
    String password,
  ) async {
    final response = await callGrpcEndpoint(() async {
      final request = LoginRequest(username: username, password: password);
      return await state.login(request);
    });

    if (response is GrpcSuccess<LoginResponse>) {
      final loginResponse = response.data;
      ref.read(usernameProvider.notifier).state = username;
      ref.read(tokenProvider.notifier).state = loginResponse.token;
      ref.read(rolesProvider.notifier).state = loginResponse.roles.toList();
    }

    return response;
  }

  void logout() {
    ref.read(usernameProvider.notifier).clear();
    ref.read(tokenProvider.notifier).clear();
    ref.read(rolesProvider.notifier).clear();
  }

  @override
  UserServiceClient build() {
    final channel = ref.watch(grpcChannelProvider);
    return UserServiceClient(channel);
  }
}

@riverpod
bool isLoggedIn(Ref ref) {
  final token = ref.watch(tokenProvider);
  return token?.isNotEmpty ?? false;
}
