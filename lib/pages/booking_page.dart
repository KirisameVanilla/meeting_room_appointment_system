import 'package:flutter/material.dart';
import 'package:meeting_room_booking_system/pages/week_viewModel.dart';
import '../main.dart';

class BookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BookingSys')),
      drawer: AppDrawer(),
      body: WeekView(),
    );
  }
}
