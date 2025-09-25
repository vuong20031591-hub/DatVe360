import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

class FareSelector extends StatelessWidget {
  const FareSelector({
    super.key,
    required this.classes,
    required this.selectedClassId,
    required this.onClassSelected,
  });

  final List<Map<String, dynamic>> classes;
  final String? selectedClassId;
  final Function(String) onClassSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn hạng vé',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        ...classes.map((classData) {
          final isSelected = selectedClassId == classData['id'];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onClassSelected(classData['id']),
                child: Container(
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            // Class icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getClassIcon(classData['id']),
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Class name and price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    classData['name'],
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    '${classData['availableSeats']} ghế còn lại',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatPrice(classData['price']),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : AppColors.lightSuccess,
                                  ),
                                ),
                                Text(
                                  'VND',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Selection indicator
                            Radio<String>(
                              value: classData['id'],
                              groupValue: selectedClassId,
                              onChanged: (value) {
                                if (value != null) {
                                  onClassSelected(value);
                                }
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Amenities
                        if (classData['amenities'] != null)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: (classData['amenities'] as List<String>)
                                .map((amenity) => Chip(
                                  label: Text(
                                    amenity,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  backgroundColor: isSelected
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.surfaceVariant,
                                  side: BorderSide.none,
                                ))
                                .toList(),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // Policies (expandable)
                        ExpansionTile(
                          title: Text(
                            'Chính sách & Hành lý',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(top: 8),
                          children: [
                            _buildPolicyItem(
                              theme,
                              Icons.luggage,
                              'Hành lý',
                              classData['baggage'] ?? 'Không bao gồm',
                            ),
                            _buildPolicyItem(
                              theme,
                              Icons.refresh,
                              'Đổi vé',
                              classData['changePolicy'] ?? 'Không được phép',
                            ),
                            _buildPolicyItem(
                              theme,
                              Icons.money_off,
                              'Hoàn vé',
                              classData['refundPolicy'] ?? 'Không được phép',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPolicyItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getClassIcon(String classId) {
    switch (classId.toLowerCase()) {
      case 'economy':
        return Icons.airline_seat_recline_normal;
      case 'business':
        return Icons.airline_seat_flat;
      case 'first':
        return Icons.airline_seat_individual_suite;
      default:
        return Icons.airline_seat_recline_normal;
    }
  }

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}K';
  }
}
