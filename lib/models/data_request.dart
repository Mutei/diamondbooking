import 'package:flutter/animation.dart';

class DataRequest {
  late String ID, Name, Price, FromDate, ToDate, NameHotel, Status;
  Color? color = Color(0xFF000000);
  DataRequest({
    required this.ID,
    required this.Name,
    required this.Price,
    required this.FromDate,
    required this.ToDate,
    required this.NameHotel,
    required this.Status,
    required this.color,
  });
}
