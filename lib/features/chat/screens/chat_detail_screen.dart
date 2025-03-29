import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/loading_indicator.dart';
import 'package:helpper/features/chat/chat_controller.dart';
import 'package:helpper/features/chat/widgets/chat_message.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({Key? key}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatController _controller = Get.find<ChatController>();
  late String chatId;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  void _setupChat() async {
    // Check if we're opening an existing chat or creating a new one
    if (Get.arguments is String) {
      // Open existing chat by ID
      chatId = Get.arguments as String;
      _controller.loadMessages(chatId);
    } else if (Get.arguments is Map<String, dynamic>) {
      // Create a new chat with a user
      final args = Get.arguments as Map<String, dynamic>;
      final userId = args['userId'] as String;
      final userName = args['userName'] as String;

      // Create or get existing chat
      final createdChatId = await _controller.createChat(userId, userName);

      if (createdChatId != null) {
        chatId = createdChatId;
        _controller.loadMessages(chatId);
      } else {
        Get.back();
        Get.snackbar(
          'Erro',
          'Não foi possível iniciar a conversa',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.back();
      Get.snackbar(
        'Erro',
        'Parâmetros inválidos',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _sendMessage() {
    final text = _controller.messageController.text.trim();
    if (text.isNotEmpty) {
      _controller.sendMessage(chatId, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final chat = _controller.currentChat.value;
          if (chat == null) {
            return const Text('Carregando...');
          }
          return Text(_controller.getChatName(chat));
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_controller.isLoadingMessages.value) {
                return const Center(
                  child: LoadingIndicator(),
                );
              }

              if (_controller.messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: ColorConstants.textSecondaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma mensagem',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Envie uma mensagem para iniciar a conversa',
                        style: TextStyle(
                          color: ColorConstants.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _controller.messages.length,
                itemBuilder: (context, index) {
                  final message = _controller.messages[index];
                  final previousMessage = index > 0 ? _controller.messages[index - 1] : null;

                  // Check if we need to show date header
                  final showDateHeader = previousMessage == null ||
                      !_isSameDay(previousMessage.timestamp, message.timestamp);

                  return Column(
                    children: [
                      if (showDateHeader)
                        _buildDateHeader(message.timestamp),
                      ChatMessage(message: message),
                    ],
                  );
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    String formattedDate;
    if (_isSameDay(date, now)) {
      formattedDate = 'Hoje';
    } else if (_isSameDay(date, yesterday)) {
      formattedDate = 'Ontem';
    } else {
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: ColorConstants.chipBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstants.inputFillColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: ColorConstants.textSecondaryColor,
                    ),
                    onPressed: () {
                      // Show emoji picker
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller.messageController,
                      decoration: const InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        hintStyle: TextStyle(
                          color: ColorConstants.textSecondaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: ColorConstants.textSecondaryColor,
                    ),
                    onPressed: () {
                      // Show attachment options
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: ColorConstants.textSecondaryColor,
                    ),
                    onPressed: () {
                      // Open camera
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: ColorConstants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
