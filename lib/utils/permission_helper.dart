import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestCameraAndMicrophonePermissions() async {
    // Request camera permission
    final cameraStatus = await Permission.camera.request();
    
    // Request microphone permission
    final microphoneStatus = await Permission.microphone.request();
    
    // Both permissions must be granted
    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  static Future<bool> checkCameraAndMicrophonePermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    
    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
