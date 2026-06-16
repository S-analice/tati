import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/account_entity.dart';
import '../../domain/models/account_mapper.dart';
import 'account_local_storage_interface.dart';

final class AccountSharedPreferencesService implements IAccountLocalStorage {
 
  String _getStorageKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return 'account_data_${uid ?? "guest"}';
  }

  @override
  Future<VoidResult> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final key = _getStorageKey();
      await prefs.remove(key);

      return Success(null);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao deletar conta: $e'),
      );
    }
  }

  @override
  Future<AccountResult> getAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final key = _getStorageKey();
      final result = prefs.getString(key);

      if (result == null) {
        return Error(EmptyResultFailure());
      }

      final accountMap = jsonDecode(result) as Map<String, dynamic>;
      final account = AccountMapper.fromMap(accountMap);
      return Success(account);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter conta: $e'),
      );
    }
  }

  @override
  Future<VoidResult> saveAccount(Account account) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final key = _getStorageKey();
      await prefs.setString(key, jsonEncode(AccountMapper.toMap(account)));
      return Success(null);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar conta: $e'),
      );
    }
  }

  @override
  Future<VoidResult> updateAccount(Account account) {
    // Para SharedPreferences, o método de atualização é o mesmo que salvar,
    // pois ele sobrescreve os dados existentes com a mesma chave.
    return saveAccount(account);
  }
}
