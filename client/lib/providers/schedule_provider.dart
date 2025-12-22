import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/generated/api/schedule.pbgrpc.dart';
import 'package:tms_client/helpers/auth_interceptor.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/providers/grpc_channel_provider.dart';

part 'schedule_provider.g.dart';

@Riverpod(keepAlive: true)
ScheduleServiceClient scheduleService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return ScheduleServiceClient(channel, options: options);
}
