import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('greets generically without a stored username', (tester) async {
    await pumpApp(tester);

    expect(find.text('Hallo!'), findsOneWidget);
  });

  testWidgets('greets by the stored username', (tester) async {
    await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(username: 'mila')),
    );

    expect(find.text('Hallo, mila!'), findsOneWidget);
  });
}
