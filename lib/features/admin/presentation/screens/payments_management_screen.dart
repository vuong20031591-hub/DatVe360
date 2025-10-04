import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/providers/payments_admin_provider.dart';
import '../../data/services/payments_admin_service.dart';

class PaymentsManagementScreen extends ConsumerStatefulWidget {
  const PaymentsManagementScreen({super.key});

  @override
  ConsumerState<PaymentsManagementScreen> createState() => _PaymentsManagementScreenState();
}

class _PaymentsManagementScreenState extends ConsumerState<PaymentsManagementScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  String? _selectedStatus;
  String? _selectedMethod;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(paymentsAdminProvider.notifier).loadPayments();
      ref.read(paymentsAdminProvider.notifier).loadStats();
    });
  }

  void _applyFilters() {
    ref.read(paymentsAdminProvider.notifier).loadPayments(
      status: _selectedStatus,
      paymentMethod: _selectedMethod,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedMethod = null;
      _fromDate = null;
      _toDate = null;
    });
    ref.read(paymentsAdminProvider.notifier).loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(paymentsAdminProvider);
    final stats = state.stats;

    return Scaffold(
      body: Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Quản lý thanh toán',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterDialog,
                      tooltip: 'Lọc',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        ref.read(paymentsAdminProvider.notifier).loadPayments();
                        ref.read(paymentsAdminProvider.notifier).loadStats();
                      },
                      tooltip: 'Làm mới',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stats != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Tổng GD', '${stats['total'] ?? 0}', Icons.receipt_long, Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Hoàn thành', '${stats['completed'] ?? 0}', Icons.check_circle, Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Doanh thu', _currencyFormat.format(stats['completedAmount'] ?? 0), Icons.attach_money, Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Chờ xử lý', '${stats['pending'] ?? 0}', Icons.pending, Colors.amber),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Active filters chips
          if (_selectedStatus != null || _selectedMethod != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Text('Bộ lọc: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  if (_selectedStatus != null)
                    Chip(
                      label: Text(_getStatusLabel(_selectedStatus!)),
                      onDeleted: () {
                        setState(() => _selectedStatus = null);
                        _applyFilters();
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                  if (_selectedMethod != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(_selectedMethod!.toUpperCase()),
                        onDeleted: () {
                          setState(() => _selectedMethod = null);
                          _applyFilters();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Xóa tất cả'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.payments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('Chưa có giao dịch'),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => ref.read(paymentsAdminProvider.notifier).loadPayments(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tải lại'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.payments.length,
                        itemBuilder: (context, index) {
                          final payment = state.payments[index];
                          final status = payment['status'] ?? 'unknown';
                          final amount = payment['amount'] ?? 0;
                          final method = payment['paymentMethod'] ?? 'unknown';
                          final transactionId = payment['transactionId'] ?? 'N/A';
                          final user = payment['userId'];
                          final userName = user != null ? (user['displayName'] ?? user['email'] ?? 'N/A') : 'N/A';
                          final createdAt = payment['createdAt'] != null
                              ? DateTime.parse(payment['createdAt'])
                              : null;

                          Color statusColor = _getStatusColor(status);
                          IconData statusIcon = _getStatusIcon(status);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => _showPaymentDetails(payment),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(statusIcon, color: statusColor),
                              ),
                              title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('ID: $transactionId', style: const TextStyle(fontSize: 12)),
                                  Text('PT: ${method.toUpperCase()}', style: const TextStyle(fontSize: 12)),
                                  if (createdAt != null)
                                    Text(_dateFormat.format(createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_currencyFormat.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(_getStatusLabel(status), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.replay;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Chờ xử lý';
      case 'failed':
        return 'Thất bại';
      case 'refunded':
        return 'Đã hoàn';
      default:
        return status.toUpperCase();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc thanh toán'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tất cả'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) => setState(() => _selectedStatus = null),
                  ),
                  FilterChip(
                    label: const Text('Hoàn thành'),
                    selected: _selectedStatus == 'completed',
                    onSelected: (selected) => setState(() => _selectedStatus = selected ? 'completed' : null),
                  ),
                  FilterChip(
                    label: const Text('Chờ xử lý'),
                    selected: _selectedStatus == 'pending',
                    onSelected: (selected) => setState(() => _selectedStatus = selected ? 'pending' : null),
                  ),
                  FilterChip(
                    label: const Text('Thất bại'),
                    selected: _selectedStatus == 'failed',
                    onSelected: (selected) => setState(() => _selectedStatus = selected ? 'failed' : null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Phương thức:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tất cả'),
                    selected: _selectedMethod == null,
                    onSelected: (selected) => setState(() => _selectedMethod = null),
                  ),
                  FilterChip(
                    label: const Text('VNPay'),
                    selected: _selectedMethod == 'vnpay',
                    onSelected: (selected) => setState(() => _selectedMethod = selected ? 'vnpay' : null),
                  ),
                  FilterChip(
                    label: const Text('MoMo'),
                    selected: _selectedMethod == 'momo',
                    onSelected: (selected) => setState(() => _selectedMethod = selected ? 'momo' : null),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              this.setState(() {});
              _applyFilters();
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) async {
    // Fetch full payment details
    final service = PaymentsAdminService();
    final paymentId = payment['_id'] ?? payment['id'];

    if (paymentId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await service.getPaymentById(paymentId);
      Navigator.pop(context); // Close loading

      if (!mounted) return;

      final fullPayment = response['data'];
      final status = fullPayment['status'] ?? 'unknown';
      final amount = fullPayment['amount'] ?? 0;
      final method = fullPayment['paymentMethod'] ?? 'N/A';
      final transactionId = fullPayment['transactionId'] ?? 'N/A';
      final user = fullPayment['userId'];
      final userName = user != null ? (user['displayName'] ?? user['email'] ?? 'N/A') : 'N/A';
      final userEmail = user?['email'] ?? 'N/A';
      final createdAt = fullPayment['createdAt'] != null
          ? DateTime.parse(fullPayment['createdAt'])
          : null;
      final completedAt = fullPayment['completedAt'] != null
          ? DateTime.parse(fullPayment['completedAt'])
          : null;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(_getStatusIcon(status), color: _getStatusColor(status)),
              const SizedBox(width: 8),
              const Expanded(child: Text('Chi tiết thanh toán')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Mã giao dịch', transactionId),
                _buildDetailRow('Trạng thái', _getStatusLabel(status)),
                _buildDetailRow('Số tiền', _currencyFormat.format(amount)),
                _buildDetailRow('Phương thức', method.toUpperCase()),
                const Divider(height: 24),
                _buildDetailRow('Khách hàng', userName),
                _buildDetailRow('Email', userEmail),
                const Divider(height: 24),
                if (createdAt != null)
                  _buildDetailRow('Thời gian tạo', _dateFormat.format(createdAt)),
                if (completedAt != null)
                  _buildDetailRow('Hoàn thành lúc', _dateFormat.format(completedAt)),
              ],
            ),
          ),
          actions: [
            if (status == 'completed')
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showRefundDialog(paymentId, amount);
                },
                icon: const Icon(Icons.replay),
                label: const Text('Hoàn tiền'),
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(String paymentId, double amount) {
    final refundAmountController = TextEditingController(text: amount.toString());
    final refundReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn tiền'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: refundAmountController,
              decoration: InputDecoration(
                labelText: 'Số tiền hoàn',
                hintText: 'Nhập số tiền',
                prefixText: '₫ ',
                border: const OutlineInputBorder(),
                helperText: 'Tối đa: ${_currencyFormat.format(amount)}',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: refundReasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do hoàn tiền',
                hintText: 'Nhập lý do',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final refundAmount = double.tryParse(refundAmountController.text);
              final refundReason = refundReasonController.text.trim();

              if (refundAmount == null || refundAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Số tiền không hợp lệ')),
                );
                return;
              }

              if (refundAmount > amount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Số tiền hoàn không được lớn hơn số tiền gốc')),
                );
                return;
              }

              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              final success = await ref.read(paymentsAdminProvider.notifier).refundPayment(
                paymentId,
                refundAmount: refundAmount,
                refundReason: refundReason.isEmpty ? null : refundReason,
              );

              Navigator.pop(context); // Close loading

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Hoàn tiền thành công' : 'Hoàn tiền thất bại'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  ref.read(paymentsAdminProvider.notifier).loadStats();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận hoàn tiền'),
          ),
        ],
      ),
    );
  }
}
