import 'package:flutter/material.dart';
import 'package:meeting_room_booking_system/pages/home_page.dart';
import '../main.dart'; // 新增的周视图组件
import '../api_service.dart';

class RegisterPageWidget extends StatefulWidget {
  const RegisterPageWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    // 将创建的State返回
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPageWidget> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService =
      ApiService(baseUrl: 'http://localhost:5000'); // 设置后端 URL
  String _email = "";
  String _pwd = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Meeting room appointment system')),
        drawer: AppDrawer(),
        body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
                buildTitle(), // Login
                const SizedBox(height: 50),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: (v) {
                    var emailReg = RegExp(
                        r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
                    if (!emailReg.hasMatch(v!)) {
                      return '请输入正确的邮箱地址';
                    }
                    return null;
                  },
                  onSaved: (v) => _email = v!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (passwordValidator) {
                    var pwdReg = RegExp(
                        r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#^+=~])[A-Za-z\d@$!%*?&#^+=~]{8,}$");
                    var specialRegFirst = RegExp(r"[-]{2,}");
                    var specialRegSecond = RegExp(r"[;<>]{1,}");
                    if (specialRegFirst.hasMatch(passwordValidator!) ||
                        specialRegSecond.hasMatch(passwordValidator)) {
                      return '我是来写网站的，你想干什么？补药注入我口牙';
                    }
                    if (!pwdReg.hasMatch(passwordValidator)) {
                      return '密码错误或不符合要求';
                    }
                    return null;
                  },
                  onSaved: (v) => _pwd = v!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Validation Passed')),
                      );
                      _formKey.currentState!.save();
                      print(_email);
                      print(_pwd);
                      apiService.registerUser(_email, _pwd);
                    } else {
                      // 如果验证失败，也可以给出提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Validation Failed')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePageWidget()),
                        );
                      },
                      child:
                          const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            )));
  }
}

Widget buildTitle() {
  return const Padding(
      // 设置边距
      padding: EdgeInsets.all(8),
      child: Text(
        'Register',
        style: TextStyle(fontSize: 42),
      ));
}
