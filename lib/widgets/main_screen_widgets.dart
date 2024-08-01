import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/cardEstate.dart';

class CustomWidgets {
  static Widget buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Text(
        getTranslated(context, title),
        style: TextStyle(fontSize: 24, color: kPrimaryColor),
      ),
    );
  }

  static Widget buildFirebaseAnimatedListWithRatings(
    Query query,
    String icon,
    Future<String> Function(String key) getImageUrl,
    Future<Map<String, dynamic>> Function(String) getRatings,
    String selectedFilter,
    String searchQuery,
    List<Map> Function(List<Map>) sortEstates, // Add sortEstates as a parameter
  ) {
    return StreamBuilder<DatabaseEvent>(
      stream: query.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Map> estates = [];
          DataSnapshot dataValues = snapshot.data!.snapshot;

          if (dataValues.value != null) {
            var data = dataValues.value;

            if (data is Map) {
              data.forEach((key, value) {
                Map estate = value as Map;
                estate['Key'] = key;
                estates.add(estate);
              });
            } else if (data is List) {
              for (int i = 0; i < data.length; i++) {
                if (data[i] != null) {
                  Map estate = data[i] as Map;
                  estate['Key'] = i.toString();
                  estates.add(estate);
                }
              }
            }

            if (searchQuery.isNotEmpty) {
              estates = estates
                  .where((estate) => estate['NameEn']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();
            }

            estates = sortEstates(estates);
          }

          if (estates.isEmpty) {
            return Center(child: Text('No estates available'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: estates.length,
            itemBuilder: (context, index) {
              Map estate = estates[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: getRatings(estate['Key']),
                builder: (context, ratingsSnapshot) {
                  if (ratingsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (ratingsSnapshot.hasError) {
                    return Text('Error: ${ratingsSnapshot.error}');
                  } else {
                    Map<String, dynamic> ratingsData = ratingsSnapshot.data!;
                    double totalRating = ratingsData['totalRating'];
                    int ratingCount = ratingsData['ratingCount'];
                    return FutureBuilder<String>(
                      future: getImageUrl(estate['Key']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          String imageUrl = snapshot.data ??
                              'assets/images/default_image.png';
                          return CardEstate(
                            context: context,
                            obj: estate,
                            icon: icon,
                            VisEdit: false,
                            image: imageUrl,
                            Visimage: true,
                            ratings: ratingCount,
                            totalRating: totalRating,
                          );
                        }
                      },
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}

// import 'package:diamond_booking/constants/colors.dart';
// import 'package:diamond_booking/localization/language_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import '../widgets/cardEstate.dart';
//
// class CustomWidgets {
//   static Widget buildSectionTitle(BuildContext context, String title) {
//     return Container(
//       margin: const EdgeInsets.only(top: 20),
//       child: Text(
//         getTranslated(context, title),
//         style: TextStyle(fontSize: 24, color: kPrimaryColor),
//       ),
//     );
//   }
//
//   static Widget buildFirebaseAnimatedListWithRatings(
//       Query query,
//       String icon,
//       Future<String> Function(String key) getImageUrl,
//       Future<Map<String, dynamic>> Function(String) getRatings,
//       String selectedFilter,
//       String searchQuery // Add this line
//       ) {
//     return FirebaseAnimatedList(
//       scrollDirection: Axis.horizontal, // Always scroll horizontally
//       itemBuilder: (context, snapshot, animation, index) {
//         Map map = snapshot.value as Map;
//         map['Key'] = snapshot.key;
//
//         if (searchQuery.isNotEmpty &&
//             !map['NameEn']
//                 .toString()
//                 .toLowerCase()
//                 .contains(searchQuery.toLowerCase())) {
//           // Add this line
//           return Container(); // Add this line
//         } // Add this line
//
//         return FutureBuilder<Map<String, dynamic>>(
//           future: getRatings(map['Key']),
//           builder: (context, ratingsSnapshot) {
//             if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (ratingsSnapshot.hasError) {
//               return Text('Error: ${ratingsSnapshot.error}');
//             } else {
//               Map<String, dynamic> ratingsData = ratingsSnapshot.data!;
//               double totalRating = ratingsData['totalRating'];
//               int ratingCount = ratingsData['ratingCount'];
//               return FutureBuilder<String>(
//                 future: getImageUrl(map['Key']),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else {
//                     String imageUrl =
//                         snapshot.data ?? 'assets/images/default_image.png';
//                     return CardEstate(
//                       context: context,
//                       obj: map,
//                       icon: icon,
//                       VisEdit: false,
//                       image: imageUrl,
//                       Visimage: true,
//                       ratings: ratingCount,
//                       totalRating: totalRating,
//                     );
//                   }
//                 },
//               );
//             }
//           },
//         );
//       },
//       query: query,
//     );
//   }
// }
