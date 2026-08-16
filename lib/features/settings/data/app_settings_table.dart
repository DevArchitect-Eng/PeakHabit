import 'package:drift/drift.dart';

import '../domain/app_theme_mode.dart';

/// Row id of the one and only settings row.
const int singleSettingsId = 1;

/// The app-wide settings.
///
/// Exactly one row exists: the id is pinned to [singleSettingsId] by a check
/// constraint, so a second row cannot be inserted by accident. Further
/// settings become further columns here rather than tables of their own.
///
/// The enum is stored by name rather than by index — an index would silently
/// change meaning as soon as someone reorders the enum.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer()
      .withDefault(const Constant(singleSettingsId))
      // Naming the column inside its own check is how drift expresses this.
      // Nothing recurses at run time: the generated table class overrides the
      // getter, and only the generator ever reads the expression.
      // ignore: recursive_getters
      .check(id.equals(singleSettingsId))();

  TextColumn get themeMode => textEnum<AppThemeMode>()();

  /// Last change, kept so a later cloud sync has something to order by.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
