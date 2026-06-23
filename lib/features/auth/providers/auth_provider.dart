import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAdmin = false;

  bool _isConductor = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  bool get isConductor => _isConductor;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = SupabaseService.client.auth.currentUser;
    if (_user != null) {
      _checkAdminStatus();
    }
    
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _checkAdminStatus();
      } else {
        _isAdmin = false;
        _isConductor = false;
      }
      notifyListeners();
    });
  }

  Future<void> _checkAdminStatus() async {
    // In a real app, you might check a 'profiles' table or JWT claims
    // For this demo, let's assume metadata or a specific email contains 'admin'
    final userMetadata = _user?.userMetadata;
    _isAdmin = userMetadata?['role'] == 'admin';
    _isConductor = userMetadata?['role'] == 'conductor';
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, {required bool asAdmin}) async {
    _setLoading(true);
    try {
      await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'role': 'user'},
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
