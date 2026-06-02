import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request camera permission (for flashlight/optical Morse)
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// Request location permission
  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  Future<bool> isCameraGranted() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  Future<bool> isLocationGranted() async {
    final status = await Permission.locationWhenInUse.status;
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }
}
