// ignore_for_file: non_constant_identifier_names

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../localization/language_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'addImage.dart';
import 'additionalfacility.dart';

class Maps extends StatefulWidget {
  String ID;
  String TypeEstate;
  Maps({required this.ID, required this.TypeEstate});
  @override
  _State createState() => new _State(ID, TypeEstate);
}

class _State extends State<Maps> {
  String ID;
  String TypeEstate;
  _State(this.ID, this.TypeEstate);

  @override
  void initState() {
    super.initState();
  }

  LatLng latLng = LatLng(37.7749, -122.4194);
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("Estate");
  GoogleMapController? _controller;
  LatLng _center = LatLng(37.7749, -122.4194);

  void _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _center,
              zoom: 16.0,
            ),
          ),
        );
      });
    } catch (e) {
      // Handle any errors here
      print(e.toString());
    }
  }

  // ignore: prefer_const_constructors
  Marker marker = Marker(
    markerId: const MarkerId('marker_1'),
    position: LatLng(37.7749, -122.4194),
    // ignore: prefer_const_constructors
    infoWindow: InfoWindow(),
  );
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(_center.latitude, _center.longitude),
                zoom: 11.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: (argument) {
                latLng = argument;
                setState(() {
                  marker = Marker(
                    markerId: const MarkerId('marker_1'),
                    position: LatLng(latLng.latitude, latLng.longitude),
                    // ignore: prefer_const_constructors
                    infoWindow: InfoWindow(),
                  );
                });
              },
              markers: Set<Marker>.of([marker]),
            )),
        Align(
          alignment: Alignment.bottomCenter,
          child: InkWell(
            onTap: () async {
              await ref.child(TypeEstate).child(ID.toString()).update({
                "Lat": latLng.latitude,
                "Lon": latLng.longitude,
              });
              if (TypeEstate == "Hottel") {
                Map e = Map();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AdditionalFacility(
                          CheckState: "add",
                          CheckIsBooking: false,
                          IDEstate: ID,
                          estate: e,
                        )));
              } else {
                Map e = Map();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddImage(
                          IDEstate: ID.toString(),
                        )));
              }
            },
            child: Container(
              width: 150.w,
              height: 6.h,
              margin: const EdgeInsets.only(right: 40, left: 40, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF84A5FA),
                borderRadius: BorderRadius.circular(12),
              ),
              // ignore: prefer_const_constructors
              child: Center(
                child: Text(getTranslated(context, "Next")),
              ),
            ),
          ),
        )
      ],
    ));
  }
}
