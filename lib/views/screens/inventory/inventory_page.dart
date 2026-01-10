import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:chefkit/blocs/inventory/inventory_event.dart';
import 'package:chefkit/blocs/inventory/inventory_state.dart';
import 'package:chefkit/views/widgets/inventory/ingredient_card.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:chefkit/views/widgets/top_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<String> _getIngredientTypes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.ingredientTypeAll,
      l10n.ingredientTypeProtein,
      l10n.ingredientTypeVegetables,
      l10n.ingredientTypeFruits,
      l10n.ingredientTypeSpices,
      // l10n.ingredientTypeDairy,
      // l10n.ingredientTypeFats,
      // l10n.ingredientTypeGrains,
      // l10n.ingredientTypeSugars,
      // l10n.ingredientTypeLeavening,
      // l10n.ingredientTypeLiquids,
      // l10n.ingredientTypeExtracts,
      // l10n.ingredientTypeAcids,
      // l10n.ingredientTypeNutsSeeds,
      // l10n.ingredientTypePantry,
    ];
  }

  int selectedType = 0;

  @override
  void initState() {
    super.initState();
    final lang = context.read<LocaleCubit>().state.languageCode;
    context.read<InventoryBloc>().add(LoadInventoryEvent(lang));
  }

  void _onSearchChanged(String value) {
    context.read<InventoryBloc>().add(SearchInventoryEvent(value));
  }

  void _updateIngredientType(int value) {
    selectedType = value;
    setState(() {});
  }

  Widget headerText(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget availabilityCard({
    required Color borderColor,
    required Color gradientColor1,
    required Color gradientColor2,
    required Color textColor,
    required String text,
    required Widget icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [gradientColor1, gradientColor2],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          icon,
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: "LeagueSpartan",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableIngredients(InventoryState state) {
    final availableToShow = state.showMore
        ? state.available
        : state.available.take(10).toList();
    final totalItems = state.browse.length + state.available.length;
    final l10n = AppLocalizations.of(context)!;
    final hasMoreThanTen = state.available.length > 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerText(
          context,
          title: l10n.availableIngredientsTitle,
          subtitle: l10n.availableIngredientsSubtitle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            availabilityCard(
              borderColor: AppColors.success1.withOpacity(0.3),
              gradientColor1: AppColors.success1.withOpacity(0.2),
              gradientColor2: AppColors.success2.withOpacity(0.3),
              textColor: AppColors.green,
              text: l10n.availableCount(state.available.length),
              icon: Image.asset(
                "assets/images/package_icon.png",
                width: 12,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 20),
            availabilityCard(
              borderColor: const Color(0xFFFD5D69).withOpacity(0.3),
              gradientColor1: const Color(0xFFFD5D69).withOpacity(0.2),
              gradientColor2: AppColors.orange.withOpacity(0.2),
              textColor: AppColors.red600,
              text: l10n.totalItemsCount(totalItems),
              icon: Image.asset(
                "assets/images/star_icon.png",
                width: 12,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              mainAxisExtent: 180,
            ),
            itemCount: availableToShow.length,
            itemBuilder: (context, index) {
              final item = availableToShow[index];
              final lang = state.currentLang;
              return IngredientCard(
                imageUrl: item["imageUrl"]!,
                ingredientName: item["name_$lang"] ?? item["name_en"] ?? '',
                ingredientType: item["type_$lang"] ?? item["type_en"] ?? '',
                onRemove: () {
                  context.read<InventoryBloc>().add(
                    RemoveIngredientEvent(item),
                  );
                },
              );
            },
          ),
        ),
        if (hasMoreThanTen) ...[
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, 0),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    context.read<InventoryBloc>().add(ToggleShowMoreEvent());
                  },
                  child: Text(
                    state.showMore ? l10n.showLess : l10n.showMore,
                    style: TextStyle(
                      color: AppColors.browmpod,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "LeagueSpartan",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(ToggleShowMoreEvent());
                  },
                  icon: Icon(
                    state.showMore ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 24,
                    color: Color(0xFF8F4A4C),
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBrowseSection(
    InventoryState state,
    List<Map<String, String>> filteredIngredients,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final displayTypes = _getIngredientTypes(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerText(
          context,
          title: l10n.browseIngredientsTitle,
          subtitle: l10n.browseIngredientsSubtitle,
        ),
        const SizedBox(height: 30),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 30,
            children: List.generate(
              displayTypes.length,
              (index) => TextButton(
                onPressed: () => _updateIngredientType(index),
                style: TextButton.styleFrom(
                  minimumSize: Size(0, 0),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  displayTypes[index],
                  style: selectedType == index
                      ? TextStyle(
                          color: AppColors.red600,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: "LeagueSpartan",
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.red600,
                          decorationThickness: 2,
                        )
                      : TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: "LeagueSpartan",
                        ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              mainAxisExtent: 180,
            ),
            itemCount: filteredIngredients.length,
            itemBuilder: (context, index) {
              final item = filteredIngredients[index];
              final lang = state.currentLang;
              return IngredientCard(
                imageUrl: item["imageUrl"]!,
                ingredientName: item["name_$lang"] ?? item["name_en"] ?? '',
                ingredientType: item["type_$lang"] ?? item["type_en"] ?? '',
                addIngredient: true,
                onAdd: () {
                  context.read<InventoryBloc>().add(AddIngredientEvent(item));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocaleCubit, Locale>(
      listener: (context, locale) {
        context.read<InventoryBloc>().add(
          LoadInventoryEvent(locale.languageCode),
        );
      },
      child: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final displayTypes = _getIngredientTypes(context);

          final lang = state.currentLang;
          List<Map<String, String>> searchFilteredIngredients = state.browse;
          if (state.searchTerm.isNotEmpty) {
            final query = state.searchTerm.toLowerCase();
            searchFilteredIngredients = searchFilteredIngredients
                .where(
                  (i) => (i["name_$lang"] ?? i["name_en"] ?? '')
                      .toLowerCase()
                      .contains(query),
                )
                .toList();
          }

          List<Map<String, String>> filteredIngredients;
          if (selectedType == 0) {
            filteredIngredients = searchFilteredIngredients;
          } else {
            final selected = displayTypes[selectedType];
            filteredIngredients = searchFilteredIngredients
                .where((i) => (i["type_$lang"] ?? i["type_en"]) == selected)
                .toList();
          }

          final isSearching = state.searchTerm.isNotEmpty;
          final theme = Theme.of(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: TopNavBar(
              title: l10n.inventoryTitle,
              subtitle: l10n.inventorySubtitle,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      SearchBarWidget(
                        hintText: l10n.searchIngredient,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isSearching) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                              ),
                              child: _buildAvailableIngredients(state),
                            ),
                            SizedBox(height: 25),
                          ],

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: _buildBrowseSection(
                              state,
                              filteredIngredients,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
