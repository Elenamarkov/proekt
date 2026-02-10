import 'package:flutter/material.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();

    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    _simulateBotResponse(text);
  }

  void _simulateBotResponse(String userText) {
    Future.delayed(const Duration(seconds: 1), () {
      String botResponse = _getBotResponse(userText);

      ChatMessage botMessage = ChatMessage(
        text: botResponse,
        isUser: false,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    });
  }

  String _getBotResponse(String userText) {
    userText = userText.toLowerCase();

    if (userText.contains('hello') || userText.contains('hi')) {
      return 'Hello! Welcome to DreamScape. How can I assist you today?';
    } else if (userText.contains('how are you')) {
      return "I'm doing great, ready to help with your travel plans!";
    } else if (userText.contains('flight') || userText.contains('fly')) {
      return 'I can help you book flights! Visit the Flights tab to search for available flights.';
    } else if (userText.contains('hotel') || userText.contains('stay')) {
      return 'Looking for accommodation? Check the Hotels tab for great deals!';
    } else if (userText.contains('taxi') || userText.contains('transport')) {
      return 'Need transportation? The Taxis tab has various options for you.';
    } else if (userText.contains('booking') || userText.contains('receipt')) {
      return 'Your bookings and receipts are available in the Receipts tab.';
    } else if (userText.contains('bye') || userText.contains('goodbye')) {
      return 'Goodbye! Safe travels!';
    } else if (userText.contains('thank')) {
      return "You're welcome! Happy to help.";
    } else if (userText.contains('price') || userText.contains('cost')) {
      return 'Prices vary based on selection and availability. Please check specific services for pricing.';
    } else if (userText.contains('help')) {
      return 'I can assist with flights, hotels, taxis, and booking management. What do you need help with?';
    } else {
      return "I'm here to help with your travel plans! You can ask me about flights, hotels, taxis, or view your bookings.";
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Assistant'),
        backgroundColor: Colors.blue[200],
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearChat,
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _handleSubmitted,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmitted(_textController.text),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                isUser ? Theme.of(context).colorScheme.primary : Colors.green,
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Travel Assistant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: isUser
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
