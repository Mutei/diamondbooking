// lib/screens/all_posts_screen.dart

import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/constants/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/reused_all_posts_cards.dart';
import 'add_posts_screen.dart';

class AllPostsScreen extends StatefulWidget {
  const AllPostsScreen({super.key});

  @override
  State<AllPostsScreen> createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  final DatabaseReference _postsRef =
      FirebaseDatabase.instance.ref("App").child("AllPosts");
  final DatabaseReference _hotelRef =
      FirebaseDatabase.instance.ref("App").child("Estate").child("Hottel");
  final DatabaseReference _coffeeRef =
      FirebaseDatabase.instance.ref("App").child("Estate").child("Coffee");
  final DatabaseReference _restaurantRef =
      FirebaseDatabase.instance.ref("App").child("Estate").child("Restaurant");

  String userType = "2";
  String? currentUserId;
  List<Map<dynamic, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _loadUserType();
    _loadCurrentUser();
  }

  void _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString("TypeUser") ?? "2";
      print("Loaded User Type: $userType");
    });
  }

  void _loadCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid;
    });
  }

  Future<void> _fetchPosts() async {
    try {
      DatabaseEvent event = await _postsRef.once();
      Map<dynamic, dynamic>? postsData =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (postsData != null) {
        List<Map<dynamic, dynamic>> postsList = [];
        postsData.forEach((key, value) {
          value['postId'] = key;
          if (value['Date'] != null && value['Date'] is int) {
            int timestamp = value['Date'];
            DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            String relativeDate = timeago.format(date, allowFromNow: true);
            value['RelativeDate'] = relativeDate;
          } else {
            value['RelativeDate'] = 'Invalid Date';
          }
          postsList.add(value);
        });

        setState(() {
          _posts = postsList;
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  void _confirmDeletePost(String postId) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deletePost(postId);
    }
  }

  void _deletePost(String postId) async {
    try {
      await _postsRef.child(postId).remove();
      setState(() {
        _posts.removeWhere((post) => post['postId'] == postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  // Future<String> _getImages(String key) async {
  //   // Implement your image fetching logic here
  //   return 'assets/images/default_image.png';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: userType == '2'
          ? AppBar(
              iconTheme: kIconTheme,
              centerTitle: true,
              title: const Text(
                "All Posts",
                style: TextStyle(
                  color: kPrimaryColor,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: kPrimaryColor,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPostScreen()),
                    );
                    _fetchPosts();
                  },
                ),
              ],
            )
          : AppBar(
              iconTheme: kIconTheme,
              centerTitle: true,
              title: Text("All Posts"),
            ),
      body: _posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Container(height: 20),
                // CustomWidgets.buildSectionTitle(context, 'Hotel'),
                // CustomWidgets.buildFirebaseAnimatedList(
                //     _hotelRef, 'assets/images/hotel.png', _getImages),
                // Divider(),
                // CustomWidgets.buildSectionTitle(context, 'Coffee'),
                // CustomWidgets.buildFirebaseAnimatedList(
                //     _coffeeRef, 'assets/images/coffee.png', _getImages),
                // Divider(),
                // CustomWidgets.buildSectionTitle(context, 'Restaurant'),
                // CustomWidgets.buildFirebaseAnimatedList(
                //     _restaurantRef, 'assets/images/restaurant.png', _getImages),
                // Divider(),
                _buildPostsList(),
              ],
            ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        Map<dynamic, dynamic> post = _posts[index];
        return ReusedAllPostsCards(
          post: post,
          currentUserId: currentUserId,
          onDelete: () => _confirmDeletePost(post['postId']),
        );
      },
    );
  }
}

// class AllPost extends StatefulWidget {
//   const AllPost({super.key});
//
//   @override
//   State<AllPost> createState() => _AllPostState();
// }
//
// class _AllPostState extends State<AllPost> {
//   final storageRef = FirebaseStorage.instance.ref();
//
//   final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: kPrimaryColor,
//         actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
//       ),
//       body: Container(
//         child: FirebaseAnimatedList(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             defaultChild: const Center(
//               child: CircularProgressIndicator(),
//             ),
//             itemBuilder: (context, snapshot, animation, index) {
//               Map map = snapshot.value as Map;
//
//               return Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: Column(
//                   children: [
//                     ListTile(
//                       title: Text(map["NameEn"] ?? ""),
//                       subtitle: Text(map["Text"]),
//                       trailing: Text(map["Date"]),
//                     ),
//                     FutureBuilder<String>(
//                       future: getimages(map["IDEstate"], map["IDPost"]),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData &&
//                             snapshot.connectionState == ConnectionState.done) {
//                           return Container(
//                             width: MediaQuery.of(context).size.width,
//                             child: snapshot.data != ""
//                                 ? Image(
//                                     image: NetworkImage(snapshot.data!),
//                                     fit: BoxFit.cover)
//                                 : Container(),
//                           );
//                         }
//
//                         // ignore: prefer_const_constructors
//                         return Center(
//                           child: const CircularProgressIndicator(),
//                         );
//                       },
//                     )
//                   ],
//                 ),
//               );
//             },
//             query: FirebaseDatabase.instance.ref("App").child("AllPost")),
//       ),
//     );
//   }
//
//   Future<String> getimages(String EID, String id) async {
//     try {
//       String imageUrl;
//       imageUrl = await storageRef
//           .child("Post")
//           .child(EID + ".jpg")
//           .child(id)
//           .getDownloadURL()
//           .onError((error, stackTrace) => '')
//           .then((value) => value);
//       print(imageUrl.toString());
//       return imageUrl.toString();
//     } catch (e) {
//       return "";
//     }
//   }
// }
//
// class YourObject {
//   final DateTime date;
//   final String text;
//   final String name;
//   final String id;
//   final String idEstate;
//   final String idPost;
//   final String type;
//
//   YourObject({
//     required this.date,
//     required this.text,
//     required this.name,
//     required this.id,
//     required this.idEstate,
//     required this.idPost,
//     required this.type,
//   });
//
//   static List<YourObject> parseObjectToObjects(Object object) {
//     if (object is Map<String, dynamic>) {
//       return [
//         YourObject(
//           date: DateTime.parse(object['Date']),
//           text: object['Text'],
//           name: object['Name'],
//           id: object['ID'],
//           idEstate: object['IDEstate'],
//           idPost: object['IDPost'],
//           type: object['Type'],
//         )
//       ];
//     } else {
//       throw Exception("Invalid object format.");
//     }
//   }
// }
