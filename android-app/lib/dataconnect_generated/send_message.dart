part of 'generated.dart';

class SendMessageVariablesBuilder {
  String sessionId;
  String content;
  String sender;

  final FirebaseDataConnect _dataConnect;
  SendMessageVariablesBuilder(this._dataConnect, {required  this.sessionId,required  this.content,required  this.sender,});
  Deserializer<SendMessageData> dataDeserializer = (dynamic json)  => SendMessageData.fromJson(jsonDecode(json));
  Serializer<SendMessageVariables> varsSerializer = (SendMessageVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<SendMessageData, SendMessageVariables>> execute() {
    return ref().execute();
  }

  MutationRef<SendMessageData, SendMessageVariables> ref() {
    SendMessageVariables vars= SendMessageVariables(sessionId: sessionId,content: content,sender: sender,);
    return _dataConnect.mutation("SendMessage", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class SendMessageChatMessageInsert {
  final String id;
  SendMessageChatMessageInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendMessageChatMessageInsert otherTyped = other as SendMessageChatMessageInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const SendMessageChatMessageInsert({
    required this.id,
  });
}

@immutable
class SendMessageData {
  final SendMessageChatMessageInsert chatMessage_insert;
  SendMessageData.fromJson(dynamic json):
  
  chatMessage_insert = SendMessageChatMessageInsert.fromJson(json['chatMessage_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendMessageData otherTyped = other as SendMessageData;
    return chatMessage_insert == otherTyped.chatMessage_insert;
    
  }
  @override
  int get hashCode => chatMessage_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['chatMessage_insert'] = chatMessage_insert.toJson();
    return json;
  }

  const SendMessageData({
    required this.chatMessage_insert,
  });
}

@immutable
class SendMessageVariables {
  final String sessionId;
  final String content;
  final String sender;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SendMessageVariables.fromJson(Map<String, dynamic> json):
  
  sessionId = nativeFromJson<String>(json['sessionId']),
  content = nativeFromJson<String>(json['content']),
  sender = nativeFromJson<String>(json['sender']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendMessageVariables otherTyped = other as SendMessageVariables;
    return sessionId == otherTyped.sessionId && 
    content == otherTyped.content && 
    sender == otherTyped.sender;
    
  }
  @override
  int get hashCode => Object.hashAll([sessionId.hashCode, content.hashCode, sender.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['sessionId'] = nativeToJson<String>(sessionId);
    json['content'] = nativeToJson<String>(content);
    json['sender'] = nativeToJson<String>(sender);
    return json;
  }

  const SendMessageVariables({
    required this.sessionId,
    required this.content,
    required this.sender,
  });
}

