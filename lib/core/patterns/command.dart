import 'package:signals_flutter/signals_flutter.dart';

import 'result.dart';

// Interface base para comandos
abstract interface class ICommand<TOk, TError> {
  Future<Result<TOk, TError>> execute();
}

// Comando abstrato com estado reativo e proteção contra execução concorrente.
abstract base class Command<TOk, TError>
    implements ICommand<TOk, TError> {
  final _running = signal(false);
  final _result = signal<Result<TOk, TError>?>(null);
  Future<Result<TOk, TError>>? _currentExecution;

  ReadonlySignal<bool> get isExecuting => _running.readonly();
  ReadonlySignal<Result<TOk, TError>?> get result => _result.readonly();

  late final hasResult = computed(() => _result.value != null);
  late final hasError = computed(() => _result.value?.isFailure ?? false);
  late final isSuccess = computed(() => _result.value?.isSuccess ?? false);

  Future<Result<TOk, TError>> call() async {
    if (_running.value && _currentExecution != null) {
      return _currentExecution!;
    }

    _running.value = true;
    _result.value = null;
    _currentExecution = execute();

    try {
      final result = await _currentExecution!;
      _result.value = result;
      return result;
    } finally {
      _running.value = false;
      _currentExecution = null;
    }
  }

  void clear() {
    _result.value = null;
  }

  void reset() {
    _running.value = false;
    clear();
    _currentExecution = null;
  }
}

// Comando parametrizado
abstract base class ParameterizedCommand<TOk, TError, P>
    extends Command<TOk, TError> {
  P? _parameter;

  set parameter(P? value) => _parameter = value;
  P? get parameter => _parameter;

  Future<Result<TOk, TError>> executeWith(P parameter) {
    _parameter = parameter;
    return call();
  }

  Future<Result<TOk, TError>> execute();
}

// Comando composto que executa múltiplos comandos e acumula resultados
final class CompositeCommand<TOk, TError> extends Command<List<TOk>, TError> {
  final List<Command<TOk, TError>> _commands;

  CompositeCommand(this._commands);

  @override
  Future<Result<List<TOk>, TError>> execute() async {
    final results = <TOk>[];

    for (final command in _commands) {
      final result = await command.call();

      if (result.isFailure) {
        return Error<List<TOk>, TError>(result.failureValueOrNull as TError);
      }

      final value = result.successValueOrNull;
      if (value != null) {
        results.add(value);
      }
    }

    return Success<List<TOk>, TError>(results);
  }
}
