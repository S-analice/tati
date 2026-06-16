import 'package:firebase_auth/firebase_auth.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../domain/models/account_entity.dart';
import 'auth_service_interface.dart';

final class FirebaseAuthServiceImpl implements IAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthServiceImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Result<Account, Failure>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return Error<Account, Failure>(DefaultFailure('Falha ao autenticar usuário.'));
      }

      return Success<Account, Failure>(_toAccount(user));
    } on FirebaseAuthException catch (error) {
      return Error<Account, Failure>(_mapFirebaseAuthException(error));
    } catch (error) {
      return Error<Account, Failure>(
        ApiLocalFailure('Erro interno de login: $error'),
      );
    }
  }

  @override
  Future<Result<Account, Failure>> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return Error<Account, Failure>(DefaultFailure('Falha ao criar usuário.'));
      }

      await user.updateDisplayName(displayName);
      await user.reload();
      final refreshedUser = _auth.currentUser ?? user;

      return Success<Account, Failure>(_toAccount(refreshedUser, displayName: displayName));
    } on FirebaseAuthException catch (error) {
      return Error<Account, Failure>(_mapFirebaseAuthException(error));
    } catch (error) {
      return Error<Account, Failure>(
        ApiLocalFailure('Erro interno de cadastro: $error'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await _auth.signOut();
      return Success<void, Failure>(null);
    } on FirebaseAuthException catch (error) {
      return Error<void, Failure>(
        ApiLocalFailure('Erro ao fazer logout: ${error.message ?? error.code}'),
      );
    } catch (error) {
      return Error<void, Failure>(
        ApiLocalFailure('Erro interno de logout: $error'),
      );
    }
  }

  Account _toAccount(User user, {String? displayName}) {
    final createdAt = user.metadata.creationTime ?? DateTime.now();
    final updatedAt = user.metadata.lastSignInTime ?? DateTime.now();
    final safeDisplayName = displayName ?? user.displayName ?? user.email?.split('@').first ?? 'Jogador';

    return Account(
      name: safeDisplayName,
      email: user.email ?? '',
      displayName: safeDisplayName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      level: 1,
      gold: 0,
      gems: 0,
      energy: 5,
    );
  }

  Failure _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return InvalidEmail(error.message);
      case 'user-disabled':
        return DefaultFailure('Usuário desabilitado.');
      case 'user-not-found':
        return DefaultFailure('Usuário não encontrado.');
      case 'wrong-password':
        return InvalidPassword('Senha incorreta.');
      case 'email-already-in-use':
        return DefaultFailure('Este e-mail já está em uso.');
      case 'weak-password':
        return InvalidPassword('A senha é muito fraca.');
      case 'operation-not-allowed':
        return DefaultFailure('Operação de autenticação não permitida.');
      default:
        return DefaultFailure(error.message ?? 'Erro desconhecido de autenticação.');
    }
  }
}
