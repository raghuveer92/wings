import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatefulWidget {
  final double height;
  final double width;
  final String imageUrl;
  final BoxFit fit;

  const ImageView({Key key, this.height, this.width, this.imageUrl, this.fit}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ImageView();
}

class _ImageView extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.white,
      );
    }
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
      ),
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: widget.fit ?? BoxFit.cover,
        placeholder: (context, image) {
          return Center(
              child: Image(
            width: 32,
            height: 32,
            image: AssetImage('icons/app_logo.png'),
            fit: BoxFit.cover,
          ));
        },
      ),
    );
  }
}
