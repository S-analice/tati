// Classe selada (sealed) que representa um resultado que pode ser sucesso ou erro.
// TOk: tipo do valor em caso de sucesso.
// TError: tipo do valor em caso de erro.

sealed class Result<TOk, TError> {
  const Result();

  // Indica se o resultado é sucesso
  bool get isSuccess => this is Success<TOk, TError>;

  // Indica se o resultado é erro
  bool get isFailure => this is Error<TOk, TError>;

  TOk? get successValueOrNull => isSuccess ? (this as Success<TOk, TError>)._value : null;
  TError? get failureValueOrNull => isFailure ? (this as Error<TOk, TError>)._value : null;

  R fold<R>({
    required R Function(TOk okValue) onSuccess,
    required R Function(TError errorValue) onFailure,
  }) {
    if (this is Success<TOk, TError>) {
      return onSuccess((this as Success<TOk, TError>)._value);
    } else if (this is Error<TOk, TError>) {
      return onFailure((this as Error<TOk, TError>)._value);
    }
    throw Exception('Unreachable code');
  }
}

final class Success<TOk, TError> extends Result<TOk, TError> {
  final TOk _value;
  const Success(this._value);
}

final class Error<TOk, TError> extends Result<TOk, TError> {
  final TError _value;
  const Error(this._value);
}
