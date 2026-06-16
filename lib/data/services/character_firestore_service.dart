import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'character_local_storage_interface.dart';

final class CharacterFirestoreService implements ICharacterLocalStorage {
  final FirebaseFirestore _firestore;

  CharacterFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Retorna a referência da subcoleção de personagens do usuário logado
  CollectionReference<Map<String, dynamic>>? _getCharactersCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    // Acessa: users -> uid -> characters
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('characters');
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final collection = _getCharactersCollection();
      if (collection == null) {
        return Error(DefaultFailure('Usuário não autenticado para salvar personagem.'));
      }

      // Salva o documento usando o próprio ID gerado para o personagem
      final characterMap = CharacterMapper.toMap(character);
      await collection.doc(character.id).set(characterMap);

      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao salvar personagem: $e'));
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final collection = _getCharactersCollection();
      if (collection == null) {
        return Error(DefaultFailure('Usuário não autenticado para buscar personagens.'));
      }

      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final characters = snapshot.docs
          .map((doc) => CharacterMapper.fromMap(doc.data()))
          .toList();

      return Success(characters);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter personagens: $e'));
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final collection = _getCharactersCollection();
      if (collection == null) {
        return Error(DefaultFailure('Usuário não autenticado.'));
      }

      final doc = await collection.doc(id).get();

      if (!doc.exists || doc.data() == null) {
        return Error(DefaultFailure('Personagem não encontrado.'));
      }

      final character = CharacterMapper.fromMap(doc.data()!);
      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    try {
      final collection = _getCharactersCollection();
      if (collection == null) {
        return Error(DefaultFailure('Usuário não autenticado para atualizar.'));
      }

      final characterMap = CharacterMapper.toMap(character);
      // O método .update() atualiza apenas os campos alterados ou sobrescreve se usar .set()
      await collection.doc(character.id).update(characterMap);

      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao atualizar personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final collection = _getCharactersCollection();
      if (collection == null) {
        return Error(DefaultFailure('Usuário não autenticado para exclusão.'));
      }

      // Primeiro buscamos o personagem para poder retorná-lo no Success
      final characterResult = await getCharacterById(id);

      return await characterResult.fold(
        onSuccess: (character) async {
          await collection.doc(id).delete();
          return Success(character);
        },
        onFailure: (failure) async => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao deletar personagem: $e'));
    }
  }
}