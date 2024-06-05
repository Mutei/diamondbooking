import 'dart:typed_data';
import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:diamond_booking/extension/sized_box_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constants/utils.dart';
import '../localization/language_constants.dart';
import '../widgets/profile_text_form_field.dart';
import 'edit_profile_screen.dart';

class ProfileScreenUser extends StatefulWidget {
  const ProfileScreenUser({super.key});

  @override
  State<ProfileScreenUser> createState() => _ProfileScreenUserState();
}

class _ProfileScreenUserState extends State<ProfileScreenUser> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  final databaseRef =
      FirebaseDatabase.instance.ref().child('App').child('User');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterLayoutWidgetBuild());
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _secondNameController.dispose();
    _lastNameController.dispose();
  }

  Future<String> uploadImageToStorage(Uint8List image, String userId) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');
      UploadTask uploadTask = storageRef.putData(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e.toString());
      return '';
    }
  }

  Future<void> saveImageUrlToDatabase(String userId, String imageUrl) async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('App')
        .child('User')
        .child(userId);
    await userRef.update({'ProfileImageUrl': imageUrl});
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      String imageUrl = await uploadImageToStorage(im, userId);
      if (imageUrl.isNotEmpty) {
        await saveImageUrlToDatabase(userId, imageUrl);
        await _updateProfilePicture(
            userId, imageUrl); // Added to update profile picture in posts
      }
    }
  }

  Future<void> _updateProfilePicture(
      String userId, String newProfileImageUrl) async {
    try {
      // Update the profile picture URL in all posts made by this user
      await _updateProfilePictureInPosts(userId, newProfileImageUrl);
      print('Profile picture updated successfully');
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> _updateProfilePictureInPosts(
      String userId, String newProfileImageUrl) async {
    try {
      DatabaseReference postsRef =
          FirebaseDatabase.instance.ref("App").child("AllPosts");
      DatabaseEvent event = await postsRef.once();
      Map<dynamic, dynamic>? postsData =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (postsData != null) {
        for (var key in postsData.keys) {
          if (postsData[key]['userId'] == userId) {
            await postsRef.child(key).update({
              'ProfileImageUrl': newProfileImageUrl,
            });
          }
        }
        print('Profile picture updated in all posts');
      }
    } catch (e) {
      print('Error updating profile picture in posts: $e');
    }
  }

  void afterLayoutWidgetBuild() async {
    String? id = FirebaseAuth.instance.currentUser?.uid;
    if (id != null) {
      setState(() {
        _isLoading = true;
      });
      databaseRef.child(id).once().then((DatabaseEvent event) {
        if (event.snapshot.exists) {
          final Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _firstNameController.text = data['FirstName'] ?? '';
            _secondNameController.text = data['SecondName'] ?? '';
            _lastNameController.text = data['LastName'] ?? '';
            _emailController.text = data['Email'] ?? '';
            _phoneController.text = data['PhoneNumber'] ?? '';
            _countryController.text = data['Country'] ?? '';
            _cityController.text = data['City'] ?? '';
            if (data['ProfileImageUrl'] != null &&
                data['ProfileImageUrl'].isNotEmpty) {
              loadImageFromUrl(data['ProfileImageUrl']);
            } else {
              _isLoading = false;
            }
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void loadImageFromUrl(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _image = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getTranslated(context, 'Profile'),
          style: const TextStyle(
            color: kPrimaryColor,
          ),
        ),
        iconTheme: kIconTheme,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: _image != null
                          ? MemoryImage(_image!)
                          : const AssetImage('assets/images/man.png')
                              as ImageProvider,
                      backgroundColor: Colors.transparent,
                      child:
                          _isLoading ? const CircularProgressIndicator() : null,
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                16.kH,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          firstName: _firstNameController.text,
                          secondName: _secondNameController.text,
                          lastName: _lastNameController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                          country: _countryController.text,
                          city: _cityController.text,
                        ),
                      ),
                    );

                    if (result == true) {
                      afterLayoutWidgetBuild();
                    }
                  },
                  child: Text(
                    getTranslated(
                      context,
                      "Edit Profile",
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                32.kH,
                ProfileInfoTextField(
                  textEditingController: _firstNameController,
                  textInputType: TextInputType.text,
                  iconData: Icons.person,
                  iconColor: kPrimaryColor,
                ),
                24.kH,
                ProfileInfoTextField(
                  textEditingController: _secondNameController,
                  textInputType: TextInputType.text,
                  iconData: Icons.person,
                  iconColor: kPrimaryColor,
                ),
                24.kH,
                ProfileInfoTextField(
                  textEditingController: _lastNameController,
                  textInputType: TextInputType.text,
                  iconData: Icons.person,
                  iconColor: kPrimaryColor,
                ),
                24.kH,
                ProfileInfoTextField(
                  textEditingController: _emailController,
                  textInputType: TextInputType.text,
                  iconData: Icons.email,
                  iconColor: kPrimaryColor,
                ),
                24.kH,
                ProfileInfoTextField(
                  textEditingController: _phoneController,
                  textInputType: TextInputType.text,
                  iconData: Icons.phone,
                  iconColor: kPrimaryColor,
                ),
                24.kH,
                ProfileInfoTextField(
                  textEditingController: _countryController,
                  textInputType: TextInputType.text,
                  iconData: Icons.location_city,
                  iconColor: kPrimaryColor,
                ),
                24.kH,
                ProfileInfoTextField(
                  textEditingController: _cityController,
                  textInputType: TextInputType.text,
                  iconData: Icons.location_city,
                  iconColor: kPrimaryColor,
                ),
                24.kH,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
