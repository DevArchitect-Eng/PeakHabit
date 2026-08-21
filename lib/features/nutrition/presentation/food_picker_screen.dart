import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_logger.dart';
import '../data/nutrition_providers.dart';
import '../domain/food.dart';
import 'food_editor.dart';
import 'nutrition_formatting.dart';

const _logger = AppLogger('nutrition');

/// Picks what goes into a meal: something already in the catalogue, or a food
/// created on the spot.
///
/// Pops with the chosen [FoodItem], or with nothing when the screen is left
/// without a choice. It hands back the item rather than writing the entry
/// itself — how much of it was eaten is the next question, and it belongs to
/// whoever asked for the food.
///
/// Dishes are listed next to plain foods but cannot be created here: putting
/// one together is its own screen, and the picker's job is to find what is
/// already there.
class FoodPickerScreen extends ConsumerStatefulWidget {
  const FoodPickerScreen({super.key});

  @override
  ConsumerState<FoodPickerScreen> createState() => _FoodPickerScreenState();
}

class _FoodPickerScreenState extends ConsumerState<FoodPickerScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(foodsProvider);
    final dishes = ref.watch(compositeFoodsProvider);
    final unreadable = foods.hasError || dishes.hasError;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lebensmittel wählen'),
        actions: [
          IconButton(
            onPressed: _createFood,
            icon: const Icon(Icons.add),
            tooltip: 'Lebensmittel anlegen',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Suchen',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
      body: _body(foods, dishes, unreadable: unreadable),
    );
  }

  Widget _body(
    AsyncValue<List<Food>> foods,
    AsyncValue<List<CompositeFood>> dishes, {
    required bool unreadable,
  }) {
    if (unreadable) {
      return const _Message('Der Katalog konnte nicht geladen werden.');
    }
    // Reading from a local database takes about a frame, so there is nothing
    // to show in the meantime — and a spinner would never settle for a widget
    // test waiting on it.
    if (!foods.hasValue || !dishes.hasValue) return const SizedBox.shrink();

    final all = <FoodItem>[...foods.value!, ...dishes.value!]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final matches = all.where(_matches).toList();

    if (matches.isEmpty) {
      return _Message(
        all.isEmpty
            ? 'Noch keine Lebensmittel. Das erste legt der Knopf oben an.'
            : 'Nichts gefunden. Über den Knopf oben lässt es sich anlegen.',
      );
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) => _ItemRow(
        item: matches[index],
        onTap: () => context.pop(matches[index]),
      ),
    );
  }

  /// Whether [item] answers to what has been typed — by its name, or by the
  /// brand that is what tells two products of the same name apart.
  bool _matches(FoodItem item) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    if (item.name.toLowerCase().contains(query)) return true;
    return item is Food && (item.brand?.toLowerCase().contains(query) ?? false);
  }

  /// Creates a food, saves it, and picks it in one go: someone who types a
  /// food in while logging a meal means to eat it, not to file it away.
  Future<void> _createFood() async {
    final food = await showFoodEditor(context);
    if (food == null || !mounted) return;

    final Food saved;
    try {
      saved = await ref.read(foodRepositoryProvider).saveFood(food);
    } catch (error, stackTrace) {
      // Without this the write fails silently: the screen would look exactly
      // as it does after a successful one, only without the food in it.
      _logger.error('Saving the food failed', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Das Lebensmittel konnte nicht gespeichert werden.'),
        ),
      );
      return;
    }
    if (!mounted) return;

    context.pop(saved);
  }
}

/// One food or dish in the list: what it is called, and what 100 g of it
/// carry.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.onTap});

  final FoodItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    final brand = item is Food ? item.brand : null;
    final per100g = item.nutrientsPer100g;

    return ListTile(
      leading: Icon(
        item is CompositeFood ? Icons.restaurant_menu : Icons.egg_outlined,
      ),
      title: Text(item.name),
      subtitle: Text(
        [?brand, '${formatKcal(per100g.kcal)} / 100 g'].join(' · '),
      ),
      onTap: onTap,
    );
  }
}

/// A line that reports rather than shows — set apart the way a subtitle is.
class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
