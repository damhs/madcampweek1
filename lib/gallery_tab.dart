import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

class GalleryTab extends StatefulWidget {
  GalleryTab({Key? key}) : super(key: key);

  @override
  _GalleryTabState createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  // 초기 이미지와 설명 리스트
  final List<Map<String, String>> items = [
    {
      'image': 'img/img1.jpeg',
      'description': '자유로부터의 도피',
      'timestamp': '2024-12-28 12:00:00'
    },
    {
      'image': 'img/img2.jpeg',
      'description': '모비딕',
      'timestamp': '2024-12-28 12:00:00'
    },
    {
      'image': 'img/img3.jpeg',
      'description': '채식주의자',
      'timestamp': '2024-12-28 12:00:00'
    },
    {
      'image': 'img/img4.jpeg',
      'description': '철학',
      'timestamp': '2024-12-28 12:00:00'
    },
    {
      'image': 'img/img5.jpeg',
      'description': '채식주의자',
      'timestamp': '2024-12-28 12:00:00'
    },
    {
      'image': 'img/img6.jpeg',
      'description': '철학',
      'timestamp': '2024-12-28 12:00:00'
    },
  ];

  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지를 선택
  Future<void> _pickImage() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 13) {
      final request = await Permission.photos.request();
      havePermission = request.isGranted;
    } else {
      final status = await Permission.storage.request();
      havePermission = status.isGranted;
    }

    // 권한 요청
    print("권한 요청");
    if (havePermission) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        String? description = await _showDescriptionDialog();
        if (description == null) {
          return;
        }
        setState(() {
          items.add({
            'image': pickedFile.path,
            'description': description,
            'timestamp': DateTime.now().toString()
          });
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 접근 권한이 필요합니다.')),
      );
    }
  }

  Future<String?> _showDescriptionDialog() async {
    String? description;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('설명 추가'),
          content: TextField(
            onChanged: (value) {
              description = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(description);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 독서 모음'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: sizeX,
        height: sizeY,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
            childAspectRatio: 1.0,
          ),
          itemCount: items.length,
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      image: items[index]['image']!,
                      description: items[index]['description']!,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: index < 6
                            ? AssetImage(items[index]['image']!)
                                as ImageProvider
                            : FileImage(File(items[index]['image']!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    margin: const EdgeInsets.all(5.0),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        items[index]['timestamp']!,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Color(0xFF33CCCC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String image;
  final String description;

  const DetailPage({Key? key, required this.image, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상세보기'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image!) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
