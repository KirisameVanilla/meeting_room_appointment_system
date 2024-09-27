import 'package:flutter/material.dart';
import 'package:meeting_room_booking_system/pages/week_viewModel.dart';
import '../main.dart';// 新增的周视图组件

class BookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('预定系统')),
      drawer: AppDrawer(),
      body: WeekView(),
    );
  }
}
