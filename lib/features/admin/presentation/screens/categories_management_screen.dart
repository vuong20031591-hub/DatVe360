import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transport_operator.dart';
import '../../domain/providers/categories_admin_provider.dart';
import '../widgets/operator_form_dialog.dart';

class CategoriesManagementScreen extends ConsumerStatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  ConsumerState<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends ConsumerState<CategoriesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'flight';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedType = ['flight', 'train', 'bus'][_tabController.index];
        });
      }
    });

    // Load data
    Future.microtask(() {
      ref.read(categoriesAdminProvider.notifier).loadCategories();
      ref.read(categoriesAdminProvider.notifier).loadStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesAdminProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quản lý Danh mục Vé'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.flight), text: 'Máy bay'),
            Tab(icon: Icon(Icons.train), text: 'Tàu hỏa'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Xe khách'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(categoriesAdminProvider.notifier)
                            .loadCategories(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOperatorsList('flight', state.categories['flight'] ?? []),
                    _buildOperatorsList('train', state.categories['train'] ?? []),
                    _buildOperatorsList('bus', state.categories['bus'] ?? []),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOperatorDialog(null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm nhà cung cấp'),
      ),
    );
  }

  Widget _buildOperatorsList(String type, List<TransportOperator> operators) {
    if (operators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'flight'
                  ? Icons.flight
                  : type == 'train'
                      ? Icons.train
                      : Icons.directions_bus,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có nhà cung cấp nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: operators.length,
      itemBuilder: (context, index) {
        final operator = operators[index];
        return _buildOperatorCard(operator);
      },
    );
  }

  Widget _buildOperatorCard(TransportOperator operator) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: operator.logo.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(operator.logo),
                onBackgroundImageError: (_, __) {},
                child: operator.logo.isEmpty
                    ? Text(operator.code.substring(0, 2))
                    : null,
              )
            : CircleAvatar(
                child: Text(operator.code.substring(0, 2)),
              ),
        title: Text(
          operator.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã: ${operator.code}'),
            if (operator.description.isNotEmpty)
              Text(
                operator.description,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!operator.isActive)
              const Chip(
                label: Text('Ngừng hoạt động', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.grey,
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showOperatorDialog(operator);
                } else if (value == 'delete') {
                  _deleteOperator(operator);
                }
              },
            ),
          ],
        ),
        isThreeLine: operator.description.isNotEmpty,
      ),
    );
  }

  Future<void> _showOperatorDialog(TransportOperator? operator) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => OperatorFormDialog(
        operator: operator,
        initialType: _selectedType,
      ),
    );

    if (result == true && mounted) {
      ref.read(categoriesAdminProvider.notifier).loadCategories();
      ref.read(categoriesAdminProvider.notifier).loadStats();
    }
  }

  Future<void> _deleteOperator(TransportOperator operator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${operator.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(categoriesAdminProvider.notifier)
            .deleteOperator(operator.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa nhà cung cấp')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }
}

