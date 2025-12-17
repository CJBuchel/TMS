/// Represents the result of a gRPC call - either success with data or failure with error info
sealed class GrpcResult<T> {
  const GrpcResult();
}

/// Successful gRPC call result
final class GrpcSuccess<T> extends GrpcResult<T> {
  final T data;
  const GrpcSuccess(this.data);
}

/// Failed gRPC call result with user-friendly message and original error
final class GrpcFailure<T> extends GrpcResult<T> {
  final String userMessage;
  final int? statusCode;
  final String? technicalMessage;

  const GrpcFailure({
    required this.userMessage,
    this.statusCode,
    this.technicalMessage,
  });
}
