import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tms/generated/infra/fll_infra/mission.dart';

class MissionImage extends StatefulWidget {
  final Mission mission;
  final String season;
  final double? width;
  final double? height;
  final double? borderRadius;

  const MissionImage({
    Key? key,
    required this.mission,
    required this.season,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  _MissionImageState createState() => _MissionImageState();
}

class _MissionImageState extends State<MissionImage> {
  late Image _image;

  @override
  void initState() {
    super.initState();

    // default image
    _image = Image(
      image: const AssetImage('assets/images/FIRST_LOGO.png'),
      width: widget.width,
      height: widget.height,
      fit: BoxFit.fill,
    );

    // fetch image
    _fetchImage();
  }

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _fetchImage() async {
    // fetch image from assets
    final String imagePath = 'assets/images/missions/${widget.season}/${widget.mission.id}.png';

    if (await _assetExists(imagePath)) {
      setState(() {
        _image = Image(
          image: AssetImage(imagePath),
          width: widget.width,
          height: widget.height,
          fit: BoxFit.fill,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
        child: _image,
      ),
    );
  }
}
