import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/product.dart';

// category를 만든다
Future addCategories(String title) async {
  final db = FirebaseFirestore.instance;
  final ref = db.collection("category");
  await ref.add({"title": title});
}

// 검색창에 맞게 내용을 입력할 것이다. 검색창을 만든 후에 제작할 함수이다.
Future<List<Product>> fetchProducts() async {
  final db = FirebaseFirestore.instance;
  final resp = await db.collection("products").orderBy("timeStamp").get();
  List<Product> items = [];
  for (var doc in resp.docs) {
    // 돌면서 데이터를 만들어준다.
    final item = Product.fromJson(doc.data());
    final realItem = item.copyWith(docId: doc.id);
    items.add(item);
  }
  return items;
}

Stream<QuerySnapshot> streamProducts(String query) {
  final db = FirebaseFirestore.instance;
  if (query.isNotEmpty) {
    return db
        .collection("products")
        .orderBy("title")
        .startAt([query]).endAt([query + "\uf8ff"]).snapshots();
  }
  // query 가 없을 경우
  return db.collection("products").orderBy("timestamp").snapshots();
  // snapshots이 stream을 반환한다.
}

class SellerWidget extends StatefulWidget {
  const SellerWidget({super.key});

  @override
  State<SellerWidget> createState() => _SellerWidgetState();
}

class _SellerWidgetState extends State<SellerWidget> {
  TextEditingController textEditingController = TextEditingController();

  // 물품 수정하기를 진행한다. update라는 함수로 묶어서 사용
  update(Product? item) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection("products");
    await ref.doc(item?.docId).update(
          item!
              .copyWith(
                title: "milk",
                price: 1000,
                stock: 10,
                isSale: false,
              )
              .toJson(),
        );
  }

  delete(Product? item) async{
    final db = FirebaseFirestore
        .instance;
    await db
        .collection("products")
        .doc(item?.docId)
        .delete();

    final productCategory =
    await db
        .collection(
        "products")
        .doc(item?.docId)
        .collection(
        "category")
        .get();

    final foo = productCategory
        .docs.first;
    final categoryId =
    foo.data()["docId"];
    final bar = await db
        .collection("category")
        .doc(categoryId)
        .collection("product")
        .where(
      "docId",
      isEqualTo: item?.docId,
    )
        .get();
    bar.docs.forEach(
          (element) {
        element.reference
            .delete();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            controller: textEditingController,
            leading: Icon(Icons.search),
            onChanged: (s) {
              setState(() {});
            },
            hintText: "상품명 입력",
            onTap: () {},
          ),
          const SizedBox(),
          ButtonBar(
            children: [
              ElevatedButton(
                onPressed: () async {
                  List<String> categories = [
                    "정육",
                    "과일",
                    "과자",
                    "아이스크림",
                    "유제품",
                    "라면",
                    "생수",
                    "빵/쿠키"
                  ];
                  final ref = FirebaseFirestore.instance.collection("category");
                  final tmp = await ref.get();

                  for (var element in tmp.docs) {
                    // 돌면서 중복을 삭제한다.
                    await element.reference.delete();
                  }

                  for (var element in categories) {
                    await ref.add({"title": element});
                  }
                },
                child: const Text('카테고리 일괄등록'),
              ),
              ElevatedButton(
                onPressed: () {
                  TextEditingController tec = TextEditingController();
                  showAdaptiveDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: TextField(
                        controller: tec,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            if (tec.text.isNotEmpty) {
                              await addCategories(tec.text.trim());
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('등록'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('카테고리 등록'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '상품목록',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              // ListView.builder를 Builder로 묶는다.
              stream: streamProducts(textEditingController.text),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final items = snapshot.data?.docs
                      .map((e) =>
                          Product.fromJson(e.data() as Map<String, dynamic>)
                              .copyWith(docId: e.id))
                      .toList();
                  return ListView.builder(
                    itemCount: items?.length,
                    itemBuilder: (context, index) {
                      final item = items?[index];
                      return GestureDetector(
                        onTap: () {
                          print(item?.docId);
                        },
                        child: Container(
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 16),
                          //color: Colors.orange,
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                      image: NetworkImage(item?.imgurl ??
                                          "https://pixabay.com/ko/photos/%EB%B2%A0%EB%8B%88%EC%8A%A4-%EC%9D%B4%ED%83%88%EB%A6%AC%EC%95%84-%EA%B1%B4%EC%B6%95%EB%AC%BC-%EB%8F%84%EC%8B%9C-8889871/"),
                                      fit: BoxFit.cover
                                      // 이 주소 안에 image 주소를넣자. 여기서는 pixabay에서
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item?.title ?? "제품 명 ?? ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          PopupMenuButton(
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                child: Text('리뷰'),
                                              ),
                                              PopupMenuItem(
                                                onTap: () async {
                                                  update(item);
                                                },
                                                child: Text('수정하기'),
                                              ),
                                              PopupMenuItem(
                                                child: const Text('삭제'),
                                                onTap: () async {
                                                  delete(item);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text("${item?.price}원"),
                                      Text(switch (item?.isSale) {
                                        true => "할인 중",
                                        false => "할인 없음",
                                        _ => "??"
                                      }),
                                      Text("재고수량 : ${item?.stock}개"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
