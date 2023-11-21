import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';

void senderValidation(List<ScoreAnswer> answers) async {
  try {
    var message = QuestionsValidateRequest(answers: answers, authToken: await NetworkAuth.getToken());

    SocketMessage m = SocketMessage(
      topic: "validation",
      subTopic: "",
      message: jsonEncode(message.toJson()),
    );
    Network.publish(m);
  } catch (e) {
    Logger().e("Error sending message: $e");
  }
}
