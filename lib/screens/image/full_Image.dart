import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/widgets/image_loader.dart';

class FullImage extends StatefulWidget {
  final String image;

  const FullImage({Key key, this.image}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FullImageState();
}

class _FullImageState extends BaseState<FullImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image")),
      body: Center(
        child: PinchZoomImage(
          image: ImageView(imageUrl: '${widget.image}'),
          hideStatusBarWhileZooming: true,
        ),
      ),
    );
  }
}
