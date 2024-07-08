import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
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
      String selectedFilter) {
    bool isVertical = selectedFilter != 'All';

    return Container(
      height: isVertical ? null : 200, // Adjust height for vertical layout
      child: FirebaseAnimatedList(
        shrinkWrap: isVertical,
        defaultChild: const Center(child: CircularProgressIndicator()),
        scrollDirection: isVertical
            ? Axis.vertical
            : Axis.horizontal, // Adjust scroll direction
        itemBuilder: (context, snapshot, animation, index) {
          Map map = snapshot.value as Map;
          map['Key'] = snapshot.key;
          return FutureBuilder<Map<String, dynamic>>(
            future: getRatings(map['Key']),
            builder: (context, ratingsSnapshot) {
              if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (ratingsSnapshot.hasError) {
                return Text('Error: ${ratingsSnapshot.error}');
              } else {
                Map<String, dynamic> ratingsData = ratingsSnapshot.data!;
                double totalRating = ratingsData['totalRating'];
                int ratingCount = ratingsData['ratingCount'];
                return FutureBuilder<String>(
                  future: getImageUrl(map['Key']),
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
        query: query,
      ),
    );
  }
}
