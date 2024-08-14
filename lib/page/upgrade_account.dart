import 'package:diamond_booking/constants/colors.dart';
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
  String? selectedTypeAccount;

  @override
  void initState() {
    super.initState();
    LstTypeCustomersPayment.add(TypeCustomersPayment(
        Name: "Star", subtitle: "", ID: "1", image: "assets/images/star.png"));
    LstTypeCustomersPayment.add(TypeCustomersPayment(
        Name: "Vip", subtitle: "", ID: "2", image: "assets/images/vip.png"));
    LstTypeCustomersPayment.add(TypeCustomersPayment(
        Name: "Diamond",
        subtitle: "",
        ID: "3",
        image: "assets/images/dia.png"));

    fetchCurrentAccountType();
  }

  Future<void> fetchCurrentAccountType() async {
    String? id = FirebaseAuth.instance.currentUser?.uid;
    if (id != null) {
      DatabaseReference userRef = ref.child(id);
      DataSnapshot snapshot = await userRef.child("TypeAccount").get();
      setState(() {
        selectedTypeAccount = snapshot.value as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);
    objProvider.CheckLang();
    return Scaffold(
      key: _scaffoldKey1,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                ),
                child: RichText(
                  text: TextSpan(
                    text: getTranslated(context, 'Hello ,'),
                    style: GoogleFonts.laila(
                        fontSize: 6.w,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
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
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Display only the available account types
              CardTypes(LstTypeCustomersPayment[0], objProvider),
              CardTypes(LstTypeCustomersPayment[1], objProvider),
              CardTypes(LstTypeCustomersPayment[2], objProvider),
            ],
          ),
        ),
      ),
    );
  }

  CardTypes(TypeCustomersPayment obj, GeneralProvider objProvider) {
    bool isSelected = obj.ID == selectedTypeAccount;

    return InkWell(
      onTap: () async {
        String? id = FirebaseAuth.instance.currentUser?.uid;
        if (id != null) {
          await ref.child(id).update({"TypeAccount": obj.ID});
          setState(() {
            selectedTypeAccount = obj.ID;
          });
          objProvider.FunSnackBarPage("Updated", context);
        }
      },
      child: Container(
        height: 15.h,
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withOpacity(0.2) : Colors.white,
          border: Border.all(
            color: isSelected ? kPrimaryColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            getTranslated(context, obj.Name),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(obj.image),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          subtitle: Text(
            obj.subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: kPrimaryColor, size: 30)
              : null,
        ),
      ),
    );
  }
}

class TypeCustomersPayment {
  late String Name, subtitle, ID, image;
  TypeCustomersPayment(
      {required this.Name,
      required this.subtitle,
      required this.ID,
      required this.image});
}
