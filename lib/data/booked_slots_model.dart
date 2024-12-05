import 'dart:convert';

List<List<Map<String, String?>>> bookedSlots =
    List.generate(3, (_) => List.generate(7, (_) => myMap));

Map<String, String> myMap = {
  '10:00 AM': "",
  '10:30 AM': "",
  '11:00 AM': "",
  '11:30 AM': "",
  '12:00 PM': "",
  '12:30 PM': "",
  '1:00 PM': "",
  '1:30 PM': "",
  '2:00 PM': "",
  '2:30 PM': "",
  '3:00 PM': "",
  '3:30 PM': "",
  '4:00 PM': "",
  '4:30 PM': "",
  '5:00 PM': "",
  '5:30 PM': "",
};

String convertToString(List<List<Map<String, String?>>> bookedSlots) {
  return jsonEncode(bookedSlots);
}

List<List<Map<String, String?>>> convertFromString(String jsonString) {
  var decodedJson = jsonDecode(jsonString);
  List<List<Map<String, String?>>> bookedSlots = (decodedJson as List)
      .map((week) => (week as List)
          .map((day) => (day as Map).cast<String, String?>())
          .toList())
      .toList();
  return bookedSlots;
}
