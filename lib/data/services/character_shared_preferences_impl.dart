import 'dart:convert';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'character_local_storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADICIONADO: Para ler o UID atual

final class CharacterSharedPreferencesService implements ICharacterLocalStorage {
  
  // CORRIGIDO: Agora a chave muda dinamicamente baseada em quem está logado!
  String _getStorageKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return 'characters_data_${uid ?? "guest"}';
  }

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final index = characters.indexWhere((c) => c.id == id);
          if (index < 0) {
            return Error(
              DefaultFailure('Personagem não encontrado para exclusão.'),
            );
          }

          final deleted = characters[index];
          final updated = [...characters]..removeAt(index);
          await _saveCharacters(updated);
          return Success(deleted);
        },
        onFailure: (failure) async => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao deletar: $e'));
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // CORRIGIDO: Lendo da chave dinâmica do usuário atual
      final key = _getStorageKey();
      final result = prefs.getString(key);

      if (result == null || result.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final decoded = jsonDecode(result) as List<dynamic>;

      final characters = decoded
          .map((e) => CharacterMapper.fromMap(e as Map<String, dynamic>))
          .toList();

      return Success(characters);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final index = characters.indexWhere((c) => c.id == character.id);
          if (index < 0) {
            return Error(
              DefaultFailure('Personagem não encontrado para atualização.'),
            );
          }

          final updatedCharacters = [...characters];
          updatedCharacters[index] = character;
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) async => Error(failure),
      );
    } catch (e) {
      return Error(
        ApiLocalFailure(
          'Shared Preferences - Erro ao atualizar personagem: $e',
        ),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final currentResult = await getAllCharacters();

      return currentResult.fold(
        onSuccess: (characters) {
          final index = characters.indexWhere((c) => c.id == id);
          if (index < 0) {
            return Error(DefaultFailure('Personagem não encontrado.'));
          }

          return Success(characters[index]);
        },
        onFailure: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(
        ApiLocalFailure(
          'Shared Preferences - Erro ao obter personagem por id: $e',
        ),
      );
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final updatedCharacters = [...characters, character];
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) async {
          if (failure is EmptyResultFailure) {
            await _saveCharacters([character]);
            return Success(character);
          }

          return Error(ApiLocalFailure());
        },
      );
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar personagem: $e'),
      );
    }
  }

  /// Salva os personagens no storage
  Future<void> _saveCharacters(List<Character> characters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        characters.map((c) => CharacterMapper.toMap(c)).toList(),
      );
      
      // CORRIGIDO: Gravando na chave dinâmica baseada no usuário logado
      final key = _getStorageKey();
      await prefs.setString(key, jsonString);
    } catch (e) {
      throw ApiLocalFailure('Erro ao salvar personagens: $e');
    }
  }
}