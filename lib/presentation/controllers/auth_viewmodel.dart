import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
// ignore: unused_import
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/account_repository_interface.dart';
import '../../data/services/auth_service_interface.dart';
import '../../domain/models/account_entity.dart';
import '../commands/auth_commands.dart';
import 'account_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

class AuthViewModel {
  final IAuthService _authService;
  final IAccountRepository _accountRepository;
  final AccountViewModel _accountViewModel;

  late final LoginCommand loginCommand;
  late final SignupCommand signupCommand;
  late final LogoutCommand logoutCommand;

  final authMessage = signal<String?>(null);
  final authAccount = signal<Account?>(null);

  AuthViewModel({
    required IAuthService authService,
    required IAccountRepository accountRepository,
    required AccountViewModel accountViewModel,
  })  : _authService = authService,
        _accountRepository = accountRepository,
        _accountViewModel = accountViewModel {
    loginCommand = LoginCommand(_authService);
    signupCommand = SignupCommand(_authService);
    logoutCommand = LogoutCommand(_authService);
  }

  ReadonlySignal<bool> get isExecuting =>
      computed(() =>
          loginCommand.isExecuting.value ||
          signupCommand.isExecuting.value ||
          logoutCommand.isExecuting.value)
          .readonly();

  void clearMessage() => authMessage.value = null;

  Future<Result<void, Failure>> saveAccountLocally(Account account) async {
    final result = await _accountRepository.saveAccount(account);

    if (result.isSuccess) {
      _accountViewModel.accountState.setAccount(account);
    }

    return result;
  }

  Future<Result<void, Failure>> deleteLocalAccount() async {
    final result = await _accountRepository.deleteAccount();

    if (result.isSuccess) {
      _accountViewModel.accountState.setAccount(null);
    }

    return result;
  }
}
