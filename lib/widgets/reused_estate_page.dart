import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
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

  Map<String, bool> coffeeMusicFilters = {
    'Oud': false,
    'DJ': false,
    'Singer': false,
  };

  Map<String, bool> entryAllowedFilters = {
    'Single': false,
    'Familial': false,
    'mixed': false,
  };

  Map<String, bool> entryHotelFilters = {
    'Single': false,
    'Double': false,
    'Suite': false,
    'Family': false,
  };

  Map<String, bool> sessionsTypeFilters = {
    'internal sessions': false,
    'External sessions': false,
  };

  Map<String, bool> musicFilters = {
    'There is no music': false,
    'There is music': false,
  };

  Map<String, bool> valetFilters = {
    'Has valet': false,
    'No valet': false,
    'Valet with fees': false,
    'Valet with no fees': false,
  };

  Map<String, bool> kidsAreaFilters = {
    'Has Kids Area': false,
    'No Kids Area': false,
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
        case 'Entry Hotel':
          entryHotelFilters[filterOption] = value;
          break;
        case 'Sessions Type':
          sessionsTypeFilters[filterOption] = value;
          break;
        case 'Music':
          musicFilters[filterOption] = value;
          break;
        case 'Coffee Music':
          coffeeMusicFilters[filterOption] = value;
          break;
        case 'Valet':
          valetFilters[filterOption] = value;
          break;
        case 'Kids Area':
          kidsAreaFilters[filterOption] = value;
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
        return _buildRestaurantFilterOptions(context);
      case 'Coffee':
        return _buildCoffeeFilterOptions(context);
      case 'Hotel':
        return _buildHotelFilterOptions(context);
      default:
        return Container();
    }
  }

  Widget _buildRestaurantFilterOptions(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            children: [
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
              const Divider(),
              Text(getTranslated(context, 'Valet Options')),
              ...valetFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: valetFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      valetFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Valet', filterOption, value!);
                  },
                );
              }).toList(),
              const Divider(),
              Text(getTranslated(context, 'Kids Area Options')),
              ...kidsAreaFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: kidsAreaFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      kidsAreaFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Kids Area', filterOption, value!);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoffeeFilterOptions(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            children: [
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
              const Divider(),
              Text(getTranslated(context, 'Coffee Music Options')),
              ...coffeeMusicFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: coffeeMusicFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      coffeeMusicFilters[filterOption] = value!;
                    });
                    _updateFilterSelection(
                        'Coffee Music', filterOption, value!);
                  },
                );
              }).toList(),
              const Divider(),
              Text(getTranslated(context, 'Valet Options')),
              ...valetFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: valetFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      valetFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Valet', filterOption, value!);
                  },
                );
              }).toList(),
              const Divider(),
              Text(getTranslated(context, 'Kids Area Options')),
              ...kidsAreaFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: kidsAreaFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      kidsAreaFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Kids Area', filterOption, value!);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHotelFilterOptions(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Text(getTranslated(context, 'Room types')),
              ...entryHotelFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: entryHotelFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      entryHotelFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Entry Hotel', filterOption, value!);
                  },
                );
              }).toList(),
              const Divider(),
              Text(getTranslated(context, 'Valet Options')),
              ...valetFilters.keys.map((filterOption) {
                return CheckboxListTile(
                  title: Text(getTranslated(context, filterOption)),
                  value: valetFilters[filterOption],
                  onChanged: (bool? value) {
                    setState(() {
                      valetFilters[filterOption] = value!;
                    });
                    _updateFilterSelection('Valet', filterOption, value!);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    return Column(
      children: [
        Container(
          color: Colors.white,
          margin:
              const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
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
                  _buildEstateList(
                      widget.queryHotel, 'assets/images/hotel.png'),
                const Divider(),
                if (widget.selectedFilter == 'All' ||
                    widget.selectedFilter == 'Coffee')
                  _buildSectionWithFilterIcon(context, 'Coffee'),
                if (widget.selectedFilter == 'All' ||
                    widget.selectedFilter == 'Coffee')
                  _buildEstateList(
                      widget.queryCoffee, 'assets/images/coffee.png'),
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
        ),
      ],
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
        _sortEstates, // Pass the sorting function
      ),
    );
  }

  List<Map> _sortEstates(List<Map> estates) {
    // Combine all selected filters
    final filterOrder = [
      ...restaurantFilters.keys.where((filter) => restaurantFilters[filter]!),
      ...entryAllowedFilters.keys
          .where((filter) => entryAllowedFilters[filter]!),
      ...entryHotelFilters.keys.where((filter) => entryHotelFilters[filter]!),
      ...sessionsTypeFilters.keys
          .where((filter) => sessionsTypeFilters[filter]!),
      ...musicFilters.keys.where((filter) => musicFilters[filter]!),
      ...coffeeMusicFilters.keys.where((filter) => coffeeMusicFilters[filter]!),
      ...valetFilters.keys.where((filter) => valetFilters[filter]!),
      ...kidsAreaFilters.keys.where((filter) => kidsAreaFilters[filter]!),
    ];

    estates.sort((a, b) {
      for (var filter in filterOrder) {
        bool aMatches = _matchesFilter(a, filter);
        bool bMatches = _matchesFilter(b, filter);

        if (aMatches && !bMatches) return -1;
        if (!aMatches && bMatches) return 1;
      }
      return 0;
    });

    return estates;
  }

  bool _matchesFilter(Map estate, String filter) {
    bool matches = false;

    if (filter == 'There is music' && estate['Music'] == '1') {
      matches = true;
    } else if (filter == 'There is no music' && estate['Music'] == '0') {
      matches = true;
    } else if (filter.toLowerCase() == 'oud' &&
        estate['Lstmusic']?.toLowerCase().contains('oud') == true) {
      matches = true;
    } else if (filter.toLowerCase() == 'dj' &&
        estate['Lstmusic']?.toLowerCase().contains('dj') == true) {
      matches = true;
    } else if (filter.toLowerCase() == 'singer' &&
        estate['Lstmusic']?.toLowerCase().contains('singer') == true) {
      matches = true;
    } else if (estate['TypeofRestaurant']?.contains(filter) == true) {
      matches = true;
    } else if (estate['Entry']?.contains(filter) == true) {
      matches = true;
    } else if (estate['Sessions']?.contains(filter) == true) {
      matches = true;
    } else if (filter == 'Has valet' && estate['HasValet'] == '1') {
      matches = true;
    } else if (filter == 'No valet' && estate['HasValet'] == '0') {
      matches = true;
    } else if (filter == 'Valet with fees' && estate['ValetWithFees'] == '1') {
      matches = true;
    } else if (filter == 'Valet with no fees' &&
        estate['ValetWithFees'] == '0') {
      matches = true;
    } else if (filter == 'Has Kids Area' && estate['HasKidsArea'] == '1') {
      matches = true;
    } else if (filter == 'No Kids Area' && estate['HasKidsArea'] == '0') {
      matches = true;
    }

    return matches;
  }
}
