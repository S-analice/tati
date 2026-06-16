import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/models/character_entity.dart';
import '../commands/character_commands.dart';
import 'characters_state_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersCommandsViewModel {
  final CharactersStateViewmodel state;
  final GetAllCharactersCommand _getAccountCommand;
  final CreateCharacterCommand _createCharacterCommand;
  final DeleteCharacterCommand _deleteCharacterCommand; //adicionamos//
  final UpdateCharacterCommand _updateCharacterCommand; //adicionamos//

  CharactersCommandsViewModel({
    required this.state,
    required GetAllCharactersCommand getAccountCommand,
    required CreateCharacterCommand createCharacterCommand,
    required DeleteCharacterCommand deleteCharacterCommand,
    required UpdateCharacterCommand updateCharacterCommand,
  }) : _getAccountCommand = getAccountCommand,
       _createCharacterCommand = createCharacterCommand,
       _deleteCharacterCommand = deleteCharacterCommand, //adicionamos//
       _updateCharacterCommand = updateCharacterCommand { //adicionamos//
    // Observers para cada comando
    _observeGetAllCharacters();
    _observeCreateCharacter();
     _observeDeleteCharacter();
     _observeUpdateCharacter();
  }

  // ========================================================
  //   GETTERS PARA WIDGETS USAREM DIRETAMENTE OS COMANDOS
  // ========================================================
  GetAllCharactersCommand get getAllCharactersCommand => _getAccountCommand;
  CreateCharacterCommand get createCharacterCommand => _createCharacterCommand;
  DeleteCharacterCommand get deleteCharacterCommand => _deleteCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand => _updateCharacterCommand; //adicionamos//
  
  // ========================================================
  //   MÉTODO GENÉRICO DE OBSERVAÇÃO DE COMANDOS
  // ========================================================
  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }) {
    effect(() {
      // 1) Ignora enquanto está executando
      if (command.isExecuting.value) return;

      // 2) Ignora até existir um resultado
      final result = command.result.value;
      if (result == null) return;

      // 3) Sucesso ou falha
      result.fold(
        onSuccess: (data) {
          state.clearMessage(); // sempre limpa erros em sucesso
          onSuccess(data); // ação específica para esse comando
          command.clear();
        },
        onFailure: (err) {
          state.setMessage(err.msg); // registra o erro no estado
          if (onFailure != null) onFailure(err);
          command.clear();
        },
      );
    });
  }

  // ========================================================
  //   OBSERVERS ESPECÍFICOS
  // ========================================================

  /// Buscar todos os personagens
  void _observeGetAllCharacters() {
    _observeCommand<List<Character>>(
      _getAccountCommand,
      onSuccess: (characters) {
        state.clearMessage(); // Limpa mensagens anteriores
        state.state.value = characters;
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }
  /// Criar um novo personagem
  void _observeCreateCharacter() {  
    _observeCommand<Character>(
      _createCharacterCommand,
      onSuccess: (newCharacter) {
        final currentList = state.state.value;
        final newlist = [...currentList, newCharacter]; // Adiciona o novo personagem à lista
        state.state.value = newlist; 
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }

  //fizemos//
  void _observeDeleteCharacter() {  
    _observeCommand<Character>(
      _deleteCharacterCommand,
      onSuccess: (deletedCharacter) {
        final currentList = state.state.value;
        final updatedlist = currentList.where((c) => c.id != deletedCharacter.id).toList();
        state.state.value = updatedlist; 
      },
      onFailure: (err) =>
          state.setMessage(err.msg), 
    );
  }

  //fizemos//
  void _observeUpdateCharacter() {  
  _observeCommand<Character>(
    _updateCharacterCommand,
    onSuccess: (updatedCharacter) {
      final currentList = state.state.value;

      final updatedList = currentList.map((c) {
        return c.id == updatedCharacter.id ? updatedCharacter : c;
      }).toList();

      state.state.value = updatedList;
    },
    onFailure: (err) => state.setMessage(err.msg),
  );
}

  // ========================================================
  //   MÉTODOS PÚBLICOS (CHAMADOS PELOS WIDGETS)
  //   que disparam os commands
  // ========================================================
  /// buscca personagens e atualiza o estado
  Future<void> fetchCharacters() async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _getAccountCommand.executeWith(());
  }

  /// adiciona personagem e atualiza o estado
  Future<void> addCharacter(Character character) async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _createCharacterCommand.executeWith((character: character));
  }

  //fizemos//
  Future<void> deleteCharacter(String id) async {
    state.clearMessage();
    await _deleteCharacterCommand.executeWith((id: id));
  }

  //fizemos//
  Future<void> updateCharacter(Character character) async {
  state.clearMessage();
  await _updateCharacterCommand.executeWith((character: character));
}
}
