import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/provider/provider_file.dart';

class HorizontalSlider extends StatefulWidget {
  const HorizontalSlider({Key? key, this.subjects}) : super(key: key);
  final List<Map<String, dynamic>>? subjects;
  @override
  State<HorizontalSlider> createState() => _HorizontalSliderState();
}

class _HorizontalSliderState extends State<HorizontalSlider>
    with TickerProviderStateMixin {
  int? _idx;
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _tabController =
        TabController(length: widget.subjects!.length, vsync: this);
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: const Color(0xFFAFB4C6),
          // indicator: BoxDecoration(
          //   borderRadius: BorderRadius.circular(25), // Creates border
          //   color: Colors.lightBlueAccent,
          // ),
          indicatorColor: const Color(0xFF417BFB),
          indicatorSize: TabBarIndicatorSize.label,
          // indicatorPadding: EdgeInsets.all(5),
          indicatorWeight: 4.0,
          isScrollable: true,
          tabs: [
            ...widget.subjects!
                .map(
                  (e) => Tab(
                    child: Text(
                      e['subject'],
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
        SizedBox(height: 10),
        TabBarView(
            controller: _tabController,
            children: widget.subjects!
                .map<Widget>((e) => Column(
                    children: (e['chapters'] as List)
                        .map((item) => item as String)
                        .toList()
                        .map<Widget>(
                          (e) => SizedBox(
                            height: 50,
                            child: GFListTile(
                              titleText: e,
                              subTitleText:
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing',
                              icon: const Icon(Icons.favorite),
                            ),
                          ),
                        )
                        .toList()
                    // ,GFListTile(
                    //     titleText: e,
                    //     subTitleText:
                    //         'Lorem ipsum dolor sit amet, consectetur adipiscing',
                    //     icon: const Icon(Icons.favorite),
                    //   ),

                    ))
                .toList())
      ],
    );
  }
  // return Container(
  //   margin: const EdgeInsets.symmetric(vertical: 20.0),
  //   padding: const EdgeInsets.symmetric(horizontal: 10),
  //   height: 35.0,
  //   child: ListView.separated(
  //     // This next line does the trick.
  //     scrollDirection: Axis.horizontal,
  //     itemBuilder: (BuildContext context, int index) {
  //       return GFButton(
  //         onPressed: () {
  //           setState(() {
  //             _idx = index;
  //           });
  //         },
  //         text: "primary",
  //         shape: GFButtonShape.pills,
  //         color: Colors.red,
  //       );
  //     },
  //     separatorBuilder: (BuildContext context, int index) {
  //       return const SizedBox(width: 8);
  //     },
  //     itemCount: 6,
  //   ),
  // );
  // }
}

class Subject extends StatelessWidget {
  const Subject({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<ProviderState>().subject);
  }
}
