import 'package:flutter/material.dart';

class ReusedAllPostsCards extends StatelessWidget {
  final Map post;
  final String? currentUserId;
  final VoidCallback onEdit;

  const ReusedAllPostsCards({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onEdit,
  });

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
              title: Text(post['UserName'] ?? 'Unknown User'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['Text'] ?? 'No Text Available'),
                  Text(post['NameEn'] ?? 'Unknown Name'),
                ],
              ),
              trailing: Text(post['RelativeDate'] ?? 'Unknown Date'),
            ),
            if (post['ImageUrl'] != null && post['ImageUrl'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  post['ImageUrl'],
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            if (post['userId'] == currentUserId)
              TextButton(
                onPressed: onEdit,
                child: Text("Edit Post"),
              ),
          ],
        ),
      ),
    );
  }
}
