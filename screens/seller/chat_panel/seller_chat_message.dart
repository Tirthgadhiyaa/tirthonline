import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

import '../../../bloc/chat_bloc/chat_bloc.dart';
import '../../../bloc/chat_bloc/chat_event.dart';
import '../../../bloc/chat_bloc/chat_state.dart';
import '../../../models/chat_message_model.dart';
import '../../../models/chat_room_model.dart';
import '../../../models/product_response_model.dart';
import '../../../services/api/product_service.dart';
import '../../../services/chatpanel_service/web_file_picker.dart';
import '../../../utils/shared_preference.dart';
import '../../../widgets/chats/message_bubble.dart';
import '../../../widgets/chats/web_attachment_preview.dart';

class SellerChatMessage extends StatefulWidget {
  final String roomId;
  ChatRoom? room;
  final String productId;

  SellerChatMessage({
    Key? key,
    required this.roomId,
    required this.room,
    required this.productId,
  }) : super(key: key);

  @override
  State<SellerChatMessage> createState() => _SellerChatMessageState();
}

class _SellerChatMessageState extends State<SellerChatMessage>
    with SingleTickerProviderStateMixin {
  bool showRightPanel = false;
  String selectedTab = "Stones";
  int selectedConversation = 0;
  String searchQuery = "";
  ChatRoom? _selectedRoom;

  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _selectedFiles = [];
  final FocusNode _messageFocusNode = FocusNode();
  String? _currentUserId;
  String? _currentUserRole;
  Timer? _typingTimer;
  final bool _isTyping = false;
  bool _isUploading = false;
  final bool _isSearching = false;
  bool _showEmojiPicker = false;
  ChatRoom? _currentRoom;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  Product? selectedProduct;

  final ProductService _productService = ProductService();
  final Map<String, bool> downloadedDocs = {};
  String? selectedRoomId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchMessages();
    // _fetchRoomDetails();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Focus the message input when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageFocusNode.requestFocus();
    });
  }

  Future<void> _loadUserData() async {
    await SharedPreferencesHelper.instance.loadSavedData();
    final userData = SharedPreferencesHelper.instance.userData;
    setState(() {
      _currentUserId = userData?.id;
      _currentUserRole = userData?.role;
    });
  }

  void _fetchMessages() {
    context.read<ChatBloc>().add(FetchChatMessages(
          roomId: widget.roomId,
          refresh: true,
        ));
  }

  void _fetchRoomDetails() {
    // Check if rooms are already loaded in the bloc
    final currentState = context.read<ChatBloc>().state;
    if (currentState is ChatRoomsLoaded) {
      // If rooms are already loaded, find the current room
      try {
        final room = currentState.rooms.firstWhere(
          (room) => room.id == widget.roomId,
          orElse: () => throw Exception('Room not found'),
        );
        setState(() {
          _currentRoom = room;
        });
      } catch (e) {
        // If room not found, fetch rooms
        context.read<ChatBloc>().add(FetchChatRooms());
      }
    } else {
      // If rooms are not loaded, fetch them
      context.read<ChatBloc>().add(FetchChatRooms());
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = context.read<ChatBloc>().state;
      if (state is ChatMessagesLoaded && state.hasMore) {
        context.read<ChatBloc>().add(FetchChatMessages(
              roomId: widget.roomId,
              skip: state.messages.length,
            ));
      }
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedFiles.isEmpty) return;

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    if (_selectedFiles.isNotEmpty) {
      final fileBytes = _selectedFiles.map((f) => f['bytes'] as Uint8List).toList();
      final fileNames = _selectedFiles.map((f) => f['name'] as String).toList();
      // Handle attachments
      context.read<ChatBloc>().add(SendMessageWithAttachments(
        roomId: widget.roomId,
        content: message, fileNames: fileNames, fileBytes: fileBytes,
      ));
    } else {
      context.read<ChatBloc>().add(SendTextMessage(
            roomId: widget.roomId,
            content: message,
          ));
    }

    _messageController.clear();
    setState(() {
      _selectedFiles.clear();
      _showEmojiPicker = false;
    });

    // Stop typing indicator
    _stopTypingTimer();
    _sendTypingStatus(false);

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendTypingStatus(bool isTyping) {
    context.read<ChatBloc>().add(SendTypingStatus(
          roomId: widget.roomId,
          isTyping: isTyping,
        ));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _stopTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = null;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _messageFocusNode.dispose();
    _animationController.dispose();
    _stopTypingTimer();

    // Leave the room when screen is closed
    context.read<ChatBloc>().add(LeaveChatRoom(roomId: widget.roomId));
    // TODO: implement dispose
    super.dispose();
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.room!.otherUser!.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(widget.room!.product.stock_number,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () async {
                        final productId = widget.productId ?? '';
                        if (productId.isNotEmpty) {
                          final product =
                              await _productService.getProductById(productId);
                          setState(() {
                            selectedProduct = product;
                            showRightPanel = !showRightPanel;
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // Messages list
                    Expanded(
                      child: BlocConsumer<ChatBloc, ChatState>(
                        listenWhen: (previous, current) =>
                            current is ChatMessagesError &&
                                current.roomId == widget.roomId ||
                            current is SendMessageError &&
                                current.roomId == widget.roomId,
                        listener: (context, state) {
                          if (state is ChatMessagesError ||
                              state is SendMessageError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state is ChatMessagesError
                                    ? state.message
                                    : (state as SendMessageError).message),
                                backgroundColor: colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'Retry',
                                  textColor: colorScheme.onError,
                                  onPressed: () {
                                    if (state is ChatMessagesError) {
                                      _fetchMessages();
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        buildWhen: (previous, current) =>
                            current is ChatLoading ||
                            (current is ChatMessagesLoaded &&
                                current.roomId == widget.roomId) ||
                            current is ChatMessagesLoading &&
                                current.roomId == widget.roomId,
                        builder: (context, state) {
                          if (state is ChatMessagesLoaded &&
                              state.roomId == widget.roomId) {
                            return _buildMessagesList(state, theme);
                          } else if (state is ChatMessagesLoading &&
                              state.roomId == widget.roomId) {
                            if (state.previousMessages != null &&
                                state.previousMessages!.isNotEmpty) {
                              return _buildMessagesList(
                                ChatMessagesLoaded(
                                  roomId: widget.roomId,
                                  messages: state.previousMessages!,
                                  totalMessages: state.previousMessages!.length,
                                  hasMore: false,
                                ),
                                theme,
                              );
                            }
                            return _buildLoadingState(theme);
                          } else if (state is ChatLoading) {
                            return _buildLoadingState(theme);
                          }
                          return _buildEmptyState(theme);
                        },
                      ),
                    ),

                    // Typing indicator
                    BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (previous, current) =>
                          current is ChatMessagesLoaded &&
                          current.roomId == widget.roomId,
                      builder: (context, state) {
                        if (state is ChatMessagesLoaded &&
                            state.roomId == widget.roomId &&
                            state.typingUsers.isNotEmpty) {
                          return _buildTypingIndicator(theme);
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Selected files preview
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _selectedFiles.isNotEmpty ? 100 : 0,
                      padding: EdgeInsets.symmetric(vertical: _selectedFiles.isNotEmpty ? 8 : 0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedFiles.length,
                        itemBuilder: (context, index) {
                          final file = _selectedFiles[index];
                          return WebAttachmentPreview(
                            fileName: file['name'],
                            mimeType: file['mime'],
                            fileSize: file['size'],
                            bytes: file['bytes'],
                            onRemove: () {
                              setState(() {
                                _selectedFiles.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E5EA))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _isUploading ? null : _pickFile,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
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
                        print("object${_messageController.text}");
                        _messageController.text.trim().isNotEmpty ||
                                _selectedFiles.isNotEmpty
                            ? _sendMessage()
                            : null;
                      },
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF850026),
                        radius: 20,
                        child: _isUploading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                color: colorScheme.onPrimary,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (selectedProduct != null)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: showRightPanel ? 320 : 0,
              curve: Curves.easeInOut,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFFE5E5EA))),
              ),
              child: selectedProduct != null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: selectedProduct == null
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.network(
                                      selectedProduct!.images.isNotEmpty
                                          ? selectedProduct!.images.first
                                          : '',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    selectedProduct!.name ?? 'Unnamed Product',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Center(
                                  child: Text(
                                    "${selectedProduct!.carat}ct, ${selectedProduct!.clarity}, ${selectedProduct!.color}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text('Specifications',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                detailRow('Carat Weight',
                                    "${selectedProduct!.carat} ct"),
                                detailRow(
                                    'Clarity', selectedProduct!.clarity ?? '-'),
                                detailRow(
                                    'Color', selectedProduct!.color ?? '-'),
                                detailRow('Cut', selectedProduct!.cut ?? '-'),
                                detailRow(
                                    'Polish', selectedProduct!.polish ?? '-'),
                                detailRow('Symmetry',
                                    selectedProduct!.symmetry ?? '-'),
                                const SizedBox(height: 20),
                                const Text('Shared Media',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedProduct!.images
                                      .map((img) => ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              img,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 20),
                                const Text('Documents',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 8),
                                docItem('Certification.pdf', downloadedDocs,
                                    context, (name) {
                                  setState(() {
                                    downloadedDocs[name] =
                                        !(downloadedDocs[name] ?? false);
                                  });
                                }),
                                docItem(
                                    'Price Quote.pdf', downloadedDocs, context,
                                    (name) {
                                  setState(() {
                                    downloadedDocs[name] =
                                        !(downloadedDocs[name] ?? false);
                                  });
                                }),
                                docItem('Inspection Report.pdf', downloadedDocs,
                                    context, (name) {
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
          ),
      ],
    );
  }

  Widget _buildMessagesList(ChatMessagesLoaded state, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    // Modified/New Code
    // More efficient filtering with memoization
    final searchTerm = _searchController.text.toLowerCase();
    final messages = searchTerm.isEmpty
        ? state.messages
        : state.messages.where((message) {
            return message.content.toLowerCase().contains(searchTerm);
          }).toList();

    if (searchTerm.isNotEmpty && messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No matching messages',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (messages.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Stack(
      children: [
        // Search bar overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildSearchBar(theme),
        ),

        // Messages list
        Padding(
          padding: EdgeInsets.only(top: _isSearching ? 56 : 0),
          child: AnimationLimiter(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: messages.length,
              // Modified/New Code
              // Add caching for better performance
              cacheExtent: 1000, // Cache more items for smoother scrolling
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == _currentUserId;
                final showDate = index == messages.length - 1 ||
                    _shouldShowDate(messages, index);

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 20.0,
                    child: FadeInAnimation(
                      child: Column(
                        children: [
                          if (showDate)
                            _buildDateSeparator(message.createdAt, theme),
                          MessageBubble(
                            message: message,
                            isMe: isMe,
                            showStatus: true,
                            isNew: message.id.startsWith('temp_'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  bool _shouldShowDate(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;

    final currentDate = DateTime(
      messages[index].createdAt.year,
      messages[index].createdAt.month,
      messages[index].createdAt.day,
    );

    final previousDate = DateTime(
      messages[index + 1].createdAt.year,
      messages[index + 1].createdAt.month,
      messages[index + 1].createdAt.day,
    );

    return currentDate != previousDate;
  }

  Future<void> _pickFile() async {
    setState(() => _isUploading = true);

    try {
      final fileData = await WebFilePicker.pickFile();
      if (fileData != null) {
        final fileName = fileData['name'] as String;
        final fileBytes = fileData['bytes'] as Uint8List;
        final fileSize = fileData['size'] as int;

        // Detect mime type using filename and bytes (headerBytes optional but improves detection)
        final mimeType = lookupMimeType(fileName, headerBytes: fileBytes) ?? 'application/octet-stream';

        const maxSize = 10 * 1024 * 1024; // 10 MB limit
        if (fileSize > maxSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File size exceeds 10MB limit'), backgroundColor: Colors.red),
          );
          return;
        }

        if (_selectedFiles.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 5 attachments allowed'), backgroundColor: Colors.red),
          );
          return;
        }

        setState(() {
          _selectedFiles.add({
            'name': fileName,
            'size': fileSize,
            'bytes': fileBytes,
            'mime': mimeType,
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildDateSeparator(DateTime date, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDate(date),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return DateFormat('MMMM d, y').format(date); // Full date
    }
  }

  Widget _buildSearchBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearching ? 56 : 0,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: _isSearching ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search in conversation...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            )
          : null,
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading messages...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation by sending a message',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _messageFocusNode.requestFocus();
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Start Typing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget docItem(String name, Map<String, bool> downloadedDocs,
      BuildContext context, void Function(String) onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              color: downloadedDocs[name] ?? false
                  ? Colors.green
                  : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDots(colorScheme),
            const SizedBox(width: 8),
            Text(
              'Typing...',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDots(ColorScheme colorScheme) {
    return SizedBox(
      width: 24,
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              final sinValue = (value + (index * 0.3)) % 1.0;
              final size = 4.0 +
                  4.0 * (sinValue < 0.5 ? sinValue * 2 : (1.0 - sinValue) * 2);

              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
