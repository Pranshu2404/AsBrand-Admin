import '../../../models/my_notification.dart';
import '../../../models/notification_result.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/data/data_provider.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class NotificationProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final sendNotificationFormKey = GlobalKey<FormState>();

  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  TextEditingController imageUrlCtrl = TextEditingController();

  NotificationResult? notificationResult;

  NotificationProvider(this._dataProvider) {
    getNotificationInfo();
  }

  Future<void> sendNotification() async {
    try {
      final Map<String, dynamic> notificationData = {
        'title': titleCtrl.text,
        'description': descriptionCtrl.text,
        'imageUrl': imageUrlCtrl.text,
      };

      final response = await service.addItem(
        endpointUrl: 'notification/send-notification',
        itemData: notificationData,
      );

      if (response.isOk) {
        clearFields();
        getNotificationInfo();
        SnackBarHelper.showSuccessSnackBar('Notification sent successfully');
      } else {
        SnackBarHelper.showErrorSnackBar('Failed to send notification');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'notification/delete-notification',
        itemId: id,
      );

      if (response.isOk) {
        getNotificationInfo();
        SnackBarHelper.showSuccessSnackBar('Notification deleted successfully');
      } else {
        SnackBarHelper.showErrorSnackBar('Failed to delete notification');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: $e');
    }
  }

  Future<void> getNotificationInfo() async {
    try {
      final response = await service.getItems(endpointUrl: 'notification/all-notification');
      if (response.isOk && response.body != null) {
        final data = response.body;
        if (data['success'] == true) {
          final List list = data['data'] ?? [];
          final notifications = list.map((json) => MyNotification.fromJson(json)).toList();
          _dataProvider.updateNotifications(notifications);
        }
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> trackNotification(String? id) async {
    if (id == null) return;
    notificationResult = null;
    notifyListeners();
    try {
      final response = await service.getItems(endpointUrl: 'notification/track-notification/$id');
      if (response.isOk && response.body != null) {
        final data = response.body;
        if (data['success'] == true) {
          notificationResult = NotificationResult.fromJson(data['data']);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error tracking notification: $e');
    }
  }

  clearFields() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    imageUrlCtrl.clear();
  }

  updateUI() {
    notifyListeners();
  }
}
