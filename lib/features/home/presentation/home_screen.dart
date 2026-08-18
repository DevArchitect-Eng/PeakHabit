import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/user_profile_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final username = profile.value?.username.trim() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('PeakHabit')),
      body: Center(
        child: Text(username.isEmpty ? 'Hallo!' : 'Hallo, $username!'),
      ),
    );
  }
}
