import 'package:flutter/material.dart';
import 'pages/booking_overview_page.dart';
import 'pages/week_view.dart';
import 'pages/home_page.dart';
import 'data/booked_slots.dart';

void main() {
  runApp(ConferenceRoomApp());
}

class ConferenceRoomApp extends StatefulWidget {
  @override
  State<ConferenceRoomApp> createState() => _ConferenceRoomAppState();
}

class _ConferenceRoomAppState extends State<ConferenceRoomApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '会议室预定系统',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/book': (context) => WeekView(),
        '/overview': (context) => BookingOverviewPage(
          bookedSlots: bookedSlots,
          rooms: ['会议室 A', '会议室 B', '会议室 C'], // 会议室名称
          timeSlots: [
            '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', 
            '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM', 
            '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM'
          ], // 时间块
        ),
      },
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              '会议室预定系统',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text('主页'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            title: Text('查看预定情况'), // 新增的菜单项
            onTap: () {
              Navigator.pushNamed(context, '/overview');
            },
          ),
          ListTile(
            title: Text('预定'), // 新增的菜单项
            onTap: () {
              Navigator.pushNamed(context, '/book');
            },
          ),
        ],
      ),
    );
  }
}
