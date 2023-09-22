import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/requests/game_requests.dart';
import 'package:tms/requests/proxy_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/tool_bar.dart';

class RuleBook extends StatefulWidget {
  const RuleBook({Key? key}) : super(key: key);

  @override
  State<RuleBook> createState() => _RuleBookState();
}

class _RuleBookState extends State<RuleBook> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Uint8List _pdfBytes = Uint8List(0);
  String ruleBookUrl = "";
  late PdfViewerController _pdfViewerController;

  void _fetchData() async {
    var response = await getProxyBytes(ruleBookUrl);

    if (response.item1 == HttpStatus.ok) {
      if (mounted) {
        setState(() {
          _pdfBytes = response.item2;
        });
      }
    }
  }

  void onConnect() {
    if (mounted) {
      if (ruleBookUrl.isEmpty) {
        getGameRequest().then((game) {
          if (mounted && game.item1 == HttpStatus.ok) {
            setState(() {
              ruleBookUrl = game.item2?.ruleBookUrl ?? "";
            });
            _fetchData();
          }
        });
      } else {
        _fetchData();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    onGameEventUpdate((game) {
      if (mounted) {
        setState(() {
          ruleBookUrl = game.ruleBookUrl;
        });
        _fetchData();
      }
    });

    Network.isConnected().then((connected) {
      if (connected) onConnect();
    });
  }

  Widget getPdf() {
    if (_pdfBytes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return SfPdfViewer.memory(
        _pdfBytes,
        controller: _pdfViewerController,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double controlBarHeight = Responsive.isMobile(context) ? 60 : 80;
    double iconSize = Responsive.isMobile(context) ? 25 : 45;
    return Scaffold(
      appBar: TmsToolBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              SizedBox(
                height: constraints.maxHeight - controlBarHeight,
                child: getPdf(),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // refresh button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _pdfBytes = Uint8List(0);
                        });
                        _fetchData();
                      },
                      icon: const Icon(Icons.refresh),
                      iconSize: iconSize,
                    ),
                    // zoom in button
                    IconButton(
                      onPressed: () {
                        _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.1);
                      },
                      icon: const Icon(Icons.zoom_in),
                      iconSize: iconSize,
                    ),
                    // zoom out button
                    IconButton(
                      onPressed: () {
                        _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.1);
                      },
                      icon: const Icon(Icons.zoom_out),
                      iconSize: iconSize,
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
