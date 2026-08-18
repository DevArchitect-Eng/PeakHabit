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
  List<GeneratedColumn> get $columns => [id, themeMode, updatedAt];
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

  /// Last change, kept so a later cloud sync has something to order by.
  final DateTime updatedAt;
  const AppSettingsRow({
    required this.id,
    required this.themeMode,
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
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
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
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    AppThemeMode? themeMode,
    DateTime? updatedAt,
  }) => AppSettingsRow(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, themeMode, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<AppThemeMode> themeMode;
  final Value<DateTime> updatedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required AppThemeMode themeMode,
    required DateTime updatedAt,
  }) : themeMode = Value(themeMode),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<AppThemeMode>? themeMode,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BodyWeightEntriesTable bodyWeightEntries =
      $BodyWeightEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    appSettings,
    bodyWeightEntries,
  ];
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
      required DateTime updatedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<AppThemeMode> themeMode,
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
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeMode: themeMode,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required AppThemeMode themeMode,
                required DateTime updatedAt,
              }) => AppSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BodyWeightEntriesTableTableManager get bodyWeightEntries =>
      $$BodyWeightEntriesTableTableManager(_db, _db.bodyWeightEntries);
}
