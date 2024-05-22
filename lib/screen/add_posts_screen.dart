import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _postId = widget.post!['postId'];
      _titleController.text = widget.post!['Description'];
      _textController.text = widget.post!['Text'];
    }
    _fetchUserEstates();
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
    if (_formKey.currentState!.validate() && _selectedEstate != null) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('User not authenticated');
          return;
        }
        String userId = user.uid;

        Map<dynamic, dynamic> selectedEstate = _userEstates.firstWhere(
          (estate) => estate['type'] == _selectedEstate,
          orElse: () => {},
        );

        if (selectedEstate.isEmpty) {
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
          'EstateName': selectedEstate['data']['NameEn'],
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
        title: Text(widget.post == null ? "Add Post" : "Edit Post"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
