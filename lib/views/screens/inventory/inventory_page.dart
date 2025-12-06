import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:chefkit/blocs/inventory/inventory_event.dart';
import 'package:chefkit/blocs/inventory/inventory_state.dart';
import 'package:chefkit/views/widgets/inventory/ingredient_card.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
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
      l10n.ingredientTypeSpices,
      l10n.ingredientTypeFruits,
    ];
  }

  // Keep original keys for logic filtering
  final List<String> _ingredientTypeKeys = [
    "All",
    "Protein",
    "Vegetables",
    "Spices",
    "Fruits",
  ];

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

  Widget headerText({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Color(0xFF6A7282),
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
        : state.available.take(4).toList();
    final totalItems = state.browse.length + state.available.length;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerText(
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
        GridView.builder(
          shrinkWrap: true,
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
            return IngredientCard(
              imageUrl: item["imageUrl"]!,
              ingredientName: item["name"]!,
              ingredientType: item["type"]!,
              onRemove: () {
                context.read<InventoryBloc>().add(RemoveIngredientEvent(item));
              },
            );
          },
        ),
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
    );
  }

  Widget _buildBrowseSection(
    InventoryState state,
    List<Map<String, String>> filteredIngredients,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final displayTypes = _getIngredientTypes(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerText(
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
                          color: AppColors.black,
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

        GridView.builder(
          shrinkWrap: true,
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
            return IngredientCard(
              imageUrl: item["imageUrl"]!,
              ingredientName: item["name"]!,
              ingredientType: item["type"]!,
              addIngredient: true,
              onAdd: () {
                context.read<InventoryBloc>().add(AddIngredientEvent(item));
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        List<Map<String, String>> searchFilteredIngredients = state.browse;
        if (state.searchTerm.isNotEmpty) {
          final query = state.searchTerm.toLowerCase();
          searchFilteredIngredients = searchFilteredIngredients
              .where((i) => i["name"]!.toLowerCase().contains(query))
              .toList();
        }

        List<Map<String, String>> filteredIngredients;
        if (selectedType == 0) {
          filteredIngredients = searchFilteredIngredients;
        } else {
          final selected = _ingredientTypeKeys[selectedType];
          filteredIngredients = searchFilteredIngredients
              .where((i) => i["type"] == selected)
              .toList();
        }

        final isSearching = state.searchTerm.isNotEmpty;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 72,
            leading: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                "assets/images/list-ingredients.png",
                width: 52,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.inventoryTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.inventorySubtitle,
                  style: const TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "LeagueSpartan",
                  ),
                ),
              ],
            ),
            centerTitle: false,
          ),
          body: Padding(
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

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20.0,
                      ), // Add padding for the bottom
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isSearching) ...[
                            _buildAvailableIngredients(state),
                            SizedBox(height: 25),
                          ],

                          _buildBrowseSection(state, filteredIngredients),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
