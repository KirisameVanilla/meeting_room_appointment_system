import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_slot_model.dart';
import '../models/user_provider.dart';
import '../data/booked_slots_model.dart';
import '../api_service.dart';

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
  bool isSubscribeMode = false; // 订阅模式状态

  // 会议室列表
  final List<String> rooms = ['会议室 A', '会议室 B', '会议室 C'];

  // 选择时间块的逻辑
  void selectTimeSlot(String timeSlot) {
    setState(() {
      String? userName =
          Provider.of<UserProvider>(context, listen: false).userId;
      if (isCancelMode) {
        // 在取消模式下，允许选择已预定的时间块
        if (bookedSlots[selectedRoomIndex][selectedDayIndex][timeSlot] ==
            userName) {
          if (selectedSlots.contains(timeSlot)) {
            selectedSlots.remove(timeSlot);
          } else {
            selectedSlots.add(timeSlot);
          }
        }
      }
      if (isSubscribeMode) {
        if (bookedSlots[selectedRoomIndex][selectedDayIndex][timeSlot] != '' &&
            bookedSlots[selectedRoomIndex][selectedDayIndex][timeSlot] !=
                userName) {
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
        final ApiService apiService =
            ApiService(baseUrl: 'http://localhost:5000');
        String? userName =
            Provider.of<UserProvider>(context, listen: false).userId;
        for (var slot in selectedSlots) {
          bookedSlots[selectedRoomIndex][selectedDayIndex][slot] = userName;
        }
        selectedSlots.clear(); // 清空已选中状态
        apiService.saveSlots();
      } catch (e) {
        print(e);
      }
    });
  }

  // 取消选中预定的逻辑
  void cancelSelectedBookings() {
    setState(() {
      final ApiService apiService =
          ApiService(baseUrl: 'http://localhost:5000');
      String? userName =
          Provider.of<UserProvider>(context, listen: false).userId;
      for (var slot in selectedSlots) {
        if (userName ==
            bookedSlots[selectedRoomIndex][selectedDayIndex][slot]) {
          bookedSlots[selectedRoomIndex][selectedDayIndex][slot] = "";
        }

        List<String> subscribedEmails = List.from(
            subscricedSlots[selectedRoomIndex][selectedDayIndex][slot] ?? []);

        // 调用后端 API 发送邮件通知
        if (subscribedEmails.isNotEmpty) {
          apiService.sendCancellationEmails(subscribedEmails, slot);
        }
      }
      selectedSlots.clear(); // 清空已选中状态
      apiService.saveSlots();
      isCancelMode = false; // 退出取消模式
    });
  }

  void subscribeSelectedBookings() {
    setState(() {
      final ApiService apiService =
          ApiService(baseUrl: 'http://localhost:5000');
      String? userName =
          Provider.of<UserProvider>(context, listen: false).userId;
      for (var slot in selectedSlots) {
        subscricedSlots[selectedRoomIndex][selectedDayIndex][slot]!
            .add(userName);
      }
      selectedSlots.clear(); // 清空已选中状态
      apiService.subscribeSlots();
      isSubscribeMode = false; // 退出取消模式
    });
  }

  @override
  void initState() {
    super.initState();
    final ApiService apiService = ApiService(baseUrl: 'http://localhost:5000');
    apiService.loadSlots(); // 加载本地文件中的预约数据
    apiService.loadSubscription();
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
                        isSubscribeMode: isSubscribeMode,
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
                      onPressed: selectedSlots.isNotEmpty &&
                              !isCancelMode &&
                              !isSubscribeMode
                          ? bookSelectedSlots
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedSlots.isNotEmpty &&
                                !isCancelMode &&
                                !isSubscribeMode
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
                        if (isSubscribeMode) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("错误"),
                                content: Text("请先退出订阅模式再选择取消模式"),
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
                        } else {
                          setState(() {
                            isCancelMode = !isCancelMode; // 切换取消模式状态
                            selectedSlots.clear(); // 切换模式时清空选择
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCancelMode ? Colors.red : Colors.blue,
                      ),
                      child: Text(isCancelMode ? '退出取消模式' : '进入取消模式'),
                    ),
                    ElevatedButton(
                      onPressed: isSubscribeMode && selectedSlots.isNotEmpty
                          ? subscribeSelectedBookings
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSubscribeMode && selectedSlots.isNotEmpty
                                ? Colors.red
                                : Colors.grey,
                      ),
                      child: Text('确认订阅'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (isCancelMode) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("错误"),
                                content: Text("请先退出取消模式再选择订阅模式"),
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
                        } else {
                          setState(() {
                            isSubscribeMode = !isSubscribeMode; // 切换取消模式状态
                            selectedSlots.clear(); // 切换模式时清空选择
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSubscribeMode ? Colors.red : Colors.blue,
                      ),
                      child: Text(isSubscribeMode ? '退出订阅模式' : '进入订阅模式'),
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
