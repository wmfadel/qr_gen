import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  static final String routeName = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dataController = TextEditingController();
  GlobalKey _globalKey = new GlobalKey();
  var imageBytes;
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
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) {
                    // close the keyboard
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      showQR = true;
                    });
                  },
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
                            onPressed: () async {
                              var imagePath = await _capturePng();
                              await Share.file(
                                  'Qr-Gen', imagePath, imageBytes, 'image/png',
                                  text: 'My Qr Code.');
                            },
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
                              _dataController.text = '';
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
      print('getting permissions');
      // saving image to device
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);

      if (permission == PermissionStatus.disabled ||
          permission == PermissionStatus.restricted ||
          permission == PermissionStatus.unknown ||
          permission == PermissionStatus.denied) {
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

        await PermissionHandler()
            .checkPermissionStatus(PermissionGroup.storage);
      }

      Directory directory = await getExternalStorageDirectory();
      String path = directory.path;
      print('image path: $path');

      await Directory('$path/qr_gen').create(recursive: true);

      imageBytes = pngBytes.buffer.asInt8List();
      String imagePath = '$path/gr_gen-${_dataController.text}.png';
      File(imagePath)..writeAsBytesSync(imageBytes, mode: FileMode.write);

      return imagePath;
    } catch (e) {
      print(e);
    }
  }
}
