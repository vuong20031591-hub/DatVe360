import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/ticket_provider.dart';

class TicketPage extends ConsumerWidget {
  const TicketPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ticketDataAsync = ref.watch(ticketDataProvider(bookingId));

    return ticketDataAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Vé điện tử')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Vé điện tử')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Có lỗi xảy ra', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                onPressed: () {
                  ref.invalidate(ticketDataProvider(bookingId));
                },
                text: 'Thử lại',
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
      data: (ticketState) {
        if (ticketState.booking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Vé điện tử')),
            body: const Center(child: Text('Không tìm thấy thông tin vé')),
          );
        }

        final booking = ticketState.booking!;
        final tickets = ticketState.tickets;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Vé điện tử'),
            actions: [
              IconButton(
                onPressed: () => _shareTicket(context),
                icon: const Icon(Icons.share),
                tooltip: 'Chia sẻ vé',
              ),
              IconButton(
                onPressed: () => _downloadPdf(context, ref),
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
                _buildTicketCard(theme, booking, tickets),

                const SizedBox(height: 24),

                // QR Code
                _buildQRCode(theme, tickets.isNotEmpty ? tickets.first : null),

                const SizedBox(height: 24),

                // Important notes
                _buildImportantNotes(theme),

                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(context, ref),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(
    ThemeData theme,
    Map<String, dynamic> booking,
    List<Map<String, dynamic>> tickets,
  ) {
    final schedule = booking['scheduleId'] as Map<String, dynamic>?;
    final passenger = booking['passengers']?.isNotEmpty == true
        ? booking['passengers'][0] as Map<String, dynamic>
        : null;

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
                const Icon(Icons.check_circle, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  'VÉ ĐÃ XÁC NHẬN',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mã đặt vé: ${booking['pnr'] ?? 'N/A'}',
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
                            _formatTime(schedule?['departureTime']),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            schedule?['route']?['from']?['name'] ?? 'N/A',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            _formatDate(schedule?['departureTime']),
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
                          _calculateDuration(
                            schedule?['departureTime'],
                            schedule?['arrivalTime'],
                          ),
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
                            _formatTime(schedule?['arrivalTime']),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            schedule?['route']?['to']?['name'] ?? 'N/A',
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            _formatDate(schedule?['arrivalTime']),
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
                        passenger != null
                            ? '${passenger['firstName'] ?? ''} ${passenger['lastName'] ?? ''}'
                                  .trim()
                            : 'N/A',
                        Icons.person,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        theme,
                        'Ghế',
                        passenger?['seatNumber'] ?? 'N/A',
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
                        schedule?['carrier'] ?? 'N/A',
                        Icons.flight,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        theme,
                        'Số hiệu',
                        schedule?['vehicleNumber'] ?? 'N/A',
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

  Widget _buildQRCode(ThemeData theme, Map<String, dynamic>? ticket) {
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
              child: ticket != null && ticket['qrData'] != null
                  ? QrImageView(
                      data: ticket['qrData'],
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    )
                  : Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'QR Code không khả dụng',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
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
            _buildNoteItem(
              'Có mặt tại sân bay trước giờ bay ít nhất 2 tiếng',
              theme,
            ),
            _buildNoteItem(
              'Mang theo giấy tờ tùy thân có ảnh và còn hiệu lực',
              theme,
            ),
            _buildNoteItem(
              'Kiểm tra kỹ hành lý theo quy định của hãng bay',
              theme,
            ),
            _buildNoteItem(
              'Vé điện tử có giá trị như vé giấy truyền thống',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(String text, ThemeData theme) {
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                onPressed: () => _downloadPdf(context, ref),
                text: 'Tải PDF',
                type: AppButtonType.outline,
                icon: Icons.download,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                onPressed: () => _shareTicket(context),
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
            onPressed: () => _addToWallet(context),
            text: 'Thêm vào ví điện tử',
            type: AppButtonType.outline,
            icon: Icons.wallet,
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    DateTime date;
    if (dateTime is String) {
      try {
        date = DateTime.parse(dateTime);
      } catch (e) {
        return 'N/A';
      }
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'N/A';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    DateTime date;
    if (dateTime is String) {
      try {
        date = DateTime.parse(dateTime);
      } catch (e) {
        return 'N/A';
      }
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'N/A';
    }

    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(dynamic departureTime, dynamic arrivalTime) {
    if (departureTime == null || arrivalTime == null) return 'N/A';

    try {
      DateTime departure = departureTime is String
          ? DateTime.parse(departureTime)
          : departureTime as DateTime;
      DateTime arrival = arrivalTime is String
          ? DateTime.parse(arrivalTime)
          : arrivalTime as DateTime;

      Duration duration = arrival.difference(departure);
      int hours = duration.inHours;
      int minutes = duration.inMinutes % 60;

      return '${hours}h ${minutes}m';
    } catch (e) {
      return 'N/A';
    }
  }

  void _shareTicket(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chia sẻ vé sẽ được cập nhật sau'),
      ),
    );
  }

  void _downloadPdf(BuildContext context, WidgetRef ref) {
    // TODO: Implement PDF download
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đang tải PDF...')));
  }

  void _addToWallet(BuildContext context) {
    // TODO: Implement add to wallet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng thêm vào ví sẽ được cập nhật sau'),
      ),
    );
  }
}
