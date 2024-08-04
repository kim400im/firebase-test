import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_market/home/camera_example_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_market/model/category.dart';

import '../model/product.dart';

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSale = false;

  // image_picker를 사용해서 이미지를 넣자
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  Uint8List? imageData;
  XFile? image;

  // image_picker가 1.0.2이어야 받을 수 있다.

  //Category? selectedCategory;
  Category? selectedCategory;

  TextEditingController titleTEC = TextEditingController();
  TextEditingController descriptionTEC = TextEditingController();
  TextEditingController priceTEC = TextEditingController();
  TextEditingController stockTEC = TextEditingController();
  TextEditingController salePercentTEC = TextEditingController();

  List<Category> categoryItems = [];

  Future<List<Category>> _fetchCategories() async {
    //FirebaseFirestore db = FirebaseFirestore.instance;
    final resp = await db.collection("category").get();
    for (var doc in resp.docs) {
      categoryItems.add(Category(
        docId: doc.id,
        title: doc.data()['title'],
      ));
    }
    setState(() {
      selectedCategory = categoryItems.first;
    });
    return categoryItems;
  }

  // 입력되는 사진 크기가 너무크면 안되기에 compress를 한다.
  Future<Uint8List> imageCompressList(Uint8List list) async{
    var result = await FlutterImageCompress.compressWithList(list, quality: 50);
    return result;
  }

  Future addProduct() async {
    if (imageData != null) {
      // 이미지 사진이 있어야 등록을 한다.
      final storageRef = storage.ref().child(
          "${DateTime.now().millisecondsSinceEpoch}_${image?.name ?? "??"}.jpg");
      await storageRef.putData(imageData!);

      final downloadLink = await storageRef.getDownloadURL();
      final sampleData = Product(
        title: titleTEC.text,
        description: descriptionTEC.text,
        price: int.parse(priceTEC.text),
        stock: int.parse(stockTEC.text),
        isSale: isSale,
        saleRate: salePercentTEC.text.isNotEmpty
            ? double.parse(salePercentTEC.text)
            : 0,
        imgurl: downloadLink,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      final doc = await db.collection("products").add(sampleData.toJson());
      await doc.collection("category").add(selectedCategory?.toJson() ?? {});
      final categoRef = db.collection("category").doc(selectedCategory?.docId);
      await categoRef.collection("products").add({"docId": doc.id});
    }

  }

  Future addProducts() async{
    if (imageData != null) {
      // 이미지 사진이 있어야 등록을 한다.
      final storageRef = storage.ref().child(
          "${DateTime.now().millisecondsSinceEpoch}_${image?.name ?? "??"}.jpg");
      await storageRef.putData(imageData!);

      final downloadLink = await storageRef.getDownloadURL();

      for(var i=0;i<10;i++){
        final sampleData = Product(
          title:  "${titleTEC.text}$i",
          description: descriptionTEC.text,
          price: int.parse(priceTEC.text),
          stock: int.parse(stockTEC.text),
          isSale: isSale,
          saleRate: salePercentTEC.text.isNotEmpty
              ? double.parse(salePercentTEC.text)
              : 0,
          imgurl: downloadLink,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        final doc = await db.collection("products").add(sampleData.toJson());
        await doc.collection("category").add(selectedCategory?.toJson() ?? {});
        final categoRef = db.collection("category").doc(selectedCategory?.docId);
        await categoRef.collection("products").add({"docId": doc.id});
      }

    }
  }




  // Future addProduct() async {
  //   if (imageData != null) {
  //     // 이미지 사진이 있어야 등록을 한다.
  //     final storageRef = storage.ref().child(
  //         "${DateTime.now().millisecondsSinceEpoch}_${image?.name ?? "??"}.jpg");
  //     final compressedData = await imageCompressList(imageData!);
  //     await storageRef.putData(compressedData);
  //     final downloadLink = await storageRef.getDownloadURL();
  //     final sampleData = Product(
  //       title: titleTEC.text,
  //       description: descriptionTEC.text,
  //       price: int.parse(priceTEC.text),
  //       stock: int.parse(stockTEC.text),
  //       isSale: isSale,
  //       saleRate: salePercentTEC.text.isNotEmpty
  //         ? double.parse(salePercentTEC.text) : 0,
  //       imgurl: downloadLink,
  //       timestamp: DateTime.now().millisecondsSinceEpoch,
  //     );
  //     final doc = await db.collection("products").add(sampleData.toJson());
  //     await doc.collection("category").add(selectedCategory?.toJson() ?? {});
  //     final categoRef = db.collection("category").doc(selectedCategory?.docId);
  //     await categoRef.collection("products").add({"docId": doc.id});
  //   }
  // }


  // Future<void> addProduct() async {
  //   if (_formKey.currentState!.validate() && imageData != null) {
  //     try {
  //       // Compress the image
  //       final compressedImage = await imageCompressList(imageData!);
  //       if (compressedImage == null) {
  //         throw 'Image compression failed';
  //       }
  //
  //       // 이미지 사진이 있어야 등록을 한다.
  //       final storageRef = storage.ref().child(
  //         "${DateTime.now().millisecondsSinceEpoch}_${image?.name ?? "??"}.jpg",
  //       );
  //       final uploadTask = storageRef.putData(compressedImage);
  //       final snapshot = await uploadTask.whenComplete(() => {});
  //       final imageUrl = await snapshot.ref.getDownloadURL();
  //
  //       // Firestore에 제품 정보 등록
  //       await db.collection('products').add({
  //         'title': titleTEC.text,
  //         'description': descriptionTEC.text,
  //         'price': int.parse(priceTEC.text),
  //         'stock': int.parse(stockTEC.text),
  //         'isSale': isSale,
  //         'salePercent': isSale ? int.parse(salePercentTEC.text) : 0,
  //         'category': selectedCategory?.docId,
  //         'imageUrl': imageUrl,
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Product added successfully!')),
  //       );
  //     } catch (e) {
  //       print('Error adding product: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to add product. Please try again.')),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please complete the form and add an image.')),
  //     );
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("상품 추가"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return CameraExamplePage();
                  },
                ),
              );
            },
            icon: Icon(Icons.camera),
          ),
          IconButton(
            onPressed: () {
              addProducts();
            },
            icon: const Icon(Icons.batch_prediction),
          ),
          IconButton(
            onPressed: () {
              addProduct();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aigin을 gesturedetector로 감싼다. image_picker 사용을 위해
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  image = await picker.pickImage(source: ImageSource.gallery);
                  print("${image?.name}, ${image?.path}");
                  imageData = await image?.readAsBytes();
                  // image 정보를 바이트 형태로 저장한다.
                  setState(() {});
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 240,
                    width: 240,
                    decoration: BoxDecoration(
                      color: Colors.grey[200]!,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: imageData == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              Text("제품(상품) 이미지 추가"),
                            ],
                          )
                        : Image.memory(
                            imageData!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("기본정보"),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleTEC,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "상품명",
                          hintText: "제품명을 입력하세요"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: descriptionTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "상품 설명",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다";
                        }
                        return null;
                      },
                      maxLength: 254,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: priceTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "가격(단가)",
                        hintText: "1개 가격 입력",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: stockTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "수량",
                        hintText: "입고 및 재고 수량",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SwitchListTile.adaptive(
                      value: isSale,
                      onChanged: (v) {
                        setState(() {
                          isSale = v;
                        });
                      },
                      title: const Text("할인여부"),
                    ),
                    if (isSale)
                      TextFormField(
                        controller: salePercentTEC,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "할인율",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return null;
                        },
                      ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "카테고리 선택",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    categoryItems.isNotEmpty
                        ? DropdownButton<Category>(
                            isExpanded: true,
                            value: selectedCategory,
                            items: categoryItems
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("${e.title}"),
                                  ),
                                )
                                .toList(),
                            onChanged: (s) {
                              setState(() {
                                selectedCategory = s;
                              });
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
