import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/api/game_match.pb.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/helpers/grpc_call_wrapper.dart';
import 'package:tms_client/providers/match_provider.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/widgets/signature_pad.dart';

/// Referee page: pick a match + table, then have the team sign off the score.
class RefereeView extends ConsumerWidget {
  const RefereeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesProvider);

    if (matches.isEmpty) {
      return const Center(child: Text('No matches'));
    }

    final entries = matches.entries.toList()
      ..sort(
        (a, b) => _compareMatchNumber(a.value.matchNumber, b.value.matchNumber),
      );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in entries)
          Card(
            child: ExpansionTile(
              title: Text('Match ${entry.value.matchNumber}'),
              children: [
                for (final assignment in entry.value.assignments)
                  ListTile(
                    leading: const Icon(Icons.draw),
                    title: Text('Table ${assignment.tableId}'),
                    subtitle: Text('Team ${assignment.teamId}'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TeamSignatureScreen(
                          matchId: entry.key,
                          match: entry.value,
                          assignment: assignment,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static int _compareMatchNumber(String a, String b) {
    final an = int.tryParse(a);
    final bn = int.tryParse(b);
    if (an != null && bn != null) return an.compareTo(bn);
    return a.compareTo(b);
  }
}

/// Full-screen sign-off for one team at one table, shown before submitting.
class TeamSignatureScreen extends ConsumerStatefulWidget {
  final String matchId;
  final GameMatch match;
  final TableAssignment assignment;

  const TeamSignatureScreen({
    super.key,
    required this.matchId,
    required this.match,
    required this.assignment,
  });

  @override
  ConsumerState<TeamSignatureScreen> createState() =>
      _TeamSignatureScreenState();
}

class _TeamSignatureScreenState extends ConsumerState<TeamSignatureScreen> {
  final _controller = SignaturePadController();
  final _padKey = GlobalKey();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_error != null) setState(() => _error = null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final size = _padKey.currentContext?.size ?? Size.zero;
    final png = await _controller.toPngBytes(size: size);
    if (png == null) {
      setState(() => _error = 'Please sign before submitting');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final client = ref.read(gameMatchServiceProvider);
    final result = await callGrpcEndpoint(
      () => client.submitSignature(
        SubmitSignatureRequest(
          matchId: widget.matchId,
          tableId: widget.assignment.tableId,
          signaturePng: png,
        ),
      ),
    );

    if (!mounted) return;
    switch (result) {
      case GrpcSuccess():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signature submitted')));
        Navigator.of(context).pop();
      case GrpcFailure(:final userMessage):
        setState(() {
          _submitting = false;
          _error = 'Failed to submit signature: $userMessage';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Match ${widget.match.matchNumber} · Table ${widget.assignment.tableId}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Team ${widget.assignment.teamId}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'By signing, the team agrees to the score for this match.',
            ),
            const SizedBox(height: 16),
            SignaturePad(key: _padKey, controller: _controller, height: 240),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _submitting ? null : _controller.clear,
                  child: const Text('Clear'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
