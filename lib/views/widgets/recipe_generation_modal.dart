import 'package:flutter/material.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import '../../common/constants.dart';

class RecipeGenerationModal extends StatefulWidget {
  final List<String> availableIngredients;
  final List<String>? backendIngredients; // English names for backend API
  final Function(int duration, List<String> selectedIngredients) onProceed;

  const RecipeGenerationModal({
    Key? key,
    required this.availableIngredients,
    this.backendIngredients,
    required this.onProceed,
  }) : super(key: key);

  @override
  State<RecipeGenerationModal> createState() => _RecipeGenerationModalState();
}

class _RecipeGenerationModalState extends State<RecipeGenerationModal> {
  double _duration = 30; // Default 30 minutes
  late List<String> _selectedIngredients;
  bool _showAllIngredients = false;
  static const int _maxVisibleIngredients = 7;

  @override
  void initState() {
    super.initState();
    _selectedIngredients = List.from(widget.availableIngredients);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final ingredientsToShow = _showAllIngredients
        ? widget.availableIngredients
        : widget.availableIngredients.take(_maxVisibleIngredients).toList();
    final hasMoreIngredients =
        widget.availableIngredients.length > _maxVisibleIngredients;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.generateRecipe,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.cookingDuration,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                l10n.minutes(_duration.round().toString()),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.red600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Slider(
            value: _duration,
            min: 10,
            max: 240,
            divisions: 23,
            activeColor: AppColors.red600,
            inactiveColor: AppColors.red600.withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _duration = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            l10n.availableIngredients,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ingredientsToShow.map((ingredient) {
                      final isSelected = _selectedIngredients.contains(
                        ingredient,
                      );
                      return FilterChip(
                        label: Text(ingredient),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedIngredients.add(ingredient);
                            } else {
                              _selectedIngredients.remove(ingredient);
                            }
                          });
                        },
                        selectedColor: AppColors.red600.withOpacity(0.1),
                        checkmarkColor: AppColors.red600,
                        backgroundColor: isDark
                            ? Color(0xFF2A2A2A)
                            : Colors.grey[100],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.red600
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.red600
                                : Colors.transparent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (hasMoreIngredients) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAllIngredients = !_showAllIngredients;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showAllIngredients ? l10n.showLess : l10n.showMore,
                            style: TextStyle(
                              color: AppColors.red600,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _showAllIngredients
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.red600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedIngredients.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          widget.onProceed(
                            _duration.round(),
                            _selectedIngredients,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red600,
                    disabledBackgroundColor: isDark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.proceed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
