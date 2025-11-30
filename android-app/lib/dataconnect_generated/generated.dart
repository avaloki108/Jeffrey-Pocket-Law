library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'create_court_case.dart';

part 'add_case_event.dart';

part 'send_message.dart';

part 'get_user.dart';

part 'get_my_cases.dart';

part 'get_chat_history.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser ({required String email, }) {
    return CreateUserVariablesBuilder(dataConnect, email: email,);
  }
  
  
  CreateCourtCaseVariablesBuilder createCourtCase ({required String userEmail, required String title, required String status, }) {
    return CreateCourtCaseVariablesBuilder(dataConnect, userEmail: userEmail,title: title,status: status,);
  }
  
  
  AddCaseEventVariablesBuilder addCaseEvent ({required String caseId, required String title, required Timestamp date, }) {
    return AddCaseEventVariablesBuilder(dataConnect, caseId: caseId,title: title,date: date,);
  }
  
  
  SendMessageVariablesBuilder sendMessage ({required String sessionId, required String content, required String sender, }) {
    return SendMessageVariablesBuilder(dataConnect, sessionId: sessionId,content: content,sender: sender,);
  }
  
  
  GetUserVariablesBuilder getUser ({required String email, }) {
    return GetUserVariablesBuilder(dataConnect, email: email,);
  }
  
  
  GetMyCasesVariablesBuilder getMyCases ({required String userEmail, }) {
    return GetMyCasesVariablesBuilder(dataConnect, userEmail: userEmail,);
  }
  
  
  GetChatHistoryVariablesBuilder getChatHistory ({required String sessionId, }) {
    return GetChatHistoryVariablesBuilder(dataConnect, sessionId: sessionId,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'jeffery-friendly-pocket-law-4-service',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
