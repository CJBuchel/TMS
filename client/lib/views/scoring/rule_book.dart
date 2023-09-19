import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/requests/proxy_requests.dart';

class RuleBook extends StatefulWidget {
  const RuleBook({Key? key}) : super(key: key);

  @override
  State<RuleBook> createState() => _RuleBookState();
}

class _RuleBookState extends State<RuleBook> {
  Uint8List? _pdfData;

  void onConnected() async {
    if (await Network.isConnected()) {
      _fetchData();
    }
  }

  void _fetchData() async {
    await getProxyBytes(
            "https://firstinspiresst01.blob.core.windows.net/first-in-show-masterpiece/fll-challenge/fll-challenge-masterpiece-rgr-en.pdf")
        .then((res) {
      if (res.item1 == HttpStatus.ok && mounted) {
        setState(() {
          _pdfData = res.item2;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onConnected();
  }

  @override
  void initState() {
    super.initState();

    NetworkHttp.httpState.addListener(onConnected);
    NetworkWebSocket.wsState.addListener(onConnected);
    NetworkAuth.loginState.addListener(onConnected);
    onConnected();
  }

  Widget getPdf() {
    if (_pdfData != null) {
      return SfPdfViewer.memory(_pdfData!);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF View")),
      body: getPdf(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    NetworkHttp.httpState.removeListener(onConnected);
    NetworkWebSocket.wsState.removeListener(onConnected);
    NetworkAuth.loginState.removeListener(onConnected);
  }
}
