import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:tms_client/utils/logger.dart';

Future<T> callGrpcEndpoint<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on GrpcError catch (e) {
    logger.e('gRPC Error: [${e.code}:${e.codeName}] ${e.message}');

    // TODO: show popup to user
    final userMessage = switch (e.code) {
      StatusCode.unauthenticated => 'Invalid credentials',
      StatusCode.permissionDenied => 'Permission denied',
      StatusCode.internal => 'Server error occurred',
      StatusCode.unavailable => 'Server unavailable',
      StatusCode.invalidArgument => 'Invalid request',
      StatusCode.notFound => 'Resource not found',
      _ => e.message ?? 'An error occurred',
    };

    throw Exception(userMessage);
  } catch (e) {
    logger.e('Unexpected error: $e');
    // TODO: show popup to user
    throw Exception('An unexpected error occurred');
  }
}
