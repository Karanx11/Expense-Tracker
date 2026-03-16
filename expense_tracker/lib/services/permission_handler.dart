import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestSMSPermission() async {
    PermissionStatus status = await Permission.sms.request();

    if (status.isDenied) {
      print("SMS permission denied");
    }
  }
}
