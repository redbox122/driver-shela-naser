import 'package:shellafood_delivery/api/api_client.dart';
import 'package:shellafood_delivery/interface/repository_interface.dart';

abstract class ChatRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getConversationList(int offset);
  Future<dynamic> searchConversationList(String name);
  Future<dynamic> getMessages(
      int offset, int? userId, String userType, int? conversationID);
  Future<dynamic> sendMessage(String message, List<MultipartBody> file,
      int? conversationId, int? userId, String userType);
}
