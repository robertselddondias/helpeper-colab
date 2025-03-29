import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpper/data/models/chat_model.dart';
import 'package:helpper/data/models/message_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rx<ChatModel?> currentChat = Rx<ChatModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString error = ''.obs;

  // Scroll controller for chat message list
  final ScrollController scrollController = ScrollController();

  // Message input controller
  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.firebaseUser.value?.uid;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // Listen to chats collection where user is a participant
      _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
          chats.clear();
          for (var doc in snapshot.docs) {
            chats.add(ChatModel.fromFirestore(doc));
          }
          isLoading.value = false;
        },
        onError: (e) {
          isLoading.value = false;
          error.value = e.toString();
          debugPrint('Error loading chats: $e');
        },
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error setting up chats listener: $e');
    }
  }

  Future<void> loadMessages(String chatId) async {
    try {
      isLoadingMessages.value = true;
      error.value = '';

      // Get chat information
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        currentChat.value = ChatModel.fromFirestore(chatDoc);

        // Mark all messages as read
        markChatAsRead(chatId);

        // Listen to messages for this chat
        _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp')
            .snapshots()
            .listen(
              (snapshot) {
            messages.clear();
            for (var doc in snapshot.docs) {
              messages.add(MessageModel.fromFirestore(doc));
            }

            isLoadingMessages.value = false;

            // Scroll to bottom after messages load
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          },
          onError: (e) {
            isLoadingMessages.value = false;
            error.value = e.toString();
            debugPrint('Error loading messages: $e');
          },
        );
      } else {
        isLoadingMessages.value = false;
        error.value = 'Chat not found';
      }
    } catch (e) {
      isLoadingMessages.value = false;
      error.value = e.toString();
      debugPrint('Error setting up messages listener: $e');
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      final userId = _authController.firebaseUser.value?.uid;

      if (userId == null) return;

      // Get the chat document
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        final chat = ChatModel.fromFirestore(chatDoc);

        // Check if this user has unread messages
        if (chat.unreadCount != null &&
            chat.unreadCount!.containsKey(userId) &&
            chat.unreadCount![userId]! > 0) {

          // Update the unread count for this user
          final unreadMap = Map<String, int>.from(chat.unreadCount!);
          unreadMap[userId] = 0;

          await _firestore
              .collection('chats')
              .doc(chatId)
              .update({
            'unreadCount': unreadMap,
          });
        }
      }
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return;

    try {
      final userId = _authController.firebaseUser.value?.uid;
      final userName = _authController.userModel.value?.name;

      if (userId == null || userName == null) return;

      // Clear the input
      messageController.clear();

      // Get the chat to know the other participant
      final chat = currentChat.value;

      if (chat == null) return;

      String recipientId = chat.participants.firstWhere((id) => id != userId);

      // Create the message document
      final messageDoc = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final message = MessageModel(
        id: messageDoc.id,
        chatId: chatId,
        senderId: userId,
        senderName: userName,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Upload message to Firestore
      await messageDoc.set(message.toMap());

      // Update the chat document with last message info
      final unreadMap = Map<String, int>.from(chat.unreadCount ?? {});
      // Increment unread count for recipient
      unreadMap[recipientId] = (unreadMap[recipientId] ?? 0) + 1;

      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({
        'lastMessage': text,
        'lastMessageSenderId': userId,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': unreadMap,
      });

      // Scroll to the bottom of the list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error sending message: $e');

      Get.snackbar(
        'Erro',
        'Não foi possível enviar a mensagem',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> createChat(String userId, String userName) async {
    try {
      final currentUserId = _authController.firebaseUser.value?.uid;
      final currentUserName = _authController.userModel.value?.name;

      if (currentUserId == null || currentUserName == null) return null;

      // Check if chat already exists
      final existingChat = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingChat.docs) {
        final chat = ChatModel.fromFirestore(doc);
        if (chat.participants.contains(userId)) {
          return chat.id;
        }
      }

      // Create a new chat
      final chatDoc = _firestore.collection('chats').doc();

      final unreadMap = <String, int>{
        currentUserId: 0,
        userId: 0,
      };

      final chat = ChatModel(
        id: chatDoc.id,
        participants: [currentUserId, userId],
        participantNames: {
          currentUserId: currentUserName,
          userId: userName,
        },
        lastMessage: '',
        lastMessageSenderId: '',
        lastMessageTime: DateTime.now(),
        unreadCount: unreadMap,
        createdAt: DateTime.now(),
      );

      await chatDoc.set(chat.toMap());

      return chat.id;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Error creating chat: $e');

      Get.snackbar(
        'Erro',
        'Não foi possível iniciar a conversa',
        snackPosition: SnackPosition.BOTTOM,
      );

      return null;
    }
  }

  String getChatName(ChatModel chat) {
    final userId = _authController.firebaseUser.value?.uid;

    if (userId == null) return 'Chat';

    // Return the name of the other participant
    final otherUserId = chat.participants.firstWhere(
          (id) => id != userId,
      orElse: () => '',
    );

    return chat.participantNames[otherUserId] ?? 'Usuário';
  }
}
