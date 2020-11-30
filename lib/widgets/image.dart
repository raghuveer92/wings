import 'dart:io';

import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/widgets/image_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
class MainImage extends StatefulWidget {
  final Map<String, dynamic> imageMap;

  const MainImage({Key key, this.imageMap}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WingsImageState();
}

class _WingsImageState extends BaseState<MainImage> {
  bool imageUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 200,
        margin: EdgeInsets.only(right: 4),
        color: Colors.grey[500],
        child: imageUploading
            ? Center(
                child: Container(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : widget.imageMap["image"] != null
                ? ImageView(
                    imageUrl: '${widget.imageMap["image"]}',
                    height: 200,
                  )
                : Center(
                    child: Icon(Icons.camera_alt_rounded),
                  ),
      ),
    );
  }

  void _pickImage() async {
    final file = await _picker.getImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 800,
      imageQuality: 90,
    );
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio3x2,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    print("file: $croppedFile");
    setState(() {
      imageUploading = true;
    });
    widget.imageMap["image"] = await Backendless.files.upload(croppedFile, "/uploads");
    setState(() {
      imageUploading = false;
    });
  }
}
