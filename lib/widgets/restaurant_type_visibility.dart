import 'package:flutter/material.dart';
import '../constants/reused_provider_estate_container.dart';
import '../localization/language_constants.dart';
import '../widgets/text_form_style.dart';

class RestaurantTypeVisibility extends StatefulWidget {
  final bool isVisible;
  final Function(bool, String) onCheckboxChanged;

  const RestaurantTypeVisibility({
    super.key,
    required this.isVisible,
    required this.onCheckboxChanged,
  });

  @override
  _RestaurantTypeVisibilityState createState() =>
      _RestaurantTypeVisibilityState();
}

class _RestaurantTypeVisibilityState extends State<RestaurantTypeVisibility> {
  bool checkPopularRestaurants = false;
  bool checkIndianRestaurant = false;
  bool checkItalianRestaurant = false;
  bool checkSeafoodRestaurant = false;
  bool checkFastFoodRestaurant = false;
  bool checkSteak = false;
  bool checkGrills = false;
  bool checkHealthy = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return Container();

    return Column(
      children: [
        _buildCheckboxRow(
          context,
          'popular restaurant',
          checkPopularRestaurants,
          (value) {
            setState(() => checkPopularRestaurants = value);
            widget.onCheckboxChanged(value, 'popular restaurant');
          },
        ),
        _buildCheckboxRow(
          context,
          'Indian Restaurant',
          checkIndianRestaurant,
          (value) {
            setState(() => checkIndianRestaurant = value);
            widget.onCheckboxChanged(value, 'Indian Restaurant');
          },
        ),
        _buildCheckboxRow(
          context,
          'Italian',
          checkItalianRestaurant,
          (value) {
            setState(() => checkItalianRestaurant = value);
            widget.onCheckboxChanged(value, 'Italian');
          },
        ),
        _buildCheckboxRow(
          context,
          'Seafood Restaurant',
          checkSeafoodRestaurant,
          (value) {
            setState(() => checkSeafoodRestaurant = value);
            widget.onCheckboxChanged(value, 'Seafood Restaurant');
          },
        ),
        _buildCheckboxRow(
          context,
          'Fast Food',
          checkFastFoodRestaurant,
          (value) {
            setState(() => checkFastFoodRestaurant = value);
            widget.onCheckboxChanged(value, 'Fast Food');
          },
        ),
        _buildCheckboxRow(
          context,
          'Steak',
          checkSteak,
          (value) {
            setState(() => checkSteak = value);
            widget.onCheckboxChanged(value, 'Steak');
          },
        ),
        _buildCheckboxRow(
          context,
          'Grills',
          checkGrills,
          (value) {
            setState(() => checkGrills = value);
            widget.onCheckboxChanged(value, 'Grills');
          },
        ),
        _buildCheckboxRow(
          context,
          'healthy',
          checkHealthy,
          (value) {
            setState(() => checkHealthy = value);
            widget.onCheckboxChanged(value, 'healthy');
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(BuildContext context, String label, bool value,
      Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            getTranslated(context, label),
          ),
        ),
        Expanded(
          child: Checkbox(
            checkColor: Colors.white,
            value: value,
            onChanged: (bool? newValue) => onChanged(newValue!),
          ),
        ),
      ],
    );
  }
}
