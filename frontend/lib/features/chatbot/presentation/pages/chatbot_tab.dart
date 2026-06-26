import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';

class ChatbotTab extends StatefulWidget {
  const ChatbotTab({super.key});

  @override
  State<ChatbotTab> createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<ChatbotTab> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _suggestions = [
    {
      'title': 'Calorie Check',
      'subtitle': 'Berapa kalori dalam sebutir telur rebus?',
      'icon': Icons.bookmark_outline_rounded,
    },
    {
      'title': 'Meal Ideas',
      'subtitle': 'Berikan ide makan malam tinggi protein.',
      'icon': Icons.restaurant_rounded,
    },
    {
      'title': 'Makanan khas Bogor',
      'subtitle': 'Berapa estimasi kalori Asinan Bogor?',
      'icon': Icons.camera_alt_outlined,
    },
    {
      'title': 'My Goals',
      'subtitle': 'Apakah makronutrisi saya hari ini aman?',
      'icon': Icons.person_outline_rounded,
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getFallbackResponse(String text) {
    final msg = text.toLowerCase();
    if (msg.contains('asinan')) {
      return 'Asinan Bogor memiliki estimasi sekitar 150 kkal per porsi. Hidangan segar ini kaya akan serat, Vitamin C, dan antioksidan karena terdiri dari buah-buahan dan sayuran segar dengan kuah asam pedas.';
    } else if (msg.contains('soto') || msg.contains('kuning')) {
      return 'Soto Kuning Bogor memiliki estimasi sekitar 350-400 kkal per porsi. Kandungan utamanya adalah protein dan lemak dari kuah santan serta kaldu daging.';
    } else if (msg.contains('telur')) {
      return 'Satu butir telur rebus mengandung sekitar 78 kkal, 6 gram protein berkualitas tinggi, serta vitamin D dan B12. Sangat baik untuk pemulihan otot.';
    } else if (msg.contains('makan') || msg.contains('ide') || msg.contains('saran')) {
      return 'Ide makan sehat tinggi protein: Dada ayam panggang dengan tumis brokoli dan nasi merah. Total kalori sekitar 450 kkal dengan kandungan protein sekitar 40g.';
    } else {
      return 'Halo! Saya adalah asisten gizi pintar Anda. Tanyakan kepada saya tentang estimasi kalori makanan khas Bogor (seperti Asinan atau Soto Kuning), rekomendasi gizi, atau tips diet Anda.';
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': DateTime.now(),
      });
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    final result = await _apiService.sendChatMessage(text);

    String reply;
    if (result['success'] == true) {
      reply = result['message'] ?? '';
    } else {
      reply = _getFallbackResponse(text);
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'sender': 'bot',
          'text': reply,
          'time': DateTime.now(),
        });
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _messages.isEmpty ? _buildWelcomeView() : _buildChatView(),
    );
  }

  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputBox(true),
          const SizedBox(height: 24),
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _suggestions[index];
              return _buildSuggestionCard(
                item['title'] as String,
                item['subtitle'] as String,
                item['icon'] as IconData,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Percakapan Aktif',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _messages.clear();
                  });
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Chat Baru',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return _buildTypingIndicator();
              }
              final msg = _messages[index];
              final isUser = msg['sender'] == 'user';
              return _buildChatBubble(msg['text'] as String, isUser);
            },
          ),
        ),
        _buildInputBox(false),
      ],
    );
  }

  Widget _buildInputBox(bool isWelcome) {
    return Padding(
      padding: EdgeInsets.only(
        left: isWelcome ? 0 : 24,
        right: isWelcome ? 0 : 24,
        bottom: isWelcome ? 0 : 16,
        top: isWelcome ? 0 : 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.smart_toy_outlined,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Tanya apa saja tentang nutrisi...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  Icon(
                    Icons.mic_none_rounded,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppTheme.neutralColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can I help you today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Saya asisten AI gizi Nutrify Anda. Tanyakan tentang meal planning, hitung kalori, atau kandungan gizi makanan untuk mencapai hidup sehat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () => _sendMessage(subtitle),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : const Color(0xFFF0FAF7),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.neutralColor,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppTheme.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF7),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  return const _BlinkingDot();
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
