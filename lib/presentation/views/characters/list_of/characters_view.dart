import 'package:flutter/material.dart';
import 'widgets/characters_app_bar.dart';
import 'widgets/characters_body.dart';
import 'widgets/characters_floating_button.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/account_entity.dart';
import '../../../../domain/models/character_entity.dart';
import '../../../../domain/models/extensions/character_ui.dart';
import '../../../controllers/characters_state_viewmodel.dart';
import '../../../controllers/characters_view_model.dart';
import '../../../widgets/account_summary_card.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/star_rating.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Página de listagem de personagens
class CharactersView extends StatefulWidget {
  final Account account;

  const CharactersView({super.key, required this.account});

  @override
  State<CharactersView> createState() => _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  late final CharactersViewModel _viewModel;
  Account get account => widget.account;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<CharactersViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.commands.fetchCharacters();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _viewModel.refresh();
  }

  //arrumammos//
  Future<void> _deleteCharacter(Character character) async {
    await _viewModel.commands.deleteCharacter(character.id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${character.name} removido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CharactersAppBar(state: _viewModel.charactersState),

      // appBar: AppBar(
      //   title: const Text('Personagens'),
      //   actions: [
      //     // Botão de direção da ordenação
      //     Watch((context) {
      //       final order = _viewModel.charactersState.sortOrder.value;
      //       return IconButton(
      //         icon: Icon(
      //           order == SortOrder.ascending
      //               ? Icons.arrow_upward
      //               : Icons.arrow_downward,
      //         ),
      //         tooltip: order == SortOrder.ascending
      //             ? 'Ascendente'
      //             : 'Descendente',
      //         onPressed: _viewModel.charactersState.toggleSortOrder,
      //       );
      //     }),
      //     // Botão de ordenação
      //     Watch((context) {
      //       final currentSort = _viewModel.charactersState.sortBy.value;
      //       return PopupMenuButton<SortBy>(
      //         icon: const Icon(Icons.sort),
      //         tooltip: 'Ordenar',
      //         onSelected: _viewModel.charactersState.setSortBy,
      //         itemBuilder: (context) => [
      //           PopupMenuItem(
      //             value: SortBy.name,
      //             child: Row(
      //               children: [
      //                 Icon(
      //                   Icons.sort_by_alpha,
      //                   color: currentSort == SortBy.name
      //                       ? Colors.amber
      //                       // ? Theme.of(context).colorScheme.secondary
      //                       : null,
      //                 ),
      //                 const SizedBox(width: AppSpacing.sm),
      //                 Text(
      //                   'Nome',
      //                   style: currentSort == SortBy.name
      //                       ? TextStyle(
      //                           color: Colors.amber,
      //                           // color: Theme.of(context).colorScheme.secondary,
      //                           fontWeight: FontWeight.bold,
      //                         )
      //                       : null,
      //                 ),
      //               ],
      //             ),
      //           ),
      //           PopupMenuItem(
      //             value: SortBy.level,
      //             child: Row(
      //               children: [
      //                 Icon(
      //                   Icons.trending_up,
      //                   color: currentSort == SortBy.level
      //                       ? Colors.amber
      //                       : null,
      //                 ),
      //                 const SizedBox(width: AppSpacing.sm),
      //                 Text(
      //                   'Level',
      //                   style: currentSort == SortBy.level
      //                       ? TextStyle(
      //                           color: Colors.amber,
      //                           fontWeight: FontWeight.bold,
      //                         )
      //                       : null,
      //                 ),
      //               ],
      //             ),
      //           ),
      //           PopupMenuItem(
      //             value: SortBy.stars,
      //             child: Row(
      //               children: [
      //                 Icon(
      //                   Icons.star,
      //                   color: currentSort == SortBy.stars
      //                       ? Colors.amber
      //                       : null,
      //                 ),
      //                 const SizedBox(width: AppSpacing.sm),
      //                 Text(
      //                   'Estrelas',
      //                   style: currentSort == SortBy.stars
      //                       ? TextStyle(
      //                           color: Colors.amber,
      //                           fontWeight: FontWeight.bold,
      //                         )
      //                       : null,
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       );
      //     }),
      //   ],
      // ),
      drawer: AppDrawer(),
      body: CharactersBody(account: account, viewModel: _viewModel),
      // body: Watch((context) {
      //   final isLoading =
      //       _viewModel.commands.getAllCharactersCommand.isExecuting.value;

      //   final characters = _viewModel.charactersState.sortedCharacters.value;

      //   return RefreshIndicator(
      //     onRefresh: () async {},
      //     child: CustomScrollView(
      //       slivers: [
      //         /// Header
      //         SliverToBoxAdapter(
      //           child: Padding(
      //             padding: AppSpacing.paddingMd,
      //             child: AccountSummaryCard(account: account),
      //           ),
      //         ),

      //         /// Filtros
      //         SliverToBoxAdapter(child: FilterPanel(viewModel: _viewModel)),

      //         /// Conteúdo (loading | empty | lista)
      //         if (isLoading)
      //           SliverFillRemaining(
      //             hasScrollBody: false,
      //             child: LoadingIndicator(message: 'Carregando personagens...'),
      //           )
      //         else if (characters.isEmpty)
      //           SliverFillRemaining(
      //             hasScrollBody: false,
      //             child: const EmptyState(),
      //           )
      //         else
      //           SliverPadding(
      //             padding: AppSpacing.paddingMd,
      //             sliver: SliverList(
      //               delegate: SliverChildBuilderDelegate((context, index) {
      //                 final character = characters[index];
      //                 return CharacterListItem(
      //                   character: character,
      //                   onDelete: () => _deleteCharacter(character),
      //                   onTap: () {},
      //                 );
      //               }, childCount: characters.length),
      //             ),
      //           ),
      //       ],
      //     ),
      //   );
      // }),
      floatingActionButton: CharactersFab(viewModel: _viewModel),
      // floatingActionButton: Watch((context) {
      //   final isExecuting =
      //       _viewModel.commands.createCharacterCommand.isExecuting.value;

      //   return FloatingActionButton(
      //     onPressed: isExecuting
      //         ? null
      //         : () async {
      //             final character = CharacterFactory.list(1).first;
      //             await _viewModel.commands.addCharacter(character);
      //           },
      //     child: isExecuting
      //         ? const SizedBox(
      //             width: 22,
      //             height: 22,
      //             child: CircularProgressIndicator(
      //               strokeWidth: 2.5,
      //               color: Colors.white,
      //             ),
      //           )
      //         : const Icon(Icons.add),
      //   );
      // }),
    );
  }
}

// class EmptyState extends StatelessWidget {
//   const EmptyState({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppSpacing.xxl,
//           vertical: AppSpacing.xxl,
//         ),
//         child: Column(
//           // mainAxisSize: MainAxisSize.max,
//           // mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Icon(
//               Icons.people_outline,
//               size: 72,
//               color: Theme.of(context).colorScheme.outline,
//             ),
//             const SizedBox(height: AppSpacing.md),
//             Text(
//               'Nenhum personagem encontrado',
//               textAlign: TextAlign.center,
//               style: context.textStyles.titleMedium?.semiBold,
//             ),
//             const SizedBox(height: AppSpacing.sm),
//             Text(
//               'Adicione seu primeiro personagem usando o botão +',
//               textAlign: TextAlign.center,
//               style: context.textStyles.bodyMedium?.withColor(
//                 Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Item da lista de personagens
// class CharacterListItem extends StatelessWidget {
//   final Character character;
//   final VoidCallback onDelete;
//   final VoidCallback onTap;

//   const CharacterListItem({
//     super.key,
//     required this.character,
//     required this.onDelete,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: Key(character.id),
//       background: Container(
//         margin: const EdgeInsets.only(bottom: AppSpacing.md),
//         decoration: BoxDecoration(
//           color: Colors.blue,
//           borderRadius: BorderRadius.circular(AppRadius.md),
//         ),
//         alignment: Alignment.centerLeft,
//         padding: const EdgeInsets.only(left: AppSpacing.lg),
//         child: const Icon(Icons.edit, color: Colors.white),
//       ),
//       secondaryBackground: Container(
//         margin: const EdgeInsets.only(bottom: AppSpacing.md),
//         decoration: BoxDecoration(
//           color: Colors.red,
//           borderRadius: BorderRadius.circular(AppRadius.md),
//         ),
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: AppSpacing.lg),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       confirmDismiss: (direction) async {
//         if (direction == DismissDirection.startToEnd) {
//           onTap();
//           return false;
//         } else {
//           return await showDialog<bool>(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Confirmar exclusão'),
//                   content: Text('Deseja realmente excluir ${character.name}?'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text('Cancelar'),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text('Excluir'),
//                     ),
//                   ],
//                 ),
//               ) ??
//               false;
//         }
//       },
//       onDismissed: (direction) {
//         if (direction == DismissDirection.endToStart) {
//           onDelete();
//         }
//       },
//       child: Card(
//         color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
//         margin: const EdgeInsets.only(bottom: AppSpacing.md),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(AppRadius.md),
//           child: Padding(
//             padding: AppSpacing.paddingMd,
//             child: Row(
//               children: [
//                 // Indicador de raridade
//                 Container(
//                   width: 4,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: character.rarity.color,
//                     borderRadius: BorderRadius.circular(AppRadius.sm),
//                   ),
//                 ),
//                 const SizedBox(width: AppSpacing.md),
//                 // Conteúdo principal
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               character.name,
//                               style: context.textStyles.titleMedium?.semiBold,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           const SizedBox(width: AppSpacing.sm),
//                           Text(
//                             'Nv. ${character.level}',
//                             style: context.textStyles.labelLarge?.withColor(
//                               Theme.of(context).colorScheme.onSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: AppSpacing.xs),
//                       Row(
//                         children: [
//                           Icon(
//                             character.characterClass.icon,
//                             size: 16,
//                             color: character.characterClass.color,
//                           ),
//                           const SizedBox(width: AppSpacing.xs),
//                           Text(
//                             character.characterClass.displayName,
//                             style: context.textStyles.bodySmall?.withColor(
//                               Theme.of(context).colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: AppSpacing.xs),
//                       StarRating(stars: character.stars, size: 14),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class FilterPanel extends StatelessWidget {
//   final CharactersViewModel viewModel;

//   const FilterPanel({super.key, required this.viewModel});

//   CharactersStateViewmodel get state => viewModel.charactersState;

//   @override
//   Widget build(BuildContext context) {
//     return Watch((context) {
//       final filtersCount = state.activeFiltersCount.value;
//       final isExpanded = state.isFilterPanelExpanded.value;

//       return Container(
//         margin: EdgeInsets.only(
//           left: AppSpacing.md,
//           right: AppSpacing.md,
//           bottom: AppSpacing.md,
//         ),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
//               Theme.of(context).colorScheme.secondary,
//               Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(AppRadius.md),
//           color: Theme.of(context).colorScheme.secondary,
//           border: Border(
//             bottom: BorderSide(
//               color: Theme.of(context).colorScheme.outlineVariant,
//               width: 1,
//             ),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Cabeçalho do painel
//             InkWell(
//               onTap: state.toggleFilterPanel,
//               child: Padding(
//                 padding: AppSpacing.paddingMd,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.filter_list,
//                       color: Theme.of(context).colorScheme.onSecondary,
//                     ),
//                     const SizedBox(width: AppSpacing.sm),
//                     Text(
//                       'Filtros',
//                       style: context.textStyles.titleSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     if (filtersCount > 0) ...[
//                       const SizedBox(width: 6),

//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 3,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.primary,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           '$filtersCount',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],

//                     const Spacer(),

//                     if (filtersCount > 0)
//                       TextButton.icon(
//                         onPressed: state.clearFilters,
//                         icon: const Icon(Icons.clear, size: 16),
//                         label: const Text('Limpar'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Theme.of(
//                             context,
//                           ).colorScheme.onSecondary,
//                           textStyle: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: AppSpacing.sm,
//                           ),
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                       ),
//                     Icon(
//                       isExpanded ? Icons.expand_less : Icons.expand_more,
//                       color: Theme.of(context).colorScheme.onSecondary,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Conteúdo do painel (expansível)
//             if (isExpanded)
//               // if (_isExpanded)
//               SizedBox(
//                 width: double.infinity,
//                 child: _FiltersContent(state: state),
//               ),
//           ],
//         ),
//       );
//     });
//   }
// }

// class _FiltersContent extends StatelessWidget {
//   const _FiltersContent({required this.state});

//   final CharactersStateViewmodel state;

//   @override
//   Widget build(BuildContext context) {
//     return Watch((context) {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(
//           AppSpacing.lg,
//           0,
//           AppSpacing.md,
//           AppSpacing.md,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔹 RARIDADE
//             _FilterSection(
//               title: 'Raridade',
//               sectionKey: 'rarity',
//               state: state,
//               child: Wrap(
//                 spacing: AppSpacing.xs,
//                 runSpacing: AppSpacing.xs,
//                 children: CharacterRarity.values.map((rarity) {
//                   final isSelected = state.selectedRarities.value.contains(
//                     rarity,
//                   );

//                   return FilterChip(
//                     label: Text(
//                       rarity.displayName,
//                       style: TextStyle(color: rarity.color),
//                     ),
//                     selected: isSelected,
//                     onSelected: (_) => state.toggleRarity(rarity),
//                   );
//                 }).toList(),
//               ),
//             ),

//             /// 🔹 CLASSE
//             _FilterSection(
//               title: 'Classe',
//               sectionKey: 'class',
//               state: state,
//               child: Wrap(
//                 spacing: AppSpacing.xs,
//                 runSpacing: AppSpacing.xs,
//                 children: CharacterClass.values.map((characterClass) {
//                   final isSelected = state.selectedClasses.value.contains(
//                     characterClass,
//                   );

//                   return FilterChip(
//                     label: Text(
//                       characterClass.displayName,
//                       style: TextStyle(color: characterClass.color),
//                     ),
//                     selected: isSelected,
//                     onSelected: (_) => state.toggleClass(characterClass),
//                   );
//                 }).toList(),
//               ),
//             ),

//             /// 🔹 LEVEL
//             _FilterSection(
//               title: 'Level',
//               sectionKey: 'level',
//               state: state,
//               child: Wrap(
//                 spacing: AppSpacing.xs,
//                 runSpacing: AppSpacing.xs,
//                 children: LevelFilter.values.map((filter) {
//                   return FilterChip(
//                     label: Text(filter.label),
//                     selected: state.levelFilter.value == filter,
//                     onSelected: (_) => state.setLevelFilter(filter),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// class _FilterSection extends StatelessWidget {
//   final String title;
//   final String sectionKey;
//   final CharactersStateViewmodel state;
//   final Widget child;

//   const _FilterSection({
//     required this.title,
//     required this.sectionKey,
//     required this.state,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Watch((context) {
//       final isExpanded = state.isSectionExpanded(sectionKey);
//       final selectedCount = switch (sectionKey) {
//         'rarity' => state.selectedRarities.value.length,
//         'class' => state.selectedClasses.value.length,
//         'alignment' => state.selectedAlignments.value.length,
//         _ => 0,
//       };

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             onTap: () => state.toggleSection(sectionKey),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
//               child: Row(
//                 children: [
//                   Text(title),
//                   if (selectedCount > 0) ...[
//                     const SizedBox(width: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.primary,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         '$selectedCount',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                   const Spacer(),
//                   Icon(
//                     isExpanded ? Icons.expand_less : Icons.expand_more,
//                     color: Theme.of(context).colorScheme.onSecondary,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           AnimatedCrossFade(
//             firstChild: const SizedBox.shrink(),
//             secondChild: Padding(
//               padding: const EdgeInsets.only(top: AppSpacing.xs),
//               child: child,
//             ),
//             crossFadeState: isExpanded
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             duration: const Duration(milliseconds: 200),
//           ),

//           const SizedBox(height: AppSpacing.md),
//         ],
//       );
//     });
//   }
// }
