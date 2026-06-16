import 'package:flutter/material.dart';
import 'package:injustice_app/domain/models/character_entity.dart';

class CharacterEditView extends StatefulWidget {
  final Character character;

  const CharacterEditView({super.key, required this.character});

  @override
  State<CharacterEditView> createState() => _CharacterEditViewState();
}

class _CharacterEditViewState extends State<CharacterEditView> {
  late TextEditingController _nameController;

  late CharacterClass selectedClass;
  late CharacterRarity selectedRarity;
  late CharacterAlignment selectedAlignment;

  late int level;
  late int attack;
  late int health;
  late int stars;
  late int threat;

  @override
  void initState() {
    super.initState();

    final c = widget.character;

    _nameController = TextEditingController(text: c.name);

    selectedClass = c.characterClass;
    selectedRarity = c.rarity;
    selectedAlignment = c.alignment;

    level = c.level;
    attack = c.attack;
    health = c.health;
    stars = c.stars;
    threat = c.threat;
  }

  void _save() {
    final updated = widget.character.copyWith(
      name: _nameController.text,
      characterClass: selectedClass,
      rarity: selectedRarity,
      alignment: selectedAlignment,
      level: level,
      attack: attack,
      health: health,
      stars: stars,
      threat: threat,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, updated);
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
      appBar: AppBar(title: const Text('Editar Personagem')),
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

            _numberField('Level', level, (v) => level = v),
            const SizedBox(height: 12),

            _numberField('Ataque', attack, (v) => attack = v),
            const SizedBox(height: 12),

            _numberField('Vida', health, (v) => health = v),
            const SizedBox(height: 12),

            _numberField('Ameaça', threat, (v) => threat = v),
            const SizedBox(height: 12),

            _numberField('Estrelas', stars, (v) => stars = v),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _save,
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}