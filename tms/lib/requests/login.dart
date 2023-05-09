import 'package:tms/network/network.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, String>> login(String username, String password) async {
  try {
    var message = LoginRequest(username: username, password: password).toJson();
    print("Trying login");
    print("Message $message");
    var res = await Network.serverPost("login", message);
    if (res.item1) {
      return Tuple2(res.item2, LoginResponse.fromJson(res.item3).authToken);
    } else {
      throw "Internal Server Error";
    }
  } catch (e) {
    print(e);
    rethrow;
  }
}
