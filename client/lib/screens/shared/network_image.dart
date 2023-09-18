import 'dart:io';
import 'dart:typed_data';
import 'package:build_web_compilers/builders.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/requests/proxy_requests.dart';

class NetworkImageWidget extends StatefulWidget {
  final String src;
  final double? width;
  final double? height;
  final ImageProvider? defaultImage;
  final double? borderRadius;

  const NetworkImageWidget({
    Key? key,
    required this.src,
    this.width,
    this.height,
    this.defaultImage,
    this.borderRadius,
  }) : super(key: key);

  @override
  _NetworkImageState createState() => _NetworkImageState();
}

class _NetworkImageState extends State<NetworkImageWidget> {
  late Image _image;

  void onConnected() {
    precacheImage(_image.image, context);
    _fetchData();
  }

  @override
  void initState() {
    super.initState();
    _image = Image(
      image: const AssetImage('assets/images/FIRST_LOGO.png'),
      width: widget.width,
      height: widget.height,
    );

    NetworkHttp.httpState.addListener(onConnected);
    NetworkWebSocket.wsState.addListener(onConnected);
    NetworkAuth.loginState.addListener(onConnected);
  }

  @override
  void dispose() {
    NetworkHttp.httpState.removeListener(onConnected);
    NetworkWebSocket.wsState.removeListener(onConnected);
    NetworkAuth.loginState.removeListener(onConnected);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onConnected();
  }

  void _fetchData() async {
    getProxyNetworkImage(widget.src).then((res) {
      if (res.item1 == HttpStatus.ok && mounted) {
        MemoryImage memoryImage = MemoryImage(Uint8List.fromList(res.item2));
        precacheImage(memoryImage, context).then((value) {
          if (mounted) {
            setState(() {
              _image = Image(
                image: memoryImage,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.fill,
              );
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
        child: _image,
      ),
    );
  }
}
