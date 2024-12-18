import 'dart:convert';

List<List<Map<String, String?>>> bookedSlots =
    List.generate(3, (_) => List.generate(7, (_) => Map.from(myMap)));

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

List<List<Map<String, List>>> subscricedSlots =
    List.generate(3, (_) => List.generate(7, (_) => Map.from(subMap)));

Map<String, List> subMap = {
  '10:00 AM': [],
  '10:30 AM': [],
  '11:00 AM': [],
  '11:30 AM': [],
  '12:00 PM': [],
  '12:30 PM': [],
  '1:00 PM': [],
  '1:30 PM': [],
  '2:00 PM': [],
  '2:30 PM': [],
  '3:00 PM': [],
  '3:30 PM': [],
  '4:00 PM': [],
  '4:30 PM': [],
  '5:00 PM': [],
  '5:30 PM': [],
};

String convertToString(List<List<Map<String, String?>>> bookedSlots) {
  return jsonEncode(bookedSlots);
}

List<List<Map<String, String?>>> convertFromString(String jsonString) {
  var decodedJson = jsonDecode(jsonString);

  // Ensure that the decodedJson is a List of Lists of Maps, and handle if it's not valid
  if (decodedJson is List) {
    return (decodedJson).map((week) {
      if (week is List) {
        return (week).map((day) {
          if (day is Map) {
            // Cast the Map to Map<String, String?> to ensure types match
            return (day).cast<String, String?>();
          } else {
            // Handle invalid data if needed
            return <String, String?>{};
          }
        }).toList();
      } else {
        // Handle invalid data if needed
        return <Map<String, String?>>[];
      }
    }).toList();
  } else {
    // Handle error or invalid format, return an empty list or default values
    print("Error: Invalid data format.");
    return List.generate(3, (_) => List.generate(7, (_) => Map.from(myMap)));
  }
}

List<List<Map<String, List>>> convertFromStringSub(String jsonString) {
  // 解析 JSON 字符串
  var decodedJson = jsonDecode(jsonString);

  // 确保解析后的结果是一个 List<List<Map<String, List>>> 类型
  if (decodedJson is List) {
    return (decodedJson).map((week) {
      if (week is List) {
        return (week).map((day) {
          if (day is Map) {
            // 检查每个时间段的值是 List 类型
            return day.cast<String, List>(); // 将 Map<String, List> 强制转换为指定类型
          } else {
            // 如果不是 Map 类型，返回一个空的 Map
            return <String, List>{};
          }
        }).toList();
      } else {
        // 如果不是 List 类型，返回一个空的 List
        return <Map<String, List>>[];
      }
    }).toList();
  } else {
    // 如果不是有效的格式，返回一个默认的结构
    print("Error: Invalid data format.");
    return List.generate(3, (_) => List.generate(7, (_) => <String, List>{}));
  }
}
