import 'package:shellafood_delivery/interface/repository_interface.dart';

abstract class AddressRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getZone(String lat, String lng);
  String? getUserAddress();
  Future<bool> saveUserAddress(String address, List<int>? zoneIDs);
}
