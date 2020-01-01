import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple_permissions/simple_permissions.dart';

class HomePage extends StatefulWidget {
  static final String routeName = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dataController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  GlobalKey _globalKey = new GlobalKey();
  bool showQR = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('QR-Gen', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: TextField(
                  controller: _dataController,
                  maxLines: 5,
                  minLines: 1,
                  autofocus: true,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                      hintText: 'Qr Data',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: () {
                          // close the keyboard
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            showQR = true;
                          });
                        },
                      )),
                ),
              ),
              SizedBox(height: 20),
              if (showQR)
                Padding(
                  padding: EdgeInsets.all(10),
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: QrImage(
                      data: _dataController.text ?? 'QR-Gen',
                      version: QrVersions.auto,
                      size: MediaQuery.of(context).size.width * 0.8,
                      backgroundColor: Colors.white,
                      gapless: false,
                      embeddedImage: AssetImage('assets/pics/ic_launcher.png'),
                      embeddedImageStyle:
                          QrEmbeddedImageStyle(size: Size(80, 80)),
                    ),
                  ),
                ),
              SizedBox(height: 15),
              if (showQR)
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Material(
                    color: Colors.white,
                    elevation: 15,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.share,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.save,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () async {
                              await _capturePng();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              FocusScope.of(context).requestFocus(_focusNode);
                              setState(() {
                                showQR = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        ));
  }

  _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();

      // saving image to device
      PermissionStatus permissionResult =
          await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);
      if (permissionResult == PermissionStatus.authorized) {
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        print('image path: $path');

        await Directory('$path/qr_gen').create(recursive: true);

        File('$path/gr_gen/${DateTime.now().toUtc().toIso8601String()}.png')
            .writeAsBytesSync(pngBytes.buffer.asInt8List());
      }
    } catch (e) {
      print(e);
    }
  }
}
