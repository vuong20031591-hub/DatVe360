import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../features/search/data/repositories/search_repository.dart';
import '../../features/results/data/repositories/trip_repository.dart';
import '../../features/booking/data/repositories/booking_repository.dart';
import '../../features/tickets/data/repositories/ticket_repository.dart';

// Core providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient.instance;
});

// Repository providers
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SearchRepository(dioClient);
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TripRepository(dioClient);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingRepository(dioClient);
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TicketRepository(dioClient);
});

// Simple state providers
final themeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = Provider<String>((ref) => 'vi');
final searchHistoryProvider = Provider<List<String>>((ref) => []);
final loadingProvider = Provider<bool>((ref) => false);
final errorProvider = Provider<String?>((ref) => null);
final connectivityProvider = Provider<bool>((ref) => true);
