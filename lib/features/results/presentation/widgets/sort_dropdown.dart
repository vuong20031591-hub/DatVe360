import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  const SortDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      icon: const Icon(Icons.sort),
      tooltip: 'Sắp xếp',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'price_asc',
          child: Row(
            children: [
              Icon(Icons.arrow_upward, size: 16),
              SizedBox(width: 8),
              Text('Giá tăng dần'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'price_desc',
          child: Row(
            children: [
              Icon(Icons.arrow_downward, size: 16),
              SizedBox(width: 8),
              Text('Giá giảm dần'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duration_asc',
          child: Row(
            children: [
              Icon(Icons.schedule, size: 16),
              SizedBox(width: 8),
              Text('Thời gian ngắn nhất'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'departure_asc',
          child: Row(
            children: [
              Icon(Icons.access_time, size: 16),
              SizedBox(width: 8),
              Text('Khởi hành sớm nhất'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'departure_desc',
          child: Row(
            children: [
              Icon(Icons.access_time_filled, size: 16),
              SizedBox(width: 8),
              Text('Khởi hành muộn nhất'),
            ],
          ),
        ),
      ],
    );
  }
}
