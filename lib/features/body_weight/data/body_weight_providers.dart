import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../domain/body_weight_entry.dart';
import 'body_weight_repository.dart';

/// Access to the stored weight entries. Widgets that only write, and those
/// that need a range of their own, go through this one.
final bodyWeightRepositoryProvider = Provider<BodyWeightRepository>(
  (ref) => BodyWeightRepository(ref.watch(databaseProvider)),
);

/// The most recent weight entry, re-emitted on every change, and `null` while
/// nothing has been recorded.
///
/// The range queries deliberately have no provider yet: their bounds move with
/// whatever period the screen offers, and a family would have to guess that
/// shape before the first screen using it exists. The home widget (#5) and the
/// statistics (#6) bring the provider that fits them.
final latestBodyWeightProvider = StreamProvider<BodyWeightEntry?>(
  (ref) => ref.watch(bodyWeightRepositoryProvider).watchLatest(),
);
