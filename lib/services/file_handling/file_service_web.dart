import 'package:flutter/material.dart';

/// Web implementation of AppFile that uses String path (Blob URL)
class AppFile {
  final String path;
  AppFile(this.path);
}

Widget getFileImage(AppFile file, {double? width, double? height, BoxFit? fit}) {
  return Image.network(
     file.path,
     width: width,
     height: height,
     fit: fit,
  );
}
