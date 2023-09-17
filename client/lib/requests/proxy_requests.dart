import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tms/constants.dart';
import 'dart:typed_data';

import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, Uint8List>> getProxyNetworkImage(String url) async {
  try {
    var address = await Network.getServerIP();
    var encodedUrl = Uri.encodeComponent(url);
    var res = await http.get(Uri.parse("http://$address:$requestPort/requests/proxy_image/get?url=$encodedUrl"));

    if (res.body.isNotEmpty) {
      var proxyImageResponse = ProxyImageResponse.fromJson(jsonDecode(res.body));
      return Tuple2(res.statusCode, Uint8List.fromList(proxyImageResponse.image));
    } else {
      return Tuple2(HttpStatus.badRequest, Uint8List.fromList([]));
    }
  } catch (e) {
    return Tuple2(HttpStatus.badRequest, Uint8List.fromList([]));
  }
}
