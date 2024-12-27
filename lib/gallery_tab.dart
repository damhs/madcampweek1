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
    {'image': 'img/img1.jpeg', 'description': '설명 1'},
    {'image': 'img/img2.jpeg', 'description': '설명 2'},
    {'image': 'img/img3.jpeg', 'description': '설명 3'},
    {'image': 'img/img4.jpeg', 'description': '설명 4'},
    {'image': 'img/img5.jpeg', 'description': '설명 5'},
    {'image': 'img/img6.jpeg', 'description': '설명 6'},
  ];

  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지를 선택
  Future<void> _pickImage() async {
    // 권한 요청
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          items.add({
            'image': pickedFile.path,
            'description': '추가된 설명 ${items.length + 1}',
          });
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 접근 권한이 필요합니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    return Scaffold(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
