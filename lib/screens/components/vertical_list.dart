import 'package:getwidget/getwidget.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/provider/provider_file.dart';
import 'package:provider/provider.dart';

class VerticalSlider extends StatefulWidget {
  const VerticalSlider({Key? key, required this.chapters}) : super(key: key);
  final List<dynamic> chapters;

  @override
  State<VerticalSlider> createState() => _VerticalSliderState();
}

class _VerticalSliderState extends State<VerticalSlider> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
      itemCount: widget.chapters.length,
      itemBuilder: (BuildContext context, int index) {
        return GFListTile(
          titleText: widget.chapters[index],
          subTitleText: 'Lorem ipsum dolor sit amet, consectetur adipiscing',
          icon: const Icon(Icons.favorite),
        );
      },
    );
  }
}
