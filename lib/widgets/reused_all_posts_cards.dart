import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReusedAllPostsCards extends StatefulWidget {
  final Map post;
  final String? currentUserId;
  final String? currentUserTypeAccount;
  final VoidCallback onDelete;

  const ReusedAllPostsCards({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.currentUserTypeAccount,
    required this.onDelete,
  });

  @override
  _ReusedAllPostsCardsState createState() => _ReusedAllPostsCardsState();
}

class _ReusedAllPostsCardsState extends State<ReusedAllPostsCards> {
  late PageController _pageController;
  int _currentPage = 0;
  VideoPlayerController? _videoController;
  bool _isMuted = false;
  bool _showControls = true;
  double _dragStart = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    if (widget.post['VideoUrls'] != null &&
        widget.post['VideoUrls'].isNotEmpty) {
      _videoController =
          VideoPlayerController.network(widget.post['VideoUrls'][0])
            ..initialize().then((_) {
              setState(() {});
              _videoController?.setLooping(true);
            });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController?.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _rewind() {
    final currentPosition = _videoController?.value.position ?? Duration.zero;
    _videoController?.seekTo(currentPosition - Duration(seconds: 10));
  }

  void _forward() {
    final currentPosition = _videoController?.value.position ?? Duration.zero;
    final duration = _videoController?.value.duration ?? Duration.zero;
    _videoController?.seekTo(currentPosition + Duration(seconds: 10));
    if (currentPosition + Duration(seconds: 10) > duration) {
      _videoController?.seekTo(duration);
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _dragStart = 0.0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final dragEnd = details.globalPosition.dx;
    final dragDistance = dragEnd - _dragStart;

    if (dragDistance.abs() > 10) {
      final currentPosition = _videoController?.value.position ?? Duration.zero;
      final seekDuration = Duration(seconds: dragDistance ~/ 10);

      _videoController?.seekTo(currentPosition + seekDuration);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    List imageUrls = widget.post['ImageUrls'] ?? [];
    List videoUrls = widget.post['VideoUrls'] ?? [];
    String displayName = widget.post['userType'] == '1' &&
            (widget.post['typeAccount'] == '2' ||
                widget.post['typeAccount'] == '3')
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
                        as ImageProvider<Object>?
                    : AssetImage('assets/images/default_profile.png')
                        as ImageProvider<Object>?,
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
            if (imageUrls.isNotEmpty || videoUrls.isNotEmpty)
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleControls,
                    onHorizontalDragStart: _onHorizontalDragStart,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    child: Container(
                      height: 550, // Fixed height for images and videos
                      width: double.infinity, // Ensure full width
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length + videoUrls.length,
                        itemBuilder: (context, index) {
                          if (index < imageUrls.length) {
                            return Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity, // Full width for images
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                            );
                          } else {
                            return _videoController != null &&
                                    _videoController!.value.isInitialized
                                ? AspectRatio(
                                    aspectRatio: 16 / 9, // Fixed aspect ratio
                                    child: VideoPlayer(_videoController!),
                                  )
                                : Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                  if (_showControls &&
                      _videoController != null &&
                      _videoController!.value.isInitialized)
                    Positioned.fill(
                      child: Container(
                        color: Colors
                            .black38, // Add a slight transparency background
                        child: _buildVideoControls(),
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
                        '${_currentPage + 1}/${imageUrls.length + videoUrls.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.post['userId'] == widget.currentUserId &&
                (widget.currentUserTypeAccount == '2' ||
                    widget.currentUserTypeAccount == '3'))
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

  Widget _buildVideoControls() {
    return Stack(
      children: [
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.replay_10, color: Colors.white),
                    onPressed: _rewind,
                  ),
                  IconButton(
                    icon: Icon(Icons.forward_10, color: Colors.white),
                    onPressed: _forward,
                  ),
                  IconButton(
                    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white),
                    onPressed: _toggleMute,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
