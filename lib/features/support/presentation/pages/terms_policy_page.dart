import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';

class TermsPolicyPage extends ConsumerStatefulWidget {
  const TermsPolicyPage({super.key});

  @override
  ConsumerState<TermsPolicyPage> createState() => _TermsPolicyPageState();
}

class _TermsPolicyPageState extends ConsumerState<TermsPolicyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính sách & Điều khoản'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Điều khoản'),
            Tab(text: 'Bảo mật'),
            Tab(text: 'Hoàn tiền'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTermsOfService(context, theme),
          _buildPrivacyPolicy(context, theme),
          _buildRefundPolicy(context, theme),
        ],
      ),
    );
  }

  Widget _buildTermsOfService(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, 'Điều khoản sử dụng'),
          _buildLastUpdated(theme, '15/12/2024'),
          const SizedBox(height: 16),
          
          _buildSection(
            theme,
            '1. Chấp nhận điều khoản',
            'Bằng việc sử dụng ứng dụng DatVe360, bạn đồng ý tuân thủ và bị ràng buộc bởi các điều khoản và điều kiện sử dụng này. Nếu bạn không đồng ý với bất kỳ phần nào của các điều khoản này, vui lòng không sử dụng dịch vụ của chúng tôi.',
          ),
          
          _buildSection(
            theme,
            '2. Mô tả dịch vụ',
            'DatVe360 là nền tảng đặt vé trực tuyến cho các phương tiện giao thông bao gồm máy bay, tàu hỏa, xe khách và phà. Chúng tôi cung cấp dịch vụ tìm kiếm, so sánh và đặt vé từ các nhà cung cấp dịch vụ vận chuyển.',
          ),
          
          _buildSection(
            theme,
            '3. Tài khoản người dùng',
            'Để sử dụng một số tính năng của dịch vụ, bạn cần tạo tài khoản. Bạn có trách nhiệm bảo mật thông tin tài khoản và chịu trách nhiệm về tất cả hoạt động diễn ra dưới tài khoản của mình.',
          ),
          
          _buildSection(
            theme,
            '4. Đặt vé và thanh toán',
            'Khi đặt vé qua DatVe360, bạn đồng ý thanh toán đầy đủ chi phí vé và các phí dịch vụ liên quan. Tất cả giao dịch thanh toán đều được xử lý an toàn thông qua các cổng thanh toán được chứng nhận.',
          ),
          
          _buildSection(
            theme,
            '5. Hủy và hoàn tiền',
            'Chính sách hủy và hoàn tiền tuân theo quy định của từng nhà cung cấp dịch vụ vận chuyển. DatVe360 sẽ hỗ trợ xử lý các yêu cầu hủy và hoàn tiền theo chính sách được quy định.',
          ),
          
          _buildSection(
            theme,
            '6. Trách nhiệm của người dùng',
            'Người dùng cam kết cung cấp thông tin chính xác, không sử dụng dịch vụ cho mục đích bất hợp pháp, và tuân thủ các quy định của pháp luật hiện hành.',
          ),
          
          _buildSection(
            theme,
            '7. Giới hạn trách nhiệm',
            'DatVe360 không chịu trách nhiệm về các thiệt hại gián tiếp, ngẫu nhiên hoặc hậu quả phát sinh từ việc sử dụng dịch vụ. Trách nhiệm của chúng tôi được giới hạn trong phạm vi cho phép của pháp luật.',
          ),
          
          _buildSection(
            theme,
            '8. Thay đổi điều khoản',
            'DatVe360 có quyền thay đổi các điều khoản này bất cứ lúc nào. Các thay đổi sẽ có hiệu lực ngay khi được đăng tải trên ứng dụng.',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, 'Chính sách bảo mật'),
          _buildLastUpdated(theme, '15/12/2024'),
          const SizedBox(height: 16),
          
          _buildSection(
            theme,
            '1. Thu thập thông tin',
            'Chúng tôi thu thập thông tin cá nhân khi bạn đăng ký tài khoản, đặt vé, hoặc liên hệ với chúng tôi. Thông tin bao gồm: họ tên, email, số điện thoại, thông tin thanh toán và lịch sử giao dịch.',
          ),
          
          _buildSection(
            theme,
            '2. Sử dụng thông tin',
            'Thông tin cá nhân được sử dụng để: xử lý đặt vé, cung cấp dịch vụ khách hàng, gửi thông báo quan trọng, cải thiện dịch vụ và tuân thủ các yêu cầu pháp lý.',
          ),
          
          _buildSection(
            theme,
            '3. Chia sẻ thông tin',
            'Chúng tôi không bán, cho thuê hoặc chia sẻ thông tin cá nhân với bên thứ ba, trừ khi: cần thiết để hoàn thành giao dịch, tuân thủ pháp luật, hoặc có sự đồng ý của bạn.',
          ),
          
          _buildSection(
            theme,
            '4. Bảo mật thông tin',
            'Chúng tôi áp dụng các biện pháp bảo mật kỹ thuật và tổ chức phù hợp để bảo vệ thông tin cá nhân khỏi truy cập trái phép, mất mát hoặc tiết lộ.',
          ),
          
          _buildSection(
            theme,
            '5. Cookie và công nghệ theo dõi',
            'Ứng dụng sử dụng cookie và các công nghệ tương tự để cải thiện trải nghiệm người dùng, phân tích sử dụng và cung cấp nội dung phù hợp.',
          ),
          
          _buildSection(
            theme,
            '6. Quyền của người dùng',
            'Bạn có quyền: truy cập, chỉnh sửa, xóa thông tin cá nhân; rút lại sự đồng ý; yêu cầu hạn chế xử lý; và khiếu nại với cơ quan có thẩm quyền.',
          ),
          
          _buildSection(
            theme,
            '7. Lưu trữ dữ liệu',
            'Thông tin cá nhân được lưu trữ trong thời gian cần thiết để cung cấp dịch vụ hoặc theo yêu cầu của pháp luật.',
          ),
          
          _buildSection(
            theme,
            '8. Liên hệ',
            'Nếu có câu hỏi về chính sách bảo mật, vui lòng liên hệ: privacy@datve360.com hoặc hotline 1900-xxxx.',
          ),
        ],
      ),
    );
  }

  Widget _buildRefundPolicy(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, 'Chính sách hoàn tiền'),
          _buildLastUpdated(theme, '15/12/2024'),
          const SizedBox(height: 16),
          
          _buildSection(
            theme,
            '1. Nguyên tắc chung',
            'Chính sách hoàn tiền áp dụng theo quy định của từng nhà cung cấp dịch vụ vận chuyển. DatVe360 đóng vai trò trung gian hỗ trợ xử lý các yêu cầu hoàn tiền.',
          ),
          
          _buildSection(
            theme,
            '2. Điều kiện hoàn tiền',
            'Hoàn tiền được áp dụng khi: hủy vé trong thời gian cho phép, chuyến bị hủy bởi nhà cung cấp, lỗi hệ thống dẫn đến đặt vé sai, hoặc các trường hợp bất khả kháng được quy định.',
          ),
          
          _buildSection(
            theme,
            '3. Thời gian hoàn tiền',
            'Máy bay: 24-72 giờ trước giờ khởi hành\nTàu hỏa: 4-24 giờ trước giờ khởi hành\nXe khách: 2-12 giờ trước giờ khởi hành\nPhà: 2-6 giờ trước giờ khởi hành',
          ),
          
          _buildSection(
            theme,
            '4. Phí hủy vé',
            'Phí hủy vé được tính theo quy định của từng hãng:\n- Hủy sớm: 10-20% giá vé\n- Hủy muộn: 30-50% giá vé\n- Hủy trong ngày: 50-100% giá vé',
          ),
          
          _buildSection(
            theme,
            '5. Quy trình hoàn tiền',
            '1. Gửi yêu cầu hủy vé qua ứng dụng\n2. Xác nhận điều kiện hủy và phí\n3. Xử lý yêu cầu trong 1-2 ngày làm việc\n4. Hoàn tiền về tài khoản thanh toán trong 7-14 ngày',
          ),
          
          _buildSection(
            theme,
            '6. Trường hợp đặc biệt',
            'Hoàn tiền 100% khi: chuyến bị hủy bởi hãng, thiên tai/dịch bệnh, lỗi hệ thống DatVe360, hoặc các trường hợp bất khả kháng khác.',
          ),
          
          _buildSection(
            theme,
            '7. Hỗ trợ khách hàng',
            'Đội ngũ hỗ trợ sẵn sàng giải đáp mọi thắc mắc về chính sách hoàn tiền qua hotline 1900-xxxx hoặc email support@datve360.com.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildLastUpdated(ThemeData theme, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Cập nhật lần cuối: $date',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
