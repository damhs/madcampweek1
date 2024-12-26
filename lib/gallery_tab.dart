import 'package:flutter/material.dart';

class GalleryTab extends StatelessWidget {
  const GalleryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    return Container(
      width: sizeX,
      height: sizeY,
      child: GridView.count(
        scrollDirection: Axis.vertical,
        crossAxisCount: 2,
        children: createGallery(6),
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        padding: EdgeInsets.all(5.0),
      ),
    );
  }

  List<Widget> createGallery(int num) {
    List<Widget> images = [];
    List<String> urls = [];
    urls.add('img/img1.jpeg');
    urls.add('img/img2.jpeg');
    urls.add('img/img3.jpeg');
    urls.add('img/img4.jpeg');
    urls.add('img/img5.jpeg');
    urls.add('img/img6.jpeg');

    Widget image;
    for (int i = 0; i < num; i++) {
      image = Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(urls[i]),
            fit: BoxFit.cover,
          ),
        ),
      );
      images.add(image);
    }
    return images;
  }
}
