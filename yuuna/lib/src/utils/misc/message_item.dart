import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart';
import 'package:isar/isar.dart';

part 'message_item.g.dart';

/// Used to allow persistence of [ChatMessage].
@Collection()
class MessageItem {
  /// Initialise this object.
  MessageItem({
    required this.message,
    required this.isBot,
    this.id,
  });

  /// Converts [ChatMessage] to [MessageItem].
  factory MessageItem.fromChatMessage(ChatMessage message) {
    return MessageItem(
      message: message.text,
      isBot: message.chatMessageType == ChatMessageType.bot,
    );
  }

  /// Used for database purposes.
  Id? id;

  /// Message to show for this item.
  final String message;

  /// True if bot, false if user.
  final bool isBot;
}
