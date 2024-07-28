import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../general_provider.dart';
import 'filter_button.dart';
import 'main_screen_widgets.dart';

class ReusedEstatePage extends StatefulWidget {
  final Query queryHotel;
  final Query queryCoffee;
  final Query queryRestaurant;
  final Future<String> Function(String) getImages;
  final GeneralProvider objProvider;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Future<Map<String, dynamic>> Function(String) getEstateRatings;
  final String searchQuery;

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
    required this.searchQuery,
  });

  @override
  _ReusedEstatePageState createState() => _ReusedEstatePageState();
}

class _ReusedEstatePageState extends State<ReusedEstatePage> {
  Map<String, bool> restaurantFilters = {
    'popular restaurant': false,
    'Indian Restaurant': false,
    'Italian': false,
    'Seafood Restaurant': false,
    'Fast Food': false,
    'Steak': false,
    'Grills': false,
    'healthy': false,
  };

  Map<String, bool> entryAllowedFilters = {
    'Single': false,
    'Familial': false,
    'mixed': false,
  };

  Map<String, bool> sessionsTypeFilters = {
    'internal sessions': false,
    'External sessions': false,
  };

  Map<String, bool> musicFilters = {
    'There is no music': false,
    'There is music': false,
  };

  Map<String, bool> hotelFilters = {
    'Single': false,
    'Double': false,
    'Swite': false,
    'Family': false,
  };

  Map<String, bool> coffeeFilters = {
    'Familial': false,
    'Single': false,
    'mixed': false,
  };

  void _updateFilterSelection(
      String filterType, String filterOption, bool value) {
    setState(() {
      switch (filterType) {
        case 'Restaurant':
          restaurantFilters[filterOption] = value;
          break;
        case 'Entry Allowed':
          entryAllowedFilters[filterOption] = value;
          break;
        case 'Sessions Type':
          sessionsTypeFilters[filterOption] = value;
          break;
        case 'Music':
          musicFilters[filterOption] = value;
          break;
        case 'Hotel':
          hotelFilters[filterOption] = value;
          break;
        case 'Coffee':
          coffeeFilters[filterOption] = value;
          break;
      }
    });
  }

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
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ...restaurantFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: restaurantFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      restaurantFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Restaurant', filterOption, value!);
                  },
                );
              }).toList(),
              const Divider(),
              Text(getTranslated(context, 'Entry allowed')),
              ...entryAllowedFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: entryAllowedFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      entryAllowedFilters[filterOption] = value!;
                    });
                    _updateFilterSelection(
                        'Entry Allowed', filterOption, value!);
                  },
                );
              }).toList(),
              const Divider(),
              Text(getTranslated(context, 'Sessions type')),
              ...sessionsTypeFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: sessionsTypeFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      sessionsTypeFilters[filterOption] = value!;
                    });
                    _updateFilterSelection(
                        'Sessions Type', filterOption, value!);
                  },
                );
              }).toList(),
              const Divider(),
              Text(getTranslated(context, 'Is there music')),
              ...musicFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: musicFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      musicFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Music', filterOption, value!);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHotelFilterOptions() {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            children: hotelFilters.keys.map((filterOption) {
              return CheckboxListTile(
                title: Text(getTranslated(context, filterOption)),
                value: hotelFilters[filterOption],
                onChanged: (bool? value) {
                  setState(() {
                    hotelFilters[filterOption] = value!;
                  });
                  _updateFilterSelection('Hotel', filterOption, value!);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCoffeeFilterOptions() {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            children: coffeeFilters.keys.map((filterOption) {
              return CheckboxListTile(
                title: Text(getTranslated(context, filterOption)),
                value: coffeeFilters[filterOption],
                onChanged: (bool? value) {
                  setState(() {
                    coffeeFilters[filterOption] = value!;
                  });
                  _updateFilterSelection('Coffee', filterOption, value!);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
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
              _buildEstateList(widget.queryHotel, 'assets/images/hotel.png'),
            const Divider(),
            if (widget.selectedFilter == 'All' ||
                widget.selectedFilter == 'Coffee')
              _buildSectionWithFilterIcon(context, 'Coffee'),
            if (widget.selectedFilter == 'All' ||
                widget.selectedFilter == 'Coffee')
              _buildEstateList(widget.queryCoffee, 'assets/images/coffee.png'),
            const Divider(),
            if (widget.selectedFilter == 'All' ||
                widget.selectedFilter == 'Restaurant')
              _buildSectionWithFilterIcon(context, 'Restaurant'),
            if (widget.selectedFilter == 'All' ||
                widget.selectedFilter == 'Restaurant')
              _buildEstateList(
                  widget.queryRestaurant, 'assets/images/restaurant.png'),
          ],
        ),
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

  Widget _buildEstateList(Query query, String icon) {
    return SizedBox(
      height: 200,
      child: CustomWidgets.buildFirebaseAnimatedListWithRatings(
        query,
        icon,
        widget.getImages,
        widget.getEstateRatings,
        widget.selectedFilter,
        widget.searchQuery,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import '../general_provider.dart';
// import 'filter_button.dart';
// import 'main_screen_widgets.dart';
//
// class ReusedEstatePage extends StatefulWidget {
//   final Query queryHotel;
//   final Query queryCoffee;
//   final Query queryRestaurant;
//   final Future<String> Function(String) getImages;
//   final GeneralProvider objProvider;
//   final String selectedFilter;
//   final Function(String) onFilterChanged;
//   final Future<Map<String, dynamic>> Function(String) getEstateRatings;
//   final String searchQuery;
//
//   const ReusedEstatePage({
//     super.key,
//     required this.queryHotel,
//     required this.queryCoffee,
//     required this.queryRestaurant,
//     required this.getImages,
//     required this.objProvider,
//     required this.selectedFilter,
//     required this.onFilterChanged,
//     required this.getEstateRatings,
//     required this.searchQuery,
//   });
//
//   @override
//   _ReusedEstatePageState createState() => _ReusedEstatePageState();
// }
//
// class _ReusedEstatePageState extends State<ReusedEstatePage> {
//   Map<String, bool> restaurantFilters = {
//     'popular restaurant': false,
//     'Indian Restaurant': false,
//     'Italian': false,
//     'Seafood Restaurant': false,
//     'Fast Food': false,
//     'Steak': false,
//     'Grills': false,
//     'healthy': false,
//   };
//
//   void _updateFilterSelection(String filterOption, bool value) {
//     setState(() {
//       restaurantFilters[filterOption] = value;
//     });
//   }
//
//   void _openFilterSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return _buildRestaurantFilterOptions();
//       },
//     );
//   }
//
//   Widget _buildRestaurantFilterOptions() {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return SingleChildScrollView(
//           child: Column(
//             children: restaurantFilters.keys.map((filterOption) {
//               return CheckboxListTile(
//                 title: Text(filterOption),
//                 value: restaurantFilters[filterOption],
//                 onChanged: (bool? value) {
//                   setState(() {
//                     restaurantFilters[filterOption] = value!;
//                   });
//                   _updateFilterSelection(filterOption, value!);
//                 },
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   List<Map> _sortEstates(List<Map> estates) {
//     // Apply sorting based on user-selected filters
//     if (restaurantFilters['popular restaurant'] == true) {
//       estates.sort((a, b) => b['popularity'].compareTo(a['popularity']));
//     } else if (restaurantFilters['Indian Restaurant'] == true) {
//       estates.sort((a, b) => a['type'].compareTo(b['type']));
//     } else if (restaurantFilters['Italian'] == true) {
//       estates.sort((a, b) => a['type'].compareTo(b['type']));
//     }
//     // Add more sorting conditions as needed
//     return estates;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       margin: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           children: [
//             Container(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 FilterButton(
//                   label: 'All',
//                   isSelected: widget.selectedFilter == 'All',
//                   onTap: () => widget.onFilterChanged('All'),
//                 ),
//                 FilterButton(
//                   label: 'Restaurant',
//                   isSelected: widget.selectedFilter == 'Restaurant',
//                   onTap: () => widget.onFilterChanged('Restaurant'),
//                 ),
//                 FilterButton(
//                   label: 'Hotel',
//                   isSelected: widget.selectedFilter == 'Hotel',
//                   onTap: () => widget.onFilterChanged('Hotel'),
//                 ),
//                 FilterButton(
//                   label: 'Coffee',
//                   isSelected: widget.selectedFilter == 'Coffee',
//                   onTap: () => widget.onFilterChanged('Coffee'),
//                 ),
//               ],
//             ),
//             const Divider(),
//             if (widget.selectedFilter == 'All' ||
//                 widget.selectedFilter == 'Hotel')
//               _buildSectionWithFilterIcon(context, 'Hotel'),
//             if (widget.selectedFilter == 'All' ||
//                 widget.selectedFilter == 'Hotel')
//               _buildEstateList(widget.queryHotel, 'assets/images/hotel.png'),
//             const Divider(),
//             if (widget.selectedFilter == 'All' ||
//                 widget.selectedFilter == 'Coffee')
//               _buildSectionWithFilterIcon(context, 'Coffee'),
//             if (widget.selectedFilter == 'All' ||
//                 widget.selectedFilter == 'Coffee')
//               _buildEstateList(widget.queryCoffee, 'assets/images/coffee.png'),
//             const Divider(),
//             if (widget.selectedFilter == 'All' ||
//                 widget.selectedFilter == 'Restaurant')
//               _buildSectionWithFilterIcon(context, 'Restaurant'),
//             if (widget.selectedFilter == 'All' ||
//                 widget.selectedFilter == 'Restaurant')
//               _buildEstateList(
//                   widget.queryRestaurant, 'assets/images/restaurant.png'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionWithFilterIcon(BuildContext context, String estateType) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         CustomWidgets.buildSectionTitle(context, estateType),
//         IconButton(
//           icon: const Icon(Icons.filter_list),
//           onPressed: () => _openFilterSheet(context),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEstateList(Query query, String icon) {
//     return SizedBox(
//       height: 200,
//       child: FirebaseAnimatedList(
//         query: query,
//         itemBuilder: (context, snapshot, animation, index) {
//           Map map = snapshot.value as Map;
//           map['Key'] = snapshot.key;
//
//           // Filter and sort estates based on user-selected filters
//           List<Map> filteredEstates = [map];
//           filteredEstates = _sortEstates(filteredEstates);
//
//           return Column(
//             children: filteredEstates.map((map) {
//               return FutureBuilder<Map<String, dynamic>>(
//                 future: widget.getEstateRatings(map['Key']),
//                 builder: (context, ratingsSnapshot) {
//                   if (ratingsSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (ratingsSnapshot.hasError) {
//                     return Text('Error: ${ratingsSnapshot.error}');
//                   } else {
//                     Map<String, dynamic> ratingsData = ratingsSnapshot.data!;
//                     double totalRating = ratingsData['totalRating'];
//                     int ratingCount = ratingsData['ratingCount'];
//                     return FutureBuilder<String>(
//                       future: widget.getImages(map['Key']),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(child: CircularProgressIndicator());
//                         } else if (snapshot.hasError) {
//                           return Text('Error: ${snapshot.error}');
//                         } else {
//                           String imageUrl = snapshot.data ??
//                               'assets/images/default_image.png';
//                           return CardEstate(
//                             context: context,
//                             obj: map,
//                             icon: icon,
//                             VisEdit: false,
//                             image: imageUrl,
//                             Visimage: true,
//                             ratings: ratingCount,
//                             totalRating: totalRating,
//                           );
//                         }
//                       },
//                     );
//                   }
//                 },
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
