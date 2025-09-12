import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';

import '../widgets/trip_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/results_shimmer.dart';
import '../widgets/empty_results.dart';

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key, this.searchQuery});

  final Map<String, dynamic>? searchQuery;

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  String _sortBy = 'price_asc';
  Map<String, dynamic> _filters = {};
  bool _isLoading = true;
  List<Map<String, dynamic>> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  void _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    _trips = _getMockTrips();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.results),
        actions: [
          // Sort dropdown
          SortDropdown(
            value: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value;
              });
              _sortTrips();
            },
          ),
          const SizedBox(width: 8),
          // Filter button
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_filters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search summary
          if (widget.searchQuery != null) _buildSearchSummary(context),

          // Results
          Expanded(child: _buildResultsList(context)),
        ],
      ),
    );
  }

  Widget _buildSearchSummary(BuildContext context) {
    final theme = Theme.of(context);
    final query = widget.searchQuery!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${query['from']} → ${query['to']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatSearchDate(query),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading)
            Text(
              '${_trips.length} chuyến',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    if (_isLoading) {
      return const ResultsShimmer();
    }

    if (_trips.isEmpty) {
      return EmptyResults(
        onRetry: _loadResults,
        onChangeSearch: () {
          Navigator.pop(context);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadResults();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TripCard(trip: trip, onTap: () => _selectTrip(trip)),
          );
        },
      ),
    );
  }

  String _formatSearchDate(Map<String, dynamic> query) {
    final departDate = query['departDate'] as DateTime?;
    final returnDate = query['returnDate'] as DateTime?;
    final passengers = '${query['adults']} người lớn';

    if (departDate == null) return passengers;

    final departStr = '${departDate.day}/${departDate.month}';
    if (returnDate != null) {
      final returnStr = '${returnDate.day}/${returnDate.month}';
      return '$departStr - $returnStr • $passengers';
    }

    return '$departStr • $passengers';
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        currentFilters: _filters,
        onApply: (filters) {
          setState(() {
            _filters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _sortTrips() {
    _trips.sort((a, b) {
      switch (_sortBy) {
        case 'price_asc':
          return a['price'].compareTo(b['price']);
        case 'price_desc':
          return b['price'].compareTo(a['price']);
        case 'duration_asc':
          return a['duration'].compareTo(b['duration']);
        case 'duration_desc':
          return b['duration'].compareTo(a['duration']);
        case 'departure_asc':
          return a['departTime'].compareTo(b['departTime']);
        case 'departure_desc':
          return b['departTime'].compareTo(a['departTime']);
        default:
          return 0;
      }
    });
    setState(() {});
  }

  void _applyFilters() {
    // TODO: Apply filters to trips list
    setState(() {});
  }

  void _selectTrip(Map<String, dynamic> trip) {
    // TODO: Navigate to trip detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chọn chuyến: ${trip['carrier']} ${trip['route']}'),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockTrips() {
    return [
      {
        'id': '1',
        'carrier': 'Vietnam Airlines',
        'logo': 'assets/images/vna_logo.png',
        'route': 'HAN → SGN',
        'departTime': '06:00',
        'arriveTime': '08:15',
        'duration': '2h 15m',
        'price': 1200000,
        'currency': 'VND',
        'stops': 0,
        'aircraft': 'A321',
      },
      {
        'id': '2',
        'carrier': 'VietJet Air',
        'logo': 'assets/images/vj_logo.png',
        'route': 'HAN → SGN',
        'departTime': '07:30',
        'arriveTime': '09:45',
        'duration': '2h 15m',
        'price': 980000,
        'currency': 'VND',
        'stops': 0,
        'aircraft': 'A320',
      },
      {
        'id': '3',
        'carrier': 'Bamboo Airways',
        'logo': 'assets/images/qh_logo.png',
        'route': 'HAN → SGN',
        'departTime': '09:15',
        'arriveTime': '11:30',
        'duration': '2h 15m',
        'price': 1100000,
        'currency': 'VND',
        'stops': 0,
        'aircraft': 'A321neo',
      },
      {
        'id': '4',
        'carrier': 'Vietnam Airlines',
        'logo': 'assets/images/vna_logo.png',
        'route': 'HAN → SGN',
        'departTime': '14:20',
        'arriveTime': '16:35',
        'duration': '2h 15m',
        'price': 1350000,
        'currency': 'VND',
        'stops': 0,
        'aircraft': 'A350',
      },
      {
        'id': '5',
        'carrier': 'VietJet Air',
        'logo': 'assets/images/vj_logo.png',
        'route': 'HAN → SGN',
        'departTime': '18:45',
        'arriveTime': '21:00',
        'duration': '2h 15m',
        'price': 1050000,
        'currency': 'VND',
        'stops': 0,
        'aircraft': 'A321',
      },
    ];
  }
}
