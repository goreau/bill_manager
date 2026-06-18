import 'dart:io';

import 'package:flutter/material.dart';

class Foto extends StatelessWidget {
  const Foto({Key? key, required this.file, required this.size}) : super(key: key);

  final File file;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size/20),
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
