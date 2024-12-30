import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    appState.statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    _showEditStatusMessageDialog(context, appState);
                  },
                ),
              ],
            ),
          ],
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
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라'),
              onTap: () async {
                final image = await _picker.pickImage(source: ImageSource.camera);
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
        );
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
}
