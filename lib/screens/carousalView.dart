import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    Key? key,
  }) : super(key: key);

  // const Carousel({Key? key, required this.docName}) : super(key: key);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _pageController;
  List<String> docList = [];

  List<String> images = [
    "https://images.wallpapersden.com/image/download/purple-sunrise-4k-vaporwave_bGplZmiUmZqaraWkpJRmbmdlrWZlbWU.jpg",
    "https://wallpaperaccess.com/full/2637581.jpg",
    "https://uhdwallpapers.org/uploads/converted/20/01/14/the-mandalorian-5k-1920x1080_477555-mm-90.jpg"
  ];

  int activePage = 1;

  retrieveDocListValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    docList = prefs.getStringList("selectedfeaturedDoc") ?? [];
    print(docList);
  }

  @override
  void initState() {
    super.initState();

    // setState(() {
    retrieveDocListValue();
    // });
    _pageController = PageController(viewportFraction: 0.9, initialPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 90,
          child: PageView.builder(
              itemCount: docList.length,
              pageSnapping: true,
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  activePage = page;
                });
              },
              itemBuilder: (context, pagePosition) {
                bool active = pagePosition == activePage;
                return slider(images, pagePosition, active, docList);
              }),
        ),

      ],
    );
  }
}

AnimatedContainer slider(images, pagePosition, active, docList) {
  double margin = active ? 10 : 20;

  return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.all(margin),

      child: Card(
        // color: Color(0xffbe1229),
        elevation: 3.0,
        child: Container(
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [
                    Color(0xffd9dbdc),
                    Color(0xffeaebec),
                  ],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(0.5, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.circular(3)),
          child: ListTile(
            title: Text(
              docList[pagePosition],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Helvetica',
                color: Colors.black87,
              ),
            ),
            trailing: Image.asset(
              'assets/images/dashboardicon/tax_treaties.png',
              scale: 1.0,
              height: 40.0,
              width: 40.0,
            ),
          ),
        ),
        // ),
      ));
}



List<Widget> indicators(imagesLength, currentIndex) {
  return List<Widget>.generate(imagesLength, (index) {
    return Container(
      margin: const EdgeInsets.all(3),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
          color: currentIndex == index ? Colors.black : Colors.black26,
          shape: BoxShape.circle),
    );
  });
}
