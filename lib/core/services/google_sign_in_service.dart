import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  late final GoogleSignIn _googleSignIn;

  void initialize({String? webClientId}) {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
      // Chỉ cần webClientId cho web platform
      clientId: kIsWeb ? webClientId : null,
    );
  }

  /// Đăng nhập với Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Google Sign-Out Error: $error');
    }
  }

  /// Ngắt kết nối tài khoản
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      debugPrint('Google Disconnect Error: $error');
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Lấy thông tin tài khoản hiện tại
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Lấy access token
  Future<String?> getAccessToken() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        return auth.accessToken;
      }
      return null;
    } catch (error) {
      debugPrint('Get Access Token Error: $error');
      return null;
    }
  }

  /// Lấy ID token
  Future<String?> getIdToken() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        return auth.idToken;
      }
      return null;
    } catch (error) {
      debugPrint('Get ID Token Error: $error');
      return null;
    }
  }
}
