part of 'generated.dart';

class CreateUserVariablesBuilder {
  String email;
  final Optional<String> _displayName =
      Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;
  CreateUserVariablesBuilder displayName(String? t) {
    _displayName.value = t;
    return this;
  }

  CreateUserVariablesBuilder(
    this._dataConnect, {
    required this.email,
  });
  Deserializer<CreateUserData> dataDeserializer =
      (dynamic json) => CreateUserData.fromJson(jsonDecode(json));
  Serializer<CreateUserVariables> varsSerializer =
      (CreateUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateUserData, CreateUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateUserData, CreateUserVariables> ref() {
    CreateUserVariables vars = CreateUserVariables(
      email: email,
      displayName: _displayName,
    );
    return _dataConnect.mutation(
        "CreateUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateUserUserUpsert {
  final String email;
  CreateUserUserUpsert.fromJson(dynamic json)
      : email = nativeFromJson<String>(json['email']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserUserUpsert otherTyped = other as CreateUserUserUpsert;
    return email == otherTyped.email;
  }

  @override
  int get hashCode => email.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['email'] = nativeToJson<String>(email);
    return json;
  }

  const CreateUserUserUpsert({
    required this.email,
  });
}

@immutable
class CreateUserData {
  final CreateUserUserUpsert userUpsert;
  CreateUserData.fromJson(dynamic json)
      : userUpsert = CreateUserUserUpsert.fromJson(json['user_upsert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserData otherTyped = other as CreateUserData;
    return userUpsert == otherTyped.userUpsert;
  }

  @override
  int get hashCode => userUpsert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_upsert'] = userUpsert.toJson();
    return json;
  }

  const CreateUserData({
    required this.userUpsert,
  });
}

@immutable
class CreateUserVariables {
  final String email;
  final Optional<String> displayName;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateUserVariables.fromJson(Map<String, dynamic> json)
      : email = nativeFromJson<String>(json['email']),
        displayName = Optional.optional(nativeFromJson, nativeToJson)
          ..value = json['displayName'] == null
              ? null
              : nativeFromJson<String>(json['displayName']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserVariables otherTyped = other as CreateUserVariables;
    return email == otherTyped.email && displayName == otherTyped.displayName;
  }

  @override
  int get hashCode => Object.hashAll([email.hashCode, displayName.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['email'] = nativeToJson<String>(email);
    if (displayName.state == OptionalState.set) {
      json['displayName'] = displayName.toJson();
    }
    return json;
  }

  const CreateUserVariables({
    required this.email,
    required this.displayName,
  });
}
