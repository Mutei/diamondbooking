class User {
  final String email;
  final String uid;
  final String userName;
  final String phoneNumber;
  final String password;
  final String birthOfDate;
  final String countryValue;
  final String stateValue;
  final String cityValue;
  final String typeAccount;
  final String typeUser;

  const User({
    required this.email,
    required this.uid,
    required this.userName,
    required this.phoneNumber,
    required this.password,
    required this.birthOfDate,
    required this.cityValue,
    required this.countryValue,
    required this.stateValue,
    required this.typeAccount,
    required this.typeUser,
  });

  Map<String, dynamic> toJson() => {
        'Name': userName,
        'ID': uid,
        'Email': email,
        'Phone': phoneNumber,
        'Password': password,
        'Date of Birth': birthOfDate,
        'CountryValue': countryValue,
        'CityValue': cityValue,
        'StateValue': stateValue,
        'TypeAccount': typeAccount,
        'TypeUser': typeUser,
      };
}
