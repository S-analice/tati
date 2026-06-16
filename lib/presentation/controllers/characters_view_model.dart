import '../../domain/facades/character_facade_usecases_interface.dart';
import '../commands/character_commands.dart';
import 'characters_commands_view_model.dart';
import 'characters_state_viewmodel.dart';

class CharactersViewModel {
  late final CharactersStateViewmodel _state;
  CharactersStateViewmodel get charactersState => _state;

  late final CharactersCommandsViewModel commands;

  CharactersViewModel(ICharacterFacadeUseCases facade) {
    _state = CharactersStateViewmodel();

    commands = CharactersCommandsViewModel(
      state: _state,
      getAccountCommand: GetAllCharactersCommand(facade),
      createCharacterCommand: CreateCharacterCommand(facade),
      deleteCharacterCommand: DeleteCharacterCommand(facade),
      updateCharacterCommand: UpdateCharacterCommand(facade),
    );
    commands.fetchCharacters();
  }

  /// Limpa a lista de personagens da memória ao deslogar
  void clearCharactersData() {
    _state.clear();
  }

  // Getters para facilitar o acesso na View
  GetAllCharactersCommand get getAllCharactersCommand =>
      commands.getAllCharactersCommand;
  CreateCharacterCommand get createCharacterCommand =>
      commands.createCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand =>
      commands.updateCharacterCommand;
  DeleteCharacterCommand get deleteCharacterCommand =>
      commands.deleteCharacterCommand;
}
