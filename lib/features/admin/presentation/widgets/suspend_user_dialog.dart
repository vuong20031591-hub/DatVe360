import 'package:flutter/material.dart';
import '../../data/models/user_admin.dart';

class SuspendResult {
  final int durationInDays;
  final String reason;
  final bool isPermanent;

  SuspendResult({
    required this.durationInDays,
    required this.reason,
    required this.isPermanent,
  });
}

class SuspendUserDialog extends StatefulWidget {
  final UserAdmin user;

  const SuspendUserDialog({
    super.key,
    required this.user,
  });

  @override
  State<SuspendUserDialog> createState() => _SuspendUserDialogState();
}

class _SuspendUserDialogState extends State<SuspendUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  bool _isPermanent = false;
  int _selectedDuration = 7; // days

  final List<int> _durations = [1, 3, 7, 14, 30, 90, 180, 365];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _suspend() {
    if (_formKey.currentState!.validate()) {
      // Return result and close dialog
      Navigator.of(context).pop(
        SuspendResult(
          durationInDays: _selectedDuration,
          reason: _reasonController.text.trim(),
          isPermanent: _isPermanent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.block, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Khóa tài khoản',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: widget.user.avatar != null
                                  ? NetworkImage(widget.user.avatar!)
                                  : null,
                              child: widget.user.avatar == null
                                  ? Text(widget.user.displayName[0].toUpperCase())
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.user.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    widget.user.email,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Permanent suspension switch
                      SwitchListTile(
                        title: const Text(
                          'Khóa vĩnh viễn',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Người dùng sẽ không thể đăng nhập mãi mãi',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isPermanent,
                        onChanged: (value) {
                          setState(() => _isPermanent = value);
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.red,
                      ),
                      const SizedBox(height: 16),

                      // Duration (only if not permanent)
                      if (!_isPermanent) ...[
                        const Text(
                          'Thời gian khóa',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _durations.map((days) {
                            final isSelected = _selectedDuration == days;
                            return ChoiceChip(
                              label: Text(_getDurationLabel(days)),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedDuration = days);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Reason
                      const Text(
                        'Lý do khóa *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập lý do khóa tài khoản...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập lý do khóa';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Warning
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPermanent
                                        ? 'Người dùng sẽ bị khóa vĩnh viễn và không thể đăng nhập!'
                                        : 'Người dùng sẽ không thể đăng nhập!',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (!_isPermanent) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _getUnlockTimeInfo(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _suspend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPermanent ? Colors.red : Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isPermanent ? 'Khóa vĩnh viễn' : 'Khóa tài khoản'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDurationLabel(int days) {
    if (days == 1) return '1 ngày';
    if (days == 3) return '3 ngày';
    if (days == 7) return '1 tuần';
    if (days == 14) return '2 tuần';
    if (days == 30) return '1 tháng';
    if (days == 90) return '3 tháng';
    if (days == 180) return '6 tháng';
    if (days == 365) return '1 năm';
    return '$days ngày';
  }

  String _getUnlockTimeInfo() {
    final now = DateTime.now();
    DateTime unlockTime;

    if (_selectedDuration == 1) {
      // Khóa 1 ngày: mở lại vào đúng giờ này ngày mai
      unlockTime = now.add(const Duration(days: 1));
      return 'Mở khóa vào ${_formatDateTime(unlockTime)} (đúng giờ này ngày mai)';
    } else {
      // Khóa nhiều ngày: mở lại vào 6h sáng
      unlockTime = now.add(Duration(days: _selectedDuration));
      unlockTime = DateTime(
        unlockTime.year,
        unlockTime.month,
        unlockTime.day,
        6, // 6h sáng
        0,
        0,
      );
      return 'Mở khóa vào ${_formatDateTime(unlockTime)} (6h sáng)';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

