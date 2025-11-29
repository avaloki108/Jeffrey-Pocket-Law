part of 'generated.dart';

class GetChatHistoryVariablesBuilder {
  String sessionId;

  final FirebaseDataConnect _dataConnect;
  GetChatHistoryVariablesBuilder(this._dataConnect, {required  this.sessionId,});
  Deserializer<GetChatHistoryData> dataDeserializer = (dynamic json)  => GetChatHistoryData.fromJson(jsonDecode(json));
  Serializer<GetChatHistoryVariables> varsSerializer = (GetChatHistoryVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetChatHistoryData, GetChatHistoryVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetChatHistoryData, GetChatHistoryVariables> ref() {
    GetChatHistoryVariables vars= GetChatHistoryVariables(sessionId: sessionId,);
    return _dataConnect.query("GetChatHistory", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetChatHistoryChatSession {
  final String title;
  final List<GetChatHistoryChatSessionMessages> messages;
  GetChatHistoryChatSession.fromJson(dynamic json):
  
  title = nativeFromJson<String>(json['title']),
  messages = (json['messages'] as List<dynamic>)
        .map((e) => GetChatHistoryChatSessionMessages.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetChatHistoryChatSession otherTyped = other as GetChatHistoryChatSession;
    return title == otherTyped.title && 
    messages == otherTyped.messages;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, messages.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['messages'] = messages.map((e) => e.toJson()).toList();
    return json;
  }

  const GetChatHistoryChatSession({
    required this.title,
    required this.messages,
  });
}

@immutable
class GetChatHistoryChatSessionMessages {
  final String sender;
  final String content;
  final Timestamp timestamp;
  GetChatHistoryChatSessionMessages.fromJson(dynamic json):
  
  sender = nativeFromJson<String>(json['sender']),
  content = nativeFromJson<String>(json['content']),
  timestamp = Timestamp.fromJson(json['timestamp']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetChatHistoryChatSessionMessages otherTyped = other as GetChatHistoryChatSessionMessages;
    return sender == otherTyped.sender && 
    content == otherTyped.content && 
    timestamp == otherTyped.timestamp;
    
  }
  @override
  int get hashCode => Object.hashAll([sender.hashCode, content.hashCode, timestamp.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['sender'] = nativeToJson<String>(sender);
    json['content'] = nativeToJson<String>(content);
    json['timestamp'] = timestamp.toJson();
    return json;
  }

  const GetChatHistoryChatSessionMessages({
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}

@immutable
class GetChatHistoryData {
  final GetChatHistoryChatSession? chatSession;
  GetChatHistoryData.fromJson(dynamic json):
  
  chatSession = json['chatSession'] == null ? null : GetChatHistoryChatSession.fromJson(json['chatSession']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetChatHistoryData otherTyped = other as GetChatHistoryData;
    return chatSession == otherTyped.chatSession;
    
  }
  @override
  int get hashCode => chatSession.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (chatSession != null) {
      json['chatSession'] = chatSession!.toJson();
    }
    return json;
  }

  const GetChatHistoryData({
    this.chatSession,
  });
}

@immutable
class GetChatHistoryVariables {
  final String sessionId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetChatHistoryVariables.fromJson(Map<String, dynamic> json):
  
  sessionId = nativeFromJson<String>(json['sessionId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetChatHistoryVariables otherTyped = other as GetChatHistoryVariables;
    return sessionId == otherTyped.sessionId;
    
  }
  @override
  int get hashCode => sessionId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['sessionId'] = nativeToJson<String>(sessionId);
    return json;
  }

  const GetChatHistoryVariables({
    required this.sessionId,
  });
}

