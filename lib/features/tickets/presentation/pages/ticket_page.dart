import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';

class TicketPage extends ConsumerStatefulWidget {
  const TicketPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends ConsumerState<TicketPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _ticketData;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  void _loadTicket() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with real API call
      // final ticketRepository = TicketRepository(DioClient());
      // _ticketData = await ticketRepository.getTicketByBookingId(widget.bookingId);

      // For now, set empty data
      _ticketData = null;
    } catch (e) {
      // Handle error
      _ticketData = null;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vé điện tử')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_ticketData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vé điện tử')),
        body: const Center(child: Text('Không tìm thấy thông tin vé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé điện tử'),
        actions: [
          IconButton(
            onPressed: _shareTicket,
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ vé',
          ),
          IconButton(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download),
            tooltip: 'Tải PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Ticket card
            _buildTicketCard(theme),

            const SizedBox(height: 24),

            // QR Code
            _buildQRCode(theme),

            const SizedBox(height: 24),

            // Important notes
            _buildImportantNotes(theme),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(ThemeData theme) {
    final ticket = _ticketData!;
    final trip = ticket['trip'] as Map<String, dynamic>;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header with status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightSuccess,
                  AppColors.lightSuccess.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  'VÉ ĐÃ XÁC NHẬN',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mã đặt vé: ${ticket['bookingId']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Flight info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route and time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['departTime'],
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(trip['from'], style: theme.textTheme.bodyLarge),
                          Text(
                            _formatDate(trip['departDate']),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip['duration'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trip['arriveTime'],
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            trip['to'],
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            _formatDate(
                              trip['arriveDate'] ?? trip['departDate'],
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Passenger and seat info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        theme,
                        'Hành khách',
                        ticket['passengerName'],
                        Icons.person,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        theme,
                        'Ghế',
                        ticket['seatNumber'],
                        Icons.airline_seat_recline_normal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        theme,
                        'Hãng bay',
                        trip['carrier'],
                        Icons.flight,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        theme,
                        'Số hiệu',
                        trip['flightNumber'],
                        Icons.confirmation_number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Mã QR check-in',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: QrImageView(
                data: _ticketData!['qrData'],
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vui lòng xuất trình mã QR này tại quầy check-in',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantNotes(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Lưu ý quan trọng',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNoteItem('Có mặt tại sân bay trước giờ bay ít nhất 2 tiếng'),
            _buildNoteItem('Mang theo giấy tờ tùy thân có ảnh và còn hiệu lực'),
            _buildNoteItem('Kiểm tra kỹ hành lý theo quy định của hãng bay'),
            _buildNoteItem('Vé điện tử có giá trị như vé giấy truyền thống'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                onPressed: _downloadPdf,
                text: 'Tải PDF',
                type: AppButtonType.outline,
                icon: Icons.download,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                onPressed: _shareTicket,
                text: 'Chia sẻ',
                icon: Icons.share,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            onPressed: _addToWallet,
            text: 'Thêm vào ví điện tử',
            type: AppButtonType.outline,
            icon: Icons.wallet,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareTicket() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chia sẻ vé sẽ được cập nhật sau'),
      ),
    );
  }

  void _downloadPdf() {
    // TODO: Implement PDF download
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đang tải PDF...')));
  }

  void _addToWallet() {
    // TODO: Implement add to wallet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng thêm vào ví sẽ được cập nhật sau'),
      ),
    );
  }
}
