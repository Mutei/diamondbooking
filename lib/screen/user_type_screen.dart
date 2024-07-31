import 'dart:io';

import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../constants/styles.dart';
import '../general_provider.dart';
import 'guide_pager.dart';

class ChooseTypeUser extends StatefulWidget {
  const ChooseTypeUser({super.key});

  @override
  _State createState() => _State();
}

class _State extends State<ChooseTypeUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  List<CustomerType> LstCustomerType = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    objProvider.CheckLang();

    LstCustomerType = [
      CustomerType(
        image: "assets/images/customer.png",
        name: "Customer",
        type: "1",
        subtext: getTranslated(context, "Customer Info"),
      ),
      CustomerType(
        image: "assets/images/provider.png",
        name: "Provider",
        type: "2",
        subtext: getTranslated(context, "Provider Info"),
      ),
    ];

    return WillPopScope(
      // ignore: sort_child_properties_last
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 100,
                  ),
                  child: RichText(
                    // ignore: prefer_const_constructors
                    text: TextSpan(
                      text: getTranslated(context, "Are you a"),
                      style: kPrimaryGoogleFontsStyle,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <TextSpan>[
                        TextSpan(
                          text: getTranslated(context, 'Customer'),
                          style: kPrimaryTypeStyle,
                        ),
                        TextSpan(
                          text: getTranslated(context, 'or a'),
                          // ignore: unnecessary_const
                          style: kPrimaryGoogleFontsStyle,
                        ),
                        TextSpan(
                          text: "\n" '${getTranslated(context, 'Provider')}?',
                          style: kPrimaryTypeStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                CardType(LstCustomerType[0], objProvider),
                CardType(LstCustomerType[1], objProvider)
              ],
            ),
          )),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    exit(0);
    // await showDialog or Show add banners or whatever
    // then
    return true; // return true if the route to be popped
  }

  CardType(CustomerType obj, GeneralProvider objProvider) {
    return InkWell(
      child: Card(
        color: kPrimaryColor,
        elevation: 7,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 30),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 20.h,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80, // Width of the CircleAvatar
                  height: 80, // Height of the CircleAvatar
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage(obj.image),
                      fit: BoxFit.contain, // Adjust image within CircleAvatar
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, obj.name),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTypeUserTextColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        obj.subtext,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString("TypeUser", obj.type);
        print("TypeUser set to: ${obj.type}");
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GuidePager(userType: obj.type),
          ),
        );
      },
    );
  }
}

class CustomerType {
  late String name, image, type, subtext;
  CustomerType(
      {required this.image,
      required this.name,
      required this.type,
      required this.subtext});
}
