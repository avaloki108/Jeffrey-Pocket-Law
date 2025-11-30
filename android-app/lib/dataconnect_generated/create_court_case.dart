part of 'generated.dart';

class CreateCourtCaseVariablesBuilder {
  String userEmail;
  String title;
  String status;

  final FirebaseDataConnect _dataConnect;
  CreateCourtCaseVariablesBuilder(this._dataConnect, {required  this.userEmail,required  this.title,required  this.status,});
  Deserializer<CreateCourtCaseData> dataDeserializer = (dynamic json)  => CreateCourtCaseData.fromJson(jsonDecode(json));
  Serializer<CreateCourtCaseVariables> varsSerializer = (CreateCourtCaseVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateCourtCaseData, CreateCourtCaseVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateCourtCaseData, CreateCourtCaseVariables> ref() {
    CreateCourtCaseVariables vars= CreateCourtCaseVariables(userEmail: userEmail,title: title,status: status,);
    return _dataConnect.mutation("CreateCourtCase", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateCourtCaseCourtCaseInsert {
  final String id;
  CreateCourtCaseCourtCaseInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCourtCaseCourtCaseInsert otherTyped = other as CreateCourtCaseCourtCaseInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateCourtCaseCourtCaseInsert({
    required this.id,
  });
}

@immutable
class CreateCourtCaseData {
  final CreateCourtCaseCourtCaseInsert courtCaseInsert;
  CreateCourtCaseData.fromJson(dynamic json):
  
  courtCaseInsert = CreateCourtCaseCourtCaseInsert.fromJson(json['courtCase_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCourtCaseData otherTyped = other as CreateCourtCaseData;
    return courtCaseInsert == otherTyped.courtCaseInsert;
    
  }
  @override
  int get hashCode => courtCaseInsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['courtCase_insert'] = courtCaseInsert.toJson();
    return json;
  }

  const CreateCourtCaseData({
    required this.courtCaseInsert,
  });
}

@immutable
class CreateCourtCaseVariables {
  final String userEmail;
  final String title;
  final String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateCourtCaseVariables.fromJson(Map<String, dynamic> json):
  
  userEmail = nativeFromJson<String>(json['userEmail']),
  title = nativeFromJson<String>(json['title']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCourtCaseVariables otherTyped = other as CreateCourtCaseVariables;
    return userEmail == otherTyped.userEmail && 
    title == otherTyped.title && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([userEmail.hashCode, title.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userEmail'] = nativeToJson<String>(userEmail);
    json['title'] = nativeToJson<String>(title);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  const CreateCourtCaseVariables({
    required this.userEmail,
    required this.title,
    required this.status,
  });
}
