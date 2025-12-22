import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/api/tournament.pbgrpc.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/helpers/grpc_call_wrapper.dart';
import 'package:tms_client/providers/tournament_provider.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/widgets/dialogs/popup_dialog.dart';

/// Custom hook that provides a function to update the tournament.
///
/// Must be used inside a HookConsumerWidget. Pass the WidgetRef from the build method.
///
/// Returns a callback that takes the current tournament and a modification function.
/// Automatically handles deep copying, sending the update, and showing error dialogs.
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final tournament = ref.watch(tournamentStreamProvider);
///   final updateTournament = useTournamentUpdater(ref);
///
///   // Later...
///   await updateTournament(
///     tournament.value!.tournament,
///     (t) => t.backupInterval = 30,
///   );
/// }
/// ```
Future<GrpcResult<SetTournamentResponse>> Function(
  Tournament currentTournament,
  void Function(Tournament) modify,
)
useTournamentUpdater(WidgetRef ref) {
  final context = useContext();

  return useCallback((
    Tournament currentTournament,
    void Function(Tournament) modify,
  ) async {
    // Create a deep copy to avoid modifying the original
    final updated = currentTournament.deepCopy();

    // Apply the modification
    modify(updated);

    // Send the update request
    final req = SetTournamentRequest(tournament: updated);
    final res = await callGrpcEndpoint(
      () => ref.read(tournamentServiceProvider).setTournament(req),
    );

    // Show error dialog if request failed
    if (context.mounted && res is GrpcFailure) {
      PopupDialog.fromGrpcStatus(result: res).show(context);
    }

    return res;
  }, [ref]);
}
