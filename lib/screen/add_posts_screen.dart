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
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _postId = widget.post!['postId'];
      _titleController.text = widget.post!['NameEn'];
      _textController.text = widget.post!['Text'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('User not authenticated');
          return;
        }
        String userId = user.uid;

        DatabaseReference userRef =
            FirebaseDatabase.instance.ref("App").child("User").child(userId);
        DatabaseEvent userEvent = await userRef.once();
        Map<dynamic, dynamic>? userData =
            userEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (userData == null) {
          print('User data not found for user ID: $userId');
          return;
        }

        String userName = "${userData['FirstName']} ${userData['LastName']}";
        String profileImageUrl = userData['ProfileImageUrl'] ?? '';

        DatabaseReference postsRef =
            FirebaseDatabase.instance.ref("App").child("AllPosts");

        if (_postId.isEmpty) {
          _postId = postsRef.push().key!;
        }

        String? imageUrl;
        if (_imageFile != null) {
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child('post_images')
              .child('$_postId.jpg')
              .putFile(_imageFile!);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        await postsRef.child(_postId).set({
          'NameEn': _titleController.text,
          'Text': _textController.text,
          'Date': DateTime.now().millisecondsSinceEpoch,
          'UserName': userName,
          'ProfileImageUrl': profileImageUrl,
          'userId': userId,
          'ImageUrl': imageUrl ?? '',
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter text';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _imageFile == null
                  ? Text("No image selected.")
                  : Image.file(_imageFile!),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick Image"),
              ),
              ElevatedButton(
                onPressed: _savePost,
                child: Text(widget.post == null ? "Save" : "Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
