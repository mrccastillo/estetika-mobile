import 'package:flutter/material.dart';
import 'package:estetika_ui/widgets/custom_app_bar.dart';
import 'package:estetika_ui/screens/chat_detail_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<MessageItem> _messages = [
    MessageItem(
      sender: "Ken Dela Cruz",
      content: "Hello i'm your designer assigned to your project",
      timestamp: DateTime(2025, 4, 12, 10, 32),
      isFromUser: false,
      profileImage: 'assets/images/profile1.jpg',
      isRead: false,
    ),
    MessageItem(
      sender: "Kehlani Marie",
      content: "Thanks for the update! Looking forward to our meeting.",
      timestamp: DateTime(2025, 4, 11, 15, 20),
      isFromUser: false,
      profileImage: 'assets/images/profile2.jpg',
      isRead: true,
    ),
    MessageItem(
      sender: "Bronny James",
      content: "Not sure if I can make it to the meeting tomorrow.",
      timestamp: DateTime(2025, 4, 10, 9, 45),
      isFromUser: false,
      profileImage: 'assets/images/profile3.jpg',
      isRead: true,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<MessageItem> _filteredMessages = [];

  @override
  void initState() {
    super.initState();
    _filteredMessages = List.from(_messages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMessages(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMessages = List.from(_messages);
      } else {
        _filteredMessages = _messages
            .where((message) =>
                message.sender.toLowerCase().contains(query.toLowerCase()) ||
                message.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        isInboxScreen: true, // Highlights the mail icon
        showBackButton: true, actions: [], title: '', // Shows back button
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildConversationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff203B32),
        onPressed: () {
          // Implement new message functionality
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: const Icon(Icons.search, color: Color(0xff203B32)),
          suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff203B32)),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filterMessages('');
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xff203B32)),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: _filterMessages,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Your inbox is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Messages from your collaborators will appear here",
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Start a new conversation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff203B32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start a conversation'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    final List<String> uniqueSenders = _messages
        .map((m) => m.sender)
        .toSet()
        .toList();
    
    // If searching, filter unique senders to only those in filtered messages
    final filteredSenders = _searchQuery.isNotEmpty
        ? uniqueSenders.where((sender) => 
            _filteredMessages.any((m) => m.sender == sender)).toList()
        : uniqueSenders;

    return filteredSenders.isEmpty && _searchQuery.isNotEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "No conversations found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            itemCount: filteredSenders.length,
            itemBuilder: (context, index) {
              final sender = filteredSenders[index];
              final latestMessage = _messages.firstWhere((m) => m.sender == sender);
              
              return _buildConversationItem(latestMessage, context);
            },
          );
  }

  Widget _buildConversationItem(MessageItem message, BuildContext context) {
    final isUserMessage = message.isFromUser;
    final displayName = isUserMessage ? "You" : message.sender;

    return InkWell(
      onTap: () {
        // Mark as read when opening
        if (!message.isRead) {
          setState(() {
            final index = _messages.indexWhere(
                (m) => m.sender == message.sender && m.timestamp == message.timestamp);
            if (index != -1) {
              _messages[index] = MessageItem(
                sender: message.sender,
                content: message.content,
                timestamp: message.timestamp,
                isFromUser: message.isFromUser,
                profileImage: message.profileImage,
                isRead: true,
              );
            }
          });
        }
        _openChatDetail(message);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.0),
          color: message.isRead ? Colors.white : Colors.grey[50],
        ),
        child: Row(
          children: [
            // Profile image
            Stack(
              children: [
                if (!isUserMessage)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: message.profileImage != null
                        ? AssetImage(message.profileImage!)
                        : null,
                    child: message.profileImage == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                if (isUserMessage)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xff203B32),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                if (!message.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xff203B32),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Message preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Timestamp
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                if (!message.isRead)
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: Color(0xff203B32),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _openChatDetail(MessageItem message) {
    final sender = message.isFromUser ? "You" : message.sender;
    final conversationMessages = _messages
        .where((m) => m.isFromUser || m.sender == message.sender)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          title: sender,
          profileImage: message.isFromUser ? null : message.profileImage,
          messages: conversationMessages,
          onSendMessage: (text) {
            setState(() {
              _messages.insert(
                0,
                MessageItem(
                  sender: "You",
                  content: text,
                  timestamp: DateTime.now(),
                  isFromUser: true,
                  isRead: true,
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

class MessageItem {
  final String sender;
  final String content;
  final DateTime timestamp;
  final bool isFromUser;
  final String? profileImage;
  final bool isRead;

  MessageItem({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isFromUser,
    this.profileImage,
    this.isRead = true,
  });
}