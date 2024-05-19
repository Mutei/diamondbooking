import 'package:flutter/material.dart';

class ReusedAllPostsCards extends StatelessWidget {
  final Map post;

  const ReusedAllPostsCards({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: post['ProfileImageUrl'] != null
                    ? NetworkImage(post['ProfileImageUrl'])
                    : null,
                child:
                    post['ProfileImageUrl'] == null ? Icon(Icons.person) : null,
              ),
              title: Text(post['NameEn'] ?? 'Unknown Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['Text'] ?? 'No Text Available'),
                  Text(post['UserName'] ?? 'Unknown User'),
                ],
              ),
              trailing: Text(post['RelativeDate'] ?? 'Unknown Date'),
            ),
          ],
        ),
      ),
    );
  }
}
