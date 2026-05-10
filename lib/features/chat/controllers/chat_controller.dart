import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shellafood_delivery/api/api_client.dart';
import 'package:shellafood_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:shellafood_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:shellafood_delivery/features/chat/domain/models/message_model.dart';
import 'package:shellafood_delivery/features/chat/domain/services/chat_service_interface.dart';
import 'package:shellafood_delivery/features/profile/controllers/profile_controller.dart';

class ChatController extends GetxController implements GetxService {
  final ChatServiceInterface chatServiceInterface;
  ChatController({required this.chatServiceInterface});

  List<bool>? _showDate;
  List<bool>? get showDate => _showDate;

  List<XFile>? _imageFiles;
  List<XFile>? get imageFiles => _imageFiles;

  bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;

  final bool _isSeen = false;
  bool get isSeen => _isSeen;

  final bool _isSend = true;
  bool get isSend => _isSend;

  final bool _isMe = false;
  bool get isMe => _isMe;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<XFile>? _chatImage = [];
  List<XFile>? get chatImage => _chatImage;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _offset;
  int? get offset => _offset;

  ConversationsModel? _conversationModel;
  ConversationsModel? get conversationModel => _conversationModel;

  ConversationsModel? _searchConversationModel;
  ConversationsModel? get searchConversationModel => _searchConversationModel;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  Future<void> getConversationList(int offset) async {
    _searchConversationModel = null;
    _conversationModel = null;
    ConversationsModel? conversationModel =
        await chatServiceInterface.getConversationList(offset);
    if (conversationModel != null) {
      if (offset == 1) {
        _conversationModel = conversationModel;
      } else {
        _conversationModel!.totalSize = conversationModel.totalSize;
        _conversationModel!.offset = conversationModel.offset;
        _conversationModel!.conversations!
            .addAll(conversationModel.conversations!);
      }
    }
    update();
  }

  Future<void> searchConversation(String name) async {
    _searchConversationModel = ConversationsModel();
    update();
    ConversationsModel? searchConversationModel =
        await chatServiceInterface.searchConversationList(name);
    if (searchConversationModel != null) {
      _searchConversationModel = searchConversationModel;
    }
    update();
  }

  void removeSearchMode() {
    _searchConversationModel = null;
    update();
  }

  Future<void> getMessages(int offset, NotificationBodyModel notificationBody,
      User? user, int? conversationID,
      {bool firstLoad = false}) async {
    if (firstLoad) {
      _messageModel = null;
    }

    MessageModel? messageModel = await chatServiceInterface.processGetMessage(
        offset, notificationBody, conversationID);

    if (messageModel != null) {
      if (offset == 1) {
        if (Get.find<ProfileController>().profileModel == null) {
          await Get.find<ProfileController>().getProfile();
        }
        _messageModel = messageModel;
        if (_messageModel!.conversation == null && user != null) {
          _messageModel!.conversation = Conversation(
              sender: User(
                id: Get.find<ProfileController>().profileModel!.id,
                imageFullUrl:
                    Get.find<ProfileController>().profileModel!.imageFullUrl,
                fName: Get.find<ProfileController>().profileModel!.fName,
                lName: Get.find<ProfileController>().profileModel!.lName,
              ),
              receiver: user);
        } else if (_messageModel!.conversation != null &&
            _messageModel!.conversation!.receiverType == 'delivery_man') {
          User? receiver = _messageModel!.conversation!.receiver;
          _messageModel!.conversation!.receiver =
              _messageModel!.conversation!.sender;
          _messageModel!.conversation!.sender = receiver;
        }
      } else {
        _messageModel!.totalSize = messageModel.totalSize;
        _messageModel!.offset = messageModel.offset;
        _messageModel!.messages!.addAll(messageModel.messages!);
      }
    }
    _isLoading = false;
    update();
  }

  Future<bool> sendMessage(
      {required String message,
      required NotificationBodyModel? notificationBody,
      required int? conversationId}) async {
    bool isSuccess = false;
    final int selectedFileCount = _chatImage?.length ?? 0;
    debugPrint(
        '[CHAT_SEND_START] conversation_id=$conversationId has_text=${message.trim().isNotEmpty} selected_files=$selectedFileCount');
    _isLoading = true;
    update();
    try {
      final List<MultipartBody> chatImage =
          chatServiceInterface.processMultipartBody(_chatImage ?? <XFile>[]);
      final MessageModel? messageModel =
          await chatServiceInterface.processSendMessage(
              notificationBody, chatImage, message, conversationId);
      if (messageModel == null) {
        debugPrint('[CHAT_SEND_ERROR] empty_response_model');
        return false;
      }
      _messageModel = messageModel;
      if (_messageModel!.conversation != null &&
          _messageModel!.conversation!.receiverType == 'delivery_man') {
        User? receiver = _messageModel!.conversation!.receiver;
        _messageModel!.conversation!.receiver =
            _messageModel!.conversation!.sender;
        _messageModel!.conversation!.sender = receiver;
      }
      _clearSelectedFiles();
      _isSendButtonActive = false;
      isSuccess = true;
      debugPrint(
          '[CHAT_SEND_SUCCESS] conversation_id=$conversationId status=${messageModel.status} messages=${messageModel.messages?.length ?? 0}');
    } catch (error) {
      debugPrint('[CHAT_SEND_ERROR] ${error.runtimeType}');
    } finally {
      _isLoading = false;
      debugPrint(
          '[CHAT_SEND_STATE_RESET] is_loading=$_isLoading send_button_active=$_isSendButtonActive');
      update();
    }
    return isSuccess;
  }

  void pickImage(bool isRemove) async {
    final ImagePicker picker = ImagePicker();
    if (isRemove) {
      _clearSelectedFiles();
    } else {
      _imageFiles = await picker.pickMultiImage(imageQuality: 30);
      if (_imageFiles != null) {
        _chatImage = imageFiles;
        _isSendButtonActive = _chatImage!.isNotEmpty;
      }
    }
    update();
  }

  void removeImage(int index, {bool hasText = false}) {
    chatImage!.removeAt(index);
    updateSendButtonActivity(hasText: hasText);
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    update();
  }

  void updateSendButtonActivity({required bool hasText}) {
    _isSendButtonActive = hasText || (_chatImage?.isNotEmpty ?? false);
    update();
  }

  void _clearSelectedFiles() {
    final int selectedFileCount = _chatImage?.length ?? 0;
    _imageFiles = [];
    _chatImage = [];
    debugPrint('[CHAT_SELECTED_FILES_CLEAR] selected_files=$selectedFileCount');
  }
}
