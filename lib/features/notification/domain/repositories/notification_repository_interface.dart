import 'package:shellafood_delivery/interface/repository_interface.dart';

abstract class NotificationRepositoryInterface extends RepositoryInterface {
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  Future<dynamic> sendDeliveredNotification(int? orderID);
}
