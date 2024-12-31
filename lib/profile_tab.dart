import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:table_calendar/table_calendar.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.teal[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 프로필 카드
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showImageSourceSelector(context, appState);
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: appState.profileImage != null
                                ? FileImage(appState.profileImage!)
                                : null,
                            child: appState.profileImage == null
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      appState.nickname,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _showEditNicknameDialog(
                                          context, appState);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      appState.statusMessage,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _showEditStatusMessageDialog(
                                          context, appState);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCalendar(appState),
                const SizedBox(height: 20),
                // 통계 카드
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatisticTile(
                          icon: Icons.photo_library,
                          label: '업로드한 사진',
                          value: appState.imageCount.toString(),
                        ),
                        _buildStatisticTile(
                          icon: Icons.edit,
                          label: '작성한 리뷰',
                          value: appState.reviewCount.toString(),
                        ),
                        _buildStatisticTile(
                          icon: Icons.calendar_today,
                          label: '활동한 날',
                          value: appState.uploadDayCount.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 뱃지 섹션
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildBadgeSection(appState),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditStatusMessageDialog(BuildContext context, AppState appState) {
    final TextEditingController statusController =
        TextEditingController(text: appState.statusMessage);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('상태 메시지 수정'),
          content: TextField(
            controller: statusController,
            decoration: const InputDecoration(
              labelText: '새 상태 메시지',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final newStatusMessage = statusController.text.trim();
                if (newStatusMessage.isNotEmpty) {
                  appState.updateStatusMessage(newStatusMessage); // 상태 메시지 저장
                }
                Navigator.pop(context); // 저장 후 닫기
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceSelector(BuildContext context, AppState appState) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: ButtonStyle(
                  maximumSize: WidgetStateProperty.all(Size(100, 100)),
                ),
                onPressed: () async {
                  final image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    appState.updateProfileImage(File(image.path));
                  }
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/img/camera.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '카메라',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  maximumSize: WidgetStateProperty.all(Size(100, 100)),
                ),
                onPressed: () async {
                  final image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    appState.updateProfileImage(File(image.path));
                  }
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/img/gallery.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '갤러리',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        /*
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라'),
              onTap: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  appState.updateProfileImage(File(image.path));
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리'),
              onTap: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  appState.updateProfileImage(File(image.path));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );*/
      },
    );
  }

  void _showEditNicknameDialog(BuildContext context, AppState appState) {
    final TextEditingController nicknameController =
        TextEditingController(text: appState.nickname);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('닉네임 수정'),
          content: TextField(
            controller: nicknameController,
            decoration: const InputDecoration(
              labelText: '새 닉네임',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final newNickname = nicknameController.text.trim();
                if (newNickname.isNotEmpty) {
                  appState.updateNickname(newNickname); // 닉네임 저장
                }
                Navigator.pop(context); // 저장 후 닫기
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.teal),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBadgeSection(AppState appState) {
    final badges = appState.badges.entries.map((entry) {
      final badgeId = entry.key;
      final isUnlocked = entry.value;

      return _buildBadgeTile(
        title: isUnlocked
            ? appState.badgeNames[badgeId] ?? '알 수 없는 뱃지' // 잠금 해제 시 실제 이름
            : '???', // 잠금 상태일 때
        iconPath: isUnlocked
            ? 'assets/badges/$badgeId.png' // 보유한 뱃지 이미지
            : 'assets/badges/locked.png', // 잠긴 뱃지 이미지
        isUnlocked: isUnlocked,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '획득한 뱃지',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) => badges[index],
        ),
      ],
    );
  }

  Widget _buildBadgeTile({
    required String title,
    required String iconPath,
    required bool isUnlocked,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconSize = constraints.maxWidth * 0.6; // 셀 너비의 60% 사용
        double textSize = constraints.maxWidth * 0.15; // 텍스트 크기 동적 조정

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
              /*color: isUnlocked ? null : Colors.grey,
              colorBlendMode:
                  isUnlocked ? null : BlendMode.saturation, // 잠긴 상태 블렌딩*/
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: textSize,
                color: isUnlocked ? Colors.black : Colors.grey,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Widget _buildCalendar(AppState appState) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이번 주 리뷰 활동',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: CalendarFormat.week,
              availableCalendarFormats: const {
                CalendarFormat.week: '주간',
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final isMarked = appState.markedDates.any((markedDate) =>
                      markedDate.year == day.year &&
                      markedDate.month == day.month &&
                      markedDate.day == day.day);

                  if (isMarked) {
                    return Positioned(
                      bottom: 1,
                      child: Icon(
                        Icons.check_circle,
                        size: 16, // 아이콘 크기 조정
                        color: Colors.green, // 아이콘 색상
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
