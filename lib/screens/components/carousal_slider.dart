import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    Key? key, required this.banners,
  }) : super(key: key);
  final List<Map<String, dynamic>> banners;
  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _pageController;

  int activePage = 0;
  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
  }
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1, initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: PageView.builder(
            itemCount: widget.banners.length,
            pageSnapping: true,
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                activePage = page;
              });
            },
            itemBuilder: (context, pagePosition) {
              bool active = pagePosition == activePage;
              return slider(pagePosition, active, widget.banners);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: indicators(widget.banners.length, activePage),
        )
      ],
    );
  }
}

AnimatedContainer slider(pagePosition, active, List<Map<String, dynamic>> banners) {
  double margin = active ? 5 : 10;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 100),
    curve: Curves.easeInOutCubic,
    margin: EdgeInsets.all(margin),
    child: CachedNetworkImage(
      imageUrl: banners[pagePosition]['url'],
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.red,
        highlightColor: Colors.yellow,
        child: const Center(
          child: Text(
            'Loading',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

imageAnimation(PageController animation, images, pagePosition) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, widget) {
      return SizedBox(
        width: 100,
        height: 200,
        child: widget,
      );
    },
    child: Container(
      margin: const EdgeInsets.all(15),
      child: Image.network(images[pagePosition], fit: BoxFit.cover),
    ),
  );
}

List<Widget> indicators(imagesLength, currentIndex) {
  return List<Widget>.generate(imagesLength, (index) {
    return Container(
      margin: const EdgeInsets.all(3),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.black : Colors.black26,
        shape: BoxShape.circle,
      ),
    );
  });
}
