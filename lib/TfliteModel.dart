import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class NewDiagnosis extends StatefulWidget {
  const NewDiagnosis({Key? key}) : super(key: key);

  @override
  _NewDiagnosis createState() => _NewDiagnosis();
}

class _NewDiagnosis extends State<NewDiagnosis> {
  late File _image;
  late List _results;
  bool imageSelect = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }

  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Skin Vision",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF7E4E98), Color(0xFFB93D62)],
                stops: <double>[0.1, 1.0],
                tileMode: TileMode.clamp)),
        child: ListView(
          children: [
            (imageSelect)
                ? Container(
                    margin: const EdgeInsets.all(10),
                    child: Image.file(_image),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    child: const Opacity(
                      opacity: 0.8,
                      child: Center(
                        child: Text(
                          "No Image Selected",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
            SingleChildScrollView(
                child: Column(
              children: (imageSelect)
                  ? _results.map((result) {
                      return Center(
                        child: Card(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: Text(
                              "${result['label']} - ${result['confidence'].toStringAsFixed(2)}" +
                                  "%",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  : [],
            ))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: pickImage,
        tooltip: "Pick Image",
        child: Icon(Icons.image, color: Colors.white),
      ),
    );
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);
    imageClassification(image);
  }
}
