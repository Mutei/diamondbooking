// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../general_provider.dart';
import '../localization/language_constants.dart';

class UpgradeAccount extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _State extends State<UpgradeAccount> {
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  List<TypeCustomersPayment> LstTypeCustomersPayment = [];
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("User");

  @override
  void initState() {
    LstTypeCustomersPayment.add(TypeCustomersPayment(
        Name: "Star",
        subtitle: "test",
        ID: "1",
        image: "assets/images/star.png",
        price: "200"));
    LstTypeCustomersPayment.add(TypeCustomersPayment(
        Name: "Double Star",
        subtitle: "test",
        ID: "2",
        image: "assets/images/star2.png",
        price: "400"));
    LstTypeCustomersPayment.add(TypeCustomersPayment(
        Name: "Vip",
        subtitle: "test",
        ID: "3",
        image: "assets/images/vip.png",
        price: "500"));
    LstTypeCustomersPayment.add(TypeCustomersPayment(
        Name: "Diamond",
        subtitle: "test",
        ID: "4",
        image: "assets/images/dia.png",
        price: "700"));
    super.initState();
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    objProvider.CheckLang();
    return Scaffold(
        key: _scaffoldKey1,
        body: SafeArea(
            child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(objProvider.CheckLangValue
                      ? "assets/images/login.png"
                      : "assets/images/login2.png"),
                  fit: BoxFit.fill)),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(
                  right: objProvider.CheckLangValue ? 80 : 10,
                  top: 30,
                  left: objProvider.CheckLangValue ? 10 : 80,
                ),
                child: RichText(
                  // ignore: prefer_const_constructors
                  text: TextSpan(
                    text: getTranslated(context, 'Hello ,'),
                    style: GoogleFonts.laila(
                        fontSize: 6.w,
                        color: Color(0xFF84A5FA),
                        fontWeight: FontWeight.bold),
                    // ignore: prefer_const_literals_to_create_immutables
                    children: <TextSpan>[
                      TextSpan(
                          text: getTranslated(
                              context, 'choose the type of account you want'),
                          style: GoogleFonts.laila(
                              fontSize: 6.w,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: getTranslated(context, 'please!'),
                          style: GoogleFonts.laila(
                              fontSize: 6.w,
                              color: Color(0xFF84A5FA),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CardTypes(LstTypeCustomersPayment[0], objProvider),
              CardTypes(LstTypeCustomersPayment[1], objProvider),
              CardTypes(LstTypeCustomersPayment[2], objProvider),
              CardTypes(LstTypeCustomersPayment[3], objProvider),
            ],
          ),
        )));
  }

  CardTypes(TypeCustomersPayment obj, GeneralProvider objProvider) {
    return InkWell(
      child: Container(
        height: 15.h,
        margin: EdgeInsets.only(left: 40, right: 40),
        width: MediaQuery.of(context).size.width - 100,

        // ignore: prefer_const_constructors
        child: ListTile(
          title: Text(
            getTranslated(context, obj.Name),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          leading: Image(image: AssetImage(obj.image)),
          subtitle: Text(obj.subtitle),
          trailing: Text(
            obj.price,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
      ),
      onTap: () async {
        String? id = FirebaseAuth.instance.currentUser?.uid;
        await ref.child(id!).update({"TypeAccount": obj.ID});
        objProvider.FunSnackBarPage("Updated", context);
        Navigator.of(context).pop();
      },
    );
  }
}

class TypeCustomersPayment {
  late String Name, subtitle, ID, image, price;
  TypeCustomersPayment(
      {required this.Name,
      required this.subtitle,
      required this.ID,
      required this.image,
      required this.price});
}
