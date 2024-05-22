import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/cardEstate.dart';
import '../widgets/reused_all_posts_cards.dart';
import 'add_posts_screen.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

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
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPostScreen(post: post),
              ),
            );
            _fetchPosts();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: userType == '2'
          ? AppBar(
              title: Text("All Posts"),
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPostScreen()),
                    );
                    _fetchPosts();
                  },
                ),
              ],
            )
          : AppBar(
              title: Text("All Posts"),
            ),
      body: _posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Container(height: 20),
                _buildSectionTitle(context, 'Hotel'),
                _buildFirebaseAnimatedList(
                    _hotelRef, 'assets/images/hotel.png'),
                Divider(),
                _buildSectionTitle(context, 'Coffee'),
                _buildFirebaseAnimatedList(
                    _coffeeRef, 'assets/images/coffee.png'),
                Divider(),
                _buildSectionTitle(context, 'Restaurant'),
                _buildFirebaseAnimatedList(
                    _restaurantRef, 'assets/images/restaurant.png'),
                Divider(),
                _buildPostsList(),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  Widget _buildFirebaseAnimatedList(Query query, String icon) {
    return Container(
      height: 200,
      child: FirebaseAnimatedList(
        shrinkWrap: true,
        defaultChild: const Center(child: CircularProgressIndicator()),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, snapshot, animation, index) {
          Map map = snapshot.value as Map;
          map['Key'] = snapshot.key;
          return FutureBuilder<String>(
            future: _getImages(map['Key']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                String imageUrl =
                    snapshot.data ?? 'assets/images/default_image.png';
                return CardEstate(
                  context: context,
                  obj: map,
                  icon: icon,
                  VisEdit: false,
                  image: imageUrl,
                  Visimage: true,
                );
              }
            },
          );
        },
        query: query,
      ),
    );
  }

  Future<String> _getImages(String key) async {
    // Implement your image fetching logic here
    return 'assets/images/default_image.png';
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
