import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/user_profile_providers.dart';
import 'body_weight_card.dart';
import 'nutrition_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final username = profile.value?.username.trim() ?? '';

    // A list rather than a column: the cards reach past the fold together, and
    // they have to scroll rather than overflow.
    return Scaffold(
      appBar: AppBar(title: const Text('PeakHabit')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            username.isEmpty ? 'Hallo!' : 'Hallo, $username!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Nutrition first: it is the card that changes several times a day,
          // while the weight below it changes once and is the same number all
          // day long.
          const NutritionCard(),
          const SizedBox(height: 12),
          const BodyWeightCard(),
        ],
      ),
    );
  }
}
