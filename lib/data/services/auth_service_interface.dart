import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../domain/models/account_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class IAuthService {
  Stream<User?> get authStateChanges;

  Future<Result<Account, Failure>> login({
    required String email,
    required String password,
  });

  Future<Result<Account, Failure>> signup({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<void, Failure>> logout();
}
