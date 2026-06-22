// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendsTable extends Friends with TableInfo<$FriendsTable, Friend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friends';
  @override
  VerificationContext validateIntegrity(Insertable<Friend> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Friend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Friend(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FriendsTable createAlias(String alias) {
    return $FriendsTable(attachedDatabase, alias);
  }
}

class Friend extends DataClass implements Insertable<Friend> {
  final String id;
  final String name;
  final String? phone;
  final String createdAt;
  const Friend(
      {required this.id,
      required this.name,
      this.phone,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  FriendsCompanion toCompanion(bool nullToAbsent) {
    return FriendsCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      createdAt: Value(createdAt),
    );
  }

  factory Friend.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Friend(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Friend copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          String? createdAt}) =>
      Friend(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        createdAt: createdAt ?? this.createdAt,
      );
  Friend copyWithCompanion(FriendsCompanion data) {
    return Friend(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Friend(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Friend &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.createdAt == this.createdAt);
}

class FriendsCompanion extends UpdateCompanion<Friend> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String> createdAt;
  final Value<int> rowid;
  const FriendsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendsCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Friend> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return FriendsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _institutionMeta =
      const VerificationMeta('institution');
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
      'institution', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _last4DigitsMeta =
      const VerificationMeta('last4Digits');
  @override
  late final GeneratedColumn<String> last4Digits = GeneratedColumn<String>(
      'last_4_digits', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackedBalanceMeta =
      const VerificationMeta('trackedBalance');
  @override
  late final GeneratedColumn<int> trackedBalance = GeneratedColumn<int>(
      'tracked_balance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<int> currentBalance = GeneratedColumn<int>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCreditMeta =
      const VerificationMeta('isCredit');
  @override
  late final GeneratedColumn<int> isCredit = GeneratedColumn<int>(
      'is_credit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _creditLimitMeta =
      const VerificationMeta('creditLimit');
  @override
  late final GeneratedColumn<int> creditLimit = GeneratedColumn<int>(
      'credit_limit', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _billingDayMeta =
      const VerificationMeta('billingDay');
  @override
  late final GeneratedColumn<int> billingDay = GeneratedColumn<int>(
      'billing_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
      'due_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
      'is_active', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<int> isDefault = GeneratedColumn<int>(
      'is_default', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        institution,
        last4Digits,
        color,
        icon,
        trackedBalance,
        currentBalance,
        isCredit,
        creditLimit,
        billingDay,
        dueDay,
        isActive,
        isDefault,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('institution')) {
      context.handle(
          _institutionMeta,
          institution.isAcceptableOrUnknown(
              data['institution']!, _institutionMeta));
    }
    if (data.containsKey('last_4_digits')) {
      context.handle(
          _last4DigitsMeta,
          last4Digits.isAcceptableOrUnknown(
              data['last_4_digits']!, _last4DigitsMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('tracked_balance')) {
      context.handle(
          _trackedBalanceMeta,
          trackedBalance.isAcceptableOrUnknown(
              data['tracked_balance']!, _trackedBalanceMeta));
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    }
    if (data.containsKey('is_credit')) {
      context.handle(_isCreditMeta,
          isCredit.isAcceptableOrUnknown(data['is_credit']!, _isCreditMeta));
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
          _creditLimitMeta,
          creditLimit.isAcceptableOrUnknown(
              data['credit_limit']!, _creditLimitMeta));
    }
    if (data.containsKey('billing_day')) {
      context.handle(
          _billingDayMeta,
          billingDay.isAcceptableOrUnknown(
              data['billing_day']!, _billingDayMeta));
    }
    if (data.containsKey('due_day')) {
      context.handle(_dueDayMeta,
          dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      institution: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}institution']),
      last4Digits: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_4_digits']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      trackedBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tracked_balance'])!,
      currentBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_balance'])!,
      isCredit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_credit'])!,
      creditLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credit_limit']),
      billingDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}billing_day']),
      dueDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_day']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_active'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final String type;
  final String? institution;
  final String? last4Digits;
  final String? color;
  final String? icon;
  final int trackedBalance;
  final int currentBalance;
  final int isCredit;
  final int? creditLimit;
  final int? billingDay;
  final int? dueDay;
  final int isActive;
  final int isDefault;
  final String createdAt;
  const Account(
      {required this.id,
      required this.name,
      required this.type,
      this.institution,
      this.last4Digits,
      this.color,
      this.icon,
      required this.trackedBalance,
      required this.currentBalance,
      required this.isCredit,
      this.creditLimit,
      this.billingDay,
      this.dueDay,
      required this.isActive,
      required this.isDefault,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    if (!nullToAbsent || last4Digits != null) {
      map['last_4_digits'] = Variable<String>(last4Digits);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['tracked_balance'] = Variable<int>(trackedBalance);
    map['current_balance'] = Variable<int>(currentBalance);
    map['is_credit'] = Variable<int>(isCredit);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<int>(creditLimit);
    }
    if (!nullToAbsent || billingDay != null) {
      map['billing_day'] = Variable<int>(billingDay);
    }
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    map['is_active'] = Variable<int>(isActive);
    map['is_default'] = Variable<int>(isDefault);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      last4Digits: last4Digits == null && nullToAbsent
          ? const Value.absent()
          : Value(last4Digits),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      trackedBalance: Value(trackedBalance),
      currentBalance: Value(currentBalance),
      isCredit: Value(isCredit),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      billingDay: billingDay == null && nullToAbsent
          ? const Value.absent()
          : Value(billingDay),
      dueDay:
          dueDay == null && nullToAbsent ? const Value.absent() : Value(dueDay),
      isActive: Value(isActive),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      institution: serializer.fromJson<String?>(json['institution']),
      last4Digits: serializer.fromJson<String?>(json['last4Digits']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      trackedBalance: serializer.fromJson<int>(json['trackedBalance']),
      currentBalance: serializer.fromJson<int>(json['currentBalance']),
      isCredit: serializer.fromJson<int>(json['isCredit']),
      creditLimit: serializer.fromJson<int?>(json['creditLimit']),
      billingDay: serializer.fromJson<int?>(json['billingDay']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
      isActive: serializer.fromJson<int>(json['isActive']),
      isDefault: serializer.fromJson<int>(json['isDefault']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'institution': serializer.toJson<String?>(institution),
      'last4Digits': serializer.toJson<String?>(last4Digits),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'trackedBalance': serializer.toJson<int>(trackedBalance),
      'currentBalance': serializer.toJson<int>(currentBalance),
      'isCredit': serializer.toJson<int>(isCredit),
      'creditLimit': serializer.toJson<int?>(creditLimit),
      'billingDay': serializer.toJson<int?>(billingDay),
      'dueDay': serializer.toJson<int?>(dueDay),
      'isActive': serializer.toJson<int>(isActive),
      'isDefault': serializer.toJson<int>(isDefault),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Account copyWith(
          {String? id,
          String? name,
          String? type,
          Value<String?> institution = const Value.absent(),
          Value<String?> last4Digits = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> icon = const Value.absent(),
          int? trackedBalance,
          int? currentBalance,
          int? isCredit,
          Value<int?> creditLimit = const Value.absent(),
          Value<int?> billingDay = const Value.absent(),
          Value<int?> dueDay = const Value.absent(),
          int? isActive,
          int? isDefault,
          String? createdAt}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        institution: institution.present ? institution.value : this.institution,
        last4Digits: last4Digits.present ? last4Digits.value : this.last4Digits,
        color: color.present ? color.value : this.color,
        icon: icon.present ? icon.value : this.icon,
        trackedBalance: trackedBalance ?? this.trackedBalance,
        currentBalance: currentBalance ?? this.currentBalance,
        isCredit: isCredit ?? this.isCredit,
        creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
        billingDay: billingDay.present ? billingDay.value : this.billingDay,
        dueDay: dueDay.present ? dueDay.value : this.dueDay,
        isActive: isActive ?? this.isActive,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      institution:
          data.institution.present ? data.institution.value : this.institution,
      last4Digits:
          data.last4Digits.present ? data.last4Digits.value : this.last4Digits,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      trackedBalance: data.trackedBalance.present
          ? data.trackedBalance.value
          : this.trackedBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      isCredit: data.isCredit.present ? data.isCredit.value : this.isCredit,
      creditLimit:
          data.creditLimit.present ? data.creditLimit.value : this.creditLimit,
      billingDay:
          data.billingDay.present ? data.billingDay.value : this.billingDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('institution: $institution, ')
          ..write('last4Digits: $last4Digits, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('trackedBalance: $trackedBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isCredit: $isCredit, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('billingDay: $billingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('isActive: $isActive, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      institution,
      last4Digits,
      color,
      icon,
      trackedBalance,
      currentBalance,
      isCredit,
      creditLimit,
      billingDay,
      dueDay,
      isActive,
      isDefault,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.institution == this.institution &&
          other.last4Digits == this.last4Digits &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.trackedBalance == this.trackedBalance &&
          other.currentBalance == this.currentBalance &&
          other.isCredit == this.isCredit &&
          other.creditLimit == this.creditLimit &&
          other.billingDay == this.billingDay &&
          other.dueDay == this.dueDay &&
          other.isActive == this.isActive &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> institution;
  final Value<String?> last4Digits;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<int> trackedBalance;
  final Value<int> currentBalance;
  final Value<int> isCredit;
  final Value<int?> creditLimit;
  final Value<int?> billingDay;
  final Value<int?> dueDay;
  final Value<int> isActive;
  final Value<int> isDefault;
  final Value<String> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.institution = const Value.absent(),
    this.last4Digits = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.trackedBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.isCredit = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.institution = const Value.absent(),
    this.last4Digits = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.trackedBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.isCredit = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDefault = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? institution,
    Expression<String>? last4Digits,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? trackedBalance,
    Expression<int>? currentBalance,
    Expression<int>? isCredit,
    Expression<int>? creditLimit,
    Expression<int>? billingDay,
    Expression<int>? dueDay,
    Expression<int>? isActive,
    Expression<int>? isDefault,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (institution != null) 'institution': institution,
      if (last4Digits != null) 'last_4_digits': last4Digits,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (trackedBalance != null) 'tracked_balance': trackedBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (isCredit != null) 'is_credit': isCredit,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (billingDay != null) 'billing_day': billingDay,
      if (dueDay != null) 'due_day': dueDay,
      if (isActive != null) 'is_active': isActive,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? institution,
      Value<String?>? last4Digits,
      Value<String?>? color,
      Value<String?>? icon,
      Value<int>? trackedBalance,
      Value<int>? currentBalance,
      Value<int>? isCredit,
      Value<int?>? creditLimit,
      Value<int?>? billingDay,
      Value<int?>? dueDay,
      Value<int>? isActive,
      Value<int>? isDefault,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      institution: institution ?? this.institution,
      last4Digits: last4Digits ?? this.last4Digits,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      trackedBalance: trackedBalance ?? this.trackedBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isCredit: isCredit ?? this.isCredit,
      creditLimit: creditLimit ?? this.creditLimit,
      billingDay: billingDay ?? this.billingDay,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (last4Digits.present) {
      map['last_4_digits'] = Variable<String>(last4Digits.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (trackedBalance.present) {
      map['tracked_balance'] = Variable<int>(trackedBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<int>(currentBalance.value);
    }
    if (isCredit.present) {
      map['is_credit'] = Variable<int>(isCredit.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<int>(creditLimit.value);
    }
    if (billingDay.present) {
      map['billing_day'] = Variable<int>(billingDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<int>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('institution: $institution, ')
          ..write('last4Digits: $last4Digits, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('trackedBalance: $trackedBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isCredit: $isCredit, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('billingDay: $billingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('isActive: $isActive, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _friendIdMeta =
      const VerificationMeta('friendId');
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
      'friend_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fromAccountIdMeta =
      const VerificationMeta('fromAccountId');
  @override
  late final GeneratedColumn<String> fromAccountId = GeneratedColumn<String>(
      'from_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toAccountIdMeta =
      const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
      'to_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurringIdMeta =
      const VerificationMeta('recurringId');
  @override
  late final GeneratedColumn<String> recurringId = GeneratedColumn<String>(
      'recurring_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
      'loan_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<String> eventDate = GeneratedColumn<String>(
      'event_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _billPhotoPathMeta =
      const VerificationMeta('billPhotoPath');
  @override
  late final GeneratedColumn<String> billPhotoPath = GeneratedColumn<String>(
      'bill_photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        amount,
        category,
        description,
        friendId,
        accountId,
        fromAccountId,
        toAccountId,
        recurringId,
        loanId,
        eventDate,
        createdAt,
        billPhotoPath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<Event> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('friend_id')) {
      context.handle(_friendIdMeta,
          friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('from_account_id')) {
      context.handle(
          _fromAccountIdMeta,
          fromAccountId.isAcceptableOrUnknown(
              data['from_account_id']!, _fromAccountIdMeta));
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
          _toAccountIdMeta,
          toAccountId.isAcceptableOrUnknown(
              data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('recurring_id')) {
      context.handle(
          _recurringIdMeta,
          recurringId.isAcceptableOrUnknown(
              data['recurring_id']!, _recurringIdMeta));
    }
    if (data.containsKey('loan_id')) {
      context.handle(_loanIdMeta,
          loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta));
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('bill_photo_path')) {
      context.handle(
          _billPhotoPathMeta,
          billPhotoPath.isAcceptableOrUnknown(
              data['bill_photo_path']!, _billPhotoPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      friendId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friend_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id']),
      fromAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_account_id']),
      toAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_account_id']),
      recurringId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurring_id']),
      loanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loan_id']),
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      billPhotoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bill_photo_path']),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String type;
  final int amount;
  final String? category;
  final String? description;
  final String? friendId;
  final String? accountId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? recurringId;
  final String? loanId;
  final String eventDate;
  final String createdAt;
  final String? billPhotoPath;
  const Event(
      {required this.id,
      required this.type,
      required this.amount,
      this.category,
      this.description,
      this.friendId,
      this.accountId,
      this.fromAccountId,
      this.toAccountId,
      this.recurringId,
      this.loanId,
      required this.eventDate,
      required this.createdAt,
      this.billPhotoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || friendId != null) {
      map['friend_id'] = Variable<String>(friendId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || fromAccountId != null) {
      map['from_account_id'] = Variable<String>(fromAccountId);
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || recurringId != null) {
      map['recurring_id'] = Variable<String>(recurringId);
    }
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<String>(loanId);
    }
    map['event_date'] = Variable<String>(eventDate);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || billPhotoPath != null) {
      map['bill_photo_path'] = Variable<String>(billPhotoPath);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      friendId: friendId == null && nullToAbsent
          ? const Value.absent()
          : Value(friendId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      fromAccountId: fromAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromAccountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      recurringId: recurringId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringId),
      loanId:
          loanId == null && nullToAbsent ? const Value.absent() : Value(loanId),
      eventDate: Value(eventDate),
      createdAt: Value(createdAt),
      billPhotoPath: billPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(billPhotoPath),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      category: serializer.fromJson<String?>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      friendId: serializer.fromJson<String?>(json['friendId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      fromAccountId: serializer.fromJson<String?>(json['fromAccountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      recurringId: serializer.fromJson<String?>(json['recurringId']),
      loanId: serializer.fromJson<String?>(json['loanId']),
      eventDate: serializer.fromJson<String>(json['eventDate']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      billPhotoPath: serializer.fromJson<String?>(json['billPhotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'category': serializer.toJson<String?>(category),
      'description': serializer.toJson<String?>(description),
      'friendId': serializer.toJson<String?>(friendId),
      'accountId': serializer.toJson<String?>(accountId),
      'fromAccountId': serializer.toJson<String?>(fromAccountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'recurringId': serializer.toJson<String?>(recurringId),
      'loanId': serializer.toJson<String?>(loanId),
      'eventDate': serializer.toJson<String>(eventDate),
      'createdAt': serializer.toJson<String>(createdAt),
      'billPhotoPath': serializer.toJson<String?>(billPhotoPath),
    };
  }

  Event copyWith(
          {String? id,
          String? type,
          int? amount,
          Value<String?> category = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> friendId = const Value.absent(),
          Value<String?> accountId = const Value.absent(),
          Value<String?> fromAccountId = const Value.absent(),
          Value<String?> toAccountId = const Value.absent(),
          Value<String?> recurringId = const Value.absent(),
          Value<String?> loanId = const Value.absent(),
          String? eventDate,
          String? createdAt,
          Value<String?> billPhotoPath = const Value.absent()}) =>
      Event(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        category: category.present ? category.value : this.category,
        description: description.present ? description.value : this.description,
        friendId: friendId.present ? friendId.value : this.friendId,
        accountId: accountId.present ? accountId.value : this.accountId,
        fromAccountId:
            fromAccountId.present ? fromAccountId.value : this.fromAccountId,
        toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
        recurringId: recurringId.present ? recurringId.value : this.recurringId,
        loanId: loanId.present ? loanId.value : this.loanId,
        eventDate: eventDate ?? this.eventDate,
        createdAt: createdAt ?? this.createdAt,
        billPhotoPath:
            billPhotoPath.present ? billPhotoPath.value : this.billPhotoPath,
      );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      fromAccountId: data.fromAccountId.present
          ? data.fromAccountId.value
          : this.fromAccountId,
      toAccountId:
          data.toAccountId.present ? data.toAccountId.value : this.toAccountId,
      recurringId:
          data.recurringId.present ? data.recurringId.value : this.recurringId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      billPhotoPath: data.billPhotoPath.present
          ? data.billPhotoPath.value
          : this.billPhotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('friendId: $friendId, ')
          ..write('accountId: $accountId, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('recurringId: $recurringId, ')
          ..write('loanId: $loanId, ')
          ..write('eventDate: $eventDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('billPhotoPath: $billPhotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      amount,
      category,
      description,
      friendId,
      accountId,
      fromAccountId,
      toAccountId,
      recurringId,
      loanId,
      eventDate,
      createdAt,
      billPhotoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.description == this.description &&
          other.friendId == this.friendId &&
          other.accountId == this.accountId &&
          other.fromAccountId == this.fromAccountId &&
          other.toAccountId == this.toAccountId &&
          other.recurringId == this.recurringId &&
          other.loanId == this.loanId &&
          other.eventDate == this.eventDate &&
          other.createdAt == this.createdAt &&
          other.billPhotoPath == this.billPhotoPath);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> amount;
  final Value<String?> category;
  final Value<String?> description;
  final Value<String?> friendId;
  final Value<String?> accountId;
  final Value<String?> fromAccountId;
  final Value<String?> toAccountId;
  final Value<String?> recurringId;
  final Value<String?> loanId;
  final Value<String> eventDate;
  final Value<String> createdAt;
  final Value<String?> billPhotoPath;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.friendId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.billPhotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String type,
    required int amount,
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.friendId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.loanId = const Value.absent(),
    required String eventDate,
    required String createdAt,
    this.billPhotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        amount = Value(amount),
        eventDate = Value(eventDate),
        createdAt = Value(createdAt);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? friendId,
    Expression<String>? accountId,
    Expression<String>? fromAccountId,
    Expression<String>? toAccountId,
    Expression<String>? recurringId,
    Expression<String>? loanId,
    Expression<String>? eventDate,
    Expression<String>? createdAt,
    Expression<String>? billPhotoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (friendId != null) 'friend_id': friendId,
      if (accountId != null) 'account_id': accountId,
      if (fromAccountId != null) 'from_account_id': fromAccountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (recurringId != null) 'recurring_id': recurringId,
      if (loanId != null) 'loan_id': loanId,
      if (eventDate != null) 'event_date': eventDate,
      if (createdAt != null) 'created_at': createdAt,
      if (billPhotoPath != null) 'bill_photo_path': billPhotoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<int>? amount,
      Value<String?>? category,
      Value<String?>? description,
      Value<String?>? friendId,
      Value<String?>? accountId,
      Value<String?>? fromAccountId,
      Value<String?>? toAccountId,
      Value<String?>? recurringId,
      Value<String?>? loanId,
      Value<String>? eventDate,
      Value<String>? createdAt,
      Value<String?>? billPhotoPath,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      friendId: friendId ?? this.friendId,
      accountId: accountId ?? this.accountId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      recurringId: recurringId ?? this.recurringId,
      loanId: loanId ?? this.loanId,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
      billPhotoPath: billPhotoPath ?? this.billPhotoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (fromAccountId.present) {
      map['from_account_id'] = Variable<String>(fromAccountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (recurringId.present) {
      map['recurring_id'] = Variable<String>(recurringId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<String>(eventDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (billPhotoPath.present) {
      map['bill_photo_path'] = Variable<String>(billPhotoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('friendId: $friendId, ')
          ..write('accountId: $accountId, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('recurringId: $recurringId, ')
          ..write('loanId: $loanId, ')
          ..write('eventDate: $eventDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('billPhotoPath: $billPhotoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<int> isDefault = GeneratedColumn<int>(
      'is_default', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, name, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_default'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final int isDefault;
  const Category(
      {required this.id, required this.name, required this.isDefault});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<int>(isDefault);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      isDefault: Value(isDefault),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<int>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<int>(isDefault),
    };
  }

  Category copyWith({String? id, String? name, int? isDefault}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        isDefault: isDefault ?? this.isDefault,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> isDefault;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? isDefault,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<int>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthRecordsTable extends MonthRecords
    with TableInfo<$MonthRecordsTable, MonthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _baseBudgetMeta =
      const VerificationMeta('baseBudget');
  @override
  late final GeneratedColumn<int> baseBudget = GeneratedColumn<int>(
      'base_budget', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _carryOverAmountMeta =
      const VerificationMeta('carryOverAmount');
  @override
  late final GeneratedColumn<int> carryOverAmount = GeneratedColumn<int>(
      'carry_over_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalBudgetMeta =
      const VerificationMeta('totalBudget');
  @override
  late final GeneratedColumn<int> totalBudget = GeneratedColumn<int>(
      'total_budget', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalSpentMeta =
      const VerificationMeta('totalSpent');
  @override
  late final GeneratedColumn<int> totalSpent = GeneratedColumn<int>(
      'total_spent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _endingBalanceMeta =
      const VerificationMeta('endingBalance');
  @override
  late final GeneratedColumn<int> endingBalance = GeneratedColumn<int>(
      'ending_balance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        year,
        month,
        baseBudget,
        carryOverAmount,
        totalBudget,
        totalSpent,
        endingBalance,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'month_records';
  @override
  VerificationContext validateIntegrity(Insertable<MonthRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('base_budget')) {
      context.handle(
          _baseBudgetMeta,
          baseBudget.isAcceptableOrUnknown(
              data['base_budget']!, _baseBudgetMeta));
    } else if (isInserting) {
      context.missing(_baseBudgetMeta);
    }
    if (data.containsKey('carry_over_amount')) {
      context.handle(
          _carryOverAmountMeta,
          carryOverAmount.isAcceptableOrUnknown(
              data['carry_over_amount']!, _carryOverAmountMeta));
    }
    if (data.containsKey('total_budget')) {
      context.handle(
          _totalBudgetMeta,
          totalBudget.isAcceptableOrUnknown(
              data['total_budget']!, _totalBudgetMeta));
    } else if (isInserting) {
      context.missing(_totalBudgetMeta);
    }
    if (data.containsKey('total_spent')) {
      context.handle(
          _totalSpentMeta,
          totalSpent.isAcceptableOrUnknown(
              data['total_spent']!, _totalSpentMeta));
    }
    if (data.containsKey('ending_balance')) {
      context.handle(
          _endingBalanceMeta,
          endingBalance.isAcceptableOrUnknown(
              data['ending_balance']!, _endingBalanceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {year, month},
      ];
  @override
  MonthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      baseBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}base_budget'])!,
      carryOverAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}carry_over_amount'])!,
      totalBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_budget'])!,
      totalSpent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_spent'])!,
      endingBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ending_balance'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MonthRecordsTable createAlias(String alias) {
    return $MonthRecordsTable(attachedDatabase, alias);
  }
}

class MonthRecord extends DataClass implements Insertable<MonthRecord> {
  final String id;
  final int year;
  final int month;
  final int baseBudget;
  final int carryOverAmount;
  final int totalBudget;
  final int totalSpent;
  final int endingBalance;
  final String createdAt;
  const MonthRecord(
      {required this.id,
      required this.year,
      required this.month,
      required this.baseBudget,
      required this.carryOverAmount,
      required this.totalBudget,
      required this.totalSpent,
      required this.endingBalance,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['base_budget'] = Variable<int>(baseBudget);
    map['carry_over_amount'] = Variable<int>(carryOverAmount);
    map['total_budget'] = Variable<int>(totalBudget);
    map['total_spent'] = Variable<int>(totalSpent);
    map['ending_balance'] = Variable<int>(endingBalance);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MonthRecordsCompanion toCompanion(bool nullToAbsent) {
    return MonthRecordsCompanion(
      id: Value(id),
      year: Value(year),
      month: Value(month),
      baseBudget: Value(baseBudget),
      carryOverAmount: Value(carryOverAmount),
      totalBudget: Value(totalBudget),
      totalSpent: Value(totalSpent),
      endingBalance: Value(endingBalance),
      createdAt: Value(createdAt),
    );
  }

  factory MonthRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthRecord(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      baseBudget: serializer.fromJson<int>(json['baseBudget']),
      carryOverAmount: serializer.fromJson<int>(json['carryOverAmount']),
      totalBudget: serializer.fromJson<int>(json['totalBudget']),
      totalSpent: serializer.fromJson<int>(json['totalSpent']),
      endingBalance: serializer.fromJson<int>(json['endingBalance']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'baseBudget': serializer.toJson<int>(baseBudget),
      'carryOverAmount': serializer.toJson<int>(carryOverAmount),
      'totalBudget': serializer.toJson<int>(totalBudget),
      'totalSpent': serializer.toJson<int>(totalSpent),
      'endingBalance': serializer.toJson<int>(endingBalance),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MonthRecord copyWith(
          {String? id,
          int? year,
          int? month,
          int? baseBudget,
          int? carryOverAmount,
          int? totalBudget,
          int? totalSpent,
          int? endingBalance,
          String? createdAt}) =>
      MonthRecord(
        id: id ?? this.id,
        year: year ?? this.year,
        month: month ?? this.month,
        baseBudget: baseBudget ?? this.baseBudget,
        carryOverAmount: carryOverAmount ?? this.carryOverAmount,
        totalBudget: totalBudget ?? this.totalBudget,
        totalSpent: totalSpent ?? this.totalSpent,
        endingBalance: endingBalance ?? this.endingBalance,
        createdAt: createdAt ?? this.createdAt,
      );
  MonthRecord copyWithCompanion(MonthRecordsCompanion data) {
    return MonthRecord(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      baseBudget:
          data.baseBudget.present ? data.baseBudget.value : this.baseBudget,
      carryOverAmount: data.carryOverAmount.present
          ? data.carryOverAmount.value
          : this.carryOverAmount,
      totalBudget:
          data.totalBudget.present ? data.totalBudget.value : this.totalBudget,
      totalSpent:
          data.totalSpent.present ? data.totalSpent.value : this.totalSpent,
      endingBalance: data.endingBalance.present
          ? data.endingBalance.value
          : this.endingBalance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthRecord(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('baseBudget: $baseBudget, ')
          ..write('carryOverAmount: $carryOverAmount, ')
          ..write('totalBudget: $totalBudget, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('endingBalance: $endingBalance, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, year, month, baseBudget, carryOverAmount,
      totalBudget, totalSpent, endingBalance, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthRecord &&
          other.id == this.id &&
          other.year == this.year &&
          other.month == this.month &&
          other.baseBudget == this.baseBudget &&
          other.carryOverAmount == this.carryOverAmount &&
          other.totalBudget == this.totalBudget &&
          other.totalSpent == this.totalSpent &&
          other.endingBalance == this.endingBalance &&
          other.createdAt == this.createdAt);
}

class MonthRecordsCompanion extends UpdateCompanion<MonthRecord> {
  final Value<String> id;
  final Value<int> year;
  final Value<int> month;
  final Value<int> baseBudget;
  final Value<int> carryOverAmount;
  final Value<int> totalBudget;
  final Value<int> totalSpent;
  final Value<int> endingBalance;
  final Value<String> createdAt;
  final Value<int> rowid;
  const MonthRecordsCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.baseBudget = const Value.absent(),
    this.carryOverAmount = const Value.absent(),
    this.totalBudget = const Value.absent(),
    this.totalSpent = const Value.absent(),
    this.endingBalance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthRecordsCompanion.insert({
    required String id,
    required int year,
    required int month,
    required int baseBudget,
    this.carryOverAmount = const Value.absent(),
    required int totalBudget,
    this.totalSpent = const Value.absent(),
    this.endingBalance = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        year = Value(year),
        month = Value(month),
        baseBudget = Value(baseBudget),
        totalBudget = Value(totalBudget),
        createdAt = Value(createdAt);
  static Insertable<MonthRecord> custom({
    Expression<String>? id,
    Expression<int>? year,
    Expression<int>? month,
    Expression<int>? baseBudget,
    Expression<int>? carryOverAmount,
    Expression<int>? totalBudget,
    Expression<int>? totalSpent,
    Expression<int>? endingBalance,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (baseBudget != null) 'base_budget': baseBudget,
      if (carryOverAmount != null) 'carry_over_amount': carryOverAmount,
      if (totalBudget != null) 'total_budget': totalBudget,
      if (totalSpent != null) 'total_spent': totalSpent,
      if (endingBalance != null) 'ending_balance': endingBalance,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthRecordsCompanion copyWith(
      {Value<String>? id,
      Value<int>? year,
      Value<int>? month,
      Value<int>? baseBudget,
      Value<int>? carryOverAmount,
      Value<int>? totalBudget,
      Value<int>? totalSpent,
      Value<int>? endingBalance,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return MonthRecordsCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      baseBudget: baseBudget ?? this.baseBudget,
      carryOverAmount: carryOverAmount ?? this.carryOverAmount,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      endingBalance: endingBalance ?? this.endingBalance,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (baseBudget.present) {
      map['base_budget'] = Variable<int>(baseBudget.value);
    }
    if (carryOverAmount.present) {
      map['carry_over_amount'] = Variable<int>(carryOverAmount.value);
    }
    if (totalBudget.present) {
      map['total_budget'] = Variable<int>(totalBudget.value);
    }
    if (totalSpent.present) {
      map['total_spent'] = Variable<int>(totalSpent.value);
    }
    if (endingBalance.present) {
      map['ending_balance'] = Variable<int>(endingBalance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('baseBudget: $baseBudget, ')
          ..write('carryOverAmount: $carryOverAmount, ')
          ..write('totalBudget: $totalBudget, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('endingBalance: $endingBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayOfMonthMeta =
      const VerificationMeta('dayOfMonth');
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
      'day_of_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'end_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requiresVerificationMeta =
      const VerificationMeta('requiresVerification');
  @override
  late final GeneratedColumn<int> requiresVerification = GeneratedColumn<int>(
      'requires_verification', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _autoApplyMeta =
      const VerificationMeta('autoApply');
  @override
  late final GeneratedColumn<int> autoApply = GeneratedColumn<int>(
      'auto_apply', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isAutopayMeta =
      const VerificationMeta('isAutopay');
  @override
  late final GeneratedColumn<int> isAutopay = GeneratedColumn<int>(
      'is_autopay', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
      'is_active', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _lastAppliedDateMeta =
      const VerificationMeta('lastAppliedDate');
  @override
  late final GeneratedColumn<String> lastAppliedDate = GeneratedColumn<String>(
      'last_applied_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<String> nextDueDate = GeneratedColumn<String>(
      'next_due_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedLoanIdMeta =
      const VerificationMeta('linkedLoanId');
  @override
  late final GeneratedColumn<String> linkedLoanId = GeneratedColumn<String>(
      'linked_loan_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        amount,
        category,
        accountId,
        frequency,
        dayOfMonth,
        dayOfWeek,
        startDate,
        endDate,
        requiresVerification,
        autoApply,
        isAutopay,
        isActive,
        lastAppliedDate,
        nextDueDate,
        linkedLoanId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
          _dayOfMonthMeta,
          dayOfMonth.isAcceptableOrUnknown(
              data['day_of_month']!, _dayOfMonthMeta));
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('requires_verification')) {
      context.handle(
          _requiresVerificationMeta,
          requiresVerification.isAcceptableOrUnknown(
              data['requires_verification']!, _requiresVerificationMeta));
    }
    if (data.containsKey('auto_apply')) {
      context.handle(_autoApplyMeta,
          autoApply.isAcceptableOrUnknown(data['auto_apply']!, _autoApplyMeta));
    }
    if (data.containsKey('is_autopay')) {
      context.handle(_isAutopayMeta,
          isAutopay.isAcceptableOrUnknown(data['is_autopay']!, _isAutopayMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_applied_date')) {
      context.handle(
          _lastAppliedDateMeta,
          lastAppliedDate.isAcceptableOrUnknown(
              data['last_applied_date']!, _lastAppliedDateMeta));
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    }
    if (data.containsKey('linked_loan_id')) {
      context.handle(
          _linkedLoanIdMeta,
          linkedLoanId.isAcceptableOrUnknown(
              data['linked_loan_id']!, _linkedLoanIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id']),
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      dayOfMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_month']),
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      requiresVerification: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}requires_verification'])!,
      autoApply: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}auto_apply'])!,
      isAutopay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_autopay'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_active'])!,
      lastAppliedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_applied_date']),
      nextDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}next_due_date']),
      linkedLoanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_loan_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }
}

class RecurringTransaction extends DataClass
    implements Insertable<RecurringTransaction> {
  final String id;
  final String name;
  final String type;
  final int amount;
  final String? category;
  final String? accountId;
  final String frequency;
  final int? dayOfMonth;
  final int? dayOfWeek;
  final String startDate;
  final String? endDate;
  final int requiresVerification;
  final int autoApply;
  final int isAutopay;
  final int isActive;
  final String? lastAppliedDate;
  final String? nextDueDate;
  final String? linkedLoanId;
  final String createdAt;
  const RecurringTransaction(
      {required this.id,
      required this.name,
      required this.type,
      required this.amount,
      this.category,
      this.accountId,
      required this.frequency,
      this.dayOfMonth,
      this.dayOfWeek,
      required this.startDate,
      this.endDate,
      required this.requiresVerification,
      required this.autoApply,
      required this.isAutopay,
      required this.isActive,
      this.lastAppliedDate,
      this.nextDueDate,
      this.linkedLoanId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<int>(dayOfWeek);
    }
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['requires_verification'] = Variable<int>(requiresVerification);
    map['auto_apply'] = Variable<int>(autoApply);
    map['is_autopay'] = Variable<int>(isAutopay);
    map['is_active'] = Variable<int>(isActive);
    if (!nullToAbsent || lastAppliedDate != null) {
      map['last_applied_date'] = Variable<String>(lastAppliedDate);
    }
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<String>(nextDueDate);
    }
    if (!nullToAbsent || linkedLoanId != null) {
      map['linked_loan_id'] = Variable<String>(linkedLoanId);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      amount: Value(amount),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      frequency: Value(frequency),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      requiresVerification: Value(requiresVerification),
      autoApply: Value(autoApply),
      isAutopay: Value(isAutopay),
      isActive: Value(isActive),
      lastAppliedDate: lastAppliedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAppliedDate),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      linkedLoanId: linkedLoanId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedLoanId),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransaction(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      category: serializer.fromJson<String?>(json['category']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      dayOfWeek: serializer.fromJson<int?>(json['dayOfWeek']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      requiresVerification:
          serializer.fromJson<int>(json['requiresVerification']),
      autoApply: serializer.fromJson<int>(json['autoApply']),
      isAutopay: serializer.fromJson<int>(json['isAutopay']),
      isActive: serializer.fromJson<int>(json['isActive']),
      lastAppliedDate: serializer.fromJson<String?>(json['lastAppliedDate']),
      nextDueDate: serializer.fromJson<String?>(json['nextDueDate']),
      linkedLoanId: serializer.fromJson<String?>(json['linkedLoanId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'category': serializer.toJson<String?>(category),
      'accountId': serializer.toJson<String?>(accountId),
      'frequency': serializer.toJson<String>(frequency),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'dayOfWeek': serializer.toJson<int?>(dayOfWeek),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'requiresVerification': serializer.toJson<int>(requiresVerification),
      'autoApply': serializer.toJson<int>(autoApply),
      'isAutopay': serializer.toJson<int>(isAutopay),
      'isActive': serializer.toJson<int>(isActive),
      'lastAppliedDate': serializer.toJson<String?>(lastAppliedDate),
      'nextDueDate': serializer.toJson<String?>(nextDueDate),
      'linkedLoanId': serializer.toJson<String?>(linkedLoanId),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  RecurringTransaction copyWith(
          {String? id,
          String? name,
          String? type,
          int? amount,
          Value<String?> category = const Value.absent(),
          Value<String?> accountId = const Value.absent(),
          String? frequency,
          Value<int?> dayOfMonth = const Value.absent(),
          Value<int?> dayOfWeek = const Value.absent(),
          String? startDate,
          Value<String?> endDate = const Value.absent(),
          int? requiresVerification,
          int? autoApply,
          int? isAutopay,
          int? isActive,
          Value<String?> lastAppliedDate = const Value.absent(),
          Value<String?> nextDueDate = const Value.absent(),
          Value<String?> linkedLoanId = const Value.absent(),
          String? createdAt}) =>
      RecurringTransaction(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        category: category.present ? category.value : this.category,
        accountId: accountId.present ? accountId.value : this.accountId,
        frequency: frequency ?? this.frequency,
        dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
        dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        requiresVerification: requiresVerification ?? this.requiresVerification,
        autoApply: autoApply ?? this.autoApply,
        isAutopay: isAutopay ?? this.isAutopay,
        isActive: isActive ?? this.isActive,
        lastAppliedDate: lastAppliedDate.present
            ? lastAppliedDate.value
            : this.lastAppliedDate,
        nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
        linkedLoanId:
            linkedLoanId.present ? linkedLoanId.value : this.linkedLoanId,
        createdAt: createdAt ?? this.createdAt,
      );
  RecurringTransaction copyWithCompanion(RecurringTransactionsCompanion data) {
    return RecurringTransaction(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      dayOfMonth:
          data.dayOfMonth.present ? data.dayOfMonth.value : this.dayOfMonth,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      requiresVerification: data.requiresVerification.present
          ? data.requiresVerification.value
          : this.requiresVerification,
      autoApply: data.autoApply.present ? data.autoApply.value : this.autoApply,
      isAutopay: data.isAutopay.present ? data.isAutopay.value : this.isAutopay,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastAppliedDate: data.lastAppliedDate.present
          ? data.lastAppliedDate.value
          : this.lastAppliedDate,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      linkedLoanId: data.linkedLoanId.present
          ? data.linkedLoanId.value
          : this.linkedLoanId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransaction(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('accountId: $accountId, ')
          ..write('frequency: $frequency, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('requiresVerification: $requiresVerification, ')
          ..write('autoApply: $autoApply, ')
          ..write('isAutopay: $isAutopay, ')
          ..write('isActive: $isActive, ')
          ..write('lastAppliedDate: $lastAppliedDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('linkedLoanId: $linkedLoanId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      amount,
      category,
      accountId,
      frequency,
      dayOfMonth,
      dayOfWeek,
      startDate,
      endDate,
      requiresVerification,
      autoApply,
      isAutopay,
      isActive,
      lastAppliedDate,
      nextDueDate,
      linkedLoanId,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransaction &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.accountId == this.accountId &&
          other.frequency == this.frequency &&
          other.dayOfMonth == this.dayOfMonth &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.requiresVerification == this.requiresVerification &&
          other.autoApply == this.autoApply &&
          other.isAutopay == this.isAutopay &&
          other.isActive == this.isActive &&
          other.lastAppliedDate == this.lastAppliedDate &&
          other.nextDueDate == this.nextDueDate &&
          other.linkedLoanId == this.linkedLoanId &&
          other.createdAt == this.createdAt);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransaction> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> amount;
  final Value<String?> category;
  final Value<String?> accountId;
  final Value<String> frequency;
  final Value<int?> dayOfMonth;
  final Value<int?> dayOfWeek;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int> requiresVerification;
  final Value<int> autoApply;
  final Value<int> isAutopay;
  final Value<int> isActive;
  final Value<String?> lastAppliedDate;
  final Value<String?> nextDueDate;
  final Value<String?> linkedLoanId;
  final Value<String> createdAt;
  final Value<int> rowid;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.accountId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.requiresVerification = const Value.absent(),
    this.autoApply = const Value.absent(),
    this.isAutopay = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastAppliedDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.linkedLoanId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    required String id,
    required String name,
    required String type,
    required int amount,
    this.category = const Value.absent(),
    this.accountId = const Value.absent(),
    required String frequency,
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    this.requiresVerification = const Value.absent(),
    this.autoApply = const Value.absent(),
    this.isAutopay = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastAppliedDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.linkedLoanId = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        amount = Value(amount),
        frequency = Value(frequency),
        startDate = Value(startDate),
        createdAt = Value(createdAt);
  static Insertable<RecurringTransaction> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? category,
    Expression<String>? accountId,
    Expression<String>? frequency,
    Expression<int>? dayOfMonth,
    Expression<int>? dayOfWeek,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? requiresVerification,
    Expression<int>? autoApply,
    Expression<int>? isAutopay,
    Expression<int>? isActive,
    Expression<String>? lastAppliedDate,
    Expression<String>? nextDueDate,
    Expression<String>? linkedLoanId,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (accountId != null) 'account_id': accountId,
      if (frequency != null) 'frequency': frequency,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (requiresVerification != null)
        'requires_verification': requiresVerification,
      if (autoApply != null) 'auto_apply': autoApply,
      if (isAutopay != null) 'is_autopay': isAutopay,
      if (isActive != null) 'is_active': isActive,
      if (lastAppliedDate != null) 'last_applied_date': lastAppliedDate,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (linkedLoanId != null) 'linked_loan_id': linkedLoanId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<int>? amount,
      Value<String?>? category,
      Value<String?>? accountId,
      Value<String>? frequency,
      Value<int?>? dayOfMonth,
      Value<int?>? dayOfWeek,
      Value<String>? startDate,
      Value<String?>? endDate,
      Value<int>? requiresVerification,
      Value<int>? autoApply,
      Value<int>? isAutopay,
      Value<int>? isActive,
      Value<String?>? lastAppliedDate,
      Value<String?>? nextDueDate,
      Value<String?>? linkedLoanId,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      requiresVerification: requiresVerification ?? this.requiresVerification,
      autoApply: autoApply ?? this.autoApply,
      isAutopay: isAutopay ?? this.isAutopay,
      isActive: isActive ?? this.isActive,
      lastAppliedDate: lastAppliedDate ?? this.lastAppliedDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      linkedLoanId: linkedLoanId ?? this.linkedLoanId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (requiresVerification.present) {
      map['requires_verification'] = Variable<int>(requiresVerification.value);
    }
    if (autoApply.present) {
      map['auto_apply'] = Variable<int>(autoApply.value);
    }
    if (isAutopay.present) {
      map['is_autopay'] = Variable<int>(isAutopay.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (lastAppliedDate.present) {
      map['last_applied_date'] = Variable<String>(lastAppliedDate.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<String>(nextDueDate.value);
    }
    if (linkedLoanId.present) {
      map['linked_loan_id'] = Variable<String>(linkedLoanId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('accountId: $accountId, ')
          ..write('frequency: $frequency, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('requiresVerification: $requiresVerification, ')
          ..write('autoApply: $autoApply, ')
          ..write('isAutopay: $isAutopay, ')
          ..write('isActive: $isActive, ')
          ..write('lastAppliedDate: $lastAppliedDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('linkedLoanId: $linkedLoanId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingTransactionsTable extends PendingTransactions
    with TableInfo<$PendingTransactionsTable, PendingTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recurringIdMeta =
      const VerificationMeta('recurringId');
  @override
  late final GeneratedColumn<String> recurringId = GeneratedColumn<String>(
      'recurring_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _actionDateMeta =
      const VerificationMeta('actionDate');
  @override
  late final GeneratedColumn<String> actionDate = GeneratedColumn<String>(
      'action_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recurringId, dueDate, amount, status, actionDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<PendingTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recurring_id')) {
      context.handle(
          _recurringIdMeta,
          recurringId.isAcceptableOrUnknown(
              data['recurring_id']!, _recurringIdMeta));
    } else if (isInserting) {
      context.missing(_recurringIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('action_date')) {
      context.handle(
          _actionDateMeta,
          actionDate.isAcceptableOrUnknown(
              data['action_date']!, _actionDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recurringId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurring_id'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      actionDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingTransactionsTable createAlias(String alias) {
    return $PendingTransactionsTable(attachedDatabase, alias);
  }
}

class PendingTransaction extends DataClass
    implements Insertable<PendingTransaction> {
  final String id;
  final String recurringId;
  final String dueDate;
  final int amount;
  final String status;
  final String? actionDate;
  final String createdAt;
  const PendingTransaction(
      {required this.id,
      required this.recurringId,
      required this.dueDate,
      required this.amount,
      required this.status,
      this.actionDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recurring_id'] = Variable<String>(recurringId);
    map['due_date'] = Variable<String>(dueDate);
    map['amount'] = Variable<int>(amount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || actionDate != null) {
      map['action_date'] = Variable<String>(actionDate);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  PendingTransactionsCompanion toCompanion(bool nullToAbsent) {
    return PendingTransactionsCompanion(
      id: Value(id),
      recurringId: Value(recurringId),
      dueDate: Value(dueDate),
      amount: Value(amount),
      status: Value(status),
      actionDate: actionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(actionDate),
      createdAt: Value(createdAt),
    );
  }

  factory PendingTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingTransaction(
      id: serializer.fromJson<String>(json['id']),
      recurringId: serializer.fromJson<String>(json['recurringId']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      amount: serializer.fromJson<int>(json['amount']),
      status: serializer.fromJson<String>(json['status']),
      actionDate: serializer.fromJson<String?>(json['actionDate']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recurringId': serializer.toJson<String>(recurringId),
      'dueDate': serializer.toJson<String>(dueDate),
      'amount': serializer.toJson<int>(amount),
      'status': serializer.toJson<String>(status),
      'actionDate': serializer.toJson<String?>(actionDate),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  PendingTransaction copyWith(
          {String? id,
          String? recurringId,
          String? dueDate,
          int? amount,
          String? status,
          Value<String?> actionDate = const Value.absent(),
          String? createdAt}) =>
      PendingTransaction(
        id: id ?? this.id,
        recurringId: recurringId ?? this.recurringId,
        dueDate: dueDate ?? this.dueDate,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        actionDate: actionDate.present ? actionDate.value : this.actionDate,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingTransaction copyWithCompanion(PendingTransactionsCompanion data) {
    return PendingTransaction(
      id: data.id.present ? data.id.value : this.id,
      recurringId:
          data.recurringId.present ? data.recurringId.value : this.recurringId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      status: data.status.present ? data.status.value : this.status,
      actionDate:
          data.actionDate.present ? data.actionDate.value : this.actionDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransaction(')
          ..write('id: $id, ')
          ..write('recurringId: $recurringId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('actionDate: $actionDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, recurringId, dueDate, amount, status, actionDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingTransaction &&
          other.id == this.id &&
          other.recurringId == this.recurringId &&
          other.dueDate == this.dueDate &&
          other.amount == this.amount &&
          other.status == this.status &&
          other.actionDate == this.actionDate &&
          other.createdAt == this.createdAt);
}

class PendingTransactionsCompanion extends UpdateCompanion<PendingTransaction> {
  final Value<String> id;
  final Value<String> recurringId;
  final Value<String> dueDate;
  final Value<int> amount;
  final Value<String> status;
  final Value<String?> actionDate;
  final Value<String> createdAt;
  final Value<int> rowid;
  const PendingTransactionsCompanion({
    this.id = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.status = const Value.absent(),
    this.actionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingTransactionsCompanion.insert({
    required String id,
    required String recurringId,
    required String dueDate,
    required int amount,
    this.status = const Value.absent(),
    this.actionDate = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        recurringId = Value(recurringId),
        dueDate = Value(dueDate),
        amount = Value(amount),
        createdAt = Value(createdAt);
  static Insertable<PendingTransaction> custom({
    Expression<String>? id,
    Expression<String>? recurringId,
    Expression<String>? dueDate,
    Expression<int>? amount,
    Expression<String>? status,
    Expression<String>? actionDate,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recurringId != null) 'recurring_id': recurringId,
      if (dueDate != null) 'due_date': dueDate,
      if (amount != null) 'amount': amount,
      if (status != null) 'status': status,
      if (actionDate != null) 'action_date': actionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? recurringId,
      Value<String>? dueDate,
      Value<int>? amount,
      Value<String>? status,
      Value<String?>? actionDate,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return PendingTransactionsCompanion(
      id: id ?? this.id,
      recurringId: recurringId ?? this.recurringId,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      actionDate: actionDate ?? this.actionDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recurringId.present) {
      map['recurring_id'] = Variable<String>(recurringId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (actionDate.present) {
      map['action_date'] = Variable<String>(actionDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('recurringId: $recurringId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('actionDate: $actionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _principalMeta =
      const VerificationMeta('principal');
  @override
  late final GeneratedColumn<int> principal = GeneratedColumn<int>(
      'principal', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _interestRateMeta =
      const VerificationMeta('interestRate');
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
      'interest_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tenureMonthsMeta =
      const VerificationMeta('tenureMonths');
  @override
  late final GeneratedColumn<int> tenureMonths = GeneratedColumn<int>(
      'tenure_months', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _emiAmountMeta =
      const VerificationMeta('emiAmount');
  @override
  late final GeneratedColumn<int> emiAmount = GeneratedColumn<int>(
      'emi_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emiDayMeta = const VerificationMeta('emiDay');
  @override
  late final GeneratedColumn<int> emiDay = GeneratedColumn<int>(
      'emi_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paymentsMadeMeta =
      const VerificationMeta('paymentsMade');
  @override
  late final GeneratedColumn<int> paymentsMade = GeneratedColumn<int>(
      'payments_made', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paymentAccountIdMeta =
      const VerificationMeta('paymentAccountId');
  @override
  late final GeneratedColumn<String> paymentAccountId = GeneratedColumn<String>(
      'payment_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentTypeMeta =
      const VerificationMeta('paymentType');
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
      'payment_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _creditCardIdMeta =
      const VerificationMeta('creditCardId');
  @override
  late final GeneratedColumn<String> creditCardId = GeneratedColumn<String>(
      'credit_card_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lenderMeta = const VerificationMeta('lender');
  @override
  late final GeneratedColumn<String> lender = GeneratedColumn<String>(
      'lender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
      'is_active', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _foreclosureAmountMeta =
      const VerificationMeta('foreclosureAmount');
  @override
  late final GeneratedColumn<int> foreclosureAmount = GeneratedColumn<int>(
      'foreclosure_amount', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        principal,
        interestRate,
        tenureMonths,
        emiAmount,
        startDate,
        emiDay,
        paymentsMade,
        paymentAccountId,
        paymentType,
        creditCardId,
        lender,
        purpose,
        isActive,
        foreclosureAmount,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(Insertable<Loan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('principal')) {
      context.handle(_principalMeta,
          principal.isAcceptableOrUnknown(data['principal']!, _principalMeta));
    } else if (isInserting) {
      context.missing(_principalMeta);
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
          _interestRateMeta,
          interestRate.isAcceptableOrUnknown(
              data['interest_rate']!, _interestRateMeta));
    } else if (isInserting) {
      context.missing(_interestRateMeta);
    }
    if (data.containsKey('tenure_months')) {
      context.handle(
          _tenureMonthsMeta,
          tenureMonths.isAcceptableOrUnknown(
              data['tenure_months']!, _tenureMonthsMeta));
    } else if (isInserting) {
      context.missing(_tenureMonthsMeta);
    }
    if (data.containsKey('emi_amount')) {
      context.handle(_emiAmountMeta,
          emiAmount.isAcceptableOrUnknown(data['emi_amount']!, _emiAmountMeta));
    } else if (isInserting) {
      context.missing(_emiAmountMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('emi_day')) {
      context.handle(_emiDayMeta,
          emiDay.isAcceptableOrUnknown(data['emi_day']!, _emiDayMeta));
    } else if (isInserting) {
      context.missing(_emiDayMeta);
    }
    if (data.containsKey('payments_made')) {
      context.handle(
          _paymentsMadeMeta,
          paymentsMade.isAcceptableOrUnknown(
              data['payments_made']!, _paymentsMadeMeta));
    }
    if (data.containsKey('payment_account_id')) {
      context.handle(
          _paymentAccountIdMeta,
          paymentAccountId.isAcceptableOrUnknown(
              data['payment_account_id']!, _paymentAccountIdMeta));
    }
    if (data.containsKey('payment_type')) {
      context.handle(
          _paymentTypeMeta,
          paymentType.isAcceptableOrUnknown(
              data['payment_type']!, _paymentTypeMeta));
    }
    if (data.containsKey('credit_card_id')) {
      context.handle(
          _creditCardIdMeta,
          creditCardId.isAcceptableOrUnknown(
              data['credit_card_id']!, _creditCardIdMeta));
    }
    if (data.containsKey('lender')) {
      context.handle(_lenderMeta,
          lender.isAcceptableOrUnknown(data['lender']!, _lenderMeta));
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('foreclosure_amount')) {
      context.handle(
          _foreclosureAmountMeta,
          foreclosureAmount.isAcceptableOrUnknown(
              data['foreclosure_amount']!, _foreclosureAmountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      principal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}principal'])!,
      interestRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}interest_rate'])!,
      tenureMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tenure_months'])!,
      emiAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}emi_amount'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      emiDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}emi_day'])!,
      paymentsMade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payments_made'])!,
      paymentAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payment_account_id']),
      paymentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_type'])!,
      creditCardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}credit_card_id']),
      lender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lender']),
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_active'])!,
      foreclosureAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}foreclosure_amount']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final String id;
  final String name;
  final String type;
  final int principal;
  final double interestRate;
  final int tenureMonths;
  final int emiAmount;
  final String startDate;
  final int emiDay;
  final int paymentsMade;
  final String? paymentAccountId;
  final String paymentType;
  final String? creditCardId;
  final String? lender;
  final String? purpose;
  final int isActive;
  final int? foreclosureAmount;
  final String createdAt;
  const Loan(
      {required this.id,
      required this.name,
      required this.type,
      required this.principal,
      required this.interestRate,
      required this.tenureMonths,
      required this.emiAmount,
      required this.startDate,
      required this.emiDay,
      required this.paymentsMade,
      this.paymentAccountId,
      required this.paymentType,
      this.creditCardId,
      this.lender,
      this.purpose,
      required this.isActive,
      this.foreclosureAmount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['principal'] = Variable<int>(principal);
    map['interest_rate'] = Variable<double>(interestRate);
    map['tenure_months'] = Variable<int>(tenureMonths);
    map['emi_amount'] = Variable<int>(emiAmount);
    map['start_date'] = Variable<String>(startDate);
    map['emi_day'] = Variable<int>(emiDay);
    map['payments_made'] = Variable<int>(paymentsMade);
    if (!nullToAbsent || paymentAccountId != null) {
      map['payment_account_id'] = Variable<String>(paymentAccountId);
    }
    map['payment_type'] = Variable<String>(paymentType);
    if (!nullToAbsent || creditCardId != null) {
      map['credit_card_id'] = Variable<String>(creditCardId);
    }
    if (!nullToAbsent || lender != null) {
      map['lender'] = Variable<String>(lender);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['is_active'] = Variable<int>(isActive);
    if (!nullToAbsent || foreclosureAmount != null) {
      map['foreclosure_amount'] = Variable<int>(foreclosureAmount);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      principal: Value(principal),
      interestRate: Value(interestRate),
      tenureMonths: Value(tenureMonths),
      emiAmount: Value(emiAmount),
      startDate: Value(startDate),
      emiDay: Value(emiDay),
      paymentsMade: Value(paymentsMade),
      paymentAccountId: paymentAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentAccountId),
      paymentType: Value(paymentType),
      creditCardId: creditCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(creditCardId),
      lender:
          lender == null && nullToAbsent ? const Value.absent() : Value(lender),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      isActive: Value(isActive),
      foreclosureAmount: foreclosureAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(foreclosureAmount),
      createdAt: Value(createdAt),
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      principal: serializer.fromJson<int>(json['principal']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      tenureMonths: serializer.fromJson<int>(json['tenureMonths']),
      emiAmount: serializer.fromJson<int>(json['emiAmount']),
      startDate: serializer.fromJson<String>(json['startDate']),
      emiDay: serializer.fromJson<int>(json['emiDay']),
      paymentsMade: serializer.fromJson<int>(json['paymentsMade']),
      paymentAccountId: serializer.fromJson<String?>(json['paymentAccountId']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      creditCardId: serializer.fromJson<String?>(json['creditCardId']),
      lender: serializer.fromJson<String?>(json['lender']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      isActive: serializer.fromJson<int>(json['isActive']),
      foreclosureAmount: serializer.fromJson<int?>(json['foreclosureAmount']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'principal': serializer.toJson<int>(principal),
      'interestRate': serializer.toJson<double>(interestRate),
      'tenureMonths': serializer.toJson<int>(tenureMonths),
      'emiAmount': serializer.toJson<int>(emiAmount),
      'startDate': serializer.toJson<String>(startDate),
      'emiDay': serializer.toJson<int>(emiDay),
      'paymentsMade': serializer.toJson<int>(paymentsMade),
      'paymentAccountId': serializer.toJson<String?>(paymentAccountId),
      'paymentType': serializer.toJson<String>(paymentType),
      'creditCardId': serializer.toJson<String?>(creditCardId),
      'lender': serializer.toJson<String?>(lender),
      'purpose': serializer.toJson<String?>(purpose),
      'isActive': serializer.toJson<int>(isActive),
      'foreclosureAmount': serializer.toJson<int?>(foreclosureAmount),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Loan copyWith(
          {String? id,
          String? name,
          String? type,
          int? principal,
          double? interestRate,
          int? tenureMonths,
          int? emiAmount,
          String? startDate,
          int? emiDay,
          int? paymentsMade,
          Value<String?> paymentAccountId = const Value.absent(),
          String? paymentType,
          Value<String?> creditCardId = const Value.absent(),
          Value<String?> lender = const Value.absent(),
          Value<String?> purpose = const Value.absent(),
          int? isActive,
          Value<int?> foreclosureAmount = const Value.absent(),
          String? createdAt}) =>
      Loan(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        principal: principal ?? this.principal,
        interestRate: interestRate ?? this.interestRate,
        tenureMonths: tenureMonths ?? this.tenureMonths,
        emiAmount: emiAmount ?? this.emiAmount,
        startDate: startDate ?? this.startDate,
        emiDay: emiDay ?? this.emiDay,
        paymentsMade: paymentsMade ?? this.paymentsMade,
        paymentAccountId: paymentAccountId.present
            ? paymentAccountId.value
            : this.paymentAccountId,
        paymentType: paymentType ?? this.paymentType,
        creditCardId:
            creditCardId.present ? creditCardId.value : this.creditCardId,
        lender: lender.present ? lender.value : this.lender,
        purpose: purpose.present ? purpose.value : this.purpose,
        isActive: isActive ?? this.isActive,
        foreclosureAmount: foreclosureAmount.present
            ? foreclosureAmount.value
            : this.foreclosureAmount,
        createdAt: createdAt ?? this.createdAt,
      );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      principal: data.principal.present ? data.principal.value : this.principal,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      tenureMonths: data.tenureMonths.present
          ? data.tenureMonths.value
          : this.tenureMonths,
      emiAmount: data.emiAmount.present ? data.emiAmount.value : this.emiAmount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      emiDay: data.emiDay.present ? data.emiDay.value : this.emiDay,
      paymentsMade: data.paymentsMade.present
          ? data.paymentsMade.value
          : this.paymentsMade,
      paymentAccountId: data.paymentAccountId.present
          ? data.paymentAccountId.value
          : this.paymentAccountId,
      paymentType:
          data.paymentType.present ? data.paymentType.value : this.paymentType,
      creditCardId: data.creditCardId.present
          ? data.creditCardId.value
          : this.creditCardId,
      lender: data.lender.present ? data.lender.value : this.lender,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      foreclosureAmount: data.foreclosureAmount.present
          ? data.foreclosureAmount.value
          : this.foreclosureAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('principal: $principal, ')
          ..write('interestRate: $interestRate, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('startDate: $startDate, ')
          ..write('emiDay: $emiDay, ')
          ..write('paymentsMade: $paymentsMade, ')
          ..write('paymentAccountId: $paymentAccountId, ')
          ..write('paymentType: $paymentType, ')
          ..write('creditCardId: $creditCardId, ')
          ..write('lender: $lender, ')
          ..write('purpose: $purpose, ')
          ..write('isActive: $isActive, ')
          ..write('foreclosureAmount: $foreclosureAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      principal,
      interestRate,
      tenureMonths,
      emiAmount,
      startDate,
      emiDay,
      paymentsMade,
      paymentAccountId,
      paymentType,
      creditCardId,
      lender,
      purpose,
      isActive,
      foreclosureAmount,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.principal == this.principal &&
          other.interestRate == this.interestRate &&
          other.tenureMonths == this.tenureMonths &&
          other.emiAmount == this.emiAmount &&
          other.startDate == this.startDate &&
          other.emiDay == this.emiDay &&
          other.paymentsMade == this.paymentsMade &&
          other.paymentAccountId == this.paymentAccountId &&
          other.paymentType == this.paymentType &&
          other.creditCardId == this.creditCardId &&
          other.lender == this.lender &&
          other.purpose == this.purpose &&
          other.isActive == this.isActive &&
          other.foreclosureAmount == this.foreclosureAmount &&
          other.createdAt == this.createdAt);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> principal;
  final Value<double> interestRate;
  final Value<int> tenureMonths;
  final Value<int> emiAmount;
  final Value<String> startDate;
  final Value<int> emiDay;
  final Value<int> paymentsMade;
  final Value<String?> paymentAccountId;
  final Value<String> paymentType;
  final Value<String?> creditCardId;
  final Value<String?> lender;
  final Value<String?> purpose;
  final Value<int> isActive;
  final Value<int?> foreclosureAmount;
  final Value<String> createdAt;
  final Value<int> rowid;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.principal = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.tenureMonths = const Value.absent(),
    this.emiAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.emiDay = const Value.absent(),
    this.paymentsMade = const Value.absent(),
    this.paymentAccountId = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.creditCardId = const Value.absent(),
    this.lender = const Value.absent(),
    this.purpose = const Value.absent(),
    this.isActive = const Value.absent(),
    this.foreclosureAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCompanion.insert({
    required String id,
    required String name,
    required String type,
    required int principal,
    required double interestRate,
    required int tenureMonths,
    required int emiAmount,
    required String startDate,
    required int emiDay,
    this.paymentsMade = const Value.absent(),
    this.paymentAccountId = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.creditCardId = const Value.absent(),
    this.lender = const Value.absent(),
    this.purpose = const Value.absent(),
    this.isActive = const Value.absent(),
    this.foreclosureAmount = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        principal = Value(principal),
        interestRate = Value(interestRate),
        tenureMonths = Value(tenureMonths),
        emiAmount = Value(emiAmount),
        startDate = Value(startDate),
        emiDay = Value(emiDay),
        createdAt = Value(createdAt);
  static Insertable<Loan> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? principal,
    Expression<double>? interestRate,
    Expression<int>? tenureMonths,
    Expression<int>? emiAmount,
    Expression<String>? startDate,
    Expression<int>? emiDay,
    Expression<int>? paymentsMade,
    Expression<String>? paymentAccountId,
    Expression<String>? paymentType,
    Expression<String>? creditCardId,
    Expression<String>? lender,
    Expression<String>? purpose,
    Expression<int>? isActive,
    Expression<int>? foreclosureAmount,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (principal != null) 'principal': principal,
      if (interestRate != null) 'interest_rate': interestRate,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (emiAmount != null) 'emi_amount': emiAmount,
      if (startDate != null) 'start_date': startDate,
      if (emiDay != null) 'emi_day': emiDay,
      if (paymentsMade != null) 'payments_made': paymentsMade,
      if (paymentAccountId != null) 'payment_account_id': paymentAccountId,
      if (paymentType != null) 'payment_type': paymentType,
      if (creditCardId != null) 'credit_card_id': creditCardId,
      if (lender != null) 'lender': lender,
      if (purpose != null) 'purpose': purpose,
      if (isActive != null) 'is_active': isActive,
      if (foreclosureAmount != null) 'foreclosure_amount': foreclosureAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<int>? principal,
      Value<double>? interestRate,
      Value<int>? tenureMonths,
      Value<int>? emiAmount,
      Value<String>? startDate,
      Value<int>? emiDay,
      Value<int>? paymentsMade,
      Value<String?>? paymentAccountId,
      Value<String>? paymentType,
      Value<String?>? creditCardId,
      Value<String?>? lender,
      Value<String?>? purpose,
      Value<int>? isActive,
      Value<int?>? foreclosureAmount,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return LoansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      principal: principal ?? this.principal,
      interestRate: interestRate ?? this.interestRate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      emiAmount: emiAmount ?? this.emiAmount,
      startDate: startDate ?? this.startDate,
      emiDay: emiDay ?? this.emiDay,
      paymentsMade: paymentsMade ?? this.paymentsMade,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
      paymentType: paymentType ?? this.paymentType,
      creditCardId: creditCardId ?? this.creditCardId,
      lender: lender ?? this.lender,
      purpose: purpose ?? this.purpose,
      isActive: isActive ?? this.isActive,
      foreclosureAmount: foreclosureAmount ?? this.foreclosureAmount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (principal.present) {
      map['principal'] = Variable<int>(principal.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (tenureMonths.present) {
      map['tenure_months'] = Variable<int>(tenureMonths.value);
    }
    if (emiAmount.present) {
      map['emi_amount'] = Variable<int>(emiAmount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (emiDay.present) {
      map['emi_day'] = Variable<int>(emiDay.value);
    }
    if (paymentsMade.present) {
      map['payments_made'] = Variable<int>(paymentsMade.value);
    }
    if (paymentAccountId.present) {
      map['payment_account_id'] = Variable<String>(paymentAccountId.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (creditCardId.present) {
      map['credit_card_id'] = Variable<String>(creditCardId.value);
    }
    if (lender.present) {
      map['lender'] = Variable<String>(lender.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (foreclosureAmount.present) {
      map['foreclosure_amount'] = Variable<int>(foreclosureAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('principal: $principal, ')
          ..write('interestRate: $interestRate, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('startDate: $startDate, ')
          ..write('emiDay: $emiDay, ')
          ..write('paymentsMade: $paymentsMade, ')
          ..write('paymentAccountId: $paymentAccountId, ')
          ..write('paymentType: $paymentType, ')
          ..write('creditCardId: $creditCardId, ')
          ..write('lender: $lender, ')
          ..write('purpose: $purpose, ')
          ..write('isActive: $isActive, ')
          ..write('foreclosureAmount: $foreclosureAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoanEmiScheduleTable extends LoanEmiSchedule
    with TableInfo<$LoanEmiScheduleTable, LoanEmiScheduleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoanEmiScheduleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
      'loan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monthNumberMeta =
      const VerificationMeta('monthNumber');
  @override
  late final GeneratedColumn<int> monthNumber = GeneratedColumn<int>(
      'month_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _emiAmountMeta =
      const VerificationMeta('emiAmount');
  @override
  late final GeneratedColumn<int> emiAmount = GeneratedColumn<int>(
      'emi_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, loanId, monthNumber, emiAmount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loan_emi_schedule';
  @override
  VerificationContext validateIntegrity(
      Insertable<LoanEmiScheduleData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('loan_id')) {
      context.handle(_loanIdMeta,
          loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta));
    } else if (isInserting) {
      context.missing(_loanIdMeta);
    }
    if (data.containsKey('month_number')) {
      context.handle(
          _monthNumberMeta,
          monthNumber.isAcceptableOrUnknown(
              data['month_number']!, _monthNumberMeta));
    } else if (isInserting) {
      context.missing(_monthNumberMeta);
    }
    if (data.containsKey('emi_amount')) {
      context.handle(_emiAmountMeta,
          emiAmount.isAcceptableOrUnknown(data['emi_amount']!, _emiAmountMeta));
    } else if (isInserting) {
      context.missing(_emiAmountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {loanId, monthNumber},
      ];
  @override
  LoanEmiScheduleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanEmiScheduleData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      loanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loan_id'])!,
      monthNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month_number'])!,
      emiAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}emi_amount'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LoanEmiScheduleTable createAlias(String alias) {
    return $LoanEmiScheduleTable(attachedDatabase, alias);
  }
}

class LoanEmiScheduleData extends DataClass
    implements Insertable<LoanEmiScheduleData> {
  final String id;
  final String loanId;
  final int monthNumber;
  final int emiAmount;
  final String createdAt;
  const LoanEmiScheduleData(
      {required this.id,
      required this.loanId,
      required this.monthNumber,
      required this.emiAmount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['loan_id'] = Variable<String>(loanId);
    map['month_number'] = Variable<int>(monthNumber);
    map['emi_amount'] = Variable<int>(emiAmount);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  LoanEmiScheduleCompanion toCompanion(bool nullToAbsent) {
    return LoanEmiScheduleCompanion(
      id: Value(id),
      loanId: Value(loanId),
      monthNumber: Value(monthNumber),
      emiAmount: Value(emiAmount),
      createdAt: Value(createdAt),
    );
  }

  factory LoanEmiScheduleData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanEmiScheduleData(
      id: serializer.fromJson<String>(json['id']),
      loanId: serializer.fromJson<String>(json['loanId']),
      monthNumber: serializer.fromJson<int>(json['monthNumber']),
      emiAmount: serializer.fromJson<int>(json['emiAmount']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'loanId': serializer.toJson<String>(loanId),
      'monthNumber': serializer.toJson<int>(monthNumber),
      'emiAmount': serializer.toJson<int>(emiAmount),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  LoanEmiScheduleData copyWith(
          {String? id,
          String? loanId,
          int? monthNumber,
          int? emiAmount,
          String? createdAt}) =>
      LoanEmiScheduleData(
        id: id ?? this.id,
        loanId: loanId ?? this.loanId,
        monthNumber: monthNumber ?? this.monthNumber,
        emiAmount: emiAmount ?? this.emiAmount,
        createdAt: createdAt ?? this.createdAt,
      );
  LoanEmiScheduleData copyWithCompanion(LoanEmiScheduleCompanion data) {
    return LoanEmiScheduleData(
      id: data.id.present ? data.id.value : this.id,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      monthNumber:
          data.monthNumber.present ? data.monthNumber.value : this.monthNumber,
      emiAmount: data.emiAmount.present ? data.emiAmount.value : this.emiAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanEmiScheduleData(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('monthNumber: $monthNumber, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, loanId, monthNumber, emiAmount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanEmiScheduleData &&
          other.id == this.id &&
          other.loanId == this.loanId &&
          other.monthNumber == this.monthNumber &&
          other.emiAmount == this.emiAmount &&
          other.createdAt == this.createdAt);
}

class LoanEmiScheduleCompanion extends UpdateCompanion<LoanEmiScheduleData> {
  final Value<String> id;
  final Value<String> loanId;
  final Value<int> monthNumber;
  final Value<int> emiAmount;
  final Value<String> createdAt;
  final Value<int> rowid;
  const LoanEmiScheduleCompanion({
    this.id = const Value.absent(),
    this.loanId = const Value.absent(),
    this.monthNumber = const Value.absent(),
    this.emiAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoanEmiScheduleCompanion.insert({
    required String id,
    required String loanId,
    required int monthNumber,
    required int emiAmount,
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        loanId = Value(loanId),
        monthNumber = Value(monthNumber),
        emiAmount = Value(emiAmount),
        createdAt = Value(createdAt);
  static Insertable<LoanEmiScheduleData> custom({
    Expression<String>? id,
    Expression<String>? loanId,
    Expression<int>? monthNumber,
    Expression<int>? emiAmount,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loanId != null) 'loan_id': loanId,
      if (monthNumber != null) 'month_number': monthNumber,
      if (emiAmount != null) 'emi_amount': emiAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoanEmiScheduleCompanion copyWith(
      {Value<String>? id,
      Value<String>? loanId,
      Value<int>? monthNumber,
      Value<int>? emiAmount,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return LoanEmiScheduleCompanion(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      monthNumber: monthNumber ?? this.monthNumber,
      emiAmount: emiAmount ?? this.emiAmount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (monthNumber.present) {
      map['month_number'] = Variable<int>(monthNumber.value);
    }
    if (emiAmount.present) {
      map['emi_amount'] = Variable<int>(emiAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoanEmiScheduleCompanion(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('monthNumber: $monthNumber, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditCardStatementsTable extends CreditCardStatements
    with TableInfo<$CreditCardStatementsTable, CreditCardStatement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardStatementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardAccountIdMeta =
      const VerificationMeta('cardAccountId');
  @override
  late final GeneratedColumn<String> cardAccountId = GeneratedColumn<String>(
      'card_account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statementDateMeta =
      const VerificationMeta('statementDate');
  @override
  late final GeneratedColumn<String> statementDate = GeneratedColumn<String>(
      'statement_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statementAmountMeta =
      const VerificationMeta('statementAmount');
  @override
  late final GeneratedColumn<int> statementAmount = GeneratedColumn<int>(
      'statement_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _minimumDueMeta =
      const VerificationMeta('minimumDue');
  @override
  late final GeneratedColumn<int> minimumDue = GeneratedColumn<int>(
      'minimum_due', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<int> paidAmount = GeneratedColumn<int>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidDateMeta =
      const VerificationMeta('paidDate');
  @override
  late final GeneratedColumn<String> paidDate = GeneratedColumn<String>(
      'paid_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFullyPaidMeta =
      const VerificationMeta('isFullyPaid');
  @override
  late final GeneratedColumn<int> isFullyPaid = GeneratedColumn<int>(
      'is_fully_paid', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardAccountId,
        statementDate,
        dueDate,
        statementAmount,
        minimumDue,
        paidAmount,
        paidDate,
        isFullyPaid,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_card_statements';
  @override
  VerificationContext validateIntegrity(
      Insertable<CreditCardStatement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_account_id')) {
      context.handle(
          _cardAccountIdMeta,
          cardAccountId.isAcceptableOrUnknown(
              data['card_account_id']!, _cardAccountIdMeta));
    } else if (isInserting) {
      context.missing(_cardAccountIdMeta);
    }
    if (data.containsKey('statement_date')) {
      context.handle(
          _statementDateMeta,
          statementDate.isAcceptableOrUnknown(
              data['statement_date']!, _statementDateMeta));
    } else if (isInserting) {
      context.missing(_statementDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('statement_amount')) {
      context.handle(
          _statementAmountMeta,
          statementAmount.isAcceptableOrUnknown(
              data['statement_amount']!, _statementAmountMeta));
    } else if (isInserting) {
      context.missing(_statementAmountMeta);
    }
    if (data.containsKey('minimum_due')) {
      context.handle(
          _minimumDueMeta,
          minimumDue.isAcceptableOrUnknown(
              data['minimum_due']!, _minimumDueMeta));
    } else if (isInserting) {
      context.missing(_minimumDueMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('paid_date')) {
      context.handle(_paidDateMeta,
          paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta));
    }
    if (data.containsKey('is_fully_paid')) {
      context.handle(
          _isFullyPaidMeta,
          isFullyPaid.isAcceptableOrUnknown(
              data['is_fully_paid']!, _isFullyPaidMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditCardStatement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditCardStatement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cardAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}card_account_id'])!,
      statementDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statement_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date'])!,
      statementAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}statement_amount'])!,
      minimumDue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minimum_due'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_amount'])!,
      paidDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}paid_date']),
      isFullyPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_fully_paid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CreditCardStatementsTable createAlias(String alias) {
    return $CreditCardStatementsTable(attachedDatabase, alias);
  }
}

class CreditCardStatement extends DataClass
    implements Insertable<CreditCardStatement> {
  final String id;
  final String cardAccountId;
  final String statementDate;
  final String dueDate;
  final int statementAmount;
  final int minimumDue;
  final int paidAmount;
  final String? paidDate;
  final int isFullyPaid;
  final String createdAt;
  const CreditCardStatement(
      {required this.id,
      required this.cardAccountId,
      required this.statementDate,
      required this.dueDate,
      required this.statementAmount,
      required this.minimumDue,
      required this.paidAmount,
      this.paidDate,
      required this.isFullyPaid,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_account_id'] = Variable<String>(cardAccountId);
    map['statement_date'] = Variable<String>(statementDate);
    map['due_date'] = Variable<String>(dueDate);
    map['statement_amount'] = Variable<int>(statementAmount);
    map['minimum_due'] = Variable<int>(minimumDue);
    map['paid_amount'] = Variable<int>(paidAmount);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<String>(paidDate);
    }
    map['is_fully_paid'] = Variable<int>(isFullyPaid);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  CreditCardStatementsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardStatementsCompanion(
      id: Value(id),
      cardAccountId: Value(cardAccountId),
      statementDate: Value(statementDate),
      dueDate: Value(dueDate),
      statementAmount: Value(statementAmount),
      minimumDue: Value(minimumDue),
      paidAmount: Value(paidAmount),
      paidDate: paidDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paidDate),
      isFullyPaid: Value(isFullyPaid),
      createdAt: Value(createdAt),
    );
  }

  factory CreditCardStatement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditCardStatement(
      id: serializer.fromJson<String>(json['id']),
      cardAccountId: serializer.fromJson<String>(json['cardAccountId']),
      statementDate: serializer.fromJson<String>(json['statementDate']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      statementAmount: serializer.fromJson<int>(json['statementAmount']),
      minimumDue: serializer.fromJson<int>(json['minimumDue']),
      paidAmount: serializer.fromJson<int>(json['paidAmount']),
      paidDate: serializer.fromJson<String?>(json['paidDate']),
      isFullyPaid: serializer.fromJson<int>(json['isFullyPaid']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardAccountId': serializer.toJson<String>(cardAccountId),
      'statementDate': serializer.toJson<String>(statementDate),
      'dueDate': serializer.toJson<String>(dueDate),
      'statementAmount': serializer.toJson<int>(statementAmount),
      'minimumDue': serializer.toJson<int>(minimumDue),
      'paidAmount': serializer.toJson<int>(paidAmount),
      'paidDate': serializer.toJson<String?>(paidDate),
      'isFullyPaid': serializer.toJson<int>(isFullyPaid),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  CreditCardStatement copyWith(
          {String? id,
          String? cardAccountId,
          String? statementDate,
          String? dueDate,
          int? statementAmount,
          int? minimumDue,
          int? paidAmount,
          Value<String?> paidDate = const Value.absent(),
          int? isFullyPaid,
          String? createdAt}) =>
      CreditCardStatement(
        id: id ?? this.id,
        cardAccountId: cardAccountId ?? this.cardAccountId,
        statementDate: statementDate ?? this.statementDate,
        dueDate: dueDate ?? this.dueDate,
        statementAmount: statementAmount ?? this.statementAmount,
        minimumDue: minimumDue ?? this.minimumDue,
        paidAmount: paidAmount ?? this.paidAmount,
        paidDate: paidDate.present ? paidDate.value : this.paidDate,
        isFullyPaid: isFullyPaid ?? this.isFullyPaid,
        createdAt: createdAt ?? this.createdAt,
      );
  CreditCardStatement copyWithCompanion(CreditCardStatementsCompanion data) {
    return CreditCardStatement(
      id: data.id.present ? data.id.value : this.id,
      cardAccountId: data.cardAccountId.present
          ? data.cardAccountId.value
          : this.cardAccountId,
      statementDate: data.statementDate.present
          ? data.statementDate.value
          : this.statementDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      statementAmount: data.statementAmount.present
          ? data.statementAmount.value
          : this.statementAmount,
      minimumDue:
          data.minimumDue.present ? data.minimumDue.value : this.minimumDue,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      isFullyPaid:
          data.isFullyPaid.present ? data.isFullyPaid.value : this.isFullyPaid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardStatement(')
          ..write('id: $id, ')
          ..write('cardAccountId: $cardAccountId, ')
          ..write('statementDate: $statementDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('statementAmount: $statementAmount, ')
          ..write('minimumDue: $minimumDue, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paidDate: $paidDate, ')
          ..write('isFullyPaid: $isFullyPaid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cardAccountId,
      statementDate,
      dueDate,
      statementAmount,
      minimumDue,
      paidAmount,
      paidDate,
      isFullyPaid,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditCardStatement &&
          other.id == this.id &&
          other.cardAccountId == this.cardAccountId &&
          other.statementDate == this.statementDate &&
          other.dueDate == this.dueDate &&
          other.statementAmount == this.statementAmount &&
          other.minimumDue == this.minimumDue &&
          other.paidAmount == this.paidAmount &&
          other.paidDate == this.paidDate &&
          other.isFullyPaid == this.isFullyPaid &&
          other.createdAt == this.createdAt);
}

class CreditCardStatementsCompanion
    extends UpdateCompanion<CreditCardStatement> {
  final Value<String> id;
  final Value<String> cardAccountId;
  final Value<String> statementDate;
  final Value<String> dueDate;
  final Value<int> statementAmount;
  final Value<int> minimumDue;
  final Value<int> paidAmount;
  final Value<String?> paidDate;
  final Value<int> isFullyPaid;
  final Value<String> createdAt;
  final Value<int> rowid;
  const CreditCardStatementsCompanion({
    this.id = const Value.absent(),
    this.cardAccountId = const Value.absent(),
    this.statementDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.statementAmount = const Value.absent(),
    this.minimumDue = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.isFullyPaid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditCardStatementsCompanion.insert({
    required String id,
    required String cardAccountId,
    required String statementDate,
    required String dueDate,
    required int statementAmount,
    required int minimumDue,
    this.paidAmount = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.isFullyPaid = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cardAccountId = Value(cardAccountId),
        statementDate = Value(statementDate),
        dueDate = Value(dueDate),
        statementAmount = Value(statementAmount),
        minimumDue = Value(minimumDue),
        createdAt = Value(createdAt);
  static Insertable<CreditCardStatement> custom({
    Expression<String>? id,
    Expression<String>? cardAccountId,
    Expression<String>? statementDate,
    Expression<String>? dueDate,
    Expression<int>? statementAmount,
    Expression<int>? minimumDue,
    Expression<int>? paidAmount,
    Expression<String>? paidDate,
    Expression<int>? isFullyPaid,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardAccountId != null) 'card_account_id': cardAccountId,
      if (statementDate != null) 'statement_date': statementDate,
      if (dueDate != null) 'due_date': dueDate,
      if (statementAmount != null) 'statement_amount': statementAmount,
      if (minimumDue != null) 'minimum_due': minimumDue,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (paidDate != null) 'paid_date': paidDate,
      if (isFullyPaid != null) 'is_fully_paid': isFullyPaid,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditCardStatementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? cardAccountId,
      Value<String>? statementDate,
      Value<String>? dueDate,
      Value<int>? statementAmount,
      Value<int>? minimumDue,
      Value<int>? paidAmount,
      Value<String?>? paidDate,
      Value<int>? isFullyPaid,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return CreditCardStatementsCompanion(
      id: id ?? this.id,
      cardAccountId: cardAccountId ?? this.cardAccountId,
      statementDate: statementDate ?? this.statementDate,
      dueDate: dueDate ?? this.dueDate,
      statementAmount: statementAmount ?? this.statementAmount,
      minimumDue: minimumDue ?? this.minimumDue,
      paidAmount: paidAmount ?? this.paidAmount,
      paidDate: paidDate ?? this.paidDate,
      isFullyPaid: isFullyPaid ?? this.isFullyPaid,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardAccountId.present) {
      map['card_account_id'] = Variable<String>(cardAccountId.value);
    }
    if (statementDate.present) {
      map['statement_date'] = Variable<String>(statementDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (statementAmount.present) {
      map['statement_amount'] = Variable<int>(statementAmount.value);
    }
    if (minimumDue.present) {
      map['minimum_due'] = Variable<int>(minimumDue.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<int>(paidAmount.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<String>(paidDate.value);
    }
    if (isFullyPaid.present) {
      map['is_fully_paid'] = Variable<int>(isFullyPaid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardStatementsCompanion(')
          ..write('id: $id, ')
          ..write('cardAccountId: $cardAccountId, ')
          ..write('statementDate: $statementDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('statementAmount: $statementAmount, ')
          ..write('minimumDue: $minimumDue, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paidDate: $paidDate, ')
          ..write('isFullyPaid: $isFullyPaid, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _auditEntityNameMeta =
      const VerificationMeta('auditEntityName');
  @override
  late final GeneratedColumn<String> auditEntityName = GeneratedColumn<String>(
      'entity_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _oldValuesMeta =
      const VerificationMeta('oldValues');
  @override
  late final GeneratedColumn<String> oldValues = GeneratedColumn<String>(
      'old_values', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newValuesMeta =
      const VerificationMeta('newValues');
  @override
  late final GeneratedColumn<String> newValues = GeneratedColumn<String>(
      'new_values', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isMoneyRelatedMeta =
      const VerificationMeta('isMoneyRelated');
  @override
  late final GeneratedColumn<int> isMoneyRelated = GeneratedColumn<int>(
      'is_money_related', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        action,
        entityType,
        entityId,
        auditEntityName,
        oldValues,
        newValues,
        description,
        isMoneyRelated,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_name')) {
      context.handle(
          _auditEntityNameMeta,
          auditEntityName.isAcceptableOrUnknown(
              data['entity_name']!, _auditEntityNameMeta));
    }
    if (data.containsKey('old_values')) {
      context.handle(_oldValuesMeta,
          oldValues.isAcceptableOrUnknown(data['old_values']!, _oldValuesMeta));
    }
    if (data.containsKey('new_values')) {
      context.handle(_newValuesMeta,
          newValues.isAcceptableOrUnknown(data['new_values']!, _newValuesMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_money_related')) {
      context.handle(
          _isMoneyRelatedMeta,
          isMoneyRelated.isAcceptableOrUnknown(
              data['is_money_related']!, _isMoneyRelatedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      auditEntityName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_name']),
      oldValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}old_values']),
      newValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_values']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isMoneyRelated: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_money_related'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String? auditEntityName;
  final String? oldValues;
  final String? newValues;
  final String? description;
  final int isMoneyRelated;
  final String createdAt;
  const AuditLogData(
      {required this.id,
      required this.action,
      required this.entityType,
      required this.entityId,
      this.auditEntityName,
      this.oldValues,
      this.newValues,
      this.description,
      required this.isMoneyRelated,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || auditEntityName != null) {
      map['entity_name'] = Variable<String>(auditEntityName);
    }
    if (!nullToAbsent || oldValues != null) {
      map['old_values'] = Variable<String>(oldValues);
    }
    if (!nullToAbsent || newValues != null) {
      map['new_values'] = Variable<String>(newValues);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_money_related'] = Variable<int>(isMoneyRelated);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      auditEntityName: auditEntityName == null && nullToAbsent
          ? const Value.absent()
          : Value(auditEntityName),
      oldValues: oldValues == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValues),
      newValues: newValues == null && nullToAbsent
          ? const Value.absent()
          : Value(newValues),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isMoneyRelated: Value(isMoneyRelated),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<String>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      auditEntityName: serializer.fromJson<String?>(json['auditEntityName']),
      oldValues: serializer.fromJson<String?>(json['oldValues']),
      newValues: serializer.fromJson<String?>(json['newValues']),
      description: serializer.fromJson<String?>(json['description']),
      isMoneyRelated: serializer.fromJson<int>(json['isMoneyRelated']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'auditEntityName': serializer.toJson<String?>(auditEntityName),
      'oldValues': serializer.toJson<String?>(oldValues),
      'newValues': serializer.toJson<String?>(newValues),
      'description': serializer.toJson<String?>(description),
      'isMoneyRelated': serializer.toJson<int>(isMoneyRelated),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  AuditLogData copyWith(
          {String? id,
          String? action,
          String? entityType,
          String? entityId,
          Value<String?> auditEntityName = const Value.absent(),
          Value<String?> oldValues = const Value.absent(),
          Value<String?> newValues = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? isMoneyRelated,
          String? createdAt}) =>
      AuditLogData(
        id: id ?? this.id,
        action: action ?? this.action,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        auditEntityName: auditEntityName.present
            ? auditEntityName.value
            : this.auditEntityName,
        oldValues: oldValues.present ? oldValues.value : this.oldValues,
        newValues: newValues.present ? newValues.value : this.newValues,
        description: description.present ? description.value : this.description,
        isMoneyRelated: isMoneyRelated ?? this.isMoneyRelated,
        createdAt: createdAt ?? this.createdAt,
      );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      auditEntityName: data.auditEntityName.present
          ? data.auditEntityName.value
          : this.auditEntityName,
      oldValues: data.oldValues.present ? data.oldValues.value : this.oldValues,
      newValues: data.newValues.present ? data.newValues.value : this.newValues,
      description:
          data.description.present ? data.description.value : this.description,
      isMoneyRelated: data.isMoneyRelated.present
          ? data.isMoneyRelated.value
          : this.isMoneyRelated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('auditEntityName: $auditEntityName, ')
          ..write('oldValues: $oldValues, ')
          ..write('newValues: $newValues, ')
          ..write('description: $description, ')
          ..write('isMoneyRelated: $isMoneyRelated, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      action,
      entityType,
      entityId,
      auditEntityName,
      oldValues,
      newValues,
      description,
      isMoneyRelated,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.auditEntityName == this.auditEntityName &&
          other.oldValues == this.oldValues &&
          other.newValues == this.newValues &&
          other.description == this.description &&
          other.isMoneyRelated == this.isMoneyRelated &&
          other.createdAt == this.createdAt);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<String> id;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> auditEntityName;
  final Value<String?> oldValues;
  final Value<String?> newValues;
  final Value<String?> description;
  final Value<int> isMoneyRelated;
  final Value<String> createdAt;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.auditEntityName = const Value.absent(),
    this.oldValues = const Value.absent(),
    this.newValues = const Value.absent(),
    this.description = const Value.absent(),
    this.isMoneyRelated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String action,
    required String entityType,
    required String entityId,
    this.auditEntityName = const Value.absent(),
    this.oldValues = const Value.absent(),
    this.newValues = const Value.absent(),
    this.description = const Value.absent(),
    this.isMoneyRelated = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        action = Value(action),
        entityType = Value(entityType),
        entityId = Value(entityId),
        createdAt = Value(createdAt);
  static Insertable<AuditLogData> custom({
    Expression<String>? id,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? auditEntityName,
    Expression<String>? oldValues,
    Expression<String>? newValues,
    Expression<String>? description,
    Expression<int>? isMoneyRelated,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (auditEntityName != null) 'entity_name': auditEntityName,
      if (oldValues != null) 'old_values': oldValues,
      if (newValues != null) 'new_values': newValues,
      if (description != null) 'description': description,
      if (isMoneyRelated != null) 'is_money_related': isMoneyRelated,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith(
      {Value<String>? id,
      Value<String>? action,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String?>? auditEntityName,
      Value<String?>? oldValues,
      Value<String?>? newValues,
      Value<String?>? description,
      Value<int>? isMoneyRelated,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return AuditLogCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      auditEntityName: auditEntityName ?? this.auditEntityName,
      oldValues: oldValues ?? this.oldValues,
      newValues: newValues ?? this.newValues,
      description: description ?? this.description,
      isMoneyRelated: isMoneyRelated ?? this.isMoneyRelated,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (auditEntityName.present) {
      map['entity_name'] = Variable<String>(auditEntityName.value);
    }
    if (oldValues.present) {
      map['old_values'] = Variable<String>(oldValues.value);
    }
    if (newValues.present) {
      map['new_values'] = Variable<String>(newValues.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isMoneyRelated.present) {
      map['is_money_related'] = Variable<int>(isMoneyRelated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('auditEntityName: $auditEntityName, ')
          ..write('oldValues: $oldValues, ')
          ..write('newValues: $newValues, ')
          ..write('description: $description, ')
          ..write('isMoneyRelated: $isMoneyRelated, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventFriendsTable extends EventFriends
    with TableInfo<$EventFriendsTable, EventFriend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventFriendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _friendIdMeta =
      const VerificationMeta('friendId');
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
      'friend_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shareAmountMeta =
      const VerificationMeta('shareAmount');
  @override
  late final GeneratedColumn<int> shareAmount = GeneratedColumn<int>(
      'share_amount', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [eventId, friendId, shareAmount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_friends';
  @override
  VerificationContext validateIntegrity(Insertable<EventFriend> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(_friendIdMeta,
          friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta));
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('share_amount')) {
      context.handle(
          _shareAmountMeta,
          shareAmount.isAcceptableOrUnknown(
              data['share_amount']!, _shareAmountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, friendId};
  @override
  EventFriend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventFriend(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      friendId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friend_id'])!,
      shareAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}share_amount']),
    );
  }

  @override
  $EventFriendsTable createAlias(String alias) {
    return $EventFriendsTable(attachedDatabase, alias);
  }
}

class EventFriend extends DataClass implements Insertable<EventFriend> {
  final String eventId;
  final String friendId;
  final int? shareAmount;
  const EventFriend(
      {required this.eventId, required this.friendId, this.shareAmount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['friend_id'] = Variable<String>(friendId);
    if (!nullToAbsent || shareAmount != null) {
      map['share_amount'] = Variable<int>(shareAmount);
    }
    return map;
  }

  EventFriendsCompanion toCompanion(bool nullToAbsent) {
    return EventFriendsCompanion(
      eventId: Value(eventId),
      friendId: Value(friendId),
      shareAmount: shareAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(shareAmount),
    );
  }

  factory EventFriend.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventFriend(
      eventId: serializer.fromJson<String>(json['eventId']),
      friendId: serializer.fromJson<String>(json['friendId']),
      shareAmount: serializer.fromJson<int?>(json['shareAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'friendId': serializer.toJson<String>(friendId),
      'shareAmount': serializer.toJson<int?>(shareAmount),
    };
  }

  EventFriend copyWith(
          {String? eventId,
          String? friendId,
          Value<int?> shareAmount = const Value.absent()}) =>
      EventFriend(
        eventId: eventId ?? this.eventId,
        friendId: friendId ?? this.friendId,
        shareAmount: shareAmount.present ? shareAmount.value : this.shareAmount,
      );
  EventFriend copyWithCompanion(EventFriendsCompanion data) {
    return EventFriend(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      shareAmount:
          data.shareAmount.present ? data.shareAmount.value : this.shareAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventFriend(')
          ..write('eventId: $eventId, ')
          ..write('friendId: $friendId, ')
          ..write('shareAmount: $shareAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, friendId, shareAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventFriend &&
          other.eventId == this.eventId &&
          other.friendId == this.friendId &&
          other.shareAmount == this.shareAmount);
}

class EventFriendsCompanion extends UpdateCompanion<EventFriend> {
  final Value<String> eventId;
  final Value<String> friendId;
  final Value<int?> shareAmount;
  final Value<int> rowid;
  const EventFriendsCompanion({
    this.eventId = const Value.absent(),
    this.friendId = const Value.absent(),
    this.shareAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventFriendsCompanion.insert({
    required String eventId,
    required String friendId,
    this.shareAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : eventId = Value(eventId),
        friendId = Value(friendId);
  static Insertable<EventFriend> custom({
    Expression<String>? eventId,
    Expression<String>? friendId,
    Expression<int>? shareAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (friendId != null) 'friend_id': friendId,
      if (shareAmount != null) 'share_amount': shareAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventFriendsCompanion copyWith(
      {Value<String>? eventId,
      Value<String>? friendId,
      Value<int?>? shareAmount,
      Value<int>? rowid}) {
    return EventFriendsCompanion(
      eventId: eventId ?? this.eventId,
      friendId: friendId ?? this.friendId,
      shareAmount: shareAmount ?? this.shareAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (shareAmount.present) {
      map['share_amount'] = Variable<int>(shareAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventFriendsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('friendId: $friendId, ')
          ..write('shareAmount: $shareAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $FriendsTable friends = $FriendsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $MonthRecordsTable monthRecords = $MonthRecordsTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $PendingTransactionsTable pendingTransactions =
      $PendingTransactionsTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $LoanEmiScheduleTable loanEmiSchedule =
      $LoanEmiScheduleTable(this);
  late final $CreditCardStatementsTable creditCardStatements =
      $CreditCardStatementsTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $EventFriendsTable eventFriends = $EventFriendsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        settings,
        friends,
        accounts,
        events,
        categories,
        monthRecords,
        recurringTransactions,
        pendingTransactions,
        loans,
        loanEmiSchedule,
        creditCardStatements,
        auditLog,
        eventFriends
      ];
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SettingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SettingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
        ));
}

class $$SettingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SettingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FriendsTableCreateCompanionBuilder = FriendsCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  required String createdAt,
  Value<int> rowid,
});
typedef $$FriendsTableUpdateCompanionBuilder = FriendsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$FriendsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FriendsTable,
    Friend,
    $$FriendsTableFilterComposer,
    $$FriendsTableOrderingComposer,
    $$FriendsTableCreateCompanionBuilder,
    $$FriendsTableUpdateCompanionBuilder> {
  $$FriendsTableTableManager(_$AppDatabase db, $FriendsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FriendsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FriendsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendsCompanion(
            id: id,
            name: name,
            phone: phone,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendsCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$FriendsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get phone => $state.composableBuilder(
      column: $state.table.phone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$FriendsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get phone => $state.composableBuilder(
      column: $state.table.phone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String name,
  required String type,
  Value<String?> institution,
  Value<String?> last4Digits,
  Value<String?> color,
  Value<String?> icon,
  Value<int> trackedBalance,
  Value<int> currentBalance,
  Value<int> isCredit,
  Value<int?> creditLimit,
  Value<int?> billingDay,
  Value<int?> dueDay,
  Value<int> isActive,
  Value<int> isDefault,
  required String createdAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String?> institution,
  Value<String?> last4Digits,
  Value<String?> color,
  Value<String?> icon,
  Value<int> trackedBalance,
  Value<int> currentBalance,
  Value<int> isCredit,
  Value<int?> creditLimit,
  Value<int?> billingDay,
  Value<int?> dueDay,
  Value<int> isActive,
  Value<int> isDefault,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AccountsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AccountsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> institution = const Value.absent(),
            Value<String?> last4Digits = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> trackedBalance = const Value.absent(),
            Value<int> currentBalance = const Value.absent(),
            Value<int> isCredit = const Value.absent(),
            Value<int?> creditLimit = const Value.absent(),
            Value<int?> billingDay = const Value.absent(),
            Value<int?> dueDay = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<int> isDefault = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            type: type,
            institution: institution,
            last4Digits: last4Digits,
            color: color,
            icon: icon,
            trackedBalance: trackedBalance,
            currentBalance: currentBalance,
            isCredit: isCredit,
            creditLimit: creditLimit,
            billingDay: billingDay,
            dueDay: dueDay,
            isActive: isActive,
            isDefault: isDefault,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            Value<String?> institution = const Value.absent(),
            Value<String?> last4Digits = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> trackedBalance = const Value.absent(),
            Value<int> currentBalance = const Value.absent(),
            Value<int> isCredit = const Value.absent(),
            Value<int?> creditLimit = const Value.absent(),
            Value<int?> billingDay = const Value.absent(),
            Value<int?> dueDay = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<int> isDefault = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            type: type,
            institution: institution,
            last4Digits: last4Digits,
            color: color,
            icon: icon,
            trackedBalance: trackedBalance,
            currentBalance: currentBalance,
            isCredit: isCredit,
            creditLimit: creditLimit,
            billingDay: billingDay,
            dueDay: dueDay,
            isActive: isActive,
            isDefault: isDefault,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$AccountsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get institution => $state.composableBuilder(
      column: $state.table.institution,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get last4Digits => $state.composableBuilder(
      column: $state.table.last4Digits,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get icon => $state.composableBuilder(
      column: $state.table.icon,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get trackedBalance => $state.composableBuilder(
      column: $state.table.trackedBalance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentBalance => $state.composableBuilder(
      column: $state.table.currentBalance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isCredit => $state.composableBuilder(
      column: $state.table.isCredit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get creditLimit => $state.composableBuilder(
      column: $state.table.creditLimit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get billingDay => $state.composableBuilder(
      column: $state.table.billingDay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dueDay => $state.composableBuilder(
      column: $state.table.dueDay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AccountsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get institution => $state.composableBuilder(
      column: $state.table.institution,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get last4Digits => $state.composableBuilder(
      column: $state.table.last4Digits,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get icon => $state.composableBuilder(
      column: $state.table.icon,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get trackedBalance => $state.composableBuilder(
      column: $state.table.trackedBalance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentBalance => $state.composableBuilder(
      column: $state.table.currentBalance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isCredit => $state.composableBuilder(
      column: $state.table.isCredit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get creditLimit => $state.composableBuilder(
      column: $state.table.creditLimit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get billingDay => $state.composableBuilder(
      column: $state.table.billingDay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dueDay => $state.composableBuilder(
      column: $state.table.dueDay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String type,
  required int amount,
  Value<String?> category,
  Value<String?> description,
  Value<String?> friendId,
  Value<String?> accountId,
  Value<String?> fromAccountId,
  Value<String?> toAccountId,
  Value<String?> recurringId,
  Value<String?> loanId,
  required String eventDate,
  required String createdAt,
  Value<String?> billPhotoPath,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<int> amount,
  Value<String?> category,
  Value<String?> description,
  Value<String?> friendId,
  Value<String?> accountId,
  Value<String?> fromAccountId,
  Value<String?> toAccountId,
  Value<String?> recurringId,
  Value<String?> loanId,
  Value<String> eventDate,
  Value<String> createdAt,
  Value<String?> billPhotoPath,
  Value<int> rowid,
});

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EventsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EventsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> friendId = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<String?> fromAccountId = const Value.absent(),
            Value<String?> toAccountId = const Value.absent(),
            Value<String?> recurringId = const Value.absent(),
            Value<String?> loanId = const Value.absent(),
            Value<String> eventDate = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String?> billPhotoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            type: type,
            amount: amount,
            category: category,
            description: description,
            friendId: friendId,
            accountId: accountId,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            recurringId: recurringId,
            loanId: loanId,
            eventDate: eventDate,
            createdAt: createdAt,
            billPhotoPath: billPhotoPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required int amount,
            Value<String?> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> friendId = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<String?> fromAccountId = const Value.absent(),
            Value<String?> toAccountId = const Value.absent(),
            Value<String?> recurringId = const Value.absent(),
            Value<String?> loanId = const Value.absent(),
            required String eventDate,
            required String createdAt,
            Value<String?> billPhotoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            type: type,
            amount: amount,
            category: category,
            description: description,
            friendId: friendId,
            accountId: accountId,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            recurringId: recurringId,
            loanId: loanId,
            eventDate: eventDate,
            createdAt: createdAt,
            billPhotoPath: billPhotoPath,
            rowid: rowid,
          ),
        ));
}

class $$EventsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get friendId => $state.composableBuilder(
      column: $state.table.friendId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get accountId => $state.composableBuilder(
      column: $state.table.accountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fromAccountId => $state.composableBuilder(
      column: $state.table.fromAccountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get toAccountId => $state.composableBuilder(
      column: $state.table.toAccountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recurringId => $state.composableBuilder(
      column: $state.table.recurringId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get loanId => $state.composableBuilder(
      column: $state.table.loanId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get eventDate => $state.composableBuilder(
      column: $state.table.eventDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get billPhotoPath => $state.composableBuilder(
      column: $state.table.billPhotoPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EventsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get friendId => $state.composableBuilder(
      column: $state.table.friendId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get accountId => $state.composableBuilder(
      column: $state.table.accountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fromAccountId => $state.composableBuilder(
      column: $state.table.fromAccountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get toAccountId => $state.composableBuilder(
      column: $state.table.toAccountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recurringId => $state.composableBuilder(
      column: $state.table.recurringId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get loanId => $state.composableBuilder(
      column: $state.table.loanId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get eventDate => $state.composableBuilder(
      column: $state.table.eventDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get billPhotoPath => $state.composableBuilder(
      column: $state.table.billPhotoPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<int> isDefault,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> isDefault,
  Value<int> rowid,
});

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> isDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            isDefault: isDefault,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> isDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            isDefault: isDefault,
            rowid: rowid,
          ),
        ));
}

class $$CategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MonthRecordsTableCreateCompanionBuilder = MonthRecordsCompanion
    Function({
  required String id,
  required int year,
  required int month,
  required int baseBudget,
  Value<int> carryOverAmount,
  required int totalBudget,
  Value<int> totalSpent,
  Value<int> endingBalance,
  required String createdAt,
  Value<int> rowid,
});
typedef $$MonthRecordsTableUpdateCompanionBuilder = MonthRecordsCompanion
    Function({
  Value<String> id,
  Value<int> year,
  Value<int> month,
  Value<int> baseBudget,
  Value<int> carryOverAmount,
  Value<int> totalBudget,
  Value<int> totalSpent,
  Value<int> endingBalance,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$MonthRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MonthRecordsTable,
    MonthRecord,
    $$MonthRecordsTableFilterComposer,
    $$MonthRecordsTableOrderingComposer,
    $$MonthRecordsTableCreateCompanionBuilder,
    $$MonthRecordsTableUpdateCompanionBuilder> {
  $$MonthRecordsTableTableManager(_$AppDatabase db, $MonthRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MonthRecordsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MonthRecordsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<int> baseBudget = const Value.absent(),
            Value<int> carryOverAmount = const Value.absent(),
            Value<int> totalBudget = const Value.absent(),
            Value<int> totalSpent = const Value.absent(),
            Value<int> endingBalance = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonthRecordsCompanion(
            id: id,
            year: year,
            month: month,
            baseBudget: baseBudget,
            carryOverAmount: carryOverAmount,
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            endingBalance: endingBalance,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int year,
            required int month,
            required int baseBudget,
            Value<int> carryOverAmount = const Value.absent(),
            required int totalBudget,
            Value<int> totalSpent = const Value.absent(),
            Value<int> endingBalance = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MonthRecordsCompanion.insert(
            id: id,
            year: year,
            month: month,
            baseBudget: baseBudget,
            carryOverAmount: carryOverAmount,
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            endingBalance: endingBalance,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$MonthRecordsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MonthRecordsTable> {
  $$MonthRecordsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get year => $state.composableBuilder(
      column: $state.table.year,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get month => $state.composableBuilder(
      column: $state.table.month,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get baseBudget => $state.composableBuilder(
      column: $state.table.baseBudget,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get carryOverAmount => $state.composableBuilder(
      column: $state.table.carryOverAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalBudget => $state.composableBuilder(
      column: $state.table.totalBudget,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalSpent => $state.composableBuilder(
      column: $state.table.totalSpent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get endingBalance => $state.composableBuilder(
      column: $state.table.endingBalance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MonthRecordsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MonthRecordsTable> {
  $$MonthRecordsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get year => $state.composableBuilder(
      column: $state.table.year,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get month => $state.composableBuilder(
      column: $state.table.month,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get baseBudget => $state.composableBuilder(
      column: $state.table.baseBudget,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get carryOverAmount => $state.composableBuilder(
      column: $state.table.carryOverAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalBudget => $state.composableBuilder(
      column: $state.table.totalBudget,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalSpent => $state.composableBuilder(
      column: $state.table.totalSpent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get endingBalance => $state.composableBuilder(
      column: $state.table.endingBalance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RecurringTransactionsTableCreateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  required String id,
  required String name,
  required String type,
  required int amount,
  Value<String?> category,
  Value<String?> accountId,
  required String frequency,
  Value<int?> dayOfMonth,
  Value<int?> dayOfWeek,
  required String startDate,
  Value<String?> endDate,
  Value<int> requiresVerification,
  Value<int> autoApply,
  Value<int> isAutopay,
  Value<int> isActive,
  Value<String?> lastAppliedDate,
  Value<String?> nextDueDate,
  Value<String?> linkedLoanId,
  required String createdAt,
  Value<int> rowid,
});
typedef $$RecurringTransactionsTableUpdateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<int> amount,
  Value<String?> category,
  Value<String?> accountId,
  Value<String> frequency,
  Value<int?> dayOfMonth,
  Value<int?> dayOfWeek,
  Value<String> startDate,
  Value<String?> endDate,
  Value<int> requiresVerification,
  Value<int> autoApply,
  Value<int> isAutopay,
  Value<int> isActive,
  Value<String?> lastAppliedDate,
  Value<String?> nextDueDate,
  Value<String?> linkedLoanId,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$RecurringTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTransactionsTable,
    RecurringTransaction,
    $$RecurringTransactionsTableFilterComposer,
    $$RecurringTransactionsTableOrderingComposer,
    $$RecurringTransactionsTableCreateCompanionBuilder,
    $$RecurringTransactionsTableUpdateCompanionBuilder> {
  $$RecurringTransactionsTableTableManager(
      _$AppDatabase db, $RecurringTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$RecurringTransactionsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$RecurringTransactionsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<int?> dayOfWeek = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<int> requiresVerification = const Value.absent(),
            Value<int> autoApply = const Value.absent(),
            Value<int> isAutopay = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<String?> lastAppliedDate = const Value.absent(),
            Value<String?> nextDueDate = const Value.absent(),
            Value<String?> linkedLoanId = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion(
            id: id,
            name: name,
            type: type,
            amount: amount,
            category: category,
            accountId: accountId,
            frequency: frequency,
            dayOfMonth: dayOfMonth,
            dayOfWeek: dayOfWeek,
            startDate: startDate,
            endDate: endDate,
            requiresVerification: requiresVerification,
            autoApply: autoApply,
            isAutopay: isAutopay,
            isActive: isActive,
            lastAppliedDate: lastAppliedDate,
            nextDueDate: nextDueDate,
            linkedLoanId: linkedLoanId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            required int amount,
            Value<String?> category = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            required String frequency,
            Value<int?> dayOfMonth = const Value.absent(),
            Value<int?> dayOfWeek = const Value.absent(),
            required String startDate,
            Value<String?> endDate = const Value.absent(),
            Value<int> requiresVerification = const Value.absent(),
            Value<int> autoApply = const Value.absent(),
            Value<int> isAutopay = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<String?> lastAppliedDate = const Value.absent(),
            Value<String?> nextDueDate = const Value.absent(),
            Value<String?> linkedLoanId = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion.insert(
            id: id,
            name: name,
            type: type,
            amount: amount,
            category: category,
            accountId: accountId,
            frequency: frequency,
            dayOfMonth: dayOfMonth,
            dayOfWeek: dayOfWeek,
            startDate: startDate,
            endDate: endDate,
            requiresVerification: requiresVerification,
            autoApply: autoApply,
            isAutopay: isAutopay,
            isActive: isActive,
            lastAppliedDate: lastAppliedDate,
            nextDueDate: nextDueDate,
            linkedLoanId: linkedLoanId,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$RecurringTransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get accountId => $state.composableBuilder(
      column: $state.table.accountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dayOfMonth => $state.composableBuilder(
      column: $state.table.dayOfMonth,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dayOfWeek => $state.composableBuilder(
      column: $state.table.dayOfWeek,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get requiresVerification => $state.composableBuilder(
      column: $state.table.requiresVerification,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get autoApply => $state.composableBuilder(
      column: $state.table.autoApply,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isAutopay => $state.composableBuilder(
      column: $state.table.isAutopay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get lastAppliedDate => $state.composableBuilder(
      column: $state.table.lastAppliedDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nextDueDate => $state.composableBuilder(
      column: $state.table.nextDueDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get linkedLoanId => $state.composableBuilder(
      column: $state.table.linkedLoanId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$RecurringTransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get accountId => $state.composableBuilder(
      column: $state.table.accountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dayOfMonth => $state.composableBuilder(
      column: $state.table.dayOfMonth,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dayOfWeek => $state.composableBuilder(
      column: $state.table.dayOfWeek,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get requiresVerification => $state.composableBuilder(
      column: $state.table.requiresVerification,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get autoApply => $state.composableBuilder(
      column: $state.table.autoApply,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isAutopay => $state.composableBuilder(
      column: $state.table.isAutopay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get lastAppliedDate => $state.composableBuilder(
      column: $state.table.lastAppliedDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nextDueDate => $state.composableBuilder(
      column: $state.table.nextDueDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get linkedLoanId => $state.composableBuilder(
      column: $state.table.linkedLoanId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PendingTransactionsTableCreateCompanionBuilder
    = PendingTransactionsCompanion Function({
  required String id,
  required String recurringId,
  required String dueDate,
  required int amount,
  Value<String> status,
  Value<String?> actionDate,
  required String createdAt,
  Value<int> rowid,
});
typedef $$PendingTransactionsTableUpdateCompanionBuilder
    = PendingTransactionsCompanion Function({
  Value<String> id,
  Value<String> recurringId,
  Value<String> dueDate,
  Value<int> amount,
  Value<String> status,
  Value<String?> actionDate,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$PendingTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingTransactionsTable,
    PendingTransaction,
    $$PendingTransactionsTableFilterComposer,
    $$PendingTransactionsTableOrderingComposer,
    $$PendingTransactionsTableCreateCompanionBuilder,
    $$PendingTransactionsTableUpdateCompanionBuilder> {
  $$PendingTransactionsTableTableManager(
      _$AppDatabase db, $PendingTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$PendingTransactionsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$PendingTransactionsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> recurringId = const Value.absent(),
            Value<String> dueDate = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> actionDate = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingTransactionsCompanion(
            id: id,
            recurringId: recurringId,
            dueDate: dueDate,
            amount: amount,
            status: status,
            actionDate: actionDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String recurringId,
            required String dueDate,
            required int amount,
            Value<String> status = const Value.absent(),
            Value<String?> actionDate = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingTransactionsCompanion.insert(
            id: id,
            recurringId: recurringId,
            dueDate: dueDate,
            amount: amount,
            status: status,
            actionDate: actionDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$PendingTransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PendingTransactionsTable> {
  $$PendingTransactionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recurringId => $state.composableBuilder(
      column: $state.table.recurringId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get actionDate => $state.composableBuilder(
      column: $state.table.actionDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PendingTransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PendingTransactionsTable> {
  $$PendingTransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recurringId => $state.composableBuilder(
      column: $state.table.recurringId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get actionDate => $state.composableBuilder(
      column: $state.table.actionDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  required String id,
  required String name,
  required String type,
  required int principal,
  required double interestRate,
  required int tenureMonths,
  required int emiAmount,
  required String startDate,
  required int emiDay,
  Value<int> paymentsMade,
  Value<String?> paymentAccountId,
  Value<String> paymentType,
  Value<String?> creditCardId,
  Value<String?> lender,
  Value<String?> purpose,
  Value<int> isActive,
  Value<int?> foreclosureAmount,
  required String createdAt,
  Value<int> rowid,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<int> principal,
  Value<double> interestRate,
  Value<int> tenureMonths,
  Value<int> emiAmount,
  Value<String> startDate,
  Value<int> emiDay,
  Value<int> paymentsMade,
  Value<String?> paymentAccountId,
  Value<String> paymentType,
  Value<String?> creditCardId,
  Value<String?> lender,
  Value<String?> purpose,
  Value<int> isActive,
  Value<int?> foreclosureAmount,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$LoansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoansTable,
    Loan,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder> {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LoansTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LoansTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> principal = const Value.absent(),
            Value<double> interestRate = const Value.absent(),
            Value<int> tenureMonths = const Value.absent(),
            Value<int> emiAmount = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<int> emiDay = const Value.absent(),
            Value<int> paymentsMade = const Value.absent(),
            Value<String?> paymentAccountId = const Value.absent(),
            Value<String> paymentType = const Value.absent(),
            Value<String?> creditCardId = const Value.absent(),
            Value<String?> lender = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<int?> foreclosureAmount = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCompanion(
            id: id,
            name: name,
            type: type,
            principal: principal,
            interestRate: interestRate,
            tenureMonths: tenureMonths,
            emiAmount: emiAmount,
            startDate: startDate,
            emiDay: emiDay,
            paymentsMade: paymentsMade,
            paymentAccountId: paymentAccountId,
            paymentType: paymentType,
            creditCardId: creditCardId,
            lender: lender,
            purpose: purpose,
            isActive: isActive,
            foreclosureAmount: foreclosureAmount,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            required int principal,
            required double interestRate,
            required int tenureMonths,
            required int emiAmount,
            required String startDate,
            required int emiDay,
            Value<int> paymentsMade = const Value.absent(),
            Value<String?> paymentAccountId = const Value.absent(),
            Value<String> paymentType = const Value.absent(),
            Value<String?> creditCardId = const Value.absent(),
            Value<String?> lender = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<int?> foreclosureAmount = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCompanion.insert(
            id: id,
            name: name,
            type: type,
            principal: principal,
            interestRate: interestRate,
            tenureMonths: tenureMonths,
            emiAmount: emiAmount,
            startDate: startDate,
            emiDay: emiDay,
            paymentsMade: paymentsMade,
            paymentAccountId: paymentAccountId,
            paymentType: paymentType,
            creditCardId: creditCardId,
            lender: lender,
            purpose: purpose,
            isActive: isActive,
            foreclosureAmount: foreclosureAmount,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$LoansTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get principal => $state.composableBuilder(
      column: $state.table.principal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get interestRate => $state.composableBuilder(
      column: $state.table.interestRate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get tenureMonths => $state.composableBuilder(
      column: $state.table.tenureMonths,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get emiAmount => $state.composableBuilder(
      column: $state.table.emiAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get emiDay => $state.composableBuilder(
      column: $state.table.emiDay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get paymentsMade => $state.composableBuilder(
      column: $state.table.paymentsMade,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get paymentAccountId => $state.composableBuilder(
      column: $state.table.paymentAccountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get paymentType => $state.composableBuilder(
      column: $state.table.paymentType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get creditCardId => $state.composableBuilder(
      column: $state.table.creditCardId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get lender => $state.composableBuilder(
      column: $state.table.lender,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get purpose => $state.composableBuilder(
      column: $state.table.purpose,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get foreclosureAmount => $state.composableBuilder(
      column: $state.table.foreclosureAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$LoansTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get principal => $state.composableBuilder(
      column: $state.table.principal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get interestRate => $state.composableBuilder(
      column: $state.table.interestRate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get tenureMonths => $state.composableBuilder(
      column: $state.table.tenureMonths,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get emiAmount => $state.composableBuilder(
      column: $state.table.emiAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get emiDay => $state.composableBuilder(
      column: $state.table.emiDay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get paymentsMade => $state.composableBuilder(
      column: $state.table.paymentsMade,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get paymentAccountId => $state.composableBuilder(
      column: $state.table.paymentAccountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get paymentType => $state.composableBuilder(
      column: $state.table.paymentType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get creditCardId => $state.composableBuilder(
      column: $state.table.creditCardId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get lender => $state.composableBuilder(
      column: $state.table.lender,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get purpose => $state.composableBuilder(
      column: $state.table.purpose,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get foreclosureAmount => $state.composableBuilder(
      column: $state.table.foreclosureAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$LoanEmiScheduleTableCreateCompanionBuilder = LoanEmiScheduleCompanion
    Function({
  required String id,
  required String loanId,
  required int monthNumber,
  required int emiAmount,
  required String createdAt,
  Value<int> rowid,
});
typedef $$LoanEmiScheduleTableUpdateCompanionBuilder = LoanEmiScheduleCompanion
    Function({
  Value<String> id,
  Value<String> loanId,
  Value<int> monthNumber,
  Value<int> emiAmount,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$LoanEmiScheduleTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoanEmiScheduleTable,
    LoanEmiScheduleData,
    $$LoanEmiScheduleTableFilterComposer,
    $$LoanEmiScheduleTableOrderingComposer,
    $$LoanEmiScheduleTableCreateCompanionBuilder,
    $$LoanEmiScheduleTableUpdateCompanionBuilder> {
  $$LoanEmiScheduleTableTableManager(
      _$AppDatabase db, $LoanEmiScheduleTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LoanEmiScheduleTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LoanEmiScheduleTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> loanId = const Value.absent(),
            Value<int> monthNumber = const Value.absent(),
            Value<int> emiAmount = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoanEmiScheduleCompanion(
            id: id,
            loanId: loanId,
            monthNumber: monthNumber,
            emiAmount: emiAmount,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String loanId,
            required int monthNumber,
            required int emiAmount,
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LoanEmiScheduleCompanion.insert(
            id: id,
            loanId: loanId,
            monthNumber: monthNumber,
            emiAmount: emiAmount,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$LoanEmiScheduleTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LoanEmiScheduleTable> {
  $$LoanEmiScheduleTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get loanId => $state.composableBuilder(
      column: $state.table.loanId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get monthNumber => $state.composableBuilder(
      column: $state.table.monthNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get emiAmount => $state.composableBuilder(
      column: $state.table.emiAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$LoanEmiScheduleTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LoanEmiScheduleTable> {
  $$LoanEmiScheduleTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get loanId => $state.composableBuilder(
      column: $state.table.loanId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get monthNumber => $state.composableBuilder(
      column: $state.table.monthNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get emiAmount => $state.composableBuilder(
      column: $state.table.emiAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CreditCardStatementsTableCreateCompanionBuilder
    = CreditCardStatementsCompanion Function({
  required String id,
  required String cardAccountId,
  required String statementDate,
  required String dueDate,
  required int statementAmount,
  required int minimumDue,
  Value<int> paidAmount,
  Value<String?> paidDate,
  Value<int> isFullyPaid,
  required String createdAt,
  Value<int> rowid,
});
typedef $$CreditCardStatementsTableUpdateCompanionBuilder
    = CreditCardStatementsCompanion Function({
  Value<String> id,
  Value<String> cardAccountId,
  Value<String> statementDate,
  Value<String> dueDate,
  Value<int> statementAmount,
  Value<int> minimumDue,
  Value<int> paidAmount,
  Value<String?> paidDate,
  Value<int> isFullyPaid,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$CreditCardStatementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CreditCardStatementsTable,
    CreditCardStatement,
    $$CreditCardStatementsTableFilterComposer,
    $$CreditCardStatementsTableOrderingComposer,
    $$CreditCardStatementsTableCreateCompanionBuilder,
    $$CreditCardStatementsTableUpdateCompanionBuilder> {
  $$CreditCardStatementsTableTableManager(
      _$AppDatabase db, $CreditCardStatementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CreditCardStatementsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$CreditCardStatementsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cardAccountId = const Value.absent(),
            Value<String> statementDate = const Value.absent(),
            Value<String> dueDate = const Value.absent(),
            Value<int> statementAmount = const Value.absent(),
            Value<int> minimumDue = const Value.absent(),
            Value<int> paidAmount = const Value.absent(),
            Value<String?> paidDate = const Value.absent(),
            Value<int> isFullyPaid = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CreditCardStatementsCompanion(
            id: id,
            cardAccountId: cardAccountId,
            statementDate: statementDate,
            dueDate: dueDate,
            statementAmount: statementAmount,
            minimumDue: minimumDue,
            paidAmount: paidAmount,
            paidDate: paidDate,
            isFullyPaid: isFullyPaid,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cardAccountId,
            required String statementDate,
            required String dueDate,
            required int statementAmount,
            required int minimumDue,
            Value<int> paidAmount = const Value.absent(),
            Value<String?> paidDate = const Value.absent(),
            Value<int> isFullyPaid = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CreditCardStatementsCompanion.insert(
            id: id,
            cardAccountId: cardAccountId,
            statementDate: statementDate,
            dueDate: dueDate,
            statementAmount: statementAmount,
            minimumDue: minimumDue,
            paidAmount: paidAmount,
            paidDate: paidDate,
            isFullyPaid: isFullyPaid,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$CreditCardStatementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CreditCardStatementsTable> {
  $$CreditCardStatementsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cardAccountId => $state.composableBuilder(
      column: $state.table.cardAccountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get statementDate => $state.composableBuilder(
      column: $state.table.statementDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get statementAmount => $state.composableBuilder(
      column: $state.table.statementAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get minimumDue => $state.composableBuilder(
      column: $state.table.minimumDue,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get paidAmount => $state.composableBuilder(
      column: $state.table.paidAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get paidDate => $state.composableBuilder(
      column: $state.table.paidDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isFullyPaid => $state.composableBuilder(
      column: $state.table.isFullyPaid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CreditCardStatementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CreditCardStatementsTable> {
  $$CreditCardStatementsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cardAccountId => $state.composableBuilder(
      column: $state.table.cardAccountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get statementDate => $state.composableBuilder(
      column: $state.table.statementDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get statementAmount => $state.composableBuilder(
      column: $state.table.statementAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get minimumDue => $state.composableBuilder(
      column: $state.table.minimumDue,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get paidAmount => $state.composableBuilder(
      column: $state.table.paidAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get paidDate => $state.composableBuilder(
      column: $state.table.paidDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isFullyPaid => $state.composableBuilder(
      column: $state.table.isFullyPaid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AuditLogTableCreateCompanionBuilder = AuditLogCompanion Function({
  required String id,
  required String action,
  required String entityType,
  required String entityId,
  Value<String?> auditEntityName,
  Value<String?> oldValues,
  Value<String?> newValues,
  Value<String?> description,
  Value<int> isMoneyRelated,
  required String createdAt,
  Value<int> rowid,
});
typedef $$AuditLogTableUpdateCompanionBuilder = AuditLogCompanion Function({
  Value<String> id,
  Value<String> action,
  Value<String> entityType,
  Value<String> entityId,
  Value<String?> auditEntityName,
  Value<String?> oldValues,
  Value<String?> newValues,
  Value<String?> description,
  Value<int> isMoneyRelated,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$AuditLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogTable,
    AuditLogData,
    $$AuditLogTableFilterComposer,
    $$AuditLogTableOrderingComposer,
    $$AuditLogTableCreateCompanionBuilder,
    $$AuditLogTableUpdateCompanionBuilder> {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AuditLogTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AuditLogTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String?> auditEntityName = const Value.absent(),
            Value<String?> oldValues = const Value.absent(),
            Value<String?> newValues = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> isMoneyRelated = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogCompanion(
            id: id,
            action: action,
            entityType: entityType,
            entityId: entityId,
            auditEntityName: auditEntityName,
            oldValues: oldValues,
            newValues: newValues,
            description: description,
            isMoneyRelated: isMoneyRelated,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String action,
            required String entityType,
            required String entityId,
            Value<String?> auditEntityName = const Value.absent(),
            Value<String?> oldValues = const Value.absent(),
            Value<String?> newValues = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> isMoneyRelated = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogCompanion.insert(
            id: id,
            action: action,
            entityType: entityType,
            entityId: entityId,
            auditEntityName: auditEntityName,
            oldValues: oldValues,
            newValues: newValues,
            description: description,
            isMoneyRelated: isMoneyRelated,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$AuditLogTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get entityType => $state.composableBuilder(
      column: $state.table.entityType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get entityId => $state.composableBuilder(
      column: $state.table.entityId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get auditEntityName => $state.composableBuilder(
      column: $state.table.auditEntityName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get oldValues => $state.composableBuilder(
      column: $state.table.oldValues,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get newValues => $state.composableBuilder(
      column: $state.table.newValues,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isMoneyRelated => $state.composableBuilder(
      column: $state.table.isMoneyRelated,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AuditLogTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get entityType => $state.composableBuilder(
      column: $state.table.entityType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get entityId => $state.composableBuilder(
      column: $state.table.entityId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get auditEntityName => $state.composableBuilder(
      column: $state.table.auditEntityName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get oldValues => $state.composableBuilder(
      column: $state.table.oldValues,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get newValues => $state.composableBuilder(
      column: $state.table.newValues,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isMoneyRelated => $state.composableBuilder(
      column: $state.table.isMoneyRelated,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$EventFriendsTableCreateCompanionBuilder = EventFriendsCompanion
    Function({
  required String eventId,
  required String friendId,
  Value<int?> shareAmount,
  Value<int> rowid,
});
typedef $$EventFriendsTableUpdateCompanionBuilder = EventFriendsCompanion
    Function({
  Value<String> eventId,
  Value<String> friendId,
  Value<int?> shareAmount,
  Value<int> rowid,
});

class $$EventFriendsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventFriendsTable,
    EventFriend,
    $$EventFriendsTableFilterComposer,
    $$EventFriendsTableOrderingComposer,
    $$EventFriendsTableCreateCompanionBuilder,
    $$EventFriendsTableUpdateCompanionBuilder> {
  $$EventFriendsTableTableManager(_$AppDatabase db, $EventFriendsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EventFriendsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EventFriendsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> eventId = const Value.absent(),
            Value<String> friendId = const Value.absent(),
            Value<int?> shareAmount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventFriendsCompanion(
            eventId: eventId,
            friendId: friendId,
            shareAmount: shareAmount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String eventId,
            required String friendId,
            Value<int?> shareAmount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventFriendsCompanion.insert(
            eventId: eventId,
            friendId: friendId,
            shareAmount: shareAmount,
            rowid: rowid,
          ),
        ));
}

class $$EventFriendsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $EventFriendsTable> {
  $$EventFriendsTableFilterComposer(super.$state);
  ColumnFilters<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get friendId => $state.composableBuilder(
      column: $state.table.friendId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get shareAmount => $state.composableBuilder(
      column: $state.table.shareAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EventFriendsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $EventFriendsTable> {
  $$EventFriendsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get friendId => $state.composableBuilder(
      column: $state.table.friendId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get shareAmount => $state.composableBuilder(
      column: $state.table.shareAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$FriendsTableTableManager get friends =>
      $$FriendsTableTableManager(_db, _db.friends);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$MonthRecordsTableTableManager get monthRecords =>
      $$MonthRecordsTableTableManager(_db, _db.monthRecords);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$PendingTransactionsTableTableManager get pendingTransactions =>
      $$PendingTransactionsTableTableManager(_db, _db.pendingTransactions);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$LoanEmiScheduleTableTableManager get loanEmiSchedule =>
      $$LoanEmiScheduleTableTableManager(_db, _db.loanEmiSchedule);
  $$CreditCardStatementsTableTableManager get creditCardStatements =>
      $$CreditCardStatementsTableTableManager(_db, _db.creditCardStatements);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$EventFriendsTableTableManager get eventFriends =>
      $$EventFriendsTableTableManager(_db, _db.eventFriends);
}
