import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/drawer/gf_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/constants.dart';
import 'package:notes_app/screens/components/edit_banners.dart';
import 'package:notes_app/screens/components/pdf_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'carousal_slider.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/provider/provider_file.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.subjects, required this.isAdmin}) : super(key: key);
  final List<Map<String, dynamic>>? subjects;
  final bool isAdmin;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ScrollController? _scrollViewController;
  TabController? _tabController;
  int index = 0;
  final TextEditingController _chapterNameController = TextEditingController();
  final TextEditingController _subjectNameController = TextEditingController();
  List<Map<String, dynamic>> bannersList = [];
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subjects!.length != oldWidget.subjects!.length) {
      setState(() {
        _tabController = TabController(length: widget.subjects!.length, vsync: this);
      });
    }

  }
  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
    _tabController =
        TabController(length: widget.subjects!.length, vsync: this);
    _tabController?.addListener(() {
      // setState(() {
      index = _tabController!.index;
      // });
    });

  }

  Future<List<String>> getBannerUrls(List<Reference> banners) async {
    List<String> bannersUrls = [];
    await Future.forEach<Reference>(banners,
        (element) async => bannersUrls.add(await element.getDownloadURL()));
    return bannersUrls;
  }
  Widget _buildChapterPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Chapter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _chapterNameController,
            decoration: const InputDecoration(hintText: "chapter name", focusColor: Colors.black, ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection('chapters').add(
              {
                "chapter_name":_chapterNameController.text,
                "no_of_pdf": 0,
                "pdf_files": []
              }
            ).then((value) async {
              await FirebaseFirestore.instance.doc(widget.subjects![_tabController!.index]['reference']).update({
                'no_of_chapters': FieldValue.increment(1),
                'chapters': FieldValue.arrayUnion([value.path]),
              });
            });
            Navigator.of(context).pop();
          },
          child: const Text('submit'),
        ),
      ],
    );
  }
  _buildSubjectPopupDialog(context) {
    return AlertDialog(
      title: const Text('Add Subject'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _subjectNameController,
            decoration: const InputDecoration(hintText: "subject name", focusColor: Colors.black),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection('subjects').add(
                {
                  "subject":_subjectNameController.text,
                  "no_of_chapters": 0,
                  "chapters": []
                }
            );
            Navigator.of(context).pop();
          },
          child: const Text('submit'),
        ),
      ],
    );
  }
  _buildDeleteSubjectPopupDialog(context) {
    return AlertDialog(
      title: const Text('Delete Subject'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text("You are going to delete subjects and its contents. Are you sure?"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance.doc(widget.subjects![_tabController!.index]['reference']).delete();
            Navigator.of(context).pop();
          },
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text('No'),
        ),
      ],
    );
  }
  addChapter(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildChapterPopupDialog(context),
    );
  }
  addSubject(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildSubjectPopupDialog(context),
    );
  }
  deleteSubject(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildDeleteSubjectPopupDialog(context),
    );
  }
  editBanners(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditBanners()));
  }
  List<PopupMenuItem> pop_menu_item = [
    const PopupMenuItem(child: Text("Add a chapter"), value: 1),
    const PopupMenuItem(child: Text("Add a subject"), value: 2,),
    const PopupMenuItem(child: Text("Delete this subject"), value: 3,),
    const PopupMenuItem(child: Text("Edit Banners"), value: 4,),
  ];

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:${toMailId}?subject=${subject}&body=${body}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    TextStyle listTextStyle = TextStyle(fontSize: 15);
    return SafeArea(
      child: Scaffold(
        drawer: GFDrawer(
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(height: 15),
              Image.asset('assets/app_logo.jpg', width: 150, height: 150,),
              SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: ListTile(
                      title: Text('Share App', style: listTextStyle,),
                      onTap: null,
                    ),
                  ),
                  Flexible(child: const Icon(Icons.share))
                ],
              ),
              ListTile(
                title: Text('Rate It. It motivates us.', style: listTextStyle),
                onTap: null,
              ),
              ListTile(
                title: Text('Feedback for improvements.', style: listTextStyle),
                onTap: () => {
                  _launchURL('daily.ncert.dose@gmail.com', 'Feedback for improvement', 'Testing')
                },
              ),
              ListTile(
                title: Text('Privacy Policy.', style: listTextStyle),
                onTap: null,
              ),
              ListTile(
                title: Text('Developed By, Sita Ram Bana', style: listTextStyle),
                onTap: null,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Row(
                  children: [
                    const Text("Member of  ", style: TextStyle(fontSize: 20)),
                    Image.asset('assets/gurukripa_logo.png', width: 100, height: 100),
                    const Text(" Family", style: TextStyle(fontSize: 20)),

                  ],
                ),
              ),
              Container(
                child: Center(
                  child: GFAvatar(
                    backgroundImage: Image.asset('assets/photo.jpg').image,
                    radius: 80,
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50)
                ),
              ),
            ],
          ),
        ),
        body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text(appName),
                pinned: true,
                floating: true,
                actions: widget.isAdmin ? [
                  PopupMenuButton(
                    initialValue: 1,
                    offset: const Offset(0, 0),
                    icon: const Icon(Icons.add),
                    itemBuilder: (context) {
                      return pop_menu_item;
                    },
                    onSelected: (index) {
                      switch(index) {
                        case 1:
                          addChapter(context);
                          break;
                        case 2:
                          addSubject(context);
                          break;
                        case 3:
                          deleteSubject(context);
                          break;
                        case 4:
                          editBanners(context);
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                ] : [],
                bottom: TabBar(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  labelColor: Colors.black,
                  unselectedLabelColor: const Color(0xFFAFB4C6),
                  indicatorColor: Colors.greenAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 4.0,
                  isScrollable: true,
                  tabs: [
                    ...widget.subjects!
                        .map(
                          (e) => Tab(
                            child: Text(
                              e['subject'],
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              )
            ];
          },
          body: Column(
            children: [
              FutureBuilder(
                future:
                    FirebaseFirestore.instance.collection('banners').get(),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Map<String, dynamic>> banners = [];
                    for(var data in snapshot.data!.docs) {
                      banners.add({
                        "url": data.get('url'),
                        "reference": data.reference.path,
                      });
                    }
                    bannersList = banners;
                    return Carousel(banners: banners);
                  }
                  return const SizedBox();
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: widget.subjects!.asMap().entries.map<Widget>((e) {
                    return NotificationListener<
                        OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView.builder(
                        itemCount: e.value['no_of_chapters'],
                        itemBuilder: (BuildContext context, int index) {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .doc(e.value['chapters'][index])
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  String chapterName = (index+1).toString() +
                                      ') ' +
                                      snapshot.data!.get('chapter_name');
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PdfViewer(
                                            chapterRef: e.value['chapters'][index],
                                            chapterName: snapshot.data!
                                                .get('chapter_name'),
                                            isAdmin: widget.isAdmin,
                                            subjectRef: e.value['reference'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 7),
                                            height: 100,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF635CAE)
                                                  .withOpacity(0.8),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(40)),
                                            ),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 30, top: 30),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      chapterName,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .poppins(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    Text(
                                                      "${snapshot.data!.get('no_of_pdf')} Pdfs",
                                                      style: GoogleFonts
                                                          .poppins(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              });
                          }),
                      );
                    }).toList()
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
