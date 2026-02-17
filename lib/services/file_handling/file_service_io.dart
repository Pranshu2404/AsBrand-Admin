import 'dart:io';
import 'package:flutter/material.dart';

/// Platform-safe wrapper for File
class AppFile {
  final File file;
  AppFile(String path) : file = File(path);
  
  String get path => file.path;
}

Widget getFileImage(AppFile file, {double? width, double? height, BoxFit? fit}) {
  return Image.file(
     file.file,
     width: width,
     height: height,
     fit: fit,
  );
}
