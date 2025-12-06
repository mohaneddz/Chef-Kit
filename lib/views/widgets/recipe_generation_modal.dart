import 'package:flutter/material.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import '../../common/constants.dart';

class RecipeGenerationModal extends StatefulWidget {
  final List<String> availableIngredients;
  final Function(int duration, List<String> selectedIngredients) onProceed;

  const RecipeGenerationModal({
    Key? key,
    required this.availableIngredients,
    required this.onProceed,
  }) : super(key: key);

  @override
  State<RecipeGenerationModal> createState() => _RecipeGenerationModalState();
}

class _RecipeGenerationModalState extends State<RecipeGenerationModal> {
  double _duration = 30; // Default 30 minutes
  late List<String> _selectedIngredients;

  @override
  void initState() {
    super.initState();
    _selectedIngredients = List.from(widget.availableIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.generateRecipe,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.cookingDuration,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                AppLocalizations.of(
                  context,
                )!.minutes(_duration.round().toString()),
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
            AppLocalizations.of(context)!.availableIngredients,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.availableIngredients.map((ingredient) {
                  final isSelected = _selectedIngredients.contains(ingredient);
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
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.red600 : Colors.black87,
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
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(
                      color: Colors.black87,
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
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.proceed,
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
