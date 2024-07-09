import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../general_provider.dart'; // Assuming you have a custom_widgets.dart file
import 'filter_button.dart';
import 'main_screen_widgets.dart'; // Import the FilterButton widget

class ReusedEstatePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      // Container(
      //   padding: const EdgeInsets.only(bottom: 10),
      //   height: 13.h,
      //   child: ListView.builder(
      //     itemCount: objProvider.TypeService().length,
      //     scrollDirection: Axis.horizontal,
      //     itemBuilder: (BuildContext context, int index) {
      //       return CardType(
      //         context: context,
      //         obj: objProvider.TypeService()[index],
      //       );
      //     },
      //   ),
      // ),
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
                isSelected: selectedFilter == 'All',
                onTap: () => onFilterChanged('All'),
              ),
              FilterButton(
                label: 'Restaurant',
                isSelected: selectedFilter == 'Restaurant',
                onTap: () => onFilterChanged('Restaurant'),
              ),
              FilterButton(
                label: 'Hotel',
                isSelected: selectedFilter == 'Hotel',
                onTap: () => onFilterChanged('Hotel'),
              ),
              FilterButton(
                label: 'Coffee',
                isSelected: selectedFilter == 'Coffee',
                onTap: () => onFilterChanged('Coffee'),
              ),
            ],
          ),
          const Divider(),
          if (selectedFilter == 'All' || selectedFilter == 'Hotel')
            CustomWidgets.buildSectionTitle(context, 'Hotel'),
          if (selectedFilter == 'All' || selectedFilter == 'Hotel')
            CustomWidgets.buildFirebaseAnimatedListWithRatings(
                queryHotel,
                'assets/images/hotel.png',
                getImages,
                getEstateRatings,
                selectedFilter),
          const Divider(),
          if (selectedFilter == 'All' || selectedFilter == 'Coffee')
            CustomWidgets.buildSectionTitle(context, 'Coffee'),
          if (selectedFilter == 'All' || selectedFilter == 'Coffee')
            CustomWidgets.buildFirebaseAnimatedListWithRatings(
                queryCoffee,
                'assets/images/coffee.png',
                getImages,
                getEstateRatings,
                selectedFilter),
          const Divider(),
          if (selectedFilter == 'All' || selectedFilter == 'Restaurant')
            CustomWidgets.buildSectionTitle(context, 'Restaurant'),
          if (selectedFilter == 'All' || selectedFilter == 'Restaurant')
            CustomWidgets.buildFirebaseAnimatedListWithRatings(
                queryRestaurant,
                'assets/images/restaurant.png',
                getImages,
                getEstateRatings,
                selectedFilter),
        ],
      ),
    );
  }
}
