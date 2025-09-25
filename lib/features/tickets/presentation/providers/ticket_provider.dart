import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/repositories/ticket_repository.dart';

// Ticket Repository Provider
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TicketRepository(dioClient);
});

// Ticket Provider for getting booking and tickets data
final ticketProvider = Provider.family<TicketState, String>((ref, bookingId) {
  return const TicketState();
});

// Ticket State
class TicketState {
  final bool isLoading;
  final Map<String, dynamic>? booking;
  final List<Map<String, dynamic>> tickets;
  final String? error;

  const TicketState({
    this.isLoading = false,
    this.booking,
    this.tickets = const [],
    this.error,
  });

  TicketState copyWith({
    bool? isLoading,
    Map<String, dynamic>? booking,
    List<Map<String, dynamic>>? tickets,
    String? error,
  }) {
    return TicketState(
      isLoading: isLoading ?? this.isLoading,
      booking: booking ?? this.booking,
      tickets: tickets ?? this.tickets,
      error: error ?? this.error,
    );
  }
}

// Ticket data loader provider
final ticketDataProvider = FutureProvider.family<TicketState, String>((
  ref,
  bookingId,
) async {
  final repository = ref.read(ticketRepositoryProvider);

  try {
    // Load booking details and tickets in parallel
    final results = await Future.wait([
      repository.getBookingById(bookingId),
      repository.getTicketsByBookingId(bookingId),
    ]);

    final booking = results[0] as Map<String, dynamic>?;
    final tickets = results[1] as List<Map<String, dynamic>>;

    return TicketState(isLoading: false, booking: booking, tickets: tickets);
  } catch (e) {
    return TicketState(isLoading: false, error: e.toString());
  }
});

// QR code generator provider
final qrCodeProvider = FutureProvider.family<String, String>((
  ref,
  bookingId,
) async {
  final repository = ref.read(ticketRepositoryProvider);
  return await repository.generateQRData(bookingId);
});

// Email sender provider
final emailSenderProvider = FutureProvider.family<bool, Map<String, String>>((
  ref,
  params,
) async {
  final repository = ref.read(ticketRepositoryProvider);
  final bookingId = params['bookingId']!;
  final email = params['email']!;
  return await repository.sendTicketEmail(bookingId, email);
});
