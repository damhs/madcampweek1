import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class GalleryTab extends StatefulWidget {
  GalleryTab({Key? key}) : super(key: key);

  @override
  _GalleryTabState createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  // 초기 이미지와 설명 리스트
  final List<Map<String, String>> items = [
    {'image': 'img/img1.jpeg', 'description': '자유로부터의 도피'},
    {'image': 'img/img2.jpeg', 'description': '모비딕'},
    {'image': 'img/img3.jpeg', 'description': '채식주의자'},
    {'image': 'img/img4.jpeg', 'description': '철학'},
    {'image': 'img/img5.jpeg', 'description': '채식주의자'},
    {'image': 'img/img6.jpeg', 'description': '철학'},
  ];

  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지를 선택
  Future<void> _pickImage() async {
    // 권한 요청
    final status = await Permission.photos.request();
    print("권한 요청");
    if (status.isGranted) {
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
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            padding: const EdgeInsets.all(5.0),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
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
                  ),
                  const SizedBox(height: 8),
                  Text(
                    items[index]['description']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Color(0xFF33CCCC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
