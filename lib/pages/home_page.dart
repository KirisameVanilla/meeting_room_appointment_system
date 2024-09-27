import 'package:flutter/material.dart';
import '../main.dart';// 新增的周视图组件

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('会议室预定系统')),
      drawer: AppDrawer(),
      body: null,
    );
  }
}
