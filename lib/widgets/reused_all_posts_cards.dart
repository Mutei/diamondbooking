import 'package:flutter/material.dart';

class ReusedAllPostsCards extends StatefulWidget {
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
  _ReusedAllPostsCardsState createState() => _ReusedAllPostsCardsState();
}

class _ReusedAllPostsCardsState extends State<ReusedAllPostsCards> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List imageUrls = widget.post['ImageUrls'] ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: widget.post['ProfileImageUrl'] != null
                    ? NetworkImage(widget.post['ProfileImageUrl'])
                    : null,
                child: widget.post['ProfileImageUrl'] == null
                    ? Icon(Icons.person)
                    : null,
              ),
              title: Text(widget.post['EstateName'] ?? 'Unknown User'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post['Text'] ?? 'Text is Empty'),
                  Text(widget.post['Description'] ?? 'Description is Empty'),
                ],
              ),
              trailing: Text(widget.post['RelativeDate'] ?? 'Unknown Date'),
            ),
            if (imageUrls.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 300, // Adjust the height as needed
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${imageUrls.length}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.post['userId'] == widget.currentUserId)
              TextButton(
                onPressed: widget.onEdit,
                child: Text("Edit Post"),
              ),
          ],
        ),
      ),
    );
  }
}
