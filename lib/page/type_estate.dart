// ignore_for_file: non_constant_identifier_names

import 'package:diamond_booking/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../general_provider.dart';
import '../screen/add_estate_screen.dart';
import 'myChat.dart';
import 'myEstate.dart';
import 'myEstateChat.dart';

class TypeEstate extends StatefulWidget {
  @override
  String Check;

  TypeEstate({required this.Check});

  _State createState() => new _State(Check);
}

class _State extends State<TypeEstate> {
  String Check;
  _State(this.Check);
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    return Scaffold(
        key: _scaffoldKey1,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            // ignore: sort_child_properties_last
            child: ListView.builder(
                itemCount: objProvider.TypeService().length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                          onTap: () {
                            if (Check == "Add") {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AddEstatesScreen(
                                        userType:
                                            objProvider.TypeService()[index]
                                                .type,
                                      )));
                            } else if (Check == "chat") {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MyEstateChat(
                                      Type: objProvider.TypeService()[index]
                                          .type)));
                            } else if (Check == "chatuser") {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MyChat(
                                      Type: objProvider.TypeService()[index]
                                          .type)));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MyEstate(
                                      Type: objProvider.TypeService()[index]
                                          .type)));
                            }
                          },
                          title: Text(objProvider.TypeService()[index].name),
                          leading: Image(
                            image: AssetImage(
                                objProvider.TypeService()[index].image),
                          )),
                    ),
                  );
                }),
            height: MediaQuery.of(context).size.height,
          ),
        ));
  }
}
