import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/features/chat/chat_controller.dart';
import 'package:helpper/data/models/chat_model.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:intl/intl.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({Key? key}) : super(key: key);

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final ChatController _controller = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    _controller.loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Conversas'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_controller.chats.isEmpty) {
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
                  'Nenhuma conversa encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Inicie uma conversa com um prestador de serviços',
                  style: TextStyle(
                    color: ColorConstants.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.chats.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final chat = _controller.chats[index];
            return _buildChatItem(chat);
          },
        );
      }),
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final chatName = _controller.getChatName(chat);
    final lastMessageTime = DateFormat('HH:mm').format(chat.lastMessageTime);
    final userId = _controller.currentChat.value?.participants[0];

    // Check if this user has unread messages
    final unreadCount = userId != null && chat.unreadCount != null
        ? chat.unreadCount![userId] ?? 0
        : 0;

    return ListTile(
      onTap: () => Get.toNamed(
        AppRoutes.CHAT_DETAIL,
        arguments: chat.id,
      ),
      leading: CircleAvatar(
        backgroundColor: ColorConstants.primaryColor,
        child: Text(
          chatName[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        chatName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        chat.lastMessage.isEmpty
            ? 'Inicie uma conversa'
            : chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unreadCount > 0
              ? ColorConstants.textPrimaryColor
              : ColorConstants.textSecondaryColor,
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMessageTime,
            style: TextStyle(
              fontSize: 12,
              color: unreadCount > 0
                  ? ColorConstants.primaryColor
                  : ColorConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: ColorConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
