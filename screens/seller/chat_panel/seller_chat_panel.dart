import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:jewellery_diamond/screens/seller/chat_panel/seller_chat_message.dart';

import '../../../bloc/chat_bloc/chat_bloc.dart';
import '../../../bloc/chat_bloc/chat_event.dart';
import '../../../bloc/chat_bloc/chat_state.dart';
import '../../../models/chat_room_model.dart';
import '../../../models/product_response_model.dart';
import '../../../services/api/product_service.dart';

class SellerChatPanel extends StatefulWidget {
  static const String routeName = '/user/chat-panel';

  const SellerChatPanel({super.key});

  @override
  State<SellerChatPanel> createState() => _SellerChatPanelState();
}

class _SellerChatPanelState extends State<SellerChatPanel> {
  bool showRightPanel = false;
  String selectedTab = "Stones";
  int selectedConversation = 0;
  String searchQuery = "";
  ChatRoom? _selectedRoom;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController messageController = TextEditingController();

  final List<Map<String, dynamic>> stonesList = [
    {
      "name": "John Smith",
      "id": "DIA-2024-001",
      "message": "Can you confirm the clarity grade?",
      "status": "Available",
      "time": "10:30 AM",
      "avatar": "https://via.placeholder.com/40",
      "messages": [
        {
          "text": "Hi, I'm interested in DIA-2024-001",
          "isSender": false,
          "time": "10:25 AM"
        },
        {
          "text":
              "Hello! Yes, I have that stone available. It's a 2.5 carat VS1 diamond with excellent cut.",
          "isSender": true,
          "time": "10:27 AM"
        },
        {
          "text": "Can you share more details about the clarity grade?",
          "isSender": false,
          "time": "10:30 AM"
        },
        {
          "text":
              "Of course! The clarity grade is VS1 with only two minor inclusions that are difficult to see under 10x magnification.",
          "isSender": true,
          "time": "10:32 AM"
        },
      ]
    },
    {
      "name": "Emma Wilson",
      "id": "DIA-2024-002",
      "message": "Perfect, I'll proceed with the purchase",
      "status": "Sold",
      "time": "9:45 AM",
      "avatar": "https://via.placeholder.com/40",
      "messages": [
        {
          "text": "Perfect, I'll proceed with the purchase",
          "isSender": false,
          "time": "9:45 AM"
        },
      ]
    },
    {
      "name": "Michael Brown",
      "id": "DIA-2024-003",
      "message": "What's the current asking price?",
      "status": "Pending",
      "time": "Yesterday",
      "avatar": "https://via.placeholder.com/40",
      "messages": [
        {
          "text": "What's the current asking price?",
          "isSender": false,
          "time": "Yesterday"
        },
      ]
    },
  ];
  final Map<String, bool> downloadedDocs = {};
  final List<Map<String, dynamic>> buyersList = [
    {
      "name": "Sarah Lee",
      "id": "BUY-2024-001",
      "message": "Looking for a 3ct emerald cut",
      "status": "Active",
      "time": "Yesterday",
      "avatar": "https://via.placeholder.com/40",
      "messages": [
        {
          "text": "Looking for a 3ct emerald cut",
          "isSender": false,
          "time": "Yesterday"
        },
      ]
    },
  ];

  Product? selectedProduct;

  final ProductService _productService = ProductService();

  String? selectedRoomId;

  List<Map<String, dynamic>> get currentList =>
      selectedTab == "Stones" ? stonesList : buyersList;

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

  Map<String, dynamic> _currentChat() => currentList[selectedConversation];

  @override
  void initState() {
    print("SellerChatPanel initState");
    context.read<ChatBloc>().add(InitializeChat());
    context.read<ChatBloc>().add(FetchChatRooms());
    // context.read<ChatBloc>().add(FetchUnreadCounts());
    super.initState();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        setState(() {});
      }
    });
  }

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
      selectedRoomId = room.id;
      // _currentMessages = List<Map<String, dynamic>>.from(room.messages ?? []);
      messages.clear();
    });
    context.read<ChatBloc>().add(JoinChatRoom(roomId: room.id));
    // context.read<ChatBloc>().add(FetchChatMessages(
    //       roomId: room.id,
    //       refresh: true,
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Container(
              width: 350,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFE5E5EA))),
              ),
              child: _buildChatList(theme)),
          Expanded(
            flex: 2,
            child: _selectedRoom == null
                ? _buildEmptyDetailView(theme)
                : SellerChatMessage(
                    key: ValueKey(_selectedRoom!.id),
                    roomId: _selectedRoom!.id,
                    room: _selectedRoom,
                    productId: _selectedRoom!.productId,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title) {
    final isActive = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title;
            selectedConversation = 0;
            searchQuery = '';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF871437) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case "Available":
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        break;
      case "Sold":
        bgColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        break;
      case "Pending":
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        break;
      case "Active":
        bgColor = const Color(0xFFD1ECF1);
        textColor = const Color(0xFF0C5460);
        break;
      default:
        bgColor = Colors.grey.shade300;
        textColor = Colors.grey.shade800;
    }
    return Container(
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 10),
      ),
    );
  }

  Widget _buildEmptyDetailView(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Select a conversation',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose a conversation from the list to start chatting',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Conversations are linked to product inquiries',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Conversations',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      // Search toggle button
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Icon(
                            _isSearching ? Icons.close : Icons.search,
                            key: ValueKey<bool>(_isSearching),
                            color: _isSearching
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onPressed: _toggleSearch,
                        tooltip: _isSearching ? 'Cancel' : 'Search',
                        style: IconButton.styleFrom(
                          backgroundColor: _isSearching
                              ? colorScheme.primaryContainer.withOpacity(0.2)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      BlocBuilder<ChatBloc, ChatState>(
                        buildWhen: (previous, current) =>
                            current is WebSocketStatus,
                        builder: (context, state) {
                          final isConnected = state is WebSocketStatus
                              ? state.isConnected
                              : false;
                          return Tooltip(
                            message: isConnected
                                ? 'Connected'
                                : 'Disconnected - Reconnecting...',
                            child: Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: isConnected ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isConnected
                                            ? Colors.green
                                            : Colors.red)
                                        .withOpacity(0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isSearching ? 48 : 0,
                margin: EdgeInsets.only(top: _isSearching ? 16 : 0),
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          prefixIcon: Icon(
                            Icons.search,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      )
                    : null,
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              //   child: Row(
              //     children: [
              //       _tabButton("Stones"),
              //       const SizedBox(width: 8),
              //       _tabButton("Buyers"),
              //     ],
              //   ),
              // ),
              const Text(
                "Filter by category",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) =>
                current is ChatLoading ||
                current is ChatRoomsLoaded ||
                current is ChatRoomsLoading ||
                current is ChatRoomsError ||
                current is ChatError,
            builder: (context, state) {
              if (state is ChatLoading &&
                  state.previousState is! ChatRoomsLoaded) {
                return _buildLoadingState(theme);
              }
              // Show rooms or loading with previous rooms
              List<ChatRoom>? rooms;
              if (state is ChatRoomsLoaded) {
                rooms = state.rooms;
              } else if (state is ChatRoomsLoading &&
                  state.previousRooms != null) {
                rooms = state.previousRooms;
              } else if (state is ChatRoomsError &&
                  state.previousRooms != null) {
                rooms = state.previousRooms;

                // Show error snackbar but still display previous rooms
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: colorScheme.onError,
                        onPressed: () {
                          context.read<ChatBloc>().add(FetchChatRooms());
                        },
                      ),
                    ),
                  );
                });
              }
              if (rooms != null) {
                return _buildChatRoomsList(rooms, theme);
              } else if (state is ChatRoomsError || state is ChatError) {
                return _buildErrorState(
                    state is ChatRoomsError
                        ? state.message
                        : (state as ChatError).message,
                    theme);
              }
              return _buildEmptyState(theme);
            },
          ),
        ),
      ],
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
              'No conversations yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'When you start conversations about products, they will appear here',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading conversations...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ThemeData theme) {
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
                color: colorScheme.errorContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load conversations',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatBloc>().add(FetchChatRooms());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
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

  Widget _buildChatRoomsList(List<ChatRoom> rooms, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    // Filter rooms based on search query
    final filteredRooms = _searchController.text.isEmpty
        ? rooms
        : rooms.where((room) {
            final query = _searchController.text.toLowerCase();
            return room.product.name.toLowerCase().contains(query) ||
                (room.lastMessage?.content.toLowerCase().contains(query) ??
                    false);
          }).toList();

    if (filteredRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _searchController.text.isEmpty
                      ? Icons.chat_bubble_outline_rounded
                      : Icons.search_off_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _searchController.text.isEmpty
                    ? 'No conversations yet'
                    : 'No matching conversations',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isEmpty
                    ? 'When you start conversations about products, they will appear here'
                    : 'Try a different search term',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Animated list of chat rooms
    return AnimationLimiter(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredRooms.length,
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0,
          );
        },
        itemBuilder: (context, index) {
          final room = filteredRooms[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildChatRoomTile(room, theme),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom room, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          current is UnreadCountsLoaded ||
          (current is ChatMessagesLoaded && current.roomId == room.id),
      builder: (context, state) {
        int unreadCount = room.unreadCount;
        bool hasTypingUsers = false;

        if (state is UnreadCountsLoaded) {
          unreadCount = state.counts[room.id] ?? 0;
        }

        if (state is ChatMessagesLoaded && state.roomId == room.id) {
          hasTypingUsers = state.typingUsers.values.any((isTyping) => isTyping);
        }

        final isSelected = _selectedRoom?.id == room.id;
        final product = room.product;
        final buyer = room.otherUser;
        final lastMessage = room.lastMessage;

        return InkWell(
          onTap: () {
            // Add haptic feedback
            HapticFeedback.lightImpact();

            // Select the room and fetch messages
            _selectRoom(room);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDEDEF) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.images.isEmpty
                      ? Image.network(
                          room.product.images.first,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 56,
                              height: 56,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          child: Icon(
                            Icons.diamond_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyer!.name ?? "",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(product.stock_number,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage?.content ?? "",
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      _statusPill(product.status),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(_formatTime(room.lastActivity),
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays >= 1) {
      // Format as dd-MM-yyyy
      return '${time.day.toString().padLeft(2, '0')}-'
          '${time.month.toString().padLeft(2, '0')}-'
          '${time.year}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    }
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
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
//
// class SellerChatListItem extends StatelessWidget {
//   final ChatRoom room;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const SellerChatListItem({
//     super.key,
//     required this.room,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   Widget _statusPill(String status) {
//     Color bg;
//     Color text;
//     switch (status.toLowerCase()) {
//       case "online":
//         bg = Colors.green.withOpacity(0.1);
//         text = Colors.green;
//         break;
//       case "offline":
//         bg = Colors.red.withOpacity(0.1);
//         text = Colors.red;
//         break;
//       default:
//         bg = Colors.grey.withOpacity(0.1);
//         text = Colors.grey;
//     }
//     return Container(
//       margin: const EdgeInsets.only(top: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: text,
//           fontSize: 10,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final product = room.product;
//     final buyer = room.otherUser;
//     final lastMessage = room.lastMessage;
//
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           decoration: BoxDecoration(
//             color: isSelected ? const Color(0xFFFDEDEF) : Colors.transparent,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//           margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 22,
//                 backgroundImage: NetworkImage(product.images.first),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(buyer!.name ?? "",
//                         style: const TextStyle(
//                             fontWeight: FontWeight.w600, fontSize: 14)),
//                     Text(product.stock_number,
//                         style:
//                             const TextStyle(fontSize: 12, color: Colors.grey)),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             lastMessage?.content ?? "",
//                             style: const TextStyle(
//                                 fontSize: 11, color: Colors.grey),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     _statusPill(product.status),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(_formatTime(room.lastActivity),
//                   style: const TextStyle(fontSize: 11, color: Colors.grey)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatTime(DateTime? time) {
//     if (time == null) return '';
//     final now = DateTime.now();
//     final difference = now.difference(time);
//
//     if (difference.inDays >= 1) {
//       // Format as dd-MM-yyyy
//       return '${time.day.toString().padLeft(2, '0')}-'
//           '${time.month.toString().padLeft(2, '0')}-'
//           '${time.year}';
//     } else {
//       return '${time.hour.toString().padLeft(2, '0')}:'
//           '${time.minute.toString().padLeft(2, '0')}';
//     }
//   }
// }
