import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/users_admin_provider.dart';
import '../../data/models/user_admin.dart';
import '../widgets/user_form_dialog.dart';

class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState
    extends ConsumerState<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, active, suspended, admin

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersAdminProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserAdmin> _getFilteredUsers(List<UserAdmin> users) {
    switch (_selectedFilter) {
      case 'active':
        return users.where((u) => u.isActive && !u.isSuspended).toList();
      case 'suspended':
        return users.where((u) => u.isSuspended).toList();
      case 'admin':
        return users.where((u) => u.role == 'admin' || u.role == 'operator').toList();
      default:
        return users;
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        onSave: (user, password) async {
          final success = await ref
              .read(usersAdminProvider.notifier)
              .createUser(user, password);

          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm người dùng mới')),
            );
          }
        },
      ),
    );
  }

  void _showEditUserDialog(UserAdmin user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        onSave: (updatedUser, _) async {
          final success = await ref
              .read(usersAdminProvider.notifier)
              .updateUser(user.id!, updatedUser);

          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật người dùng')),
            );
          }
        },
      ),
    );
  }

  Future<void> _showSuspendDialog(UserAdmin user) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Khóa tài khoản'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Khóa tài khoản: ${user.displayName}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do khóa *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lý do khóa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Người dùng sẽ bị khóa và không thể đăng nhập!',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Khóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(usersAdminProvider.notifier)
          .suspendUserPermanently(user.id!, reasonController.text.trim());

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã khóa tài khoản')),
        );
      }
    }

    reasonController.dispose();
  }

  Future<void> _unsuspendUser(UserAdmin user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận mở khóa'),
        content: Text('Bạn có chắc muốn mở khóa tài khoản "${user.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Mở khóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(usersAdminProvider.notifier)
          .unsuspendUser(user.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã mở khóa tài khoản')),
        );
      }
    }
  }

  Future<void> _showResetPasswordDialog(UserAdmin user) async {
    String? newPassword;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final passwordController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Reset mật khẩu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đặt lại mật khẩu cho: ${user.displayName}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  newPassword = passwordController.text;
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && newPassword != null) {
      final success = await ref
          .read(usersAdminProvider.notifier)
          .resetPassword(user.id!, newPassword!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã reset mật khẩu thành công')),
        );
      }
    }
  }

  Future<void> _deleteUser(UserAdmin user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa người dùng "${user.displayName}"?\n\n'
          'Hành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(usersAdminProvider.notifier)
          .deleteUser(user.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa người dùng')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersAdminProvider);
    final theme = Theme.of(context);
    final filteredUsers = _getFilteredUsers(state.users);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(usersAdminProvider.notifier).loadUsers();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(usersAdminProvider.notifier).loadUsers();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  ref.read(usersAdminProvider.notifier).loadUsers();
                } else {
                  ref.read(usersAdminProvider.notifier).searchUsers(value);
                }
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all', filteredUsers.length),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Hoạt động',
                  'active',
                  state.users.where((u) => u.isActive && !u.isSuspended).length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Bị khóa',
                  'suspended',
                  state.users.where((u) => u.isSuspended).length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Admin',
                  'admin',
                  state.users.where((u) => u.role == 'admin' || u.role == 'operator').length,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Error message
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                state.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

          // Loading indicator
          if (state.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          // Users list
          else if (filteredUsers.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Không tìm thấy người dùng nào'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user, theme);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm người dùng'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildUserCard(UserAdmin user, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
          child: user.avatar == null
              ? Text(user.displayName[0].toUpperCase())
              : null,
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildStatusChip(user, theme),
                _buildRoleChip(user, theme),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.phoneNumber != null)
                  _buildInfoRow(Icons.phone, 'SĐT', user.phoneNumber!),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Tạo lúc',
                  user.createdAt != null
                      ? _formatDate(user.createdAt!)
                      : 'N/A',
                ),
                if (user.lastLoginAt != null)
                  _buildInfoRow(
                    Icons.login,
                    'Đăng nhập cuối',
                    _formatDate(user.lastLoginAt!),
                  ),
                if (user.isSuspended) ...[
                  const Divider(),
                  _buildInfoRow(
                    Icons.block,
                    'Lý do khóa',
                    user.suspensionReason ?? 'Không có',
                  ),
                  if (user.suspensionTimeRemaining != null)
                    _buildInfoRow(
                      Icons.timer,
                      'Thời gian còn lại',
                      user.suspensionTimeRemaining!,
                    ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showEditUserDialog(user),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Sửa'),
                    ),
                    if (user.isSuspended)
                      ElevatedButton.icon(
                        onPressed: () => _unsuspendUser(user),
                        icon: const Icon(Icons.lock_open, size: 18),
                        label: const Text('Mở khóa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _showSuspendDialog(user),
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Khóa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () => _showResetPasswordDialog(user),
                      icon: const Icon(Icons.lock_reset, size: 18),
                      label: const Text('Reset MK'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteUser(user),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Xóa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
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

  Widget _buildStatusChip(UserAdmin user, ThemeData theme) {
    Color color;
    if (user.isSuspended) {
      color = Colors.red;
    } else if (!user.isActive) {
      color = Colors.grey;
    } else if (!user.isVerified) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Chip(
      label: Text(
        user.statusDisplayName,
        style: const TextStyle(fontSize: 11),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRoleChip(UserAdmin user, ThemeData theme) {
    return Chip(
      label: Text(
        user.roleDisplayName,
        style: const TextStyle(fontSize: 11),
      ),
      backgroundColor: theme.primaryColor.withOpacity(0.1),
      side: BorderSide(color: theme.primaryColor),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

