import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future requestPermissions() async {
    await Permission.sms.request();

    await Permission.notification.request();

    await Permission.phone.request();
  }
}
