import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app.g.dart';

@riverpod
GraphQLClient graphQLClient(Ref ref) {
  final HttpLink httpLink = HttpLink('http://localhost:8080/graphql');

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: httpLink,
  );
}

const String getTournamentConfigQuery = r'''
  query {
    tournamentConfig {
      eventName,
      backupInterval,
      backupRetention,
      season
    }
  }
''';

class TournamentConfig {
  final String? eventName;
  final int? backupInterval;
  final int? backupRetention;
  final String? season;

  TournamentConfig({
    required this.eventName,
    required this.backupInterval,
    required this.backupRetention,
    required this.season,
  });

  factory TournamentConfig.fromJson(Map<String, dynamic> json) {
    return TournamentConfig(
      eventName: json['eventName'],
      backupInterval: json['backupInterval'],
      backupRetention: json['backupRetention'],
      season: json['season'],
    );
  }
}

@riverpod
Future<TournamentConfig> tournamentConfig(Ref ref) async {
  final GraphQLClient client = ref.watch(graphQLClientProvider);
  final QueryOptions options = QueryOptions(
    document: gql(getTournamentConfigQuery),
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print("Exception: ${result.exception}");
    throw Exception(result.exception.toString());
  }

  print(result.data?["tournamentConfig"]);

  try {
    var config = TournamentConfig.fromJson(result.data?["tournamentConfig"]);
    print(config.eventName);
    return config;
  } catch (e) {
    print("Error parsing JSON: $e");
    throw Exception("Error parsing JSON: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const CounterView());
  }
}

// consumer widget view
class CounterView extends ConsumerWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TournamentConfig> config = ref.watch(
      tournamentConfigProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: switch (config) {
          AsyncData(:final value) => Text('Event name: ${value.eventName}'),
          AsyncError() => const Text('Error loading data'),
          _ => const Text('Loading...'),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
