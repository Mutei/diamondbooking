import 'package:diamond_booking/widgets/text_form_style.dart';
import 'package:flutter/material.dart';

import '../constants/reused_provider_estate_container.dart';
import '../localization/language_constants.dart';

class RoomTypeVisibility extends StatefulWidget {
  final String userType;
  final bool single;
  final bool double;
  final bool suite;
  final bool family;
  final TextEditingController singleHotelRoomController;
  final TextEditingController doubleHotelRoomController;
  final TextEditingController suiteHotelRoomController;
  final TextEditingController familyHotelRoomController;
  final TextEditingController singleHotelRoomControllerBioAr;
  final TextEditingController singleHotelRoomControllerBioEn;
  final TextEditingController doubleHotelRoomControllerBioEn;
  final TextEditingController doubleHotelRoomControllerBioAr;
  final TextEditingController suiteHotelRoomControllerBioEn;
  final TextEditingController suiteHotelRoomControllerBioAr;
  final TextEditingController familyHotelRoomControllerBioAr;
  final TextEditingController familyHotelRoomControllerBioEn;
  final Function(bool) onSingleChanged;
  final Function(bool) onDoubleChanged;
  final Function(bool) onSuiteChanged;
  final Function(bool) onFamilyChanged;

  const RoomTypeVisibility({
    super.key,
    required this.userType,
    required this.single,
    required this.double,
    required this.suite,
    required this.family,
    required this.singleHotelRoomController,
    required this.doubleHotelRoomController,
    required this.suiteHotelRoomController,
    required this.familyHotelRoomController,
    required this.singleHotelRoomControllerBioAr,
    required this.singleHotelRoomControllerBioEn,
    required this.doubleHotelRoomControllerBioEn,
    required this.doubleHotelRoomControllerBioAr,
    required this.suiteHotelRoomControllerBioEn,
    required this.suiteHotelRoomControllerBioAr,
    required this.familyHotelRoomControllerBioAr,
    required this.familyHotelRoomControllerBioEn,
    required this.onSingleChanged,
    required this.onDoubleChanged,
    required this.onSuiteChanged,
    required this.onFamilyChanged,
  });

  @override
  _RoomTypeVisibilityState createState() => _RoomTypeVisibilityState();
}

class _RoomTypeVisibilityState extends State<RoomTypeVisibility> {
  @override
  Widget build(BuildContext context) {
    if (widget.userType != "1") return Container();

    return Column(
      children: [
        _buildRoomType(
          context,
          'Single',
          widget.single,
          widget.singleHotelRoomController,
          widget.singleHotelRoomControllerBioAr,
          widget.singleHotelRoomControllerBioEn,
          widget.onSingleChanged,
        ),
        _buildRoomType(
          context,
          'Double',
          widget.double,
          widget.doubleHotelRoomController,
          widget.doubleHotelRoomControllerBioAr,
          widget.doubleHotelRoomControllerBioEn,
          widget.onDoubleChanged,
        ),
        _buildRoomType(
          context,
          'Suite',
          widget.suite,
          widget.suiteHotelRoomController,
          widget.suiteHotelRoomControllerBioAr,
          widget.suiteHotelRoomControllerBioEn,
          widget.onSuiteChanged,
        ),
        _buildRoomType(
          context,
          'Family',
          widget.family,
          widget.familyHotelRoomController,
          widget.familyHotelRoomControllerBioAr,
          widget.familyHotelRoomControllerBioEn,
          widget.onFamilyChanged,
        ),
      ],
    );
  }

  Widget _buildRoomType(
    BuildContext context,
    String type,
    bool visible,
    TextEditingController controller,
    TextEditingController bioArController,
    TextEditingController bioEnController,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        Visibility(
          visible: !visible,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, type),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Checkbox(
                  checkColor: Colors.white,
                  value: visible,
                  onChanged: (bool? value) => onChanged(value!),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: visible,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusedProviderEstateContainer(
                        hint: type,
                      ),
                      TextFormFieldStyle(
                        context: context,
                        hint: "${type}1",
                        icon: const Icon(
                          Icons.single_bed,
                          color: Color(0xFF84A5FA),
                        ),
                        control: controller,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.number,
                      ),
                      TextFormFieldStyle(
                        context: context,
                        hint: "Bio",
                        icon: const Icon(
                          Icons.single_bed,
                          color: Color(0xFF84A5FA),
                        ),
                        control: bioArController,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.text,
                      ),
                      TextFormFieldStyle(
                        context: context,
                        hint: "BioEn",
                        icon: const Icon(
                          Icons.single_bed,
                          color: Color(0xFF84A5FA),
                        ),
                        control: bioEnController,
                        isObsecured: false,
                        validate: true,
                        textInputType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => onChanged(false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
