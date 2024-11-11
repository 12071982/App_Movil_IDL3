import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({required this.cameras, Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future<void> initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.medium);
    try {
      await _cameraController.initialize();
      setState(() {});
    } on CameraException catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<Uint8List?> takePicture() async {
    if (!_cameraController.value.isInitialized) return null;
    if (_cameraController.value.isTakingPicture) return null;
    try {
      final photo = await _cameraController.takePicture();
      final imageBytes = await photo.readAsBytes();

      // Verificar tamaño de imagen (1 MB máximo)
      if (imageBytes.lengthInBytes > 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La imagen debe ser menor a 1 MB")),
        );
        return null;
      }
      return imageBytes;
    } catch (e) {
      debugPrint("Error al tomar la foto: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _cameraController.value.isInitialized
              ? CameraPreview(_cameraController)
              : const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.7),
              child: IconButton(
                icon: const Icon(Icons.camera, color: Colors.white, size: 50),
                onPressed: () async {
                  final image = await takePicture();
                  if (image != null) {
                    Navigator.pop(context, image);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
