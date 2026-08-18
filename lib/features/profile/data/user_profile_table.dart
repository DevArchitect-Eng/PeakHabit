import 'package:drift/drift.dart';

import '../../../core/database/date_only_converter.dart';
import '../domain/user_profile.dart';

/// Row id of the one and only profile.
const int singleProfileId = 1;

/// The user profile.
///
/// Exactly one row exists: the id is pinned to [singleProfileId] by a check
/// constraint, so a second profile cannot be inserted by accident.
///
/// The enums are stored by name rather than by index — an index would silently
/// change meaning as soon as someone reorders the enum.
@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  IntColumn get id => integer()
      .withDefault(const Constant(singleProfileId))
      // Naming the column inside its own check is how drift expresses this.
      // Nothing recurses at run time: the generated table class overrides the
      // getter, and only the generator ever reads the expression.
      // ignore: recursive_getters
      .check(id.equals(singleProfileId))();

  /// Body height in centimetres.
  IntColumn get heightCm => integer().nullable()();

  /// Empty until the user sets one — a sentinel like the other fields' `null`,
  /// just spelled without one because the column and the domain field are
  /// deliberately non-nullable.
  TextColumn get username => text().withDefault(const Constant(''))();

  TextColumn get sex => textEnum<BiologicalSex>().nullable()();

  TextColumn get birthDate =>
      text().map(const DateOnlyConverter()).nullable()();

  TextColumn get activityLevel => textEnum<ActivityLevel>().nullable()();

  TextColumn get goal => textEnum<WeightGoal>()();

  /// Daily calorie target in kcal.
  IntColumn get calorieTarget => integer().nullable()();

  IntColumn get proteinPercent => integer()();
  IntColumn get carbPercent => integer()();
  IntColumn get fatPercent => integer()();

  /// Last change, kept so a later cloud sync has something to order by.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  /// The percentages split up the calorie target, so they have to add up to it
  /// here as well — the domain model is not the only way into the file.
  @override
  List<String> get customConstraints => [
    'CHECK (protein_percent + carb_percent + fat_percent = 100)',
  ];
}
