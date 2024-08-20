import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class BackendService {
  final ImagePicker imagePicker = ImagePicker();
  DatabaseReference ref = FirebaseDatabase.instance.ref("App").child("Estate");
  DatabaseReference refID =
      FirebaseDatabase.instance.ref("App").child("EstateID");

  Future<List<XFile>?> openImages() async {
    try {
      var pickedFiles = await imagePicker.pickMultiImage();
      return pickedFiles;
    } catch (e) {
      print("Error while picking file: $e");
      return null;
    }
  }

  Future<String?> getTypeAccount(String userId) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("App")
        .child("Users")
        .child(userId)
        .child("TypeAccount");
    DataSnapshot snapshot = await ref.get();
    return snapshot.value as String?;
  }

  Future<int?> getIdEstate() async {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref("App").child("EstateID");
    DataSnapshot snapshot = await starCountRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      return data['EstateID'] ?? 1;
    }
    return null;
  }

  Future<void> addEstate({
    required String childType,
    required String idEstate,
    required String nameAr,
    required String nameEn,
    required String bioAr,
    required String bioEn,
    required String country,
    required String city,
    required String state,
    required String userType,
    required String userID,
    required String typeAccount,
    required String estateNumber,
    required String taxNumber,
    required String music,
    required List<String> listTypeOfRestaurant,
    required List<String> listSessions,
    required List<String> listMusic,
    required List<String> listEntry,
    required String price,
    required String priceLast,
    required String ownerFirstName,
    required String ownerLastName,
    required String menuLink,

    // New valet fields
    required bool hasValet,
    required bool valetWithFees,

    // New Kids Area fields
    required bool hasKidsArea,

    // New hotel-specific fields
    required bool hasSwimmingPool,
    required bool hasBarber,
    required bool hasMassage,
    required bool hasGym,
  }) async {
    await ref.child(childType).child(idEstate).set({
      "NameAr": nameAr,
      "NameEn": nameEn,
      "Owner of Estate Name": "$ownerFirstName $ownerLastName",
      "BioAr": bioAr,
      "BioEn": bioEn,
      "Country": country,
      "City": city,
      "State": state,
      "Type": userType,
      "IDUser": userID,
      "IDEstate": idEstate,
      "TypeAccount": typeAccount,
      "EstateNumber": estateNumber,
      "TaxNumer": taxNumber,
      "Music": music,
      "TypeofRestaurant": listTypeOfRestaurant.join(","),
      "Sessions": listSessions.join(","),
      "Lstmusic": listMusic.join(","),
      "Entry": listEntry.join(","),
      "Price": price,
      "PriceLast": priceLast,
      "MenuLink": menuLink,

      // New valet fields
      "HasValet": hasValet ? "1" : "0",
      "ValetWithFees": valetWithFees ? "1" : "0",

      // New Kids Area field
      "HasKidsArea": hasKidsArea ? "1" : "0",

      // New hotel-specific fields
      "HasSwimmingPool": hasSwimmingPool ? "1" : "0",
      "HasBarber": hasBarber ? "1" : "0",
      "HasMassage": hasMassage ? "1" : "0",
      "HasGym": hasGym ? "1" : "0",
    });
  }

  Future<void> addRoom({
    required String estateId,
    required String roomId,
    required String roomName,
    required String roomPrice,
    required String roomBioAr,
    required String roomBioEn,
  }) async {
    DatabaseReference refRooms = FirebaseDatabase.instance
        .ref("App")
        .child("Rooms")
        .child(estateId)
        .child(roomName);

    await refRooms.set({
      "ID": roomId,
      "Name": roomName,
      "Price": roomPrice,
      "BioAr": roomBioAr,
      "BioEn": roomBioEn,
    });
  }

  Future<void> updateEstateId(int newIdEstate) async {
    await refID.update({"EstateID": newIdEstate});
  }

  Future<Map<String, String?>> getUserDetails(String userId) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("App").child("User").child(userId);
    DataSnapshot firstNameSnapShot = await userRef.child("FirstName").get();
    DataSnapshot lastNameSnapShot = await userRef.child("LastName").get();
    DataSnapshot typeAccountSnapShot = await userRef.child("TypeAccount").get();

    return {
      "firstName": firstNameSnapShot.value as String?,
      "lastName": lastNameSnapShot.value as String?,
      "typeAccount": typeAccountSnapShot.value as String?,
    };
  }
}
