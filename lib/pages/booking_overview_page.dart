import 'package:flutter/material.dart';

class BookingOverviewPage extends StatelessWidget {
  final List<List<Set<String>>> bookedSlots; // 传入的已预定时间数据
  final List<String> rooms;
  final List<String> timeSlots;

  BookingOverviewPage({
    required this.bookedSlots,
    required this.rooms,
    required this.timeSlots,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('会议室预定情况'),
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [
          // 展示时间块的表头
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 50), // 留出空位给会议室名
              ...timeSlots.map((timeSlot) => Expanded(
                child: Center(child: Text(timeSlot)),
              )),
            ],
          ),
          Divider(color: Colors.black,),
          // 遍历会议室
          for (int dateIndex = 0; dateIndex < 7; dateIndex++)...[
            Text("第${(dateIndex)}天"),
            for (int roomIndex = 0; roomIndex < rooms.length; roomIndex++)
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Center(child: Text(rooms[roomIndex])),
                  ),
                  ...timeSlots.map((timeSlot) {
                    bool isBooked = bookedSlots[roomIndex][dateIndex].contains(timeSlot);
                    return Expanded(
                      child: Container(
                        height: 50,
                        color: isBooked ? Colors.red : Colors.green, // 红色表示已预定，绿色表示未预定
                        child: Center(
                          child: Text(
                            isBooked ? '已预定' : '可用',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
          ),
          Divider(color: Colors.black,)
          ],
        ],
      ),
      ),
    );
  }
}
