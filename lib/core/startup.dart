import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/data/settings_providers.dart';
import 'database/database_provider.dart';

/// Brings the app's state up before the first frame is drawn.
///
/// The stored theme is read here rather than on the first build, so the app
/// does not start dark and then visibly switch over to light.
Future<void> warmUp(ProviderContainer container) async {
  await container.read(databaseProvider).open();

  // The subscription is what starts the provider, and it has to exist before
  // the value is awaited: without a listener the future below never completes
  // and the app hangs on an empty screen instead of starting.
  container.listen(themeModeProvider, (_, _) {}, fireImmediately: true);
  await container.read(themeModeProvider.future);
}
