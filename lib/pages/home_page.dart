import 'package:flutter/material.dart';
import '../main.dart';// 新增的周视图组件

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    // 将创建的State返回
    return HomePageState();
  }
}

class HomePageState extends State<HomePageWidget> {
  //String _email = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _formKey,
      appBar: AppBar(title: Text('会议室预定系统')),
      drawer: AppDrawer(),
      
      body: Form(
        
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
              },
              //onSaved: (v) => _email = v!,
              
            ),
            ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ))
    );
  }
}

Widget buildTitle() {
  return const Padding( // 设置边距
      padding: EdgeInsets.all(8),
      child: Text(
        'Login',
        style: TextStyle(fontSize: 42),
      ));
}

