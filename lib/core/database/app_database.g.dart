// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(singleProfileId),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(singleProfileId),
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<int> heightCm = GeneratedColumn<int>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<BiologicalSex?, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<BiologicalSex?>($UserProfilesTable.$convertersexn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> birthDate =
      GeneratedColumn<String>(
        'birth_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UserProfilesTable.$converterbirthDaten);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityLevel?, String>
  activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ActivityLevel?>($UserProfilesTable.$converteractivityLeveln);
  @override
  late final GeneratedColumnWithTypeConverter<WeightGoal, String> goal =
      GeneratedColumn<String>(
        'goal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WeightGoal>($UserProfilesTable.$convertergoal);
  static const VerificationMeta _calorieTargetMeta = const VerificationMeta(
    'calorieTarget',
  );
  @override
  late final GeneratedColumn<int> calorieTarget = GeneratedColumn<int>(
    'calorie_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinPercentMeta = const VerificationMeta(
    'proteinPercent',
  );
  @override
  late final GeneratedColumn<int> proteinPercent = GeneratedColumn<int>(
    'protein_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbPercentMeta = const VerificationMeta(
    'carbPercent',
  );
  @override
  late final GeneratedColumn<int> carbPercent = GeneratedColumn<int>(
    'carb_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPercentMeta = const VerificationMeta(
    'fatPercent',
  );
  @override
  late final GeneratedColumn<int> fatPercent = GeneratedColumn<int>(
    'fat_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    heightCm,
    username,
    sex,
    birthDate,
    activityLevel,
    goal,
    calorieTarget,
    proteinPercent,
    carbPercent,
    fatPercent,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('calorie_target')) {
      context.handle(
        _calorieTargetMeta,
        calorieTarget.isAcceptableOrUnknown(
          data['calorie_target']!,
          _calorieTargetMeta,
        ),
      );
    }
    if (data.containsKey('protein_percent')) {
      context.handle(
        _proteinPercentMeta,
        proteinPercent.isAcceptableOrUnknown(
          data['protein_percent']!,
          _proteinPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPercentMeta);
    }
    if (data.containsKey('carb_percent')) {
      context.handle(
        _carbPercentMeta,
        carbPercent.isAcceptableOrUnknown(
          data['carb_percent']!,
          _carbPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbPercentMeta);
    }
    if (data.containsKey('fat_percent')) {
      context.handle(
        _fatPercentMeta,
        fatPercent.isAcceptableOrUnknown(data['fat_percent']!, _fatPercentMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPercentMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_cm'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      sex: $UserProfilesTable.$convertersexn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        ),
      ),
      birthDate: $UserProfilesTable.$converterbirthDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}birth_date'],
        ),
      ),
      activityLevel: $UserProfilesTable.$converteractivityLeveln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_level'],
        ),
      ),
      goal: $UserProfilesTable.$convertergoal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal'],
        )!,
      ),
      calorieTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calorie_target'],
      ),
      proteinPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein_percent'],
      )!,
      carbPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carb_percent'],
      )!,
      fatPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat_percent'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BiologicalSex, String, String> $convertersex =
      const EnumNameConverter<BiologicalSex>(BiologicalSex.values);
  static JsonTypeConverter2<BiologicalSex?, String?, String?> $convertersexn =
      JsonTypeConverter2.asNullable($convertersex);
  static TypeConverter<DateTime, String> $converterbirthDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterbirthDaten =
      NullAwareTypeConverter.wrap($converterbirthDate);
  static JsonTypeConverter2<ActivityLevel, String, String>
  $converteractivityLevel = const EnumNameConverter<ActivityLevel>(
    ActivityLevel.values,
  );
  static JsonTypeConverter2<ActivityLevel?, String?, String?>
  $converteractivityLeveln = JsonTypeConverter2.asNullable(
    $converteractivityLevel,
  );
  static JsonTypeConverter2<WeightGoal, String, String> $convertergoal =
      const EnumNameConverter<WeightGoal>(WeightGoal.values);
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;

  /// Body height in centimetres.
  final int? heightCm;

  /// Empty until the user sets one — a sentinel like the other fields' `null`,
  /// just spelled without one because the column and the domain field are
  /// deliberately non-nullable.
  final String username;
  final BiologicalSex? sex;
  final DateTime? birthDate;
  final ActivityLevel? activityLevel;
  final WeightGoal goal;

  /// Daily calorie target in kcal.
  final int? calorieTarget;
  final int proteinPercent;
  final int carbPercent;
  final int fatPercent;

  /// Last change, kept so a later cloud sync has something to order by.
  final DateTime updatedAt;
  const UserProfileRow({
    required this.id,
    this.heightCm,
    required this.username,
    this.sex,
    this.birthDate,
    this.activityLevel,
    required this.goal,
    this.calorieTarget,
    required this.proteinPercent,
    required this.carbPercent,
    required this.fatPercent,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<int>(heightCm);
    }
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(
        $UserProfilesTable.$convertersexn.toSql(sex),
      );
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(
        $UserProfilesTable.$converterbirthDaten.toSql(birthDate),
      );
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(
        $UserProfilesTable.$converteractivityLeveln.toSql(activityLevel),
      );
    }
    {
      map['goal'] = Variable<String>(
        $UserProfilesTable.$convertergoal.toSql(goal),
      );
    }
    if (!nullToAbsent || calorieTarget != null) {
      map['calorie_target'] = Variable<int>(calorieTarget);
    }
    map['protein_percent'] = Variable<int>(proteinPercent);
    map['carb_percent'] = Variable<int>(carbPercent);
    map['fat_percent'] = Variable<int>(fatPercent);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      username: Value(username),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      goal: Value(goal),
      calorieTarget: calorieTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(calorieTarget),
      proteinPercent: Value(proteinPercent),
      carbPercent: Value(carbPercent),
      fatPercent: Value(fatPercent),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      heightCm: serializer.fromJson<int?>(json['heightCm']),
      username: serializer.fromJson<String>(json['username']),
      sex: $UserProfilesTable.$convertersexn.fromJson(
        serializer.fromJson<String?>(json['sex']),
      ),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      activityLevel: $UserProfilesTable.$converteractivityLeveln.fromJson(
        serializer.fromJson<String?>(json['activityLevel']),
      ),
      goal: $UserProfilesTable.$convertergoal.fromJson(
        serializer.fromJson<String>(json['goal']),
      ),
      calorieTarget: serializer.fromJson<int?>(json['calorieTarget']),
      proteinPercent: serializer.fromJson<int>(json['proteinPercent']),
      carbPercent: serializer.fromJson<int>(json['carbPercent']),
      fatPercent: serializer.fromJson<int>(json['fatPercent']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'heightCm': serializer.toJson<int?>(heightCm),
      'username': serializer.toJson<String>(username),
      'sex': serializer.toJson<String?>(
        $UserProfilesTable.$convertersexn.toJson(sex),
      ),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'activityLevel': serializer.toJson<String?>(
        $UserProfilesTable.$converteractivityLeveln.toJson(activityLevel),
      ),
      'goal': serializer.toJson<String>(
        $UserProfilesTable.$convertergoal.toJson(goal),
      ),
      'calorieTarget': serializer.toJson<int?>(calorieTarget),
      'proteinPercent': serializer.toJson<int>(proteinPercent),
      'carbPercent': serializer.toJson<int>(carbPercent),
      'fatPercent': serializer.toJson<int>(fatPercent),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileRow copyWith({
    int? id,
    Value<int?> heightCm = const Value.absent(),
    String? username,
    Value<BiologicalSex?> sex = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<ActivityLevel?> activityLevel = const Value.absent(),
    WeightGoal? goal,
    Value<int?> calorieTarget = const Value.absent(),
    int? proteinPercent,
    int? carbPercent,
    int? fatPercent,
    DateTime? updatedAt,
  }) => UserProfileRow(
    id: id ?? this.id,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    username: username ?? this.username,
    sex: sex.present ? sex.value : this.sex,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    goal: goal ?? this.goal,
    calorieTarget: calorieTarget.present
        ? calorieTarget.value
        : this.calorieTarget,
    proteinPercent: proteinPercent ?? this.proteinPercent,
    carbPercent: carbPercent ?? this.carbPercent,
    fatPercent: fatPercent ?? this.fatPercent,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      username: data.username.present ? data.username.value : this.username,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      goal: data.goal.present ? data.goal.value : this.goal,
      calorieTarget: data.calorieTarget.present
          ? data.calorieTarget.value
          : this.calorieTarget,
      proteinPercent: data.proteinPercent.present
          ? data.proteinPercent.value
          : this.proteinPercent,
      carbPercent: data.carbPercent.present
          ? data.carbPercent.value
          : this.carbPercent,
      fatPercent: data.fatPercent.present
          ? data.fatPercent.value
          : this.fatPercent,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('heightCm: $heightCm, ')
          ..write('username: $username, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goal: $goal, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('proteinPercent: $proteinPercent, ')
          ..write('carbPercent: $carbPercent, ')
          ..write('fatPercent: $fatPercent, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    heightCm,
    username,
    sex,
    birthDate,
    activityLevel,
    goal,
    calorieTarget,
    proteinPercent,
    carbPercent,
    fatPercent,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.heightCm == this.heightCm &&
          other.username == this.username &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.activityLevel == this.activityLevel &&
          other.goal == this.goal &&
          other.calorieTarget == this.calorieTarget &&
          other.proteinPercent == this.proteinPercent &&
          other.carbPercent == this.carbPercent &&
          other.fatPercent == this.fatPercent &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<int?> heightCm;
  final Value<String> username;
  final Value<BiologicalSex?> sex;
  final Value<DateTime?> birthDate;
  final Value<ActivityLevel?> activityLevel;
  final Value<WeightGoal> goal;
  final Value<int?> calorieTarget;
  final Value<int> proteinPercent;
  final Value<int> carbPercent;
  final Value<int> fatPercent;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.username = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goal = const Value.absent(),
    this.calorieTarget = const Value.absent(),
    this.proteinPercent = const Value.absent(),
    this.carbPercent = const Value.absent(),
    this.fatPercent = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.username = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.activityLevel = const Value.absent(),
    required WeightGoal goal,
    this.calorieTarget = const Value.absent(),
    required int proteinPercent,
    required int carbPercent,
    required int fatPercent,
    required DateTime updatedAt,
  }) : goal = Value(goal),
       proteinPercent = Value(proteinPercent),
       carbPercent = Value(carbPercent),
       fatPercent = Value(fatPercent),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<int>? heightCm,
    Expression<String>? username,
    Expression<String>? sex,
    Expression<String>? birthDate,
    Expression<String>? activityLevel,
    Expression<String>? goal,
    Expression<int>? calorieTarget,
    Expression<int>? proteinPercent,
    Expression<int>? carbPercent,
    Expression<int>? fatPercent,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (heightCm != null) 'height_cm': heightCm,
      if (username != null) 'username': username,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (goal != null) 'goal': goal,
      if (calorieTarget != null) 'calorie_target': calorieTarget,
      if (proteinPercent != null) 'protein_percent': proteinPercent,
      if (carbPercent != null) 'carb_percent': carbPercent,
      if (fatPercent != null) 'fat_percent': fatPercent,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<int?>? heightCm,
    Value<String>? username,
    Value<BiologicalSex?>? sex,
    Value<DateTime?>? birthDate,
    Value<ActivityLevel?>? activityLevel,
    Value<WeightGoal>? goal,
    Value<int?>? calorieTarget,
    Value<int>? proteinPercent,
    Value<int>? carbPercent,
    Value<int>? fatPercent,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      heightCm: heightCm ?? this.heightCm,
      username: username ?? this.username,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinPercent: proteinPercent ?? this.proteinPercent,
      carbPercent: carbPercent ?? this.carbPercent,
      fatPercent: fatPercent ?? this.fatPercent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<int>(heightCm.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(
        $UserProfilesTable.$convertersexn.toSql(sex.value),
      );
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(
        $UserProfilesTable.$converterbirthDaten.toSql(birthDate.value),
      );
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(
        $UserProfilesTable.$converteractivityLeveln.toSql(activityLevel.value),
      );
    }
    if (goal.present) {
      map['goal'] = Variable<String>(
        $UserProfilesTable.$convertergoal.toSql(goal.value),
      );
    }
    if (calorieTarget.present) {
      map['calorie_target'] = Variable<int>(calorieTarget.value);
    }
    if (proteinPercent.present) {
      map['protein_percent'] = Variable<int>(proteinPercent.value);
    }
    if (carbPercent.present) {
      map['carb_percent'] = Variable<int>(carbPercent.value);
    }
    if (fatPercent.present) {
      map['fat_percent'] = Variable<int>(fatPercent.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('heightCm: $heightCm, ')
          ..write('username: $username, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goal: $goal, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('proteinPercent: $proteinPercent, ')
          ..write('carbPercent: $carbPercent, ')
          ..write('fatPercent: $fatPercent, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(singleSettingsId),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(singleSettingsId),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppThemeMode, String> themeMode =
      GeneratedColumn<String>(
        'theme_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AppThemeMode>($AppSettingsTable.$converterthemeMode);
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    onboardingCompleted,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: $AppSettingsTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppThemeMode, String, String> $converterthemeMode =
      const EnumNameConverter<AppThemeMode>(AppThemeMode.values);
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final AppThemeMode themeMode;

  /// Whether the first-start onboarding has been completed. Gates whether the
  /// app shows it again, so it never runs a second time.
  final bool onboardingCompleted;

  /// Last change, kept so a later cloud sync has something to order by.
  final DateTime updatedAt;
  const AppSettingsRow({
    required this.id,
    required this.themeMode,
    required this.onboardingCompleted,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['theme_mode'] = Variable<String>(
        $AppSettingsTable.$converterthemeMode.toSql(themeMode),
      );
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      onboardingCompleted: Value(onboardingCompleted),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      themeMode: $AppSettingsTable.$converterthemeMode.fromJson(
        serializer.fromJson<String>(json['themeMode']),
      ),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(
        $AppSettingsTable.$converterthemeMode.toJson(themeMode),
      ),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    AppThemeMode? themeMode,
    bool? onboardingCompleted,
    DateTime? updatedAt,
  }) => AppSettingsRow(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, themeMode, onboardingCompleted, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<AppThemeMode> themeMode;
  final Value<bool> onboardingCompleted;
  final Value<DateTime> updatedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required AppThemeMode themeMode,
    this.onboardingCompleted = const Value.absent(),
    required DateTime updatedAt,
  }) : themeMode = Value(themeMode),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? onboardingCompleted,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<AppThemeMode>? themeMode,
    Value<bool>? onboardingCompleted,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(
        $AppSettingsTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BodyWeightEntriesTable extends BodyWeightEntries
    with TableInfo<$BodyWeightEntriesTable, BodyWeightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightEntriesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BodyWeightEntriesTable.$converterdate);
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, weightKg, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyWeightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  BodyWeightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeightRow(
      date: $BodyWeightEntriesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BodyWeightEntriesTable createAlias(String alias) {
    return $BodyWeightEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const DateOnlyConverter();
}

class BodyWeightRow extends DataClass implements Insertable<BodyWeightRow> {
  /// The day of the weighing, as `yyyy-MM-dd` — see [DateOnlyConverter] for
  /// why this is not a `dateTime()` column.
  final DateTime date;

  /// Body weight in kilograms.
  final double weightKg;

  /// Last change, kept so a later cloud sync has something to order by.
  final DateTime updatedAt;
  const BodyWeightRow({
    required this.date,
    required this.weightKg,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['date'] = Variable<String>(
        $BodyWeightEntriesTable.$converterdate.toSql(date),
      );
    }
    map['weight_kg'] = Variable<double>(weightKg);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BodyWeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightEntriesCompanion(
      date: Value(date),
      weightKg: Value(weightKg),
      updatedAt: Value(updatedAt),
    );
  }

  factory BodyWeightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeightRow(
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double>(weightKg),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BodyWeightRow copyWith({
    DateTime? date,
    double? weightKg,
    DateTime? updatedAt,
  }) => BodyWeightRow(
    date: date ?? this.date,
    weightKg: weightKg ?? this.weightKg,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BodyWeightRow copyWithCompanion(BodyWeightEntriesCompanion data) {
    return BodyWeightRow(
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightRow(')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, weightKg, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeightRow &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.updatedAt == this.updatedAt);
}

class BodyWeightEntriesCompanion extends UpdateCompanion<BodyWeightRow> {
  final Value<DateTime> date;
  final Value<double> weightKg;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BodyWeightEntriesCompanion({
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyWeightEntriesCompanion.insert({
    required DateTime date,
    required double weightKg,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       weightKg = Value(weightKg),
       updatedAt = Value(updatedAt);
  static Insertable<BodyWeightRow> custom({
    Expression<String>? date,
    Expression<double>? weightKg,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyWeightEntriesCompanion copyWith({
    Value<DateTime>? date,
    Value<double>? weightKg,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BodyWeightEntriesCompanion(
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(
        $BodyWeightEntriesTable.$converterdate.toSql(date.value),
      );
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightEntriesCompanion(')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, FoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta(
    'kcalPer100g',
  );
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
    'kcal_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta(
    'proteinPer100g',
  );
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
    'protein_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPer100gMeta = const VerificationMeta(
    'carbsPer100g',
  );
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
    'carbs_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPer100gMeta = const VerificationMeta(
    'fatPer100g',
  );
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
    'fat_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portionGramsMeta = const VerificationMeta(
    'portionGrams',
  );
  @override
  late final GeneratedColumn<double> portionGrams = GeneratedColumn<double>(
    'portion_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FoodSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FoodSource>($FoodsTable.$convertersource);
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    kcalPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    portionGrams,
    source,
    barcode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('kcal_per_100g')) {
      context.handle(
        _kcalPer100gMeta,
        kcalPer100g.isAcceptableOrUnknown(
          data['kcal_per_100g']!,
          _kcalPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kcalPer100gMeta);
    }
    if (data.containsKey('protein_per_100g')) {
      context.handle(
        _proteinPer100gMeta,
        proteinPer100g.isAcceptableOrUnknown(
          data['protein_per_100g']!,
          _proteinPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('carbs_per_100g')) {
      context.handle(
        _carbsPer100gMeta,
        carbsPer100g.isAcceptableOrUnknown(
          data['carbs_per_100g']!,
          _carbsPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPer100gMeta);
    }
    if (data.containsKey('fat_per_100g')) {
      context.handle(
        _fatPer100gMeta,
        fatPer100g.isAcceptableOrUnknown(
          data['fat_per_100g']!,
          _fatPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('portion_grams')) {
      context.handle(
        _portionGramsMeta,
        portionGrams.isAcceptableOrUnknown(
          data['portion_grams']!,
          _portionGramsMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      kcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per_100g'],
      )!,
      proteinPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per_100g'],
      )!,
      carbsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per_100g'],
      )!,
      fatPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per_100g'],
      )!,
      portionGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}portion_grams'],
      ),
      source: $FoodsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FoodSource, String, String> $convertersource =
      const EnumNameConverter<FoodSource>(FoodSource.values);
}

class FoodRow extends DataClass implements Insertable<FoodRow> {
  final int id;
  final String name;

  /// The manufacturer, `NULL` when there is none worth naming.
  final String? brand;

  /// Energy of 100 g in kilocalories.
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  /// What one portion weighs in grams, `NULL` for a food without a portion
  /// worth naming.
  final double? portionGrams;

  /// Where the food came from — see [FoodSource]. Stored by name rather than
  /// by index, like every other enum in this database: an index would
  /// silently change meaning as soon as someone reorders the enum.
  final FoodSource source;

  /// The product's barcode, `NULL` for anything typed by hand. Unique, so a
  /// product scanned twice finds the record that is already there.
  final String? barcode;
  final DateTime createdAt;

  /// Last change, kept so a later cloud sync has something to order by.
  final DateTime updatedAt;
  const FoodRow({
    required this.id,
    required this.name,
    this.brand,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.portionGrams,
    required this.source,
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['kcal_per_100g'] = Variable<double>(kcalPer100g);
    map['protein_per_100g'] = Variable<double>(proteinPer100g);
    map['carbs_per_100g'] = Variable<double>(carbsPer100g);
    map['fat_per_100g'] = Variable<double>(fatPer100g);
    if (!nullToAbsent || portionGrams != null) {
      map['portion_grams'] = Variable<double>(portionGrams);
    }
    {
      map['source'] = Variable<String>(
        $FoodsTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      kcalPer100g: Value(kcalPer100g),
      proteinPer100g: Value(proteinPer100g),
      carbsPer100g: Value(carbsPer100g),
      fatPer100g: Value(fatPer100g),
      portionGrams: portionGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(portionGrams),
      source: Value(source),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      kcalPer100g: serializer.fromJson<double>(json['kcalPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      carbsPer100g: serializer.fromJson<double>(json['carbsPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      portionGrams: serializer.fromJson<double?>(json['portionGrams']),
      source: $FoodsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      barcode: serializer.fromJson<String?>(json['barcode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'kcalPer100g': serializer.toJson<double>(kcalPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'carbsPer100g': serializer.toJson<double>(carbsPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'portionGrams': serializer.toJson<double?>(portionGrams),
      'source': serializer.toJson<String>(
        $FoodsTable.$convertersource.toJson(source),
      ),
      'barcode': serializer.toJson<String?>(barcode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FoodRow copyWith({
    int? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    double? kcalPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    Value<double?> portionGrams = const Value.absent(),
    FoodSource? source,
    Value<String?> barcode = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FoodRow(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    kcalPer100g: kcalPer100g ?? this.kcalPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    carbsPer100g: carbsPer100g ?? this.carbsPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    portionGrams: portionGrams.present ? portionGrams.value : this.portionGrams,
    source: source ?? this.source,
    barcode: barcode.present ? barcode.value : this.barcode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FoodRow copyWithCompanion(FoodsCompanion data) {
    return FoodRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      kcalPer100g: data.kcalPer100g.present
          ? data.kcalPer100g.value
          : this.kcalPer100g,
      proteinPer100g: data.proteinPer100g.present
          ? data.proteinPer100g.value
          : this.proteinPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      fatPer100g: data.fatPer100g.present
          ? data.fatPer100g.value
          : this.fatPer100g,
      portionGrams: data.portionGrams.present
          ? data.portionGrams.value
          : this.portionGrams,
      source: data.source.present ? data.source.value : this.source,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('portionGrams: $portionGrams, ')
          ..write('source: $source, ')
          ..write('barcode: $barcode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    kcalPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    portionGrams,
    source,
    barcode,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.kcalPer100g == this.kcalPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.portionGrams == this.portionGrams &&
          other.source == this.source &&
          other.barcode == this.barcode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoodsCompanion extends UpdateCompanion<FoodRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<double> kcalPer100g;
  final Value<double> proteinPer100g;
  final Value<double> carbsPer100g;
  final Value<double> fatPer100g;
  final Value<double?> portionGrams;
  final Value<FoodSource> source;
  final Value<String?> barcode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.portionGrams = const Value.absent(),
    this.source = const Value.absent(),
    this.barcode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required double kcalPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    this.portionGrams = const Value.absent(),
    required FoodSource source,
    this.barcode = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       kcalPer100g = Value(kcalPer100g),
       proteinPer100g = Value(proteinPer100g),
       carbsPer100g = Value(carbsPer100g),
       fatPer100g = Value(fatPer100g),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FoodRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<double>? kcalPer100g,
    Expression<double>? proteinPer100g,
    Expression<double>? carbsPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? portionGrams,
    Expression<String>? source,
    Expression<String>? barcode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (kcalPer100g != null) 'kcal_per_100g': kcalPer100g,
      if (proteinPer100g != null) 'protein_per_100g': proteinPer100g,
      if (carbsPer100g != null) 'carbs_per_100g': carbsPer100g,
      if (fatPer100g != null) 'fat_per_100g': fatPer100g,
      if (portionGrams != null) 'portion_grams': portionGrams,
      if (source != null) 'source': source,
      if (barcode != null) 'barcode': barcode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<double>? kcalPer100g,
    Value<double>? proteinPer100g,
    Value<double>? carbsPer100g,
    Value<double>? fatPer100g,
    Value<double?>? portionGrams,
    Value<FoodSource>? source,
    Value<String?>? barcode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      portionGrams: portionGrams ?? this.portionGrams,
      source: source ?? this.source,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per_100g'] = Variable<double>(kcalPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per_100g'] = Variable<double>(proteinPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per_100g'] = Variable<double>(carbsPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per_100g'] = Variable<double>(fatPer100g.value);
    }
    if (portionGrams.present) {
      map['portion_grams'] = Variable<double>(portionGrams.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $FoodsTable.$convertersource.toSql(source.value),
      );
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('portionGrams: $portionGrams, ')
          ..write('source: $source, ')
          ..write('barcode: $barcode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CompositeFoodsTable extends CompositeFoods
    with TableInfo<$CompositeFoodsTable, CompositeFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompositeFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preparedGramsMeta = const VerificationMeta(
    'preparedGrams',
  );
  @override
  late final GeneratedColumn<double> preparedGrams = GeneratedColumn<double>(
    'prepared_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    preparedGrams,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'composite_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompositeFoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('prepared_grams')) {
      context.handle(
        _preparedGramsMeta,
        preparedGrams.isAcceptableOrUnknown(
          data['prepared_grams']!,
          _preparedGramsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompositeFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompositeFoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      preparedGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prepared_grams'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CompositeFoodsTable createAlias(String alias) {
    return $CompositeFoodsTable(attachedDatabase, alias);
  }
}

class CompositeFoodRow extends DataClass
    implements Insertable<CompositeFoodRow> {
  final int id;
  final String name;
  final double? preparedGrams;
  final DateTime createdAt;

  /// Last change, kept so a later cloud sync has something to order by.
  final DateTime updatedAt;
  const CompositeFoodRow({
    required this.id,
    required this.name,
    this.preparedGrams,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || preparedGrams != null) {
      map['prepared_grams'] = Variable<double>(preparedGrams);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CompositeFoodsCompanion toCompanion(bool nullToAbsent) {
    return CompositeFoodsCompanion(
      id: Value(id),
      name: Value(name),
      preparedGrams: preparedGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(preparedGrams),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CompositeFoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompositeFoodRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      preparedGrams: serializer.fromJson<double?>(json['preparedGrams']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'preparedGrams': serializer.toJson<double?>(preparedGrams),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CompositeFoodRow copyWith({
    int? id,
    String? name,
    Value<double?> preparedGrams = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CompositeFoodRow(
    id: id ?? this.id,
    name: name ?? this.name,
    preparedGrams: preparedGrams.present
        ? preparedGrams.value
        : this.preparedGrams,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CompositeFoodRow copyWithCompanion(CompositeFoodsCompanion data) {
    return CompositeFoodRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      preparedGrams: data.preparedGrams.present
          ? data.preparedGrams.value
          : this.preparedGrams,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompositeFoodRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('preparedGrams: $preparedGrams, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, preparedGrams, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompositeFoodRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.preparedGrams == this.preparedGrams &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CompositeFoodsCompanion extends UpdateCompanion<CompositeFoodRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<double?> preparedGrams;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CompositeFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.preparedGrams = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CompositeFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.preparedGrams = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CompositeFoodRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? preparedGrams,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (preparedGrams != null) 'prepared_grams': preparedGrams,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CompositeFoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double?>? preparedGrams,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CompositeFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      preparedGrams: preparedGrams ?? this.preparedGrams,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (preparedGrams.present) {
      map['prepared_grams'] = Variable<double>(preparedGrams.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompositeFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('preparedGrams: $preparedGrams, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CompositeFoodIngredientsTable extends CompositeFoodIngredients
    with TableInfo<$CompositeFoodIngredientsTable, CompositeFoodIngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompositeFoodIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _compositeFoodIdMeta = const VerificationMeta(
    'compositeFoodId',
  );
  @override
  late final GeneratedColumn<int> compositeFoodId = GeneratedColumn<int>(
    'composite_food_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES composite_foods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [compositeFoodId, foodId, grams];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'composite_food_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompositeFoodIngredientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('composite_food_id')) {
      context.handle(
        _compositeFoodIdMeta,
        compositeFoodId.isAcceptableOrUnknown(
          data['composite_food_id']!,
          _compositeFoodIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compositeFoodIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {compositeFoodId, foodId};
  @override
  CompositeFoodIngredientRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompositeFoodIngredientRow(
      compositeFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}composite_food_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
    );
  }

  @override
  $CompositeFoodIngredientsTable createAlias(String alias) {
    return $CompositeFoodIngredientsTable(attachedDatabase, alias);
  }
}

class CompositeFoodIngredientRow extends DataClass
    implements Insertable<CompositeFoodIngredientRow> {
  final int compositeFoodId;
  final int foodId;

  /// How much of the food goes in, in grams.
  final double grams;
  const CompositeFoodIngredientRow({
    required this.compositeFoodId,
    required this.foodId,
    required this.grams,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['composite_food_id'] = Variable<int>(compositeFoodId);
    map['food_id'] = Variable<int>(foodId);
    map['grams'] = Variable<double>(grams);
    return map;
  }

  CompositeFoodIngredientsCompanion toCompanion(bool nullToAbsent) {
    return CompositeFoodIngredientsCompanion(
      compositeFoodId: Value(compositeFoodId),
      foodId: Value(foodId),
      grams: Value(grams),
    );
  }

  factory CompositeFoodIngredientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompositeFoodIngredientRow(
      compositeFoodId: serializer.fromJson<int>(json['compositeFoodId']),
      foodId: serializer.fromJson<int>(json['foodId']),
      grams: serializer.fromJson<double>(json['grams']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'compositeFoodId': serializer.toJson<int>(compositeFoodId),
      'foodId': serializer.toJson<int>(foodId),
      'grams': serializer.toJson<double>(grams),
    };
  }

  CompositeFoodIngredientRow copyWith({
    int? compositeFoodId,
    int? foodId,
    double? grams,
  }) => CompositeFoodIngredientRow(
    compositeFoodId: compositeFoodId ?? this.compositeFoodId,
    foodId: foodId ?? this.foodId,
    grams: grams ?? this.grams,
  );
  CompositeFoodIngredientRow copyWithCompanion(
    CompositeFoodIngredientsCompanion data,
  ) {
    return CompositeFoodIngredientRow(
      compositeFoodId: data.compositeFoodId.present
          ? data.compositeFoodId.value
          : this.compositeFoodId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      grams: data.grams.present ? data.grams.value : this.grams,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompositeFoodIngredientRow(')
          ..write('compositeFoodId: $compositeFoodId, ')
          ..write('foodId: $foodId, ')
          ..write('grams: $grams')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(compositeFoodId, foodId, grams);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompositeFoodIngredientRow &&
          other.compositeFoodId == this.compositeFoodId &&
          other.foodId == this.foodId &&
          other.grams == this.grams);
}

class CompositeFoodIngredientsCompanion
    extends UpdateCompanion<CompositeFoodIngredientRow> {
  final Value<int> compositeFoodId;
  final Value<int> foodId;
  final Value<double> grams;
  final Value<int> rowid;
  const CompositeFoodIngredientsCompanion({
    this.compositeFoodId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.grams = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompositeFoodIngredientsCompanion.insert({
    required int compositeFoodId,
    required int foodId,
    required double grams,
    this.rowid = const Value.absent(),
  }) : compositeFoodId = Value(compositeFoodId),
       foodId = Value(foodId),
       grams = Value(grams);
  static Insertable<CompositeFoodIngredientRow> custom({
    Expression<int>? compositeFoodId,
    Expression<int>? foodId,
    Expression<double>? grams,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (compositeFoodId != null) 'composite_food_id': compositeFoodId,
      if (foodId != null) 'food_id': foodId,
      if (grams != null) 'grams': grams,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompositeFoodIngredientsCompanion copyWith({
    Value<int>? compositeFoodId,
    Value<int>? foodId,
    Value<double>? grams,
    Value<int>? rowid,
  }) {
    return CompositeFoodIngredientsCompanion(
      compositeFoodId: compositeFoodId ?? this.compositeFoodId,
      foodId: foodId ?? this.foodId,
      grams: grams ?? this.grams,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (compositeFoodId.present) {
      map['composite_food_id'] = Variable<int>(compositeFoodId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompositeFoodIngredientsCompanion(')
          ..write('compositeFoodId: $compositeFoodId, ')
          ..write('foodId: $foodId, ')
          ..write('grams: $grams, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealEntriesTable extends MealEntries
    with TableInfo<$MealEntriesTable, MealEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MealEntriesTable.$converterdate);
  @override
  late final GeneratedColumnWithTypeConverter<MealType, String> mealType =
      GeneratedColumn<String>(
        'meal_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MealType>($MealEntriesTable.$convertermealType);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _compositeFoodIdMeta = const VerificationMeta(
    'compositeFoodId',
  );
  @override
  late final GeneratedColumn<int> compositeFoodId = GeneratedColumn<int>(
    'composite_food_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES composite_foods (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    mealType,
    foodId,
    compositeFoodId,
    grams,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    }
    if (data.containsKey('composite_food_id')) {
      context.handle(
        _compositeFoodIdMeta,
        compositeFoodId.isAcceptableOrUnknown(
          data['composite_food_id']!,
          _compositeFoodIdMeta,
        ),
      );
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: $MealEntriesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      mealType: $MealEntriesTable.$convertermealType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meal_type'],
        )!,
      ),
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      ),
      compositeFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}composite_food_id'],
      ),
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MealEntriesTable createAlias(String alias) {
    return $MealEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const DateOnlyConverter();
  static JsonTypeConverter2<MealType, String, String> $convertermealType =
      const EnumNameConverter<MealType>(MealType.values);
}

class MealEntryRow extends DataClass implements Insertable<MealEntryRow> {
  final int id;

  /// The day the entry belongs to, as `yyyy-MM-dd` — see [DateOnlyConverter]
  /// for why this is not a `dateTime()` column.
  final DateTime date;

  /// Which of the four meals — see [MealType].
  final MealType mealType;
  final int? foodId;
  final int? compositeFoodId;

  /// How much was eaten, in grams.
  final double grams;
  final DateTime createdAt;

  /// Last change, kept so a later cloud sync has something to order by.
  final DateTime updatedAt;
  const MealEntryRow({
    required this.id,
    required this.date,
    required this.mealType,
    this.foodId,
    this.compositeFoodId,
    required this.grams,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['date'] = Variable<String>(
        $MealEntriesTable.$converterdate.toSql(date),
      );
    }
    {
      map['meal_type'] = Variable<String>(
        $MealEntriesTable.$convertermealType.toSql(mealType),
      );
    }
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<int>(foodId);
    }
    if (!nullToAbsent || compositeFoodId != null) {
      map['composite_food_id'] = Variable<int>(compositeFoodId);
    }
    map['grams'] = Variable<double>(grams);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MealEntriesCompanion toCompanion(bool nullToAbsent) {
    return MealEntriesCompanion(
      id: Value(id),
      date: Value(date),
      mealType: Value(mealType),
      foodId: foodId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodId),
      compositeFoodId: compositeFoodId == null && nullToAbsent
          ? const Value.absent()
          : Value(compositeFoodId),
      grams: Value(grams),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MealEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealEntryRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      mealType: $MealEntriesTable.$convertermealType.fromJson(
        serializer.fromJson<String>(json['mealType']),
      ),
      foodId: serializer.fromJson<int?>(json['foodId']),
      compositeFoodId: serializer.fromJson<int?>(json['compositeFoodId']),
      grams: serializer.fromJson<double>(json['grams']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'mealType': serializer.toJson<String>(
        $MealEntriesTable.$convertermealType.toJson(mealType),
      ),
      'foodId': serializer.toJson<int?>(foodId),
      'compositeFoodId': serializer.toJson<int?>(compositeFoodId),
      'grams': serializer.toJson<double>(grams),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MealEntryRow copyWith({
    int? id,
    DateTime? date,
    MealType? mealType,
    Value<int?> foodId = const Value.absent(),
    Value<int?> compositeFoodId = const Value.absent(),
    double? grams,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MealEntryRow(
    id: id ?? this.id,
    date: date ?? this.date,
    mealType: mealType ?? this.mealType,
    foodId: foodId.present ? foodId.value : this.foodId,
    compositeFoodId: compositeFoodId.present
        ? compositeFoodId.value
        : this.compositeFoodId,
    grams: grams ?? this.grams,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MealEntryRow copyWithCompanion(MealEntriesCompanion data) {
    return MealEntryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      compositeFoodId: data.compositeFoodId.present
          ? data.compositeFoodId.value
          : this.compositeFoodId,
      grams: data.grams.present ? data.grams.value : this.grams,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealEntryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('foodId: $foodId, ')
          ..write('compositeFoodId: $compositeFoodId, ')
          ..write('grams: $grams, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    mealType,
    foodId,
    compositeFoodId,
    grams,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealEntryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.mealType == this.mealType &&
          other.foodId == this.foodId &&
          other.compositeFoodId == this.compositeFoodId &&
          other.grams == this.grams &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MealEntriesCompanion extends UpdateCompanion<MealEntryRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<MealType> mealType;
  final Value<int?> foodId;
  final Value<int?> compositeFoodId;
  final Value<double> grams;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MealEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.mealType = const Value.absent(),
    this.foodId = const Value.absent(),
    this.compositeFoodId = const Value.absent(),
    this.grams = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MealEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required MealType mealType,
    this.foodId = const Value.absent(),
    this.compositeFoodId = const Value.absent(),
    required double grams,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : date = Value(date),
       mealType = Value(mealType),
       grams = Value(grams),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MealEntryRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? mealType,
    Expression<int>? foodId,
    Expression<int>? compositeFoodId,
    Expression<double>? grams,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (mealType != null) 'meal_type': mealType,
      if (foodId != null) 'food_id': foodId,
      if (compositeFoodId != null) 'composite_food_id': compositeFoodId,
      if (grams != null) 'grams': grams,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MealEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<MealType>? mealType,
    Value<int?>? foodId,
    Value<int?>? compositeFoodId,
    Value<double>? grams,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MealEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodId: foodId ?? this.foodId,
      compositeFoodId: compositeFoodId ?? this.compositeFoodId,
      grams: grams ?? this.grams,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $MealEntriesTable.$converterdate.toSql(date.value),
      );
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(
        $MealEntriesTable.$convertermealType.toSql(mealType.value),
      );
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (compositeFoodId.present) {
      map['composite_food_id'] = Variable<int>(compositeFoodId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('foodId: $foodId, ')
          ..write('compositeFoodId: $compositeFoodId, ')
          ..write('grams: $grams, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BodyWeightEntriesTable bodyWeightEntries =
      $BodyWeightEntriesTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $CompositeFoodsTable compositeFoods = $CompositeFoodsTable(this);
  late final $CompositeFoodIngredientsTable compositeFoodIngredients =
      $CompositeFoodIngredientsTable(this);
  late final $MealEntriesTable mealEntries = $MealEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    appSettings,
    bodyWeightEntries,
    foods,
    compositeFoods,
    compositeFoodIngredients,
    mealEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'composite_foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('composite_food_ingredients', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<int?> heightCm,
      Value<String> username,
      Value<BiologicalSex?> sex,
      Value<DateTime?> birthDate,
      Value<ActivityLevel?> activityLevel,
      required WeightGoal goal,
      Value<int?> calorieTarget,
      required int proteinPercent,
      required int carbPercent,
      required int fatPercent,
      required DateTime updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<int?> heightCm,
      Value<String> username,
      Value<BiologicalSex?> sex,
      Value<DateTime?> birthDate,
      Value<ActivityLevel?> activityLevel,
      Value<WeightGoal> goal,
      Value<int?> calorieTarget,
      Value<int> proteinPercent,
      Value<int> carbPercent,
      Value<int> fatPercent,
      Value<DateTime> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BiologicalSex?, BiologicalSex, String>
  get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get birthDate =>
      $composableBuilder(
        column: $table.birthDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ActivityLevel?, ActivityLevel, String>
  get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightGoal, WeightGoal, String> get goal =>
      $composableBuilder(
        column: $table.goal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proteinPercent => $composableBuilder(
    column: $table.proteinPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbPercent => $composableBuilder(
    column: $table.carbPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatPercent => $composableBuilder(
    column: $table.fatPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proteinPercent => $composableBuilder(
    column: $table.proteinPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbPercent => $composableBuilder(
    column: $table.carbPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatPercent => $composableBuilder(
    column: $table.fatPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BiologicalSex?, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityLevel?, String> get activityLevel =>
      $composableBuilder(
        column: $table.activityLevel,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<WeightGoal, String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<int> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get proteinPercent => $composableBuilder(
    column: $table.proteinPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get carbPercent => $composableBuilder(
    column: $table.carbPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fatPercent => $composableBuilder(
    column: $table.fatPercent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<BiologicalSex?> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<ActivityLevel?> activityLevel = const Value.absent(),
                Value<WeightGoal> goal = const Value.absent(),
                Value<int?> calorieTarget = const Value.absent(),
                Value<int> proteinPercent = const Value.absent(),
                Value<int> carbPercent = const Value.absent(),
                Value<int> fatPercent = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                heightCm: heightCm,
                username: username,
                sex: sex,
                birthDate: birthDate,
                activityLevel: activityLevel,
                goal: goal,
                calorieTarget: calorieTarget,
                proteinPercent: proteinPercent,
                carbPercent: carbPercent,
                fatPercent: fatPercent,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<BiologicalSex?> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<ActivityLevel?> activityLevel = const Value.absent(),
                required WeightGoal goal,
                Value<int?> calorieTarget = const Value.absent(),
                required int proteinPercent,
                required int carbPercent,
                required int fatPercent,
                required DateTime updatedAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                heightCm: heightCm,
                username: username,
                sex: sex,
                birthDate: birthDate,
                activityLevel: activityLevel,
                goal: goal,
                calorieTarget: calorieTarget,
                proteinPercent: proteinPercent,
                carbPercent: carbPercent,
                fatPercent: fatPercent,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      required AppThemeMode themeMode,
      Value<bool> onboardingCompleted,
      required DateTime updatedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<AppThemeMode> themeMode,
      Value<bool> onboardingCompleted,
      Value<DateTime> updatedAt,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppThemeMode, AppThemeMode, String>
  get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppThemeMode, String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<AppThemeMode> themeMode = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required AppThemeMode themeMode,
                Value<bool> onboardingCompleted = const Value.absent(),
                required DateTime updatedAt,
              }) => AppSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$BodyWeightEntriesTableCreateCompanionBuilder =
    BodyWeightEntriesCompanion Function({
      required DateTime date,
      required double weightKg,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BodyWeightEntriesTableUpdateCompanionBuilder =
    BodyWeightEntriesCompanion Function({
      Value<DateTime> date,
      Value<double> weightKg,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BodyWeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BodyWeightEntriesTable> {
  $$BodyWeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyWeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyWeightEntriesTable> {
  $$BodyWeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyWeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyWeightEntriesTable> {
  $$BodyWeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateTime, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BodyWeightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyWeightEntriesTable,
          BodyWeightRow,
          $$BodyWeightEntriesTableFilterComposer,
          $$BodyWeightEntriesTableOrderingComposer,
          $$BodyWeightEntriesTableAnnotationComposer,
          $$BodyWeightEntriesTableCreateCompanionBuilder,
          $$BodyWeightEntriesTableUpdateCompanionBuilder,
          (
            BodyWeightRow,
            BaseReferences<
              _$AppDatabase,
              $BodyWeightEntriesTable,
              BodyWeightRow
            >,
          ),
          BodyWeightRow,
          PrefetchHooks Function()
        > {
  $$BodyWeightEntriesTableTableManager(
    _$AppDatabase db,
    $BodyWeightEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyWeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyWeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyWeightEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyWeightEntriesCompanion(
                date: date,
                weightKg: weightKg,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                required double weightKg,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BodyWeightEntriesCompanion.insert(
                date: date,
                weightKg: weightKg,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyWeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyWeightEntriesTable,
      BodyWeightRow,
      $$BodyWeightEntriesTableFilterComposer,
      $$BodyWeightEntriesTableOrderingComposer,
      $$BodyWeightEntriesTableAnnotationComposer,
      $$BodyWeightEntriesTableCreateCompanionBuilder,
      $$BodyWeightEntriesTableUpdateCompanionBuilder,
      (
        BodyWeightRow,
        BaseReferences<_$AppDatabase, $BodyWeightEntriesTable, BodyWeightRow>,
      ),
      BodyWeightRow,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> brand,
      required double kcalPer100g,
      required double proteinPer100g,
      required double carbsPer100g,
      required double fatPer100g,
      Value<double?> portionGrams,
      required FoodSource source,
      Value<String?> barcode,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$FoodsTableUpdateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> brand,
      Value<double> kcalPer100g,
      Value<double> proteinPer100g,
      Value<double> carbsPer100g,
      Value<double> fatPer100g,
      Value<double?> portionGrams,
      Value<FoodSource> source,
      Value<String?> barcode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$FoodsTableReferences
    extends BaseReferences<_$AppDatabase, $FoodsTable, FoodRow> {
  $$FoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $CompositeFoodIngredientsTable,
    List<CompositeFoodIngredientRow>
  >
  _compositeFoodIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.compositeFoodIngredients,
        aliasName: 'foods__id__composite_food_ingredients__food_id',
      );

  $$CompositeFoodIngredientsTableProcessedTableManager
  get compositeFoodIngredientsRefs {
    final manager = $$CompositeFoodIngredientsTableTableManager(
      $_db,
      $_db.compositeFoodIngredients,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compositeFoodIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MealEntriesTable, List<MealEntryRow>>
  _mealEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mealEntries,
    aliasName: 'foods__id__meal_entries__food_id',
  );

  $$MealEntriesTableProcessedTableManager get mealEntriesRefs {
    final manager = $$MealEntriesTableTableManager(
      $_db,
      $_db.mealEntries,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get portionGrams => $composableBuilder(
    column: $table.portionGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FoodSource, FoodSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> compositeFoodIngredientsRefs(
    Expression<bool> Function($$CompositeFoodIngredientsTableFilterComposer f)
    f,
  ) {
    final $$CompositeFoodIngredientsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compositeFoodIngredients,
          getReferencedColumn: (t) => t.foodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompositeFoodIngredientsTableFilterComposer(
                $db: $db,
                $table: $db.compositeFoodIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> mealEntriesRefs(
    Expression<bool> Function($$MealEntriesTableFilterComposer f) f,
  ) {
    final $$MealEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableFilterComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get portionGrams => $composableBuilder(
    column: $table.portionGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get portionGrams => $composableBuilder(
    column: $table.portionGrams,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FoodSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> compositeFoodIngredientsRefs<T extends Object>(
    Expression<T> Function($$CompositeFoodIngredientsTableAnnotationComposer a)
    f,
  ) {
    final $$CompositeFoodIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compositeFoodIngredients,
          getReferencedColumn: (t) => t.foodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompositeFoodIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.compositeFoodIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mealEntriesRefs<T extends Object>(
    Expression<T> Function($$MealEntriesTableAnnotationComposer a) f,
  ) {
    final $$MealEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          FoodRow,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (FoodRow, $$FoodsTableReferences),
          FoodRow,
          PrefetchHooks Function({
            bool compositeFoodIngredientsRefs,
            bool mealEntriesRefs,
          })
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double> kcalPer100g = const Value.absent(),
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> carbsPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double?> portionGrams = const Value.absent(),
                Value<FoodSource> source = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                name: name,
                brand: brand,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                portionGrams: portionGrams,
                source: source,
                barcode: barcode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                required double kcalPer100g,
                required double proteinPer100g,
                required double carbsPer100g,
                required double fatPer100g,
                Value<double?> portionGrams = const Value.absent(),
                required FoodSource source,
                Value<String?> barcode = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => FoodsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                portionGrams: portionGrams,
                source: source,
                barcode: barcode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FoodsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                compositeFoodIngredientsRefs = false,
                mealEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (compositeFoodIngredientsRefs)
                      db.compositeFoodIngredients,
                    if (mealEntriesRefs) db.mealEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (compositeFoodIngredientsRefs)
                        await $_getPrefetchedData<
                          FoodRow,
                          $FoodsTable,
                          CompositeFoodIngredientRow
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._compositeFoodIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).compositeFoodIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mealEntriesRefs)
                        await $_getPrefetchedData<
                          FoodRow,
                          $FoodsTable,
                          MealEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._mealEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).mealEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      FoodRow,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (FoodRow, $$FoodsTableReferences),
      FoodRow,
      PrefetchHooks Function({
        bool compositeFoodIngredientsRefs,
        bool mealEntriesRefs,
      })
    >;
typedef $$CompositeFoodsTableCreateCompanionBuilder =
    CompositeFoodsCompanion Function({
      Value<int> id,
      required String name,
      Value<double?> preparedGrams,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CompositeFoodsTableUpdateCompanionBuilder =
    CompositeFoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double?> preparedGrams,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CompositeFoodsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CompositeFoodsTable, CompositeFoodRow> {
  $$CompositeFoodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CompositeFoodIngredientsTable,
    List<CompositeFoodIngredientRow>
  >
  _compositeFoodIngredientsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.compositeFoodIngredients,
    aliasName:
        'composite_foods__id__composite_food_ingredients__composite_food_id',
  );

  $$CompositeFoodIngredientsTableProcessedTableManager
  get compositeFoodIngredientsRefs {
    final manager = $$CompositeFoodIngredientsTableTableManager(
      $_db,
      $_db.compositeFoodIngredients,
    ).filter((f) => f.compositeFoodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compositeFoodIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MealEntriesTable, List<MealEntryRow>>
  _mealEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mealEntries,
    aliasName: 'composite_foods__id__meal_entries__composite_food_id',
  );

  $$MealEntriesTableProcessedTableManager get mealEntriesRefs {
    final manager = $$MealEntriesTableTableManager(
      $_db,
      $_db.mealEntries,
    ).filter((f) => f.compositeFoodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompositeFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $CompositeFoodsTable> {
  $$CompositeFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get preparedGrams => $composableBuilder(
    column: $table.preparedGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> compositeFoodIngredientsRefs(
    Expression<bool> Function($$CompositeFoodIngredientsTableFilterComposer f)
    f,
  ) {
    final $$CompositeFoodIngredientsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compositeFoodIngredients,
          getReferencedColumn: (t) => t.compositeFoodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompositeFoodIngredientsTableFilterComposer(
                $db: $db,
                $table: $db.compositeFoodIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> mealEntriesRefs(
    Expression<bool> Function($$MealEntriesTableFilterComposer f) f,
  ) {
    final $$MealEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.compositeFoodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableFilterComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompositeFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompositeFoodsTable> {
  $$CompositeFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get preparedGrams => $composableBuilder(
    column: $table.preparedGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompositeFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompositeFoodsTable> {
  $$CompositeFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get preparedGrams => $composableBuilder(
    column: $table.preparedGrams,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> compositeFoodIngredientsRefs<T extends Object>(
    Expression<T> Function($$CompositeFoodIngredientsTableAnnotationComposer a)
    f,
  ) {
    final $$CompositeFoodIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compositeFoodIngredients,
          getReferencedColumn: (t) => t.compositeFoodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompositeFoodIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.compositeFoodIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mealEntriesRefs<T extends Object>(
    Expression<T> Function($$MealEntriesTableAnnotationComposer a) f,
  ) {
    final $$MealEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.compositeFoodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompositeFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompositeFoodsTable,
          CompositeFoodRow,
          $$CompositeFoodsTableFilterComposer,
          $$CompositeFoodsTableOrderingComposer,
          $$CompositeFoodsTableAnnotationComposer,
          $$CompositeFoodsTableCreateCompanionBuilder,
          $$CompositeFoodsTableUpdateCompanionBuilder,
          (CompositeFoodRow, $$CompositeFoodsTableReferences),
          CompositeFoodRow,
          PrefetchHooks Function({
            bool compositeFoodIngredientsRefs,
            bool mealEntriesRefs,
          })
        > {
  $$CompositeFoodsTableTableManager(
    _$AppDatabase db,
    $CompositeFoodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompositeFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompositeFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompositeFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> preparedGrams = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CompositeFoodsCompanion(
                id: id,
                name: name,
                preparedGrams: preparedGrams,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<double?> preparedGrams = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CompositeFoodsCompanion.insert(
                id: id,
                name: name,
                preparedGrams: preparedGrams,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompositeFoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                compositeFoodIngredientsRefs = false,
                mealEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (compositeFoodIngredientsRefs)
                      db.compositeFoodIngredients,
                    if (mealEntriesRefs) db.mealEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (compositeFoodIngredientsRefs)
                        await $_getPrefetchedData<
                          CompositeFoodRow,
                          $CompositeFoodsTable,
                          CompositeFoodIngredientRow
                        >(
                          currentTable: table,
                          referencedTable: $$CompositeFoodsTableReferences
                              ._compositeFoodIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompositeFoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).compositeFoodIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.compositeFoodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mealEntriesRefs)
                        await $_getPrefetchedData<
                          CompositeFoodRow,
                          $CompositeFoodsTable,
                          MealEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$CompositeFoodsTableReferences
                              ._mealEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompositeFoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).mealEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.compositeFoodId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompositeFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompositeFoodsTable,
      CompositeFoodRow,
      $$CompositeFoodsTableFilterComposer,
      $$CompositeFoodsTableOrderingComposer,
      $$CompositeFoodsTableAnnotationComposer,
      $$CompositeFoodsTableCreateCompanionBuilder,
      $$CompositeFoodsTableUpdateCompanionBuilder,
      (CompositeFoodRow, $$CompositeFoodsTableReferences),
      CompositeFoodRow,
      PrefetchHooks Function({
        bool compositeFoodIngredientsRefs,
        bool mealEntriesRefs,
      })
    >;
typedef $$CompositeFoodIngredientsTableCreateCompanionBuilder =
    CompositeFoodIngredientsCompanion Function({
      required int compositeFoodId,
      required int foodId,
      required double grams,
      Value<int> rowid,
    });
typedef $$CompositeFoodIngredientsTableUpdateCompanionBuilder =
    CompositeFoodIngredientsCompanion Function({
      Value<int> compositeFoodId,
      Value<int> foodId,
      Value<double> grams,
      Value<int> rowid,
    });

final class $$CompositeFoodIngredientsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompositeFoodIngredientsTable,
          CompositeFoodIngredientRow
        > {
  $$CompositeFoodIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompositeFoodsTable _compositeFoodIdTable(_$AppDatabase db) =>
      db.compositeFoods.createAlias(
        'composite_food_ingredients__composite_food_id__composite_foods__id',
      );

  $$CompositeFoodsTableProcessedTableManager get compositeFoodId {
    final $_column = $_itemColumn<int>('composite_food_id')!;

    final manager = $$CompositeFoodsTableTableManager(
      $_db,
      $_db.compositeFoods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compositeFoodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('composite_food_ingredients__food_id__foods__id');

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<int>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompositeFoodIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $CompositeFoodIngredientsTable> {
  $$CompositeFoodIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  $$CompositeFoodsTableFilterComposer get compositeFoodId {
    final $$CompositeFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositeFoodId,
      referencedTable: $db.compositeFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositeFoodsTableFilterComposer(
            $db: $db,
            $table: $db.compositeFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositeFoodIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompositeFoodIngredientsTable> {
  $$CompositeFoodIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompositeFoodsTableOrderingComposer get compositeFoodId {
    final $$CompositeFoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositeFoodId,
      referencedTable: $db.compositeFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositeFoodsTableOrderingComposer(
            $db: $db,
            $table: $db.compositeFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositeFoodIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompositeFoodIngredientsTable> {
  $$CompositeFoodIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  $$CompositeFoodsTableAnnotationComposer get compositeFoodId {
    final $$CompositeFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositeFoodId,
      referencedTable: $db.compositeFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositeFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.compositeFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositeFoodIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompositeFoodIngredientsTable,
          CompositeFoodIngredientRow,
          $$CompositeFoodIngredientsTableFilterComposer,
          $$CompositeFoodIngredientsTableOrderingComposer,
          $$CompositeFoodIngredientsTableAnnotationComposer,
          $$CompositeFoodIngredientsTableCreateCompanionBuilder,
          $$CompositeFoodIngredientsTableUpdateCompanionBuilder,
          (
            CompositeFoodIngredientRow,
            $$CompositeFoodIngredientsTableReferences,
          ),
          CompositeFoodIngredientRow,
          PrefetchHooks Function({bool compositeFoodId, bool foodId})
        > {
  $$CompositeFoodIngredientsTableTableManager(
    _$AppDatabase db,
    $CompositeFoodIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompositeFoodIngredientsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CompositeFoodIngredientsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CompositeFoodIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> compositeFoodId = const Value.absent(),
                Value<int> foodId = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompositeFoodIngredientsCompanion(
                compositeFoodId: compositeFoodId,
                foodId: foodId,
                grams: grams,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int compositeFoodId,
                required int foodId,
                required double grams,
                Value<int> rowid = const Value.absent(),
              }) => CompositeFoodIngredientsCompanion.insert(
                compositeFoodId: compositeFoodId,
                foodId: foodId,
                grams: grams,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompositeFoodIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compositeFoodId = false, foodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compositeFoodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.compositeFoodId,
                                referencedTable:
                                    $$CompositeFoodIngredientsTableReferences
                                        ._compositeFoodIdTable(db),
                                referencedColumn:
                                    $$CompositeFoodIngredientsTableReferences
                                        ._compositeFoodIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable:
                                    $$CompositeFoodIngredientsTableReferences
                                        ._foodIdTable(db),
                                referencedColumn:
                                    $$CompositeFoodIngredientsTableReferences
                                        ._foodIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompositeFoodIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompositeFoodIngredientsTable,
      CompositeFoodIngredientRow,
      $$CompositeFoodIngredientsTableFilterComposer,
      $$CompositeFoodIngredientsTableOrderingComposer,
      $$CompositeFoodIngredientsTableAnnotationComposer,
      $$CompositeFoodIngredientsTableCreateCompanionBuilder,
      $$CompositeFoodIngredientsTableUpdateCompanionBuilder,
      (CompositeFoodIngredientRow, $$CompositeFoodIngredientsTableReferences),
      CompositeFoodIngredientRow,
      PrefetchHooks Function({bool compositeFoodId, bool foodId})
    >;
typedef $$MealEntriesTableCreateCompanionBuilder =
    MealEntriesCompanion Function({
      Value<int> id,
      required DateTime date,
      required MealType mealType,
      Value<int?> foodId,
      Value<int?> compositeFoodId,
      required double grams,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$MealEntriesTableUpdateCompanionBuilder =
    MealEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<MealType> mealType,
      Value<int?> foodId,
      Value<int?> compositeFoodId,
      Value<double> grams,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$MealEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntryRow> {
  $$MealEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('meal_entries__food_id__foods__id');

  $$FoodsTableProcessedTableManager? get foodId {
    final $_column = $_itemColumn<int>('food_id');
    if ($_column == null) return null;
    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompositeFoodsTable _compositeFoodIdTable(_$AppDatabase db) => db
      .compositeFoods
      .createAlias('meal_entries__composite_food_id__composite_foods__id');

  $$CompositeFoodsTableProcessedTableManager? get compositeFoodId {
    final $_column = $_itemColumn<int>('composite_food_id');
    if ($_column == null) return null;
    final manager = $$CompositeFoodsTableTableManager(
      $_db,
      $_db.compositeFoods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compositeFoodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MealEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MealType, MealType, String> get mealType =>
      $composableBuilder(
        column: $table.mealType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompositeFoodsTableFilterComposer get compositeFoodId {
    final $$CompositeFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositeFoodId,
      referencedTable: $db.compositeFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositeFoodsTableFilterComposer(
            $db: $db,
            $table: $db.compositeFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompositeFoodsTableOrderingComposer get compositeFoodId {
    final $$CompositeFoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositeFoodId,
      referencedTable: $db.compositeFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositeFoodsTableOrderingComposer(
            $db: $db,
            $table: $db.compositeFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompositeFoodsTableAnnotationComposer get compositeFoodId {
    final $$CompositeFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositeFoodId,
      referencedTable: $db.compositeFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositeFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.compositeFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealEntriesTable,
          MealEntryRow,
          $$MealEntriesTableFilterComposer,
          $$MealEntriesTableOrderingComposer,
          $$MealEntriesTableAnnotationComposer,
          $$MealEntriesTableCreateCompanionBuilder,
          $$MealEntriesTableUpdateCompanionBuilder,
          (MealEntryRow, $$MealEntriesTableReferences),
          MealEntryRow,
          PrefetchHooks Function({bool foodId, bool compositeFoodId})
        > {
  $$MealEntriesTableTableManager(_$AppDatabase db, $MealEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<MealType> mealType = const Value.absent(),
                Value<int?> foodId = const Value.absent(),
                Value<int?> compositeFoodId = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MealEntriesCompanion(
                id: id,
                date: date,
                mealType: mealType,
                foodId: foodId,
                compositeFoodId: compositeFoodId,
                grams: grams,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required MealType mealType,
                Value<int?> foodId = const Value.absent(),
                Value<int?> compositeFoodId = const Value.absent(),
                required double grams,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MealEntriesCompanion.insert(
                id: id,
                date: date,
                mealType: mealType,
                foodId: foodId,
                compositeFoodId: compositeFoodId,
                grams: grams,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MealEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false, compositeFoodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable: $$MealEntriesTableReferences
                                    ._foodIdTable(db),
                                referencedColumn: $$MealEntriesTableReferences
                                    ._foodIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (compositeFoodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.compositeFoodId,
                                referencedTable: $$MealEntriesTableReferences
                                    ._compositeFoodIdTable(db),
                                referencedColumn: $$MealEntriesTableReferences
                                    ._compositeFoodIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MealEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealEntriesTable,
      MealEntryRow,
      $$MealEntriesTableFilterComposer,
      $$MealEntriesTableOrderingComposer,
      $$MealEntriesTableAnnotationComposer,
      $$MealEntriesTableCreateCompanionBuilder,
      $$MealEntriesTableUpdateCompanionBuilder,
      (MealEntryRow, $$MealEntriesTableReferences),
      MealEntryRow,
      PrefetchHooks Function({bool foodId, bool compositeFoodId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BodyWeightEntriesTableTableManager get bodyWeightEntries =>
      $$BodyWeightEntriesTableTableManager(_db, _db.bodyWeightEntries);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$CompositeFoodsTableTableManager get compositeFoods =>
      $$CompositeFoodsTableTableManager(_db, _db.compositeFoods);
  $$CompositeFoodIngredientsTableTableManager get compositeFoodIngredients =>
      $$CompositeFoodIngredientsTableTableManager(
        _db,
        _db.compositeFoodIngredients,
      );
  $$MealEntriesTableTableManager get mealEntries =>
      $$MealEntriesTableTableManager(_db, _db.mealEntries);
}
