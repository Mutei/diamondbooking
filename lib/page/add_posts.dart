// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../general_provider.dart';
import '../localization/language_constants.dart';

class AddPost extends StatefulWidget {
  Map map;
  AddPost({required this.map});
  @override
  _State createState() => new _State(map);
}

class _State extends State<AddPost> {
  Map map;
  _State(this.map);

  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();

  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("Post");
  DatabaseReference refAll =
      FirebaseDatabase.instance.ref("App").child("AllPost");

  bool flagImage = true;
  final ImagePicker imgpicker = ImagePicker();
  List<File> image = [];
  late File imageFile;
  TextEditingController _textEditingController = TextEditingController();
  late int IDPost;

  _getFromGallery() async {
    List<XFile> pickedFile = await imgpicker.pickMultiImage();
    if (pickedFile != null) {
      image = [];
      for (int i = 0; i < pickedFile.length; i++) {
        setState(() {
          imageFile = File(pickedFile[i].path);
          image.add(imageFile);
          flagImage = false;
        });
      }
    }
  }

  DatabaseReference starCountRef =
      FirebaseDatabase.instance.ref("App").child("PostID");
  @override
  void initState() {
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;

      IDPost = data['PostID'];
    });
    super.initState();
  }

  Future<UploadTask?> uploadFile(File? file, String id, String Uid) async {
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
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("Post")
          .child('/${map['IDEstate'].toString()}.jpg')
          .child(IDPost.toString());

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path},
      );

      uploadTask = ref.putData(await file.readAsBytes(), metadata);

      return Future.value(uploadTask);
    }
  }

  final storageRef = FirebaseStorage.instance.ref();

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    bool check = false;
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        child: ListView(children: [
          Expanded(
              flex: 1,
              child: Container(
                // ignore: prefer_const_constructors
                child: Container(
                  height: 170,

                  // ignore: prefer_const_constructors
                  child: InkWell(
                      onTap: () async {
                        await _getFromGallery();
                        String? id = FirebaseAuth.instance.currentUser?.uid;
                        UploadTask? task =
                            await uploadFile(image[0], 0.toString(), id!);
                      },
                      child: Container(
                        child: image.length > 0
                            ? SizedBox(
                                width: 60,
                                height: 60,
                                child: Image.file(image[0]),
                              )
                            : Container(
                                child: const Icon(Icons.add),
                              ),
                      )),
                ),
              )),
          TextField(
            controller: _textEditingController,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
                icon: Icon(Icons.post_add),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: getTranslated(context, "Post"),
                hintStyle: const TextStyle(fontSize: 12)
                //fillColor: Colors.green
                ),
          ),
          Container(
            height: 10,
          ),
          Container(
            child: Row(children: [
              Text(
                getTranslated(context, "For All"),
              ),
              Checkbox(
                checkColor: Colors.white,
                value: check,
                onChanged: (bool? value) {
                  setState(() {
                    check = value!;
                  });
                },
              ),
            ]),
          ),
          Container(
            height: 10,
          ),
          InkWell(
            child: Container(
              width: 150.w,
              height: 6.h,
              margin: const EdgeInsets.only(right: 40, left: 40, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF84A5FA),
                borderRadius: BorderRadius.circular(12),
              ),
              // ignore: prefer_const_constructors
              child: Center(child: Text(getTranslated(context, "share"))),
            ),
            onTap: () async {
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              String? id = sharedPreferences.getString("ID");
              String Type = "1";
              if (check) {
                await refAll.child(IDPost.toString()).set({
                  "Date": DateTime.now().toString(),
                  "Text": _textEditingController.text,
                  "Name": sharedPreferences.getString("Name"),
                  "ID": id,
                  "IDEstate": map['IDEstate'].toString(),
                  "NameEn": map['NameEn'].toString(),
                  "NameAr": map['NameAr'].toString(),
                  "IDPost": IDPost.toString(),
                  "Type": "2"
                });
                IDPost = (IDPost + 1);
                starCountRef.update({"PostID": IDPost});
                Navigator.of(context).pop();
              } else {
                await ref
                    .child(map['IDEstate'].toString())
                    .child(IDPost.toString())
                    .set({
                  "Date": DateTime.now().toString(),
                  "Text": _textEditingController.text,
                  "Name": sharedPreferences.getString("Name"),
                  "ID": id,
                  "NameEn": map['NameEn'].toString(),
                  "NameAr": map['NameAr'].toString(),
                  "IDEstate": map['IDEstate'].toString(),
                  "IDPost": IDPost.toString(),
                  "Type": "1"
                });
                IDPost = (IDPost + 1);
                starCountRef.update({"PostID": IDPost});
                Navigator.of(context).pop();
              }
            },
          ),
        ]),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF84A5FA),
      ),
    );
  }
}
