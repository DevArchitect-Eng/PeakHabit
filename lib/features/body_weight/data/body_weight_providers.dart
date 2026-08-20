import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../domain/body_weight_entry.dart';
import '../domain/weight_period.dart';
import 'body_weight_repository.dart';

/// Access to the stored weight entries. Widgets that only write, and those
/// that need a range of their own, go through this one.
final bodyWeightRepositoryProvider = Provider<BodyWeightRepository>(
  (ref) => BodyWeightRepository(ref.watch(databaseProvider)),
);

/// The most recent weight entry, re-emitted on every change, and `null` while
/// nothing has been recorded.
final latestBodyWeightProvider = StreamProvider<BodyWeightEntry?>(
  (ref) => ref.watch(bodyWeightRepositoryProvider).watchLatest(),
);

/// The oldest weight entry — the starting weight — re-emitted on every change,
/// and `null` while nothing has been recorded.
final firstBodyWeightProvider = StreamProvider<BodyWeightEntry?>(
  (ref) => ref.watch(bodyWeightRepositoryProvider).watchFirst(),
);

/// A period of the weight series, together with the window it was read over.
///
/// The window rides along rather than being worked out again by whoever draws
/// the chart: it is built from `DateTime.now()`, and a second call to that
/// would be a second answer the moment the two land on either side of
/// midnight.
typedef BodyWeightSeries = ({
  DateTime from,
  DateTime to,
  List<BodyWeightEntry> entries,
});

/// The entries of the last [WeightPeriod], oldest first, re-emitted on every
/// change.
///
/// One query per period the screen offers, so switching between them is a new
/// window rather than a re-read of the whole series.
///
/// Dropped again once nothing watches it, so a period the user has switched
/// away from does not keep a query open — and so coming back to it reads a
/// window built from the current day rather than the one it was first opened
/// on. An app left sitting on one period across midnight still keeps
/// yesterday's window: a day off at the far end of a month or a year is not
/// worth a timer that fires while nobody is looking.
final bodyWeightSeriesProvider = StreamProvider.autoDispose
    .family<BodyWeightSeries, WeightPeriod>((ref, period) {
      final today = DateTime.now();
      final from = period.startFrom(today);
      return ref
          .watch(bodyWeightRepositoryProvider)
          .watchRange(from, today)
          .map((entries) => (from: from, to: today, entries: entries));
    });
