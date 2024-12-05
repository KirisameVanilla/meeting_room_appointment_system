import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_slot_model.dart';
import '../models/user_provider.dart';
import '../data/booked_slots_model.dart'; // 导入 booked_slots.dart

class WeekView extends StatefulWidget {
  @override
  WeekViewState createState() => WeekViewState();
}

class WeekViewState extends State<WeekView> {
  final List<String> timeSlots = [
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
  ];

  // 存储每个会议室每天的已预定时间
  Set<String> selectedSlots = {};
  int selectedDayIndex = 0; // 当前选择的日期索引
  int selectedRoomIndex = 0; // 当前选择的会议室索引
  bool isCancelMode = false; // 取消模式状态

  // 会议室列表
  final List<String> rooms = ['会议室 A', '会议室 B', '会议室 C'];

  // 选择时间块的逻辑
  void selectTimeSlot(String timeSlot) {
    setState(() {
      if (isCancelMode) {
        // 在取消模式下，允许选择已预定的时间块
        if (bookedSlots[selectedRoomIndex][selectedDayIndex][timeSlot] != '') {
          if (selectedSlots.contains(timeSlot)) {
            selectedSlots.remove(timeSlot);
          } else {
            selectedSlots.add(timeSlot);
          }
        }
      } else {
        // 正常模式下，选择未预定的时间块
        if (bookedSlots[selectedRoomIndex][selectedDayIndex][timeSlot] == '') {
          if (selectedSlots.contains(timeSlot)) {
            selectedSlots.remove(timeSlot);
          } else {
            selectedSlots.add(timeSlot);
          }
        }
      }
    });
  }

  // 预定选中时间块的逻辑
  void bookSelectedSlots() {
    setState(() {
      try {
        String? userName =
            Provider.of<UserProvider>(context, listen: false).userId;
        for (var slot in selectedSlots) {
          bookedSlots[selectedRoomIndex][selectedDayIndex][slot] = userName;
        }

        selectedSlots.clear(); // 清空已选中状态
        // Todo: 使用convertToString(bookedSlots)保存
      } catch (e) {
        print(e);
      }
    });
  }

  // 取消选中预定的逻辑
  void cancelSelectedBookings() {
    setState(() {
      String? userName =
          Provider.of<UserProvider>(context, listen: false).userId;
      for (var slot in selectedSlots) {
        if (userName ==
            bookedSlots[selectedRoomIndex][selectedDayIndex][slot]) {
          bookedSlots[selectedRoomIndex][selectedDayIndex][slot] = "";
        }
      }
      selectedSlots.clear(); // 清空已选中状态
      // Todo: 使用convertToString(bookedSlots)保存
      isCancelMode = false; // 退出取消模式
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        // 会议室选择按钮
        Column(
          children: List.generate(rooms.length, (index) {
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedRoomIndex = index; // 切换选择的会议室
                  selectedSlots.clear(); // 切换会议室时清空已选择的时间
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedRoomIndex == index ? Colors.blue : Colors.grey,
              ),
              child: Text(rooms[index]),
            );
          }),
        ),
        Expanded(
          child: Column(
            children: [
              // 日期选择
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDayIndex = index; // 选择不同的日期
                        selectedSlots.clear(); // 切换日期时清空已选择的时间
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedDayIndex == index ? Colors.blue : Colors.grey,
                    ),
                    child: Text('第${index + 1}天'),
                  );
                }),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: timeSlots.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 每行显示两个时间块
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 3.0, // 控制每个时间块的宽高比
                    ),
                    itemBuilder: (context, index) {
                      String timeSlot = timeSlots[index];
                      bool isBooked = bookedSlots[selectedRoomIndex]
                              [selectedDayIndex][timeSlot] !=
                          '';
                      return TimeSlotWidget(
                        timeSlot: timeSlot,
                        isBooked: isBooked,
                        isSelected: selectedSlots.contains(timeSlot),
                        onTap: () {
                          selectTimeSlot(timeSlot);
                        },
                        isCancelMode: isCancelMode, // 传递取消模式状态
                        occupiedBy: bookedSlots[selectedRoomIndex]
                            [selectedDayIndex][timeSlot],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: selectedSlots.isNotEmpty && !isCancelMode
                          ? bookSelectedSlots
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedSlots.isNotEmpty && !isCancelMode
                                ? Colors.blue
                                : Colors.grey,
                      ),
                      child: Text('预定选中的时间块'),
                    ),
                    ElevatedButton(
                      onPressed: isCancelMode && selectedSlots.isNotEmpty
                          ? cancelSelectedBookings
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCancelMode && selectedSlots.isNotEmpty
                                ? Colors.red
                                : Colors.grey,
                      ),
                      child: Text('确认取消选中的预定'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCancelMode = !isCancelMode; // 切换取消模式状态
                          selectedSlots.clear(); // 切换模式时清空选择
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCancelMode ? Colors.red : Colors.blue,
                      ),
                      child: Text(isCancelMode ? '退出取消模式' : '进入取消模式'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
