import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_admin.dart';
import '../../data/services/users_admin_service.dart';

// Service provider
final usersAdminServiceProvider = Provider<UsersAdminService>((ref) {
  return UsersAdminService();
});

// State class
class UsersAdminState {
  final List<UserAdmin> users;
  final bool isLoading;
  final String? error;
  final UserAdmin? selectedUser;

  const UsersAdminState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.selectedUser,
  });

  UsersAdminState copyWith({
    List<UserAdmin>? users,
    bool? isLoading,
    String? error,
    UserAdmin? selectedUser,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return UsersAdminState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedUser: clearSelected ? null : (selectedUser ?? this.selectedUser),
    );
  }
}

// Notifier
class UsersAdminNotifier extends Notifier<UsersAdminState> {
  late final UsersAdminService _service;

  @override
  UsersAdminState build() {
    _service = ref.read(usersAdminServiceProvider);
    return const UsersAdminState();
  }

  // Load all users
  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final users = await _service.getAllUsers();
      state = state.copyWith(
        users: users,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Search users
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await loadUsers();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final users = await _service.searchUsers(query);
      state = state.copyWith(
        users: users,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Select user
  Future<void> selectUser(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final user = await _service.getUserById(id);
      state = state.copyWith(
        selectedUser: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create user
  Future<bool> createUser(UserAdmin user, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final newUser = await _service.createUser(user, password);
      final updatedList = [...state.users, newUser];
      state = state.copyWith(
        users: updatedList,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(String id, UserAdmin user) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedUser = await _service.updateUser(id, user);
      final updatedList = state.users.map((u) {
        return u.id == id ? updatedUser : u;
      }).toList();
      
      state = state.copyWith(
        users: updatedList,
        selectedUser: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Suspend user temporarily
  Future<bool> suspendUser(String id, int durationInDays, String reason) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedUser = await _service.suspendUser(
        id: id,
        durationInDays: durationInDays,
        reason: reason,
      );
      final updatedList = state.users.map((u) {
        return u.id == id ? updatedUser : u;
      }).toList();
      
      state = state.copyWith(
        users: updatedList,
        selectedUser: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Suspend user permanently
  Future<bool> suspendUserPermanently(String id, String reason) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedUser = await _service.suspendUserPermanently(
        id: id,
        reason: reason,
      );
      final updatedList = state.users.map((u) {
        return u.id == id ? updatedUser : u;
      }).toList();
      
      state = state.copyWith(
        users: updatedList,
        selectedUser: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Unsuspend user
  Future<bool> unsuspendUser(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedUser = await _service.unsuspendUser(id);
      final updatedList = state.users.map((u) {
        return u.id == id ? updatedUser : u;
      }).toList();
      
      state = state.copyWith(
        users: updatedList,
        selectedUser: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final success = await _service.deleteUser(id);
      if (success) {
        final updatedList = state.users.where((u) => u.id != id).toList();
        state = state.copyWith(
          users: updatedList,
          isLoading: false,
          clearSelected: true,
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Change user role
  Future<bool> changeUserRole(String id, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedUser = await _service.changeUserRole(id, role);
      final updatedList = state.users.map((u) {
        return u.id == id ? updatedUser : u;
      }).toList();
      
      state = state.copyWith(
        users: updatedList,
        selectedUser: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Verify user
  Future<bool> verifyUser(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedUser = await _service.verifyUser(id);
      final updatedList = state.users.map((u) {
        return u.id == id ? updatedUser : u;
      }).toList();

      state = state.copyWith(
        users: updatedList,
        selectedUser: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String id, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final success = await _service.resetUserPassword(id, newPassword);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Clear selected
  void clearSelected() {
    state = state.copyWith(clearSelected: true);
  }
}

// Provider
final usersAdminProvider = NotifierProvider<UsersAdminNotifier, UsersAdminState>(() {
  return UsersAdminNotifier();
});

