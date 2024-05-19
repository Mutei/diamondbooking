// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sizer/sizer.dart';

import '../general_provider.dart';
import '../page/profileEstate.dart';

class CardEstate extends StatefulWidget {
  BuildContext context;
  Map obj;
  String icon;
  bool VisEdit;
  String image;
  bool? Visimage;
  CardEstate({
    required this.context,
    required this.obj,
    required this.icon,
    required this.VisEdit,
    required this.image,
    this.Visimage,
  });

  @override
  _State createState() =>
      _State(context, obj, icon, VisEdit, image, Visimage ?? true);
}

class _State extends State<CardEstate> {
  BuildContext context;
  Map obj;
  String icon;
  bool VisEdit;
  String image;
  bool Visimage;

  final storageRef = FirebaseStorage.instance.ref();

  _State(
    this.context,
    this.obj,
    this.icon,
    this.VisEdit,
    this.image,
    this.Visimage,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<String> getimages(String EID) async {
    try {
      String imageUrl;
      imageUrl = await storageRef
          .child(EID + "/0.jpg")
          .getDownloadURL()
          .onError((error, stackTrace) => '')
          .then((value) => value);

      return imageUrl.toString();
    } catch (e) {
      return "";
    }
  }

  // Widget build(BuildContext context) {
  //   final objProvider = Provider.of<GeneralProvider>(context, listen: false);
  //
  //   return InkWell(
  //     child: Container(
  //       width: MediaQuery.of(context).size.width - 100,
  //       margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
  //       child: Column(
  //         children: [
  //           Visibility(
  //             visible: Visimage,
  //             child: FutureBuilder<String>(
  //               future: getimages(obj['IDEstate'].toString()),
  //               builder: (context, snapshot) {
  //                 if (snapshot.hasData &&
  //                     snapshot.connectionState == ConnectionState.done &&
  //                     snapshot.data!.isNotEmpty) {
  //                   // Check if snapshot.data is not empty
  //                   return Container(
  //                     height: 120,
  //                     width: MediaQuery.of(context).size.width,
  //                     child: Image(
  //                       image: NetworkImage(snapshot.data!),
  //                       fit: BoxFit.cover,
  //                     ),
  //                   );
  //                 }
  //
  //                 return Center(
  //                   child: const CircularProgressIndicator(),
  //                 );
  //               },
  //             ),
  //           ),
  //           Container(
  //             margin: const EdgeInsets.only(left: 10, right: 10),
  //             child: ListTile(
  //               title: Text(
  //                   objProvider.CheckLangValue ? obj['NameEn'] : obj['NameAr']),
  //               subtitle: !Visimage
  //                   ? Wrap(
  //                       runSpacing: 5.0,
  //                       spacing: 5.0,
  //                       children: [
  //                         Expanded(
  //                             child: Text(
  //                           obj['State'],
  //                           style: TextStyle(fontSize: 12),
  //                         )),
  //                         Expanded(
  //                             child: Visibility(
  //                                 visible: obj["Type"] == 1 ? false : true,
  //                                 child: Text(
  //                                   obj["Sessions"].toString().isNotEmpty
  //                                       ? obj["Sessions"].toString()
  //                                       : " ",
  //                                   style: TextStyle(fontSize: 12),
  //                                 ))),
  //                         Expanded(
  //                             child: Visibility(
  //                                 visible: obj["Type"] == 1 ? false : true,
  //                                 child: Text(
  //                                   obj["TypeofRestaurant"]
  //                                           .toString()
  //                                           .isNotEmpty
  //                                       ? obj["TypeofRestaurant"].toString()
  //                                       : " ",
  //                                   style: TextStyle(fontSize: 12),
  //                                 )))
  //                       ],
  //                     )
  //                   : Text(
  //                       obj['State'],
  //                       style: TextStyle(fontSize: 12),
  //                     ),
  //               trailing: !Visimage
  //                   ? SizedBox(
  //                       width: 75,
  //                       height: 100,
  //                       child: FutureBuilder<String>(
  //                         future: getimages(obj['IDEstate'].toString()),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.hasData &&
  //                               snapshot.connectionState ==
  //                                   ConnectionState.done) {
  //                             return snapshot.data != ""
  //                                 ? Image(
  //                                     image: NetworkImage(snapshot.data!),
  //                                     fit: BoxFit.fill,
  //                                   )
  //                                 : Container();
  //                           }
  //                           // ignore: prefer_const_constructors
  //                           return Center(
  //                             // ignore: prefer_const_constructors
  //                             child: CircularProgressIndicator(),
  //                           );
  //                         },
  //                       ),
  //                     )
  //                   : Container(
  //                       width: 35,
  //                       height: 35,
  //                       child: Text(""),
  //                     ),
  //             ),
  //           ),
  //           Visibility(visible: !Visimage, child: Divider())
  //         ],
  //       ),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(MaterialPageRoute(
  //           builder: (context) => ProfileEstate(
  //                 estate: obj,
  //                 icon: icon,
  //                 VisEdit: VisEdit,
  //               )));
  //     },
  //   );
  // }
  // Widget build(BuildContext context) {
  //   final objProvider = Provider.of<GeneralProvider>(context, listen: false);
  //
  //   return InkWell(
  //     child: Container(
  //       width: MediaQuery.of(context).size.width - 100,
  //       margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
  //       child: Column(
  //         children: [
  //           Visibility(
  //             visible: Visimage,
  //             child: FutureBuilder<String>(
  //               future: obj['IDEstate'] != null
  //                   ? getimages(obj['IDEstate'].toString())
  //                   : Future.value(""),
  //               builder: (context, snapshot) {
  //                 if (snapshot.hasData &&
  //                     snapshot.connectionState == ConnectionState.done &&
  //                     snapshot.data!.isNotEmpty) {
  //                   return Container(
  //                     height: 120,
  //                     width: MediaQuery.of(context).size.width,
  //                     child: Image(
  //                       image: NetworkImage(snapshot.data!),
  //                       fit: BoxFit.cover,
  //                     ),
  //                   );
  //                 } else {
  //                   return Center(
  //                     child: Text(
  //                         "No image available"), // Display a placeholder or message
  //                   );
  //                 }
  //               },
  //             ),
  //           ),
  //           Container(
  //             margin: const EdgeInsets.only(left: 10, right: 10),
  //             child: ListTile(
  //               title: Text(
  //                   objProvider.CheckLangValue ? obj['NameEn'] : obj['NameAr']),
  //               subtitle: !Visimage
  //                   ? Wrap(
  //                       runSpacing: 5.0,
  //                       spacing: 5.0,
  //                       children: [
  //                         Expanded(
  //                             child: Text(
  //                           obj['State'],
  //                           style: TextStyle(fontSize: 12),
  //                         )),
  //                         Expanded(
  //                             child: Visibility(
  //                                 visible: obj["Type"] == 1 ? false : true,
  //                                 child: Text(
  //                                   obj["Sessions"].toString().isNotEmpty
  //                                       ? obj["Sessions"].toString()
  //                                       : " ",
  //                                   style: TextStyle(fontSize: 12),
  //                                 ))),
  //                         Expanded(
  //                             child: Visibility(
  //                                 visible: obj["Type"] == 1 ? false : true,
  //                                 child: Text(
  //                                   obj["TypeofRestaurant"]
  //                                           .toString()
  //                                           .isNotEmpty
  //                                       ? obj["TypeofRestaurant"].toString()
  //                                       : " ",
  //                                   style: TextStyle(fontSize: 12),
  //                                 )))
  //                       ],
  //                     )
  //                   : Text(
  //                       obj['State'],
  //                       style: TextStyle(fontSize: 12),
  //                     ),
  //               trailing: !Visimage
  //                   ? SizedBox(
  //                       width: 75,
  //                       height: 100,
  //                       child: FutureBuilder<String>(
  //                         future: obj['IDEstate'] != null
  //                             ? getimages(obj['IDEstate'].toString())
  //                             : Future.value(""),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.hasData &&
  //                               snapshot.connectionState ==
  //                                   ConnectionState.done) {
  //                             return snapshot.data != ""
  //                                 ? Image(
  //                                     image: NetworkImage(snapshot.data!),
  //                                     fit: BoxFit.fill,
  //                                   )
  //                                 : Container();
  //                           }
  //                           return Center(
  //                             child: CircularProgressIndicator(),
  //                           );
  //                         },
  //                       ),
  //                     )
  //                   : Container(
  //                       width: 35,
  //                       height: 35,
  //                       child: Text(""),
  //                     ),
  //             ),
  //           ),
  //           Visibility(visible: !Visimage, child: Divider())
  //         ],
  //       ),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(MaterialPageRoute(
  //           builder: (context) => ProfileEstate(
  //                 estate: obj,
  //                 icon: icon,
  //                 VisEdit: VisEdit,
  //               )));
  //     },
  //   );
  // }
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    // Debugging: Print the values of the keys being used
    print('IDEstate: ${obj['IDEstate']}');
    print('NameEn: ${obj['NameEn']}');
    print('NameAr: ${obj['NameAr']}');
    print('State: ${obj['State']}');
    print('Type: ${obj['Type']}');
    print('Sessions: ${obj['Sessions']}');
    print('TypeofRestaurant: ${obj['TypeofRestaurant']}');

    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Column(
          children: [
            Visibility(
              visible: Visimage,
              child: FutureBuilder<String>(
                future: obj['IDEstate'] != null
                    ? getimages(obj['IDEstate'].toString())
                    : Future.value(""),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done &&
                      snapshot.data!.isNotEmpty) {
                    return Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      child: Image(
                        image: NetworkImage(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    return Center(
                      child: Text("No image available"),
                    );
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: ListTile(
                title: Text(
                  objProvider.CheckLangValue
                      ? (obj['NameEn'] ??
                          'Unknown') // Handle null value for NameEn
                      : (obj['NameAr'] ??
                          'Unknown'), // Handle null value for NameAr
                ),
                subtitle: !Visimage
                    ? Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: [
                          Expanded(
                            child: Text(
                              obj['State'] ??
                                  'Unknown', // Handle null value for State
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: Visibility(
                              visible: obj["Type"] == 1 ? false : true,
                              child: Text(
                                obj["Sessions"]?.toString() ??
                                    " ", // Handle null value for Sessions
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Visibility(
                              visible: obj["Type"] == 1 ? false : true,
                              child: Text(
                                obj["TypeofRestaurant"]?.toString() ??
                                    " ", // Handle null value for TypeofRestaurant
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                        ],
                      )
                    : Text(
                        obj['State'] ??
                            'Unknown', // Handle null value for State
                        style: TextStyle(fontSize: 12),
                      ),
                trailing: !Visimage
                    ? SizedBox(
                        width: 75,
                        height: 100,
                        child: FutureBuilder<String>(
                          future: obj['IDEstate'] != null
                              ? getimages(obj['IDEstate'].toString())
                              : Future.value(""),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState ==
                                    ConnectionState.done) {
                              return snapshot.data != ""
                                  ? Image(
                                      image: NetworkImage(snapshot.data!),
                                      fit: BoxFit.fill,
                                    )
                                  : Container();
                            }
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 35,
                        height: 35,
                        child: Text(""),
                      ),
              ),
            ),
            Visibility(visible: !Visimage, child: Divider())
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileEstate(
                  estate: obj,
                  icon: icon,
                  VisEdit: VisEdit,
                )));
      },
    );
  }
}
