import 'dart:io';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPostScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? post;

  const AddPostScreen({super.key, this.post});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  String _postId = '';
  List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  String? _selectedEstate;
  List<Map<dynamic, dynamic>> _userEstates = [];
  String userType = "2";

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _postId = widget.post!['postId'];
      _titleController.text = widget.post!['Description'];
      _textController.text = widget.post!['Text'];
    }
    _fetchUserEstates();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString("TypeUser") ?? "2";
      print("Loaded User Type: $userType");
    });
  }

  Future<void> _fetchUserEstates() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }
    String userId = user.uid;

    DatabaseReference estateRef =
        FirebaseDatabase.instance.ref("App").child("Estate");
    DatabaseEvent estateEvent = await estateRef.once();
    Map<dynamic, dynamic>? estatesData =
        estateEvent.snapshot.value as Map<dynamic, dynamic>?;

    if (estatesData != null) {
      List<Map<dynamic, dynamic>> userEstates = [];
      estatesData.forEach((estateType, estates) {
        estates.forEach((key, value) {
          if (value['IDUser'] == userId) {
            userEstates.add({'type': estateType, 'data': value});
          }
        });
      });
      setState(() {
        _userEstates = userEstates;
      });
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate() &&
        (_selectedEstate != null || userType != "2")) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('User not authenticated');
          return;
        }
        String userId = user.uid;

        Map<dynamic, dynamic> selectedEstate = _selectedEstate != null
            ? _userEstates.firstWhere(
                (estate) => estate['type'] == _selectedEstate,
                orElse: () => {},
              )
            : {};

        if (_selectedEstate != null && selectedEstate.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("You don't have an estate of type $_selectedEstate")),
          );
          return;
        }

        DatabaseReference postsRef =
            FirebaseDatabase.instance.ref("App").child("AllPosts");

        if (_postId.isEmpty) {
          _postId = postsRef.push().key!;
        }

        List<String> imageUrls = [];
        for (File imageFile in _imageFiles) {
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child('post_images')
              .child('$_postId${imageFile.path.split('/').last}')
              .putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;
          String imageUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }

        await postsRef.child(_postId).set({
          'Description': _titleController.text,
          'Text': _textController.text,
          'Date': DateTime.now().millisecondsSinceEpoch,
          'EstateName':
              userType == "2" ? selectedEstate['data']['NameEn'] : null,
          'EstateType': _selectedEstate,
          'userId': userId,
          'ImageUrls': imageUrls,
        });

        print('Post saved successfully');
        Navigator.pop(context);
      } catch (e) {
        print('Error saving post: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: kIconTheme,
        centerTitle: true,
        title: Text(
          widget.post == null ? "Add Post" : "Edit Post",
          style: const TextStyle(
            color: kPrimaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (userType == "2")
                  DropdownButtonFormField<String>(
                    value: _selectedEstate,
                    hint: Text("Select Estate"),
                    items: _userEstates.map((estate) {
                      return DropdownMenuItem<String>(
                        value: estate['type'],
                        child: Text(estate['data']['NameEn']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEstate = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an estate';
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Title"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _textController,
                  decoration: InputDecoration(labelText: "Text"),
                ),
                SizedBox(height: 20),
                _imageFiles.isEmpty
                    ? Text("No images selected.")
                    : Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageFiles.length,
                          itemBuilder: (context, index) {
                            return Image.file(_imageFiles[index]);
                          },
                        ),
                      ),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: Text("Pick Images"),
                ),
                ElevatedButton(
                  onPressed: _savePost,
                  child: Text(widget.post == null ? "Save" : "Update"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
