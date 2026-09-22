import 'dart:io';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceUploadScreen extends StatefulWidget {
  @override
  _FaceUploadScreenState createState() => _FaceUploadScreenState();
}

class _FaceUploadScreenState extends State<FaceUploadScreen> {
  CameraController? _cameraController;
  XFile? _capturedImage;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableContours: false, enableLandmarks: false),
  );
  bool _isFaceDetected = false;
  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    
    if (status.isGranted) {
      _initializeCamera();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera permission is required to use this feature")),
      );
    }
  }

  void _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController =
            CameraController(_cameras![_selectedCameraIndex], ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
        await _cameraController!.initialize();
        await _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);
        
        if (mounted) {
          setState(() {});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No cameras found on device")),
        );
      }
    } catch (e) {
      print("Camera initialization error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to initialize camera: $e")),
      );
    }
  }

  void _switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      _initializeCamera();
    }
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        XFile image = await _cameraController!.takePicture();
        await _detectFaces(image);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Camera error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera not initialized!")),
      );
    }
  }

  Future<void> _detectFaces(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    setState(() {
      _capturedImage = image;
      _isFaceDetected = faces.isNotEmpty;
    });

    if (faces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No face detected! Please try again.")),
      );
    }
  }

  Future<void> _uploadPhoto() async {
    if (_capturedImage != null && _isFaceDetected) {
      File imageFile = File(_capturedImage!.path);
      ApiServices().uploadPhoto(imageFile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No face detected! Cannot upload.")),
      );
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Take a Selfie'),
      body: Center(
        child: !_isCameraPermissionGranted 
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Camera permission is required"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: Text('Grant Permission'),
              ),
            ],
          )
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_capturedImage != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _capturedImage = null;
                        _isFaceDetected = false;
                        _initializeCamera();
                      });
                    },
                    child: Text('Take Again'),
                  ),
                ],
              ),
            if (_capturedImage == null && _cameras != null && _cameras!.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.switch_camera, size: 30),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              width: 300,
              height: 400,
              child: _capturedImage == null
                ? (_cameraController != null && _cameraController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    : Center(child: CircularProgressIndicator()))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
                  ),
            ),
            SizedBox(height: 10),
            if (_capturedImage == null)
              ElevatedButton(
                onPressed: _capturePhoto,
                child: Text('Capture'),
              ),
            if (_capturedImage != null)
              Column(
                children: [
                  SizedBox(height: 10),
                  _isFaceDetected
                  ? ElevatedButton(
                      onPressed: _uploadPhoto,
                      child: Text('Upload'),
                    )
                  : Text(
                      "No face detected. Retake the photo!",
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
