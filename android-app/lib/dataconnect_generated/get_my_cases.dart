part of 'generated.dart';

class GetMyCasesVariablesBuilder {
  String userEmail;

  final FirebaseDataConnect _dataConnect;
  GetMyCasesVariablesBuilder(this._dataConnect, {required  this.userEmail,});
  Deserializer<GetMyCasesData> dataDeserializer = (dynamic json)  => GetMyCasesData.fromJson(jsonDecode(json));
  Serializer<GetMyCasesVariables> varsSerializer = (GetMyCasesVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetMyCasesData, GetMyCasesVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetMyCasesData, GetMyCasesVariables> ref() {
    GetMyCasesVariables vars= GetMyCasesVariables(userEmail: userEmail,);
    return _dataConnect.query("GetMyCases", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetMyCasesCourtCases {
  final String id;
  final String title;
  final String? caseNumber;
  final String? status;
  final List<GetMyCasesCourtCasesEvents> events;
  GetMyCasesCourtCases.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  caseNumber = json['caseNumber'] == null ? null : nativeFromJson<String>(json['caseNumber']),
  status = json['status'] == null ? null : nativeFromJson<String>(json['status']),
  events = (json['events'] as List<dynamic>)
        .map((e) => GetMyCasesCourtCasesEvents.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyCasesCourtCases otherTyped = other as GetMyCasesCourtCases;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    caseNumber == otherTyped.caseNumber && 
    status == otherTyped.status && 
    events == otherTyped.events;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, caseNumber.hashCode, status.hashCode, events.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    if (caseNumber != null) {
      json['caseNumber'] = nativeToJson<String?>(caseNumber);
    }
    if (status != null) {
      json['status'] = nativeToJson<String?>(status);
    }
    json['events'] = events.map((e) => e.toJson()).toList();
    return json;
  }

  GetMyCasesCourtCases({
    required this.id,
    required this.title,
    this.caseNumber,
    this.status,
    required this.events,
  });
}

@immutable
class GetMyCasesCourtCasesEvents {
  final String title;
  final Timestamp date;
  final bool? isCompleted;
  GetMyCasesCourtCasesEvents.fromJson(dynamic json):
  
  title = nativeFromJson<String>(json['title']),
  date = Timestamp.fromJson(json['date']),
  isCompleted = json['isCompleted'] == null ? null : nativeFromJson<bool>(json['isCompleted']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyCasesCourtCasesEvents otherTyped = other as GetMyCasesCourtCasesEvents;
    return title == otherTyped.title && 
    date == otherTyped.date && 
    isCompleted == otherTyped.isCompleted;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, date.hashCode, isCompleted.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['date'] = date.toJson();
    if (isCompleted != null) {
      json['isCompleted'] = nativeToJson<bool?>(isCompleted);
    }
    return json;
  }

  GetMyCasesCourtCasesEvents({
    required this.title,
    required this.date,
    this.isCompleted,
  });
}

@immutable
class GetMyCasesData {
  final List<GetMyCasesCourtCases> courtCases;
  GetMyCasesData.fromJson(dynamic json):
  
  courtCases = (json['courtCases'] as List<dynamic>)
        .map((e) => GetMyCasesCourtCases.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyCasesData otherTyped = other as GetMyCasesData;
    return courtCases == otherTyped.courtCases;
    
  }
  @override
  int get hashCode => courtCases.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['courtCases'] = courtCases.map((e) => e.toJson()).toList();
    return json;
  }

  GetMyCasesData({
    required this.courtCases,
  });
}

@immutable
class GetMyCasesVariables {
  final String userEmail;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetMyCasesVariables.fromJson(Map<String, dynamic> json):
  
  userEmail = nativeFromJson<String>(json['userEmail']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyCasesVariables otherTyped = other as GetMyCasesVariables;
    return userEmail == otherTyped.userEmail;
    
  }
  @override
  int get hashCode => userEmail.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userEmail'] = nativeToJson<String>(userEmail);
    return json;
  }

  GetMyCasesVariables({
    required this.userEmail,
  });
}

