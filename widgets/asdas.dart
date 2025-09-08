import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/chat_bloc/chat_bloc.dart';
import '../../../bloc/chat_bloc/chat_event.dart';
import '../../../bloc/chat_bloc/chat_state.dart';
import '../../../models/chat_room_model.dart';
import '../../../models/product_response_model.dart';
import '../../../services/api/product_service.dart';

class UserChatPanel extends StatefulWidget {
  static const String routeName = '/user/chat-panel';
  const UserChatPanel({super.key});

  @override
  State<UserChatPanel> createState() => _UserChatPanelState();
}

class _UserChatPanelState extends State<UserChatPanel> {
  bool showRightPanel = false;
  ChatRoom? _selectedRoom;
  late Product selectedProduct;
  final ProductService _productService = ProductService();
  final Map<String, bool> downloadedDocs = {};
  final List<Map<String, dynamic>> messages = [
    {"text": "Royal_Diamond_Cert.pdf", "isSender": false, "isFile": true},
    {
      "text": "Thank you! Could you also share the latest pricing?",
      "isSender": true
    },
    {
      "text": "Of course! The current asking price is \$125,000.",
      "isSender": false
    },
    {
      "text":
      "I'd like to see some additional photos of the diamond from different angles.",
      "isSender": true
    },
  ];

  final TextEditingController messageController = TextEditingController();

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;
      setState(() {
        messages.add({
          "text": picked.name,
          "isSender": true,
          "isFile": picked.extension == 'pdf',
        });
      });
    }
  }
  void _selectRoom(ChatRoom room) {
    setState(() {
      _selectedRoom = room;
      messages.clear();
    });

    context.read<ChatBloc>().add(FetchChatMessages(
      roomId: room.id,
      refresh: true,
    ));

    context.read<ChatBloc>().add(JoinChatRoom(roomId: room.id));
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ChatBloc>().add(InitializeChat());
    context.read<ChatBloc>().add(FetchChatRooms());
    context.read<ChatBloc>().add(FetchUnreadCounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFE5E5EA)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 28, 0, 8),
                  child: Text(
                    'Diamond Chat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF871437),
                    ),
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search stones...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: const Icon(Icons.filter_list, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5EA),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatRoomsLoaded) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: state.rooms.length,
                          itemBuilder: (context, index) {
                            final room = state.rooms[index];
                            return ChatListItem(
                              room: room,
                              onTap: () => _selectRoom(room),
                            );
                          },
                        ),
                      );
                    } else if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text('No chat rooms available.'));
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E5EA))),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Royal Diamond',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '5.01ct, VS1, D',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () async {
                          final productId = _selectedRoom?.product.id ?? '';
                          if (productId.isNotEmpty) {
                            final product = await _productService.getProductById(productId);
                            setState(() {
                              selectedProduct = product;
                              showRightPanel = !showRightPanel;
                            });
                          }

                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(
                        text: msg['text'],
                        isSender: msg['isSender'],
                        isFile: msg['isFile'] ?? false,
                        downloaded: downloadedDocs[msg['text']] ?? false,
                        onDownloadTap: () {
                          setState(() {
                            downloadedDocs[msg['text']] =
                            !(downloadedDocs[msg['text']] ?? false);
                          });
                        },
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E5EA))),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: pickFile,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: const TextStyle(fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (messageController.text.trim().isNotEmpty) {
                            setState(() {
                              messages.add({
                                "text": messageController.text.trim(),
                                "isSender": true
                              });
                              messageController.clear();
                            });
                          }
                        },
                        child: const CircleAvatar(
                          backgroundColor: Color(0xFF850026),
                          radius: 20,
                          child:
                          Icon(Icons.send, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: showRightPanel ? 320 : 0,
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFFE5E5EA))),
            ),
            child: showRightPanel
                ? Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        'https://via.placeholder.com/120',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Royal Diamond',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      '5.01ct, VS1, D',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Specifications',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  detailRow('Carat Weight', '5.01 ct'),
                  detailRow('Clarity', 'VS1'),
                  detailRow('Color', 'D'),
                  detailRow('Cut', 'Excellent'),
                  detailRow('Polish', 'Excellent'),
                  detailRow('Symmetry', 'Excellent'),
                  const SizedBox(height: 20),
                  const Text('Shared Media',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      6,
                          (index) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://via.placeholder.com/60',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Documents',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  docItem('Certification.pdf', downloadedDocs, context,(name) {
                    setState(() {
                      downloadedDocs[name] =
                      !(downloadedDocs[name] ?? false);
                    });
                  }),
                  docItem('Price Quote.pdf', downloadedDocs, context,(name) {
                    setState(() {
                      downloadedDocs[name] =
                      !(downloadedDocs[name] ?? false);
                    });
                  }),
                  docItem('Inspection Report.pdf', downloadedDocs, context,(name) {
                    setState(() {
                      downloadedDocs[name] =
                      !(downloadedDocs[name] ?? false);
                    });
                  }),
                ],
              ),
            )
                : null,
          ),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final product = room.product;
    final lastMessage = room.lastMessage;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage("${product.images.first}"), // Assuming this exists
      ),
      title: Text("${product.shape.first} Diamond",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${product.carat}ct • ${product.clarity} • ${product.color}",
              style:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(lastMessage?.content??"",
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      trailing: Text(_formatTime(lastMessage?.createdAt),
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays >= 1) {
      return '${time.month}/${time.day}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}


class MessageBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final bool isFile;
  final bool downloaded;
  final VoidCallback? onDownloadTap;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isSender,
    this.isFile = false,
    this.downloaded = false,
    this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
          isSender ? const Color(0xFF850026) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isFile
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.black),
            const SizedBox(width: 8),
            Text(text,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDownloadTap,
              child: Icon(
                Icons.download,
                color: downloaded ? Colors.green : Colors.black,
              ),
            ),
          ],
        )
            : Text(
          text,
          style: TextStyle(
            color: isSender ? Colors.white : Colors.black87,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

Widget detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    ),
  );
}

Widget docItem(String name, Map<String, bool> downloadedDocs,BuildContext context,
    void Function(String) onTap) {
  return Padding(
    padding:  EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.picture_as_pdf, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
        GestureDetector(
          onTap: () => onTap(name),
          child: Icon(
            Icons.download,
            size: 20,
            color: downloadedDocs[name] ?? false ? Colors.green : Theme.of(context).primaryColor,
          ),
        ),
      ],
    ),
  );
}
// Expanded(
//   child: ListView.builder(
//     padding: const EdgeInsets.symmetric(
//         horizontal: 20, vertical: 16),
//     itemCount: _currentChat()["messages"].length,
//     itemBuilder: (context, index) {
//       final message = _currentChat()["messages"][index];
//       return Align(
//         alignment: message["isSender"]
//             ? Alignment.centerRight
//             : Alignment.centerLeft,
//         child: Container(
//           decoration: BoxDecoration(
//             color: message["isSender"]
//                 ? const Color(0xFF871437)
//                 : const Color(0xFFE5E5EA),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           padding: const EdgeInsets.symmetric(
//               horizontal: 16, vertical: 10),
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           child: Column(
//             crossAxisAlignment: message["isSender"]
//                 ? CrossAxisAlignment.end
//                 : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 message["text"],
//                 style: TextStyle(
//                   color: message["isSender"]
//                       ? Colors.white
//                       : Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 message["time"],
//                 style: TextStyle(
//                   color: message["isSender"]
//                       ? Colors.white70
//                       : Colors.black54,
//                   fontSize: 10,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   ),
// ),