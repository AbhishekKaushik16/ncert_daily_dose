import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class EditBanners extends StatefulWidget {
  const EditBanners({Key? key}) : super(key: key);
  @override
  State<EditBanners> createState() => _EditBannersState();
}

class _EditBannersState extends State<EditBanners> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  TextStyle textStyle = GoogleFonts.poppins(color: Colors.white);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Banners"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('banners').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView(
                    children: [
                      ...snapshot.data!.docs.asMap().entries.map((e) => Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: CachedNetworkImage(
                              imageUrl: e.value['url'],
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.red,
                                highlightColor: Colors.yellow,
                                child: const Center(
                                  child: Text(
                                    'Loading',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    replaceImage(context, e.value['storage_location'], e.value.reference.path);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration:
                                        const BoxDecoration(color: Colors.redAccent),
                                    child: Center(
                                      child: Text(
                                        "Replace",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    removeImage(context, e.value['storage_location'], e.value.reference.path);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration:
                                        const BoxDecoration(color: Colors.red),
                                    child: Center(
                                      child: Text(
                                        "Remove",
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                            addNewImage(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration:
                          const BoxDecoration(color: Colors.red),
                          child: Center(
                            child: Text(
                              "Add",
                              style: textStyle,
                            ),
                          ),
                        ),
                      ),
                    ]
                  );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
  }

  Future<bool> addNewImage(BuildContext context) async {
    try {
      FilePickerResult? images =
      await FilePicker.platform.pickFiles(withData: true,);
      if (images != null) {
        for (var image in images.files) {
          Uint8List? fileBytes = image.bytes;
          String fileName = image.name;
          File file = File(image.path!);
          UploadTask task = _firebaseStorage.ref('banners/$fileName').putData(
              fileBytes!);
          await task.then((p0) async {
            String url = await p0.ref.getDownloadURL();
            String fullPath = p0.ref.fullPath;
            await _firebaseFirestore.collection('banners').add({
              "url": url,
              "storage_location": fullPath
            });
          });
        }
      }
      return true;
    }catch (err) {
      return false;
    }
  }

  replaceImage(BuildContext context, filePath, docPath) {
    addNewImage(context).then((value) {
      if(value) {
        deleteImage(context, filePath, docPath);
      }
    });
  }
  deleteImage(BuildContext context, filePath, docPath) {
    _firebaseStorage.ref(filePath).delete().then((value) async {
      await _firebaseFirestore.doc(docPath).delete();
    });
  }
  removeImage(BuildContext context, filePath, docPath) {
    print("Image Remove");
    deleteImage(context, filePath, docPath);
  }
}
