import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../general_provider.dart'; // Assuming you have a custom_widgets.dart file
import 'filter_button.dart';
import 'main_screen_widgets.dart'; // Import the FilterButton widget

class ReusedEstatePage extends StatefulWidget {
  final Query queryHotel;
  final Query queryCoffee;
  final Query queryRestaurant;
  final Future<String> Function(String) getImages;
  final GeneralProvider objProvider;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Future<Map<String, dynamic>> Function(String) getEstateRatings;

  const ReusedEstatePage({
    super.key,
    required this.queryHotel,
    required this.queryCoffee,
    required this.queryRestaurant,
    required this.getImages,
    required this.objProvider,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.getEstateRatings,
  });

  @override
  _ReusedEstatePageState createState() => _ReusedEstatePageState();
}

class _ReusedEstatePageState extends State<ReusedEstatePage> {
  void _openFilterSheet(BuildContext context, String estateType) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildFilterOptions(context, estateType);
      },
    );
  }

  Widget _buildFilterOptions(BuildContext context, String estateType) {
    switch (estateType) {
      case 'Restaurant':
        return _buildRestaurantFilterOptions();
      case 'Hotel':
        return _buildHotelFilterOptions();
      case 'Coffee':
        return _buildCoffeeFilterOptions();
      default:
        return Container();
    }
  }

  Widget _buildRestaurantFilterOptions() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              getTranslated(context, 'Type of Restaurant'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'popular restaurant'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'Indian Restaurant'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'Italian'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'Seafood Restaurant'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'Fast Food'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'Steak'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'Grills'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(context, 'healthy'),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          // Add more filter options here...
        ],
      ),
    );
  }

  Widget _buildHotelFilterOptions() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              getTranslated(
                context,
                'What We have ?',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          CheckboxListTile(
            title: Text(
              getTranslated(
                context,
                'Single',
              ),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(
                context,
                'Double',
              ),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(
                context,
                'Swite',
              ),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: Text(
              getTranslated(
                context,
                'Family',
              ),
            ),
            value: false,
            onChanged: (bool? value) {},
          ),
          // Add more filter options here...
        ],
      ),
    );
  }

  Widget _buildCoffeeFilterOptions() {
    return Column(
      children: [
        ListTile(
          title: Text(
            getTranslated(
              context,
              'Entry allowed',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CheckboxListTile(
          title: Text(
            getTranslated(
              context,
              'Familial',
            ),
          ),
          value: false,
          onChanged: (bool? value) {},
        ),
        CheckboxListTile(
          title: Text(
            getTranslated(
              context,
              'Single',
            ),
          ),
          value: false,
          onChanged: (bool? value) {},
        ),
        CheckboxListTile(
          title: Text(
            getTranslated(
              context,
              'mixed',
            ),
          ),
          value: false,
          onChanged: (bool? value) {},
        ),
        // Add more filter options here...
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
      child: ListView(
        children: [
          Container(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilterButton(
                label: 'All',
                isSelected: widget.selectedFilter == 'All',
                onTap: () => widget.onFilterChanged('All'),
              ),
              FilterButton(
                label: 'Restaurant',
                isSelected: widget.selectedFilter == 'Restaurant',
                onTap: () => widget.onFilterChanged('Restaurant'),
              ),
              FilterButton(
                label: 'Hotel',
                isSelected: widget.selectedFilter == 'Hotel',
                onTap: () => widget.onFilterChanged('Hotel'),
              ),
              FilterButton(
                label: 'Coffee',
                isSelected: widget.selectedFilter == 'Coffee',
                onTap: () => widget.onFilterChanged('Coffee'),
              ),
            ],
          ),
          const Divider(),
          if (widget.selectedFilter == 'All' ||
              widget.selectedFilter == 'Hotel')
            _buildSectionWithFilterIcon(context, 'Hotel'),
          if (widget.selectedFilter == 'All' ||
              widget.selectedFilter == 'Hotel')
            CustomWidgets.buildFirebaseAnimatedListWithRatings(
                widget.queryHotel,
                'assets/images/hotel.png',
                widget.getImages,
                widget.getEstateRatings,
                widget.selectedFilter),
          const Divider(),
          if (widget.selectedFilter == 'All' ||
              widget.selectedFilter == 'Coffee')
            _buildSectionWithFilterIcon(context, 'Coffee'),
          if (widget.selectedFilter == 'All' ||
              widget.selectedFilter == 'Coffee')
            CustomWidgets.buildFirebaseAnimatedListWithRatings(
                widget.queryCoffee,
                'assets/images/coffee.png',
                widget.getImages,
                widget.getEstateRatings,
                widget.selectedFilter),
          const Divider(),
          if (widget.selectedFilter == 'All' ||
              widget.selectedFilter == 'Restaurant')
            _buildSectionWithFilterIcon(context, 'Restaurant'),
          if (widget.selectedFilter == 'All' ||
              widget.selectedFilter == 'Restaurant')
            CustomWidgets.buildFirebaseAnimatedListWithRatings(
                widget.queryRestaurant,
                'assets/images/restaurant.png',
                widget.getImages,
                widget.getEstateRatings,
                widget.selectedFilter),
        ],
      ),
    );
  }

  Widget _buildSectionWithFilterIcon(BuildContext context, String estateType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomWidgets.buildSectionTitle(context, estateType),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _openFilterSheet(context, estateType),
        ),
      ],
    );
  }
}
