import 'package:flutter/material.dart';

class CategoryButtonWidget extends StatelessWidget {
  final String category;
  final bool isSelected;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? selectedColor;
  final Color? textColor;
  final Color? hoverColor;
  final Function(bool)? onSelected;

  const CategoryButtonWidget({
    Key? key,
    required this.category,
    required this.isSelected,
    this.leadingIcon,
    this.trailingIcon,
    this.selectedColor = Colors.blue,
    this.hoverColor = Colors.blueAccent,
    this.textColor = Colors.white,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all<Color>(hoverColor ?? Colors.blueAccent),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Colors.black),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (isSelected) {
            return selectedColor;
          }
          return Colors.grey;
        }),
      ),
      onPressed: () => onSelected?.call(!isSelected),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (leadingIcon != null) Icon(leadingIcon),
          Text(
            category,
            style: TextStyle(
              color: textColor,
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon),
        ],
      ),
    );
  }
}

class CategoryButton {
  final String category;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? selectedColor;
  final Color? textColor;
  final Color? hoverColor;
  final Function()? onPressed;

  CategoryButton({
    required this.category,
    this.leadingIcon,
    this.trailingIcon,
    this.selectedColor,
    this.textColor,
    this.hoverColor,
    this.onPressed,
  });
}

class CategoryButtons extends StatelessWidget {
  final List<CategoryButton> buttons;
  final String? defaultCategory;
  final Function(String)? onCategoryChange;

  final ValueNotifier<CategoryButton> _selectedCategory = ValueNotifier<CategoryButton>(CategoryButton(category: ''));

  CategoryButtons({
    Key? key,
    required this.buttons,
    this.defaultCategory,
    this.onCategoryChange,
  }) : super(key: key) {
    if (defaultCategory != null) {
      _selectedCategory.value = buttons.firstWhere((element) => element.category == defaultCategory);
    } else {
      _selectedCategory.value = buttons.first;
    }
  }

  void _handleCategoryChange(String category) {
    _selectedCategory.value = buttons.firstWhere((element) => element.category == category);
    onCategoryChange?.call(category);
  }

  Widget _category(CategoryButton button) {
    return Expanded(
      child: ValueListenableBuilder<CategoryButton>(
        valueListenable: _selectedCategory,
        builder: (context, selected, child) {
          return CategoryButtonWidget(
            category: button.category,
            leadingIcon: button.leadingIcon,
            trailingIcon: button.trailingIcon,
            isSelected: button == selected,
            selectedColor: button.selectedColor,
            textColor: button.textColor,
            hoverColor: button.hoverColor,
            onSelected: (isSelected) {
              button.onPressed?.call();
              if (isSelected) {
                _handleCategoryChange(button.category);
              }
            },
          );
        },
      ),
    );
  }

  List<Widget> _categories() {
    return buttons.map((button) => _category(button)).toList();
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
