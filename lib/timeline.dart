import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/Widgets/instapost.dart';
import 'package:file_picker/file_picker.dart';
import 'package:insta_clone/addpage.dart';
import 'package:video_player/video_player.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  late PlatformFile file;
  VideoPlayerController? _currentVideoController;

  @override
  void dispose() {
    _currentVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddPage(),
              ),
            );
          },
          icon: const Icon(Icons.add),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          var posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var data = posts[index].data();
              var username = posts[index].id;
              var caption = data['caption'] ?? '';
              var comments = data['comments'] ?? '';
              var likes = data['likes'] ?? '';
              var loc = data['location'] ?? '';
              var video = data['videoname'] ?? '';

              return GestureDetector(
                onTap: () {
                  if (_currentVideoController != null) {
                    _currentVideoController!.pause();
                  }
                  setState(() {
                    _currentVideoController =
                        VideoPlayerController.networkUrl(video)
                          ..initialize().then((_) {
                            _currentVideoController!.play();
                          });
                  });
                },
                child: InstagramPost(
                  caption: caption,
                  comments: comments,
                  likes: likes,
                  loc: loc,
                  username: username,
                  videoPath: video,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
