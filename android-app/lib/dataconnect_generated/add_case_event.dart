part of 'generated.dart';

class AddCaseEventVariablesBuilder {
  String caseId;
  String title;
  Timestamp date;

  final FirebaseDataConnect _dataConnect;
  AddCaseEventVariablesBuilder(this._dataConnect, {required  this.caseId,required  this.title,required  this.date,});
  Deserializer<AddCaseEventData> dataDeserializer = (dynamic json)  => AddCaseEventData.fromJson(jsonDecode(json));
  Serializer<AddCaseEventVariables> varsSerializer = (AddCaseEventVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddCaseEventData, AddCaseEventVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddCaseEventData, AddCaseEventVariables> ref() {
    AddCaseEventVariables vars= AddCaseEventVariables(caseId: caseId,title: title,date: date,);
    return _dataConnect.mutation("AddCaseEvent", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddCaseEventCaseEventInsert {
  final String id;
  AddCaseEventCaseEventInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCaseEventCaseEventInsert otherTyped = other as AddCaseEventCaseEventInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddCaseEventCaseEventInsert({
    required this.id,
  });
}

@immutable
class AddCaseEventData {
  final AddCaseEventCaseEventInsert caseEvent_insert;
  AddCaseEventData.fromJson(dynamic json):
  
  caseEvent_insert = AddCaseEventCaseEventInsert.fromJson(json['caseEvent_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCaseEventData otherTyped = other as AddCaseEventData;
    return caseEvent_insert == otherTyped.caseEvent_insert;
    
  }
  @override
  int get hashCode => caseEvent_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['caseEvent_insert'] = caseEvent_insert.toJson();
    return json;
  }

  AddCaseEventData({
    required this.caseEvent_insert,
  });
}

@immutable
class AddCaseEventVariables {
  final String caseId;
  final String title;
  final Timestamp date;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddCaseEventVariables.fromJson(Map<String, dynamic> json):
  
  caseId = nativeFromJson<String>(json['caseId']),
  title = nativeFromJson<String>(json['title']),
  date = Timestamp.fromJson(json['date']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCaseEventVariables otherTyped = other as AddCaseEventVariables;
    return caseId == otherTyped.caseId && 
    title == otherTyped.title && 
    date == otherTyped.date;
    
  }
  @override
  int get hashCode => Object.hashAll([caseId.hashCode, title.hashCode, date.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['caseId'] = nativeToJson<String>(caseId);
    json['title'] = nativeToJson<String>(title);
    json['date'] = date.toJson();
    return json;
  }

  AddCaseEventVariables({
    required this.caseId,
    required this.title,
    required this.date,
  });
}

