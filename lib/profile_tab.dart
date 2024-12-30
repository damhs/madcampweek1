import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // 프로필 사진 수정 로직 추가 예정
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: appState.profileImage != null
                    ? FileImage(appState.profileImage!)
                    : null,
                child: appState.profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  appState.nickname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    _showEditNicknameDialog(context, appState);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
}
