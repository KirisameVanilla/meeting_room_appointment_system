import 'package:flutter/material.dart';
import 'package:meeting_room_booking_system/pages/booking_page.dart';
import 'package:provider/provider.dart';
import 'pages/booking_overview_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'data/booked_slots_model.dart';
import 'models/user_provider.dart';
import '../api_service.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => UserProvider(),
    child: ConferenceRoomApp(),
  ));
}

class ConferenceRoomApp extends StatefulWidget {
  @override
  State<ConferenceRoomApp> createState() => _ConferenceRoomAppState();
}

class _ConferenceRoomAppState extends State<ConferenceRoomApp> {
  
  @override
  void initState() {
    super.initState();
    final ApiService apiService = ApiService(baseUrl: 'http://localhost:5000');
    apiService.loadSlots(); // 加载本地文件中的预约数据
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting room appointment system',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePageWidget(),
        '/register': (context) => RegisterPageWidget(),
        '/book': (context) => BookPage(),
        '/overview': (context) => BookingOverviewPage(
              bookedSlots: bookedSlots,
              rooms: ['会议室 A', '会议室 B', '会议室 C'], // 会议室名称
              timeSlots: [
                '10:00 AM',
                '10:30 AM',
                '11:00 AM',
                '11:30 AM',
                '12:00 PM',
                '12:30 PM',
                '1:00 PM',
                '1:30 PM',
                '2:00 PM',
                '2:30 PM',
                '3:00 PM',
                '3:30 PM',
                '4:00 PM',
                '4:30 PM',
                '5:00 PM',
                '5:30 PM'
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
            title: Text('预定'),
            onTap: () {
              String? userName = Provider.of<UserProvider>(context, listen: false).userId;
              if (userName != null && userName != "") {
                Navigator.pushNamed(context, '/book');
              } else {            
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("未登录"),
                      content: Text("请先登录再访问预订页面"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                          child: Text("确认"),
                        ),
                      ],
                    );
                  },
                );
                return;
              }
            },
          ),
          ListTile(
            title: Text('查看预定情况'),
            onTap: () {
              Navigator.pushNamed(context, '/overview');
            },
          ),
        ],
      ),
    );
  }
}
