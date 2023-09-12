import 'dart:io';
import 'package:gallery_app_flutter/screens/video_list.dart';

import 'resources/save_video.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'utils.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MyHomePage()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _videoURL;
  VideoPlayerController? _controller;
  String? _downloadURL;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("video upload"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoList(),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Center(
        child: _videoURL != null
            ? _videoPreviewWidget()
            : const Text("No Video Selected"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        child: Icon(Icons.video_library),
      ),
    );
  }

  void _pickVideo() async {
    _videoURL = await pickVideo();
    _initailzeVideoPlayer();
  }

  Widget _videoPreviewWidget() {
    if (_controller != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            ElevatedButton(onPressed: _uploadVideo, child: Text("Upload"))
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  void _initailzeVideoPlayer() {
    _controller = VideoPlayerController.file(File(_videoURL!))
      ..initialize().then((_) {
        setState(() {
          _controller!.play();
        });
      });
  }

  void _uploadVideo() async {
    _downloadURL = await StoreData().uploadVideo(_videoURL!);
    await StoreData().saveVideoData(_downloadURL!);
    setState(() {
      _videoURL = null;
    });
  }
}
