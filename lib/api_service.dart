import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/booked_slots_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<void> registerUser(String email, String password) async {
    print('Email: $email, Password: $password');
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 201) {
      print('User registered successfully');
    } else {
      print('Failed to register: ${response.body}');
    }
  }

  Future<void> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      String token = jsonResponse['access_token'];
      print('Logged in successfully, token: $token');
    } else {
      print('Failed to log in: ${response.body}');
    }
  }

  void saveSlots() async {
    try {
      // 将 bookedSlots 转换为 JSON 字符串
      String jsonString = convertToString(bookedSlots);

      // 发送到后端
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/save_slots'),
        headers: {'Content-Type': 'application/json'},
        body: jsonString,
      );

      if (response.statusCode == 200) {
        print('Slots saved successfully!');
      } else {
        print('Error saving slots: ${response.body}');
      }
    } catch (e) {
      print('Exception while saving slots: $e');
    }
  }

  Future<void> loadSlots() async {
    try {
      // 从后端获取 JSON 数据
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/get_slots'),
      );

      if (response.statusCode == 200) {
        // 解析 JSON 字符串为 bookedSlots
        String jsonString = response.body;
        if (jsonString == '{}\n' || jsonString.isEmpty) {
        // 如果为空，则使用默认的初始化数据

        bookedSlots = List.generate(3, (_) => 
          List.generate(7, (_) => 
            Map.from(myMap)
          )
        );
        saveSlots();
        print('Slots loaded as empty. Initialized with default values.');
      } else {
        // 如果 JSON 数据有效，则进行解析
        bookedSlots = convertFromString(jsonString);
        print('Slots loaded successfully!');
      }
      } else {
        print('Error loading slots: ${response.body}');
      }
    } catch (e) {
      print('Exception while loading slots: $e');
    }
  }

  void subscribeSlots() async {
    try {
      // 将 bookedSlots 转换为 JSON 字符串
      String jsonString = json.encode(subscricedSlots);

      // 发送到后端
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/subscribe_slots'),
        headers: {'Content-Type': 'application/json'},
        body: jsonString,
      );

      if (response.statusCode == 200) {
        print('Subscription saved successfully!');
      } else {
        print('Error subscriping slots: ${response.body}');
      }
    } catch (e) {
      print('Exception while subscriping slots: $e');
    }
  }

  Future<void> loadSubscription() async {
    try {
      // 从后端获取 JSON 数据
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/get_subscription'),
      );

      if (response.statusCode == 200) {
        String jsonString = response.body;
        if (jsonString == '{}\n' || jsonString.isEmpty) {
        // 如果为空，则使用默认的初始化数据

        subscricedSlots = List.generate(3, (_) => 
          List.generate(7, (_) => 
            Map.from(subMap)
          )
        );
        subscribeSlots();
        print('Subscription loaded as empty. Initialized with default values.');
      } else {
        // 如果 JSON 数据有效，则进行解析
        subscricedSlots = convertFromStringSub(jsonString);
        print('Subscription loaded successfully!');
      }
      } else {
        print('Error loading Subscription: ${response.body}');
      }
    } catch (e) {
      print('Exception while loading Subscription: $e');
    }
  }

  // 发送邮件通知
  Future<void> sendCancellationEmails(List<String> emails, String slot) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_cancellation_emails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emails': emails,
          'slot': slot,
        }),
      );

      if (response.statusCode == 200) {
        print('Cancellation emails sent successfully!');
      } else {
        print('Error sending emails: ${response.body}');
      }
    } catch (e) {
      print('Exception while sending emails: $e');
    }
  }

}