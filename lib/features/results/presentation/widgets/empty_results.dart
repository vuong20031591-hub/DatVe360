import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_button.dart';

class EmptyResults extends StatelessWidget {
  const EmptyResults({
    super.key,
    required this.onRetry,
    required this.onChangeSearch,
  });

  final VoidCallback onRetry;
  final VoidCallback onChangeSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Không tìm thấy chuyến nào',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Không có chuyến nào phù hợp với tiêu chí tìm kiếm của bạn. '
              'Hãy thử thay đổi ngày hoặc điểm đến.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Suggestions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gợi ý:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestion(
                    context,
                    Icons.date_range,
                    'Thử thay đổi ngày khởi hành',
                  ),
                  _buildSuggestion(
                    context,
                    Icons.location_on,
                    'Kiểm tra lại điểm đi và điểm đến',
                  ),
                  _buildSuggestion(
                    context,
                    Icons.filter_list,
                    'Bỏ bớt các bộ lọc đã chọn',
                  ),
                  _buildSuggestion(
                    context,
                    Icons.schedule,
                    'Mở rộng khoảng thời gian tìm kiếm',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: onRetry,
                    text: 'Thử lại',
                    type: AppButtonType.outline,
                    icon: Icons.refresh,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    onPressed: onChangeSearch,
                    text: 'Tìm kiếm mới',
                    icon: Icons.search,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestion(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
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
}
