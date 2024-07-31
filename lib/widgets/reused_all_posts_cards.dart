import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';

class ReusedAllPostsCards extends StatefulWidget {
  final Map post;
  final String? currentUserId;
  final String? currentUserTypeAccount; // Add this line
  final VoidCallback onDelete;

  const ReusedAllPostsCards({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.currentUserTypeAccount, // Add this line
    required this.onDelete,
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
    String displayName = widget.post['userType'] == '1' &&
            (widget.post['typeAccount'] == '3' ||
                widget.post['typeAccount'] == '4')
        ? widget.post['UserName'] ?? 'Unknown User'
        : widget.post['EstateName'] ?? 'Unknown User';

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
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(displayName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${imageUrls.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.post['userId'] == widget.currentUserId &&
                (widget.currentUserTypeAccount == '3' ||
                    widget.currentUserTypeAccount == '4'))
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onDelete,
                    child: Text(getTranslated(context, "Delete Post")),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
