import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InstagramPost extends StatefulWidget {
  const InstagramPost({
    Key? key,
    required this.username,
    required this.caption,
    required this.likes,
    required this.loc,
    required this.videoPath,
    required this.comments,
  }) : super(key: key);

  final String username;
  final String caption;
  final int likes;
  final String loc;
  final String videoPath;
  final int comments;

  @override
  State<InstagramPost> createState() => _InstagramPostState();
}

class _InstagramPostState extends State<InstagramPost> {
  bool isPlaying = true;
  bool isVideoHold = false;
  bool isLoading = true;

  late VideoPlayerController _controller;
  bool videoEnded = false;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    final appDir = await getTemporaryDirectory();
    final localVideoPath = '${appDir.path}/${widget.username}_video.mp4';
    final storageRef = FirebaseStorage.instance.ref(
      '${widget.username}/${widget.videoPath}',
    );

    final File videoFile = File(localVideoPath);

    if (!videoFile.existsSync()) {
      await storageRef.writeToFile(videoFile);
    }

    _controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
      });

    _controller.addListener(
      () {
        if (!isVideoHold) {
          if (isPlaying) {
            _controller.play();
          } else {
            _controller.pause();
          }
        }
      },
    );
  }

  void _onVideoHold(bool isHolding) {
    setState(() {
      isVideoHold = isHolding;
    });

    if (!isHolding) {
      if (isPlaying) {
        _controller.play();
      }
    } else {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 3.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Outdoors-man-portrait_%28cropped%29.jpg/1200px-Outdoors-man-portrait_%28cropped%29.jpg',
                  ),
                ),
                title: Text(widget.username),
                subtitle: Text(widget.loc),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ),
              FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    isLoading = false;
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: GestureDetector(
                        onLongPressStart: (_) {
                          _onVideoHold(true);
                        },
                        onLongPressEnd: (_) {
                          _onVideoHold(false);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller),
                            if (isLoading)
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading video'),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8.0),
                        const Text('Like'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8.0),
                        const Text('Comment'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8.0),
                        const Text('Send'),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Liked by ${widget.likes} people',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'View all ${widget.comments} comments',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '2 hours ago',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
