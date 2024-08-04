import 'package:flutter/material.dart';
import 'package:flutter_market/home/cart_screen.dart';
import 'package:flutter_market/home/product_add_screen.dart';
import 'package:flutter_market/home/widgets/home_widget.dart';
import 'package:flutter_market/home/widgets/seller_widget.dart';
import 'package:flutter_market/main.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menuIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('플러터 마트'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout),
          ),
          if (_menuIndex == 0)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
            ),
        ],
      ),
      body: IndexedStack(
        index: _menuIndex,
        children: const [
          HomeWidget(),
          SellerWidget(),
        ],
      ),
      floatingActionButton: switch (_menuIndex) {
        0 => FloatingActionButton(
            onPressed: () {
              final uid = userCredential?.user?.uid;
              if (uid == null){
                return;
              }
              context.go("/cart/$uid");
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => CartScreen(
              //       uid: "",
              //     ),
              //   ),
              // );
            },
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        1 => FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductAddScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        _ => Container(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _menuIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _menuIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store_outlined), label: "홈"),
          NavigationDestination(
              icon: Icon(Icons.storefront), label: "사장님(판매자)"),
        ],
      ),
    );
  }
}
