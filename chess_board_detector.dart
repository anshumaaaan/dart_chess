import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'chess_board_processor.dart';

class ChessBoardDetector extends StatefulWidget {
  @override
  _ChessBoardDetectorState createState() => _ChessBoardDetectorState();
}

class _ChessBoardDetectorState extends State<ChessBoardDetector> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  File? _lastImage;
  bool _changeDetected = false;
  List<String> _changedSquares = [];
  final ChessBoardProcessor _processor = ChessBoardProcessor();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chess Board Detector')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: _captureAndDetectChanges,
            child: Text('Capture and Detect Changes'),
          ),
          if (_changeDetected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Changes detected at squares: ${_changedSquares.join(", ")}',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _captureAndDetectChanges() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final currentImage = File(image.path);
      
      if (_lastImage != null) {
        final (changes, changedSquares) = await _detectChanges(_lastImage!, currentImage);
        setState(() {
          _changeDetected = changes;
          _changedSquares = changedSquares;
        });
      } else {
        setState(() {
          _changeDetected = false;
          _changedSquares = [];
        });
      }
      
      _lastImage = currentImage;
    } catch (e) {
      print(e);
    }
  }

  Future<(bool, List<String>)> _detectChanges(File image1, File image2) async {
    final img1 = img.decodeImage(await image1.readAsBytes());
    final img2 = img.decodeImage(await image2.readAsBytes());
    
    if (img1 == null || img2 == null) return (false, []);

    return _processor.detectChanges(img1, img2);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}