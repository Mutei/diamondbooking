// lib/widgets/custom_widgets.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import '../widgets/cardEstate.dart';

class CustomWidgets {
  static Widget buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  static Widget buildFirebaseAnimatedList(Query query, String icon,
      Future<String> Function(String key) getImageUrl) {
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
