// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../screen/main_screen.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  @override
  String IDEstate;

  AddImage({required this.IDEstate});
  _State createState() => new _State(IDEstate);
}

class _State extends State<AddImage> {
  final storageRef = FirebaseStorage.instance.ref();

  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  @override
  String IDEstate;
  _State(this.IDEstate);

  void initState() {
    final storageRef = FirebaseStorage.instance.ref();

    super.initState();
  }

  List<UploadTask> _uploadTasks = [];

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> uploadFile(File? file, String id) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file was selected'),
        ),
      );

      return null;
    } else {
      UploadTask uploadTask;

      // Create a Reference to the file
      Reference ref =
          FirebaseStorage.instance.ref().child(IDEstate).child('/${id}.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path},
      );

      uploadTask = ref.putData(await file.readAsBytes(), metadata);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add Succsuss'),
        ),
      );

      return Future.value(uploadTask);
    }
  }

  final ImagePicker imgpicker = ImagePicker();
  List<File> image = [];
  late File imageFile;

  _getFromGallery() async {
    List<XFile> pickedFile = await imgpicker.pickMultiImage();
    if (pickedFile != null) {
      for (int i = 0; i < pickedFile.length; i++) {
        setState(() {
          imageFile = File(pickedFile[i].path);
          image.add(imageFile);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    return Scaffold(
        key: _scaffoldKey1,
        appBar: AppBar(
          backgroundColor: Color(0xFF84A5FA),
          actions: [
            Container(
              // ignore: sort_child_properties_last
              child: InkWell(
                // ignore: prefer_const_constructors
                child: Icon(
                  Icons.add,
                ),
                onTap: () {
                  _getFromGallery();
                },
              ),
              margin: const EdgeInsets.all(5),
            )
          ],
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // ignore: prefer_const_constructors

            child: Stack(
              children: [
                // ignore: sort_child_properties_last
                Container(
                  // ignore: sort_child_properties_last
                  child: ListView(
                    children: [
                      // ignore: prefer_const_constructors
                      Container(
                        height: 100,
                        margin:
                            const EdgeInsets.only(top: 30, left: 15, right: 15),
                        child: Text(
                          getTranslated(context, "Add Image"),
                          // ignore: prefer_const_constructors
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40.0),
                              bottomRight: Radius.circular(40.0),
                              topLeft: Radius.circular(40.0),
                              bottomLeft: Radius.circular(40.0)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                          ),
                          // ignore: sort_child_properties_last
                          child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      childAspectRatio: 2 / 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 20),
                              itemCount: image.length,
                              itemBuilder: (BuildContext ctx, index) {
                                return Container(
                                  margin: const EdgeInsets.all(20),
                                  child: Wrap(
                                    children: [
                                      Image.file(
                                        image[index],
                                        fit: BoxFit.cover,
                                      )
                                    ],
                                  ),
                                );
                              }),
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                    ],
                  ),
                  margin:
                      const EdgeInsets.only(bottom: 30, left: 15, right: 15),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Container(
                      width: 150.w,
                      height: 6.h,
                      margin: const EdgeInsets.only(
                          right: 40, left: 40, bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF84A5FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // ignore: prefer_const_constructors
                      child: Center(
                        child: Text(getTranslated(context, "Save")),
                      ),
                    ),
                    onTap: () async {
                      for (int i = 0; i < image.length; i++) {
                        UploadTask? task =
                            await uploadFile(image[i], i.toString());
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MainScreen()));
                    },
                  ),
                ),
              ],
            )));
  }
}
