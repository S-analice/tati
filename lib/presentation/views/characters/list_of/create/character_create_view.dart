import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:injustice_app/domain/models/character_entity.dart';

class CharacterCreateView extends StatefulWidget {
  const CharacterCreateView({super.key});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  final _nameController = TextEditingController();

  CharacterClass selectedClass = CharacterClass.poderoso;
  CharacterRarity selectedRarity = CharacterRarity.prata;
  CharacterAlignment selectedAlignment = CharacterAlignment.heroi;

  int level = 1;
  int attack = 10;
  int health = 10;
  int stars = 1;
  int threat = 0;

  void _save() {
    if (_nameController.text.isEmpty) return;

    final character = Character(
      id: const Uuid().v4(),
      name: _nameController.text,
      characterClass: selectedClass,
      rarity: selectedRarity,
      level: level,
      threat: threat,
      attack: attack,
      health: health,
      stars: stars,
      alignment: selectedAlignment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, character);
  }

  Widget _numberField(String label, int value, Function(int) onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Personagem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: selectedClass,
              decoration: const InputDecoration(labelText: 'Classe'),
              items: CharacterClass.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e.displayName),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedClass = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: selectedRarity,
              decoration: const InputDecoration(labelText: 'Raridade'),
              items: CharacterRarity.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e.displayName),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedRarity = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: selectedAlignment,
              decoration: const InputDecoration(labelText: 'Alinhamento'),
              items: CharacterAlignment.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e.displayName),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedAlignment = v!),
            ),

            const SizedBox(height: 12),

            _numberField('Level (1-80)', level, (v) => level = v),
            const SizedBox(height: 12),

            _numberField('Ataque', attack, (v) => attack = v),
            const SizedBox(height: 12),

            _numberField('Vida', health, (v) => health = v),
            const SizedBox(height: 12),

            _numberField('Ameaça', threat, (v) => threat = v),
            const SizedBox(height: 12),

            _numberField('Estrelas (1-14)', stars, (v) => stars = v),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}