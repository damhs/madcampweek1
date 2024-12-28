import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

late SharedPreferences prefs;

class GalleryTab extends StatefulWidget {
  GalleryTab({Key? key}) : super(key: key);

  @override
  _GalleryTabState createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, String>> items = [];

  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    prefs = await SharedPreferences.getInstance();
    final List<String>? images = prefs.getStringList('images');
    if (images != null) {
      setState(() {
        items = images.map((image) {
          final List<String> parts = image.split(',');
          return {
            'image': parts[0],
            'description': parts[1],
            'timestamp': parts[2],
          };
        }).toList();
      });
    }
  }

  Future<void> _saveImages() async {
    await prefs.setStringList(
      'images',
      items.map((item) {
        return '${item['image']},${item['description']},${item['timestamp']}';
      }).toList(),
    );
  }

  void _addImage(String image, String description, String timestamp) {
    setState(() {
      items.add({
        'image': image,
        'description': description,
        'timestamp': timestamp,
      });
    });
    _saveImages();
  }

  void _editDescription(int index, String description) {
    setState(() {
      items[index]['description'] = description;
    });
    _saveImages();
  }

  void _deleteImage(int index) {
    setState(() {
      items.removeAt(index);
    });
    _saveImages();
  }

  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지를 선택
  Future<void> _pickImage() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(androidInfo);
    print(androidInfo.version.release);
    final int androidVersion =
        int.parse(androidInfo.version.release.split('.')[0]);
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
        _addImage(pickedFile.path, description,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
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
      body: items.isEmpty
          ? const Center(child: Text('저장된 사진이 없습니다.'))
          : Container(
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
                  return _buildImage(items: items, index: index);
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

class _buildImage extends StatelessWidget {
  const _buildImage({
    super.key,
    required this.items,
    required this.index,
  });

  final List<Map<String, String>> items;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              image: items[index]['image']!,
              description: items[index]['description']!,
              timestamp: items[index]['timestamp']!,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(items[index]['image']!)),
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
  }
}

class GalleryDetailPage extends StatelessWidget {
  final String image;
  final String description;
  final String timestamp;

  const GalleryDetailPage(
      {Key? key,
      required this.image,
      required this.description,
      required this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('독서 정보'),
            Text(
              timestamp,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Image.file(File(image)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
