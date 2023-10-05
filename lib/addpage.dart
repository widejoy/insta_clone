import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController caption = TextEditingController();
    TextEditingController username = TextEditingController();

    TextEditingController comments = TextEditingController();
    TextEditingController likes = TextEditingController();
    TextEditingController location = TextEditingController();
    File? file;
    String? fileName;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(
            height: 260,
          ),
          TextField(
            controller: caption,
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: comments,
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: likes,
          ),
          TextField(
            controller: location,
          ),
          TextField(
            controller: username,
          ),
          IconButton(
            onPressed: () async {
              FilePickerResult? result =
                  await FilePicker.platform.pickFiles(type: FileType.video);

              if (result != null) {
                file = File(result.files.single.path!);
                fileName = file!.path.split('/').last;
              } else {}
            },
            icon: const Icon(Icons.file_copy),
          ),
          OutlinedButton(
            onPressed: () {
              int parsedComments = int.tryParse(comments.text) ?? 0;
              int parsedLikes = int.tryParse(likes.text) ?? 0;

              FirebaseFirestore.instance
                  .collection("posts")
                  .doc(username.text)
                  .set(
                {
                  "caption": caption.text,
                  "comments": parsedComments,
                  "likes": parsedLikes,
                  "location": location.text,
                  "videoname": fileName
                },
              );
              FirebaseStorage.instance
                  .ref()
                  .child("${username.text}/$fileName")
                  .putFile(File(file!.path));
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
