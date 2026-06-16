import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/services/auth_service_interface.dart';
import '../../domain/models/account_entity.dart';

final class LoginCommand extends ParameterizedCommand<Account, Failure, LoginParams> {
  final IAuthService _authService;

  LoginCommand(this._authService);

  @override
  Future<Result<Account, Failure>> execute() async {
    if (parameter == null) {
      return Error<Account, Failure>(InputFailure('Parâmetro nulo para login.'));
    }

    return await _authService.login(
      email: parameter!.email,
      password: parameter!.password,
    );
  }
}

final class SignupCommand extends ParameterizedCommand<Account, Failure, SignupParams> {
  final IAuthService _authService;

  SignupCommand(this._authService);

  @override
  Future<Result<Account, Failure>> execute() async {
    if (parameter == null) {
      return Error<Account, Failure>(InputFailure('Parâmetro nulo para cadastro.'));
    }

    return await _authService.signup(
      email: parameter!.email,
      password: parameter!.password,
      displayName: parameter!.displayName,
    );
  }
}

final class LogoutCommand extends Command<void, Failure> {
  final IAuthService _authService;

  LogoutCommand(this._authService);

  @override
  Future<Result<void, Failure>> execute() async {
    return await _authService.logout();
  }
}
