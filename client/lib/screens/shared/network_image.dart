import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tms/requests/proxy_requests.dart';

class NetworkImageWidget extends StatefulWidget {
  final String src;
  final double? width;
  final double? height;
  final ImageProvider? defaultImage;

  const NetworkImageWidget({
    Key? key,
    required this.src,
    this.width,
    this.height,
    this.defaultImage,
  }) : super(key: key);

  @override
  _NetworkImageState createState() => _NetworkImageState();
}

class _NetworkImageState extends State<NetworkImageWidget> {
  late Image _image;

  @override
  void initState() {
    super.initState();
    _image = Image(
      image: const AssetImage('assets/images/FIRST_LOGO.png'),
      width: widget.width,
      height: widget.height,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_image.image, context);
    _fetchData();
  }

  void _fetchData() async {
    getProxyNetworkImage(widget.src).then((res) {
      if (res.item1 == HttpStatus.ok && mounted) {
        MemoryImage memoryImage = MemoryImage(Uint8List.fromList(res.item2));
        precacheImage(memoryImage, context).then((value) {
          setState(() {
            _image = Image(
              image: memoryImage,
              width: widget.width,
              height: widget.height,
            );
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _image;
  }
}
