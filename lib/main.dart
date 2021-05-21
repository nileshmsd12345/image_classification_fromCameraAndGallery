import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> imageFile;
  File _image;
  String result = '';
  ImagePicker imagePicker;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    loadModelFiles();
  }

  Future speak() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(0.9);
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.speak(result);
  }

  //TODO load model files
  loadModelFiles() async {
    String res = await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  //run inference and show results
  doImageClassification() async {
    var recognitions = await Tflite.runModelOnImage(
        path: _image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 5, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
    if (recognitions != null) {
      recognitions.forEach((element) {
        result += element["label"] +
            " and it's probability: " +
            (element["confidence"] as double).toStringAsFixed(2) +
            "\n";
      });
      setState(() {
        // ignore: unnecessary_statements
        result;
      });
      print(result);
      speak();
    }
  }

  _imgFromCamera() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    _image = File(pickedFile.path);
    setState(() {
      // ignore: unnecessary_statements
      _image;
      doImageClassification();
    });
  }

  _imgFromGallery() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    _image = File(pickedFile.path);
    setState(() {
      // ignore: unnecessary_statements
      _image;
      doImageClassification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/img2.jpg'), fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 100,
              ),
              Container(
                margin: EdgeInsets.only(top: 100),
                child: Stack(children: <Widget>[
                  Stack(children: <Widget>[
                    Center(
                      child: Image.asset(
                        'images/frame3.png',
                        height: 210,
                        width: 200,
                      ),
                    ),
                  ]),
                  Center(
                    child: FlatButton(
                      onPressed: _imgFromGallery,
                      onLongPress: _imgFromCamera,
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        child: _image != null
                            ? Image.file(
                                _image,
                                width: 133,
                                height: 198,
                                fit: BoxFit.fill,
                              )
                            : Container(
                                width: 140,
                                height: 190,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[800],
                                ),
                              ),
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  '$result',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'finger_paint', fontSize: 36),
                ),
              ),
            ],
          ),
        )));
  }
}
