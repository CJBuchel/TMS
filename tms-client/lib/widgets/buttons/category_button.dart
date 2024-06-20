import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String category;
  final bool isSelected;
  final Color selectedColor;
  final Color textColor;
  final Color hoverColor;
  final Function(bool)? onSelected;

  const CategoryButton({
    Key? key,
    required this.category,
    required this.isSelected,
    this.selectedColor = Colors.blue,
    this.hoverColor = Colors.blueAccent,
    this.textColor = Colors.white,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(hoverColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Colors.black),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (isSelected) {
            return selectedColor;
          }
          return Colors.grey;
        }),
      ),
      onPressed: () => onSelected?.call(!isSelected),
      child: Text(
        category,
        style: TextStyle(
          color: textColor,
        ),
      ),
    );
  }
}

class CategoryButtons extends StatelessWidget {
  final List<String> categories;
  final String? defaultCategory;
  final Function(String)? onCategoryChange;

  final ValueNotifier<String> _selectedCategory = ValueNotifier<String>('');

  CategoryButtons({
    Key? key,
    required this.categories,
    this.defaultCategory,
    this.onCategoryChange,
  }) : super(key: key) {
    _selectedCategory.value = defaultCategory ?? categories.first;
  }

  void _handleCategoryChange(String category) {
    _selectedCategory.value = category;
    onCategoryChange?.call(category);
  }

  Widget _category(String category) {
    return Expanded(
      child: ValueListenableBuilder<String>(
        valueListenable: _selectedCategory,
        builder: (context, selected, child) {
          return CategoryButton(
            category: category,
            isSelected: category == selected,
            onSelected: (isSelected) {
              if (isSelected) {
                _handleCategoryChange(category);
              }
            },
          );
        },
      ),
    );
  }

  List<Widget> _categories() {
    return categories.map((category) => _category(category)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: _categories(),
        ),
      ),
    );
  }
}
