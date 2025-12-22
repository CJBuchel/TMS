import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/utils/logger.dart';

/// Wraps a gRPC call and returns a Result type instead of throwing exceptions
Future<GrpcResult<T>> callGrpcEndpoint<T>(Future<T> Function() fn) async {
  try {
    final result = await fn();
    return GrpcSuccess(result);
  } on GrpcError catch (e) {
    logger.e('gRPC Error: [${e.code}:${e.codeName}] ${e.message}');

    final userMessage = StatusCode.name(e.code) ?? 'An error occurred';

    return GrpcFailure(
      userMessage: userMessage,
      statusCode: e.code,
      technicalMessage: e.message,
    );
  } catch (e) {
    logger.e('Unexpected error: $e');
    return GrpcFailure(
      userMessage: 'An unexpected error occurred',
      technicalMessage: e.toString(),
    );
  }
}
