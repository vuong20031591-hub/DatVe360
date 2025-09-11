import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';

class FAQPage extends ConsumerStatefulWidget {
  const FAQPage({super.key});

  @override
  ConsumerState<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends ConsumerState<FAQPage> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Câu hỏi thường gặp'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm câu hỏi...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(context, theme),
          Expanded(
            child: _buildFAQList(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ThemeData theme) {
    final categories = [
      {'id': 'all', 'name': 'Tất cả', 'icon': Icons.all_inclusive},
      {'id': 'booking', 'name': 'Đặt vé', 'icon': Icons.book_online},
      {'id': 'payment', 'name': 'Thanh toán', 'icon': Icons.payment},
      {'id': 'cancellation', 'name': 'Hủy vé', 'icon': Icons.cancel},
      {'id': 'support', 'name': 'Hỗ trợ', 'icon': Icons.support_agent},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? theme.colorScheme.onPrimary : null,
                  ),
                  const SizedBox(width: 4),
                  Text(category['name'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id'] as String;
                });
              },
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQList(BuildContext context, ThemeData theme) {
    final faqs = _getFilteredFAQs();

    if (faqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy câu hỏi nào',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return _buildFAQItem(context, theme, faq);
      },
    );
  }

  Widget _buildFAQItem(BuildContext context, ThemeData theme, Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          _getCategoryIcon(faq['category']),
          color: _getCategoryColor(faq['category']),
        ),
        title: Text(
          faq['question'],
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq['answer'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                if (faq['helpful'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Câu trả lời này có hữu ích không?',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _markHelpful(faq, true),
                        icon: const Icon(Icons.thumb_up, size: 16),
                        label: const Text('Có'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _markHelpful(faq, false),
                        icon: const Icon(Icons.thumb_down, size: 16),
                        label: const Text('Không'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFAQs() {
    var faqs = _getAllFAQs();

    // Filter by category
    if (_selectedCategory != 'all') {
      faqs = faqs.where((faq) => faq['category'] == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      faqs = faqs.where((faq) {
        final question = faq['question'].toString().toLowerCase();
        final answer = faq['answer'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return question.contains(query) || answer.contains(query);
      }).toList();
    }

    return faqs;
  }

  List<Map<String, dynamic>> _getAllFAQs() {
    return [
      {
        'category': 'booking',
        'question': 'Làm thế nào để đặt vé?',
        'answer': 'Bạn có thể đặt vé bằng cách: 1) Chọn điểm đi và điểm đến, 2) Chọn ngày khởi hành, 3) Chọn số lượng hành khách, 4) Tìm kiếm và chọn chuyến phù hợp, 5) Điền thông tin hành khách và thanh toán.',
        'helpful': null,
      },
      {
        'category': 'booking',
        'question': 'Tôi có thể đặt vé cho người khác không?',
        'answer': 'Có, bạn có thể đặt vé cho người khác. Chỉ cần điền đúng thông tin của hành khách khi đặt vé.',
        'helpful': null,
      },
      {
        'category': 'payment',
        'question': 'Những phương thức thanh toán nào được hỗ trợ?',
        'answer': 'Chúng tôi hỗ trợ thanh toán qua: Thẻ tín dụng/ghi nợ (Visa, Mastercard), Ví điện tử (MoMo, ZaloPay, VNPay), Chuyển khoản ngân hàng.',
        'helpful': null,
      },
      {
        'category': 'payment',
        'question': 'Thanh toán có an toàn không?',
        'answer': 'Tất cả giao dịch thanh toán đều được mã hóa SSL 256-bit và tuân thủ tiêu chuẩn bảo mật PCI DSS. Thông tin thẻ của bạn được bảo vệ tuyệt đối.',
        'helpful': null,
      },
      {
        'category': 'cancellation',
        'question': 'Tôi có thể hủy vé không?',
        'answer': 'Có, bạn có thể hủy vé tùy theo điều kiện của từng hãng. Phí hủy và thời gian hủy sẽ khác nhau. Vui lòng kiểm tra điều kiện hủy trước khi đặt vé.',
        'helpful': null,
      },
      {
        'category': 'cancellation',
        'question': 'Làm thế nào để hoàn tiền?',
        'answer': 'Sau khi hủy vé thành công, tiền sẽ được hoàn lại vào tài khoản thanh toán của bạn trong vòng 7-14 ngày làm việc.',
        'helpful': null,
      },
      {
        'category': 'support',
        'question': 'Làm thế nào để liên hệ hỗ trợ?',
        'answer': 'Bạn có thể liên hệ hỗ trợ qua: Hotline: 1900-xxxx (24/7), Email: support@datve360.com, Chat trực tuyến trong ứng dụng.',
        'helpful': null,
      },
      {
        'category': 'support',
        'question': 'Tôi quên mã đặt chỗ, làm sao để tìm lại?',
        'answer': 'Bạn có thể tìm lại mã đặt chỗ bằng cách: 1) Kiểm tra email xác nhận, 2) Đăng nhập vào tài khoản và xem lịch sử đặt vé, 3) Liên hệ hotline với thông tin cá nhân.',
        'helpful': null,
      },
    ];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'booking':
        return Icons.book_online;
      case 'payment':
        return Icons.payment;
      case 'cancellation':
        return Icons.cancel;
      case 'support':
        return Icons.support_agent;
      default:
        return Icons.help;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'booking':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'cancellation':
        return Colors.orange;
      case 'support':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _markHelpful(Map<String, dynamic> faq, bool helpful) {
    setState(() {
      faq['helpful'] = helpful;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(helpful ? 'Cảm ơn phản hồi của bạn!' : 'Chúng tôi sẽ cải thiện câu trả lời này'),
      ),
    );
  }
}
