// gallery_tab.dart
import 'package:flutter/material.dart';

class GalleryTab extends StatelessWidget {
  GalleryTab({Key? key}) : super(key: key);

  // 이미지와 설명 리스트
  final List<Map<String, String>> items = [
    {'image': 'img/img1.jpeg', 'description': '설명 1'},
    {'image': 'img/img2.jpeg', 'description': '설명 2'},
    {'image': 'img/img3.jpeg', 'description': '설명 3'},
    {'image': 'img/img4.jpeg', 'description': '설명 4'},
    {'image': 'img/img5.jpeg', 'description': '설명 5'},
    {'image': 'img/img6.jpeg', 'description': '설명 6'},
  ];

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
          width: sizeX,
          height: sizeY,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            padding: const EdgeInsets.all(5.0),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(items[index]['image']!),
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
      floatingActionButton: const GalleryFloatingButton(),
    );
  }
}

class GalleryFloatingButton extends StatelessWidget {
  const GalleryFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('갤러리 탭의 플로팅 버튼을 눌렀습니다.'),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
