import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class PreviewPage extends StatelessWidget {
  PreviewPage({ Key? key, required this.file }) : super(key: key);

  File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(file, fit: BoxFit.cover,),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              onPressed: ()=>{ Get.back(result: file), },
                              icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary, size: 30,),),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              onPressed: ()=>{ Get.back(), },
                              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary, size: 30,),),
                          ),
                        ),
                      )
                    ],),
                ],)
          )
        ],
      ),
    );
  }
}