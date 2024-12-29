import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

late SharedPreferences prefs;

class GalleryTab extends StatefulWidget {
  const GalleryTab({Key? key}) : super(key: key);

  @override
  _GalleryTabState createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TextEditingController _descriptionController = TextEditingController();

  List<Map<String, String>> items = [];

  void initState() {
    super.initState();
    _loadImages();

    _descriptionController = TextEditingController(text: '');
  }

  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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

  void _editImage(int index, String description) {
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
    print("권한 요청");
    if (havePermission) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _descriptionController.text = '';
        _addImage(pickedFile.path, _descriptionController.text,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              index: items.length,
              image: pickedFile.path,
              description: '',
              timestamp:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              onDelete: _deleteImage,
              onSave: _editImage,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 접근 권한이 필요합니다.')),
      );
    }
  }

  Widget _buildImage(
      {required List<Map<String, String>> items, required int index}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              index: index,
              image: items[index]['image']!,
              description: items[index]['description']!,
              timestamp: items[index]['timestamp']!,
              onDelete: _deleteImage,
              onSave: _editImage,
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

class GalleryDetailPage extends StatefulWidget {
  final int index;
  final String image;
  final String description;
  final String timestamp;
  final Function(int index) onDelete;
  final Function(int index, String description) onSave;

  const GalleryDetailPage({
    Key? key,
    required this.index,
    required this.image,
    required this.description,
    required this.timestamp,
    required this.onDelete,
    required this.onSave,
  }) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('독서 정보'),
                Text(
                  widget.timestamp,
                  style: const TextStyle(fontSize: 12.0),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete(widget.index);
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              color: Colors.purple,
              onPressed: () {
                Navigator.pop(context);
                widget.onSave(widget.index, _descriptionController.text);
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(File(widget.image)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '설명을 입력하세요.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
