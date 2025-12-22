import 'package:grpc/grpc.dart';

/// Helper function to create CallOptions with JWT authentication
/// Usage: final options = authCallOptions(token);
CallOptions? authCallOptions(String? token) {
  if (token == null || token.isEmpty) {
    return null;
  }

  return CallOptions(metadata: {'authorization': 'Bearer $token'});
}
