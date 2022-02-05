import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/provider/provider_file.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:notes_app/constants.dart';

import '../../main.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer(
      {Key? key,
      required this.chapterName,
      required this.chapterRef,
      required this.isAdmin,
      required this.subjectRef})
      : super(key: key);
  final String subjectRef;
  final String chapterRef;
  final bool isAdmin;
  final String chapterName;
  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> with TickerProviderStateMixin {
  File? file;
  UploadTask? task;
  bool english = true;
  bool downloading = false;
  UserCredential? userCredential;
  late double progress = null as double;
  TabController? _tabController;
  TextStyle textStyle = const TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  List<PopupMenuItem> pop_menu_item = [
    const PopupMenuItem(child: Text("Delete chapter"), value: 1)
  ];
  Future<List<Map<String, dynamic>>> getAllPdf(
      List<String> pdf, language) async {
    List<Map<String, dynamic>> response = [];
    FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

    for (var element in pdf) {
      await _firebaseFirestore
          .collection('pdfFiles')
          .where(FieldPath.documentId,
          isEqualTo: element.replaceAll('pdfFiles/', ''))
          .where('language', isEqualTo: language)
          .get().then((value) {
            if(value.docs.isNotEmpty) {
              response.add(value.docs[0].data());
            }
      });
    }
    // print(response);
    return response;
  }

  Future<bool> findFileInStorage(fileName) async {
    String dirloc = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    String filePath = dirloc + '/' + fileName;
    return await File(filePath).exists();
  }

  deletePdf(context, pdfPath, pdfStorageLocation) async {
    FirebaseStorage.instance
        .ref(pdfStorageLocation)
        .delete()
        .then((value) async {
      await FirebaseFirestore.instance.doc(widget.chapterRef).update({
        "pdf_files": FieldValue.arrayRemove([pdfPath]),
        'no_of_pdf': FieldValue.increment(-1),
      });
      await FirebaseFirestore.instance.doc(pdfPath).delete();
    });
  }

  deleteChapter(context) async {
    await FirebaseFirestore.instance.doc(widget.subjectRef).update({
      "chapters": FieldValue.arrayRemove([widget.chapterRef]),
      'no_of_chapters': FieldValue.increment(-1),
    });
    await FirebaseFirestore.instance
        .doc(widget.chapterRef)
        .delete()
        .then((value) => {Navigator.pop(context)});
  }

  getStreamBuilder(
      {required BuildContext context, required List<String> pdfUrls, required language}) {
    return ListView(
      shrinkWrap: true,
      children: [
        FutureBuilder(
          future: getAllPdf(pdfUrls, language),
          builder: (cntx,
              AsyncSnapshot<List<Map<String, dynamic>>>
                  snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text("No Pdf Available"));
              }
              Map<String, List<Map<String, dynamic>>> pdf = {};
              for (var element in snapshot.data!.reversed.toList()) {
                Timestamp timestamp = element['timestamp'];
                DateTime datetime =
                    DateTime.parse(timestamp.toDate().toString());
                var formattedDate =
                    "${datetime.day}-${datetime.month}-${datetime.year}";
                if (pdf.containsKey(formattedDate)) {
                  pdf[formattedDate]
                      ?.add(element);
                } else {
                  pdf[formattedDate] = [element];
                }
              }
              return Column(
                children: [
                  const SizedBox(height: 30),
                  ...pdf.entries.map(
                    (e) {
                      return Column(
                        children: [
                          Container(
                            decoration:
                                const BoxDecoration(color: Colors.purple),
                            height: 30,
                            child: Center(
                              child: Text(
                                  DateFormat.yMMMMd().format(
                                    DateTime.parse(
                                      e.value[0]['timestamp']
                                          .toDate()
                                          .toString(),
                                    ),
                                  ),
                                  style: textStyle),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...e.value.map(
                            (e) => FutureBuilder<bool>(
                              future: findFileInStorage(e['name']),
                              builder: (ctx, snapshot) {
                                if (snapshot.hasData) {
                                  return GestureDetector(
                                    onTap: () async {
                                      downloadFile(e['url'], e['name']).then(
                                          (value) => {setState(() => {})});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: defaultPadding),
                                      margin: const EdgeInsets.only(bottom: 30),
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 140,
                                              child: Text(
                                                e['name'],
                                              ),
                                            ),
                                            snapshot.data == true
                                                ? const Icon(Icons.open_in_new)
                                                : const Icon(
                                                    Icons.download_rounded),
                                            Text(
                                              DateFormat.jm().format(
                                                  DateTime.parse(e['timestamp']
                                                      .toDate()
                                                      .toString())),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            widget.isAdmin
                                                ? GestureDetector(
                                                    onTap: () {
                                                      deletePdf(
                                                          context,
                                                          'pdfFiles/' + e['id'],
                                                          e['storage_location']);
                                                    },
                                                    child: const Icon(
                                                        Icons.delete),
                                                  )
                                                : const SizedBox.shrink()
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          )
                        ],
                      );
                    },
                  )
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        const SizedBox(height: 30),
        widget.isAdmin
            ? ElevatedButton(
                onPressed: () {
                  if (widget.isAdmin) {
                    selectFile(
                            Provider.of<ProviderState>(context, listen: false)
                                .userCredential
                                .user!
                                .email)
                        .then((value) {
                      if (value) {
                        setState(() => {});
                      }
                    });
                  }
                },
                child: Center(
                  child: Text("Add New Pdf", style: textStyle),
                ))
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.doc(widget.chapterRef).snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            List<String> pdfUrls = ["pdfFiles/asasa"];
            if (snapshot.data!.get('pdf_files').length != 0) {
              pdfUrls = List<String>.from(snapshot.data!.get('pdf_files'));
            }
            return DefaultTabController(
              initialIndex: 0,
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.chapterName),
                  actions: widget.isAdmin
                      ? [
                          PopupMenuButton(
                            initialValue: 1,
                            offset: const Offset(0, 0),
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) {
                              return pop_menu_item;
                            },
                            onSelected: (index) {
                              switch (index) {
                                case 1:
                                  deleteChapter(context);
                                  break;
                                // case 2:
                                //   add_subject();
                                //   break;
                                default:
                                  break;
                              }
                            },
                          ),
                        ]
                      : [],
                  bottom: TabBar(
                    controller: _tabController,
                    onTap: (idx) {
                      if (idx == 0) {
                        english = true;
                      } else {
                        english = false;
                      }
                    },
                    isScrollable: false,
                    tabs: const [
                      Tab(
                        child: Text(
                          "English",
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Hindi",
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      getStreamBuilder(
                          context: context,
                          pdfUrls: pdfUrls,
                          language: 'English'),
                      getStreamBuilder(
                          context: context,
                          pdfUrls: pdfUrls,
                          language: 'Hindi'),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  Future selectFile(email) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;
      setState(() {
        file = File(result.files.first.path!);
      });

      task = FirebaseStorage.instance.ref('pdf/$fileName').putData(fileBytes!);
      setState(() {});
      task?.snapshotEvents.listen((event) {
        var progress =
            min((event.bytesTransferred / event.totalBytes * 100).ceil(), 100);
        _showProgressNotification(124, progress, fileName,
            result.files.first.path, 'upload', 'Uploading $progress%');
      });

      await task?.then((p0) async {
        DocumentReference ref =
            await FirebaseFirestore.instance.collection('pdfFiles').add({
          "language": english ? "English" : "Hindi",
          "name": fileName,
          "timestamp": DateTime.now(),
          "uploaded_by": email,
          "url": await p0.ref.getDownloadURL(),
          "storage_location": p0.ref.fullPath
        });
        await ref.update({"id": ref.id}).then((value) async {
          // print(value.path);
          await FirebaseFirestore.instance
              .doc(widget.chapterRef)
              .update({"no_of_pdf": FieldValue.increment(1)});
          await FirebaseFirestore.instance.doc(widget.chapterRef).update({
            "pdf_files": FieldValue.arrayUnion([ref.path])
          });
        });
      });
      return true;
    } else {
      return false;
    }
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      openAppSettings();
    }
  }

  Future saveInStorage(String fileName, File file, String extension) async {
    await _getStoragePermission();
    String _localPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    String filePath = _localPath + "/" + fileName.trim() + "_" + extension;

    File fileDef = File(filePath);
    await fileDef.create(recursive: true);
    Uint8List bytes = await file.readAsBytes();
    await fileDef.writeAsBytes(bytes);
  }

  Future<void> downloadFile(url, fileName) async {
    // _showProgressNotification(fileName);
    Dio dio = Dio();
    await _getStoragePermission();
    String dirloc = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    String filePath = dirloc + '/' + fileName;
    if (await File(filePath).exists()) {
      await OpenFile.open(filePath);
    } else {
      try {
        bool isallowed = await AwesomeNotifications().isNotificationAllowed();
        if (!isallowed) {
          //no permission of local notification
          await AwesomeNotifications().requestPermissionToSendNotifications();
        } else {
          //show notification
          await dio.download(url, filePath, deleteOnError: true,
              onReceiveProgress: (receivedBytes, totalBytes) async {
            var progress = min((receivedBytes / totalBytes * 100).ceil(), 100);
            _showProgressNotification(123, progress, fileName, filePath,
                'download', 'Downloading file in progress $progress%');
          }).then((value) async {
            if (value.statusCode == 200) {
              _showProgressNotification(123, 100, fileName, filePath,
                  'download', 'Download Completed');
            }
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> showProgressNotification(
      int id, int progress, fileName, filePath, channelKey, title) async {
    if (progress == 100) {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              channelKey: channelKey,
              title: title,
              body: fileName,
              category: NotificationCategory.Progress,
              payload: {'file': fileName, 'path': filePath},
              locked: false));
    } else {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              channelKey: channelKey,
              title: title,
              body: fileName,
              category: NotificationCategory.Progress,
              payload: {'file': fileName, 'path': filePath},
              notificationLayout: NotificationLayout.ProgressBar,
              progress: progress,
              locked: false));
    }
  }

  Future<void> _showProgressNotification(
      int id, int progress, fileName, filePath, channelKey, title) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      id.toString(),
      channelKey,
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, fileName, platformChannelSpecifics, payload: filePath);
  }
}
