import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market/firebase_options.dart';
import 'package:flutter_market/home/cart_screen.dart';
import 'package:flutter_market/home/home_screen.dart';
import 'package:flutter_market/home/product_add_screen.dart';
import 'package:flutter_market/home/product_detail_screen.dart';
import 'package:flutter_market/login/login_screen.dart';
import 'package:flutter_market/login/sign_up_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'model/product.dart';

// 카메라 개수를 셀 것이다.
List<CameraDescription> cameras = [];
// 사용자 정보를 받아오자
UserCredential? userCredential;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  cameras = await availableCameras();

  if (kDebugMode) {
    try {
      await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
      // 에뮬레이터로 돌릴떄는 위에걸로 돌리자.
      // 에뮬레이터 안 쓸거면 위의 줄 끄고 돌려야 한다.
      // 아래 코드만 있어야 파이어베이스에 저장됨
      FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
      FirebaseStorage.instance.useStorageEmulator("localhost", 9199);
    } catch (e) {
      print(e);
    }
  }

  runApp(FlutterMarketApp());
}

class FlutterMarketApp extends StatelessWidget {
  FlutterMarketApp({super.key}); // const 지우자
  final router = GoRouter(
    initialLocation: "/login",
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => HomeScreen(),
        routes: [
          GoRoute(
            path: "cart/:uid",
            builder: (context, state) => CartScreen(
              uid: state.pathParameters["uid"] ?? "",
            ),
          ),
          GoRoute(
            path: "product",
            builder: (context, state)  {
              return ProductDetailScreen(product: state.extra as Product,);
            },
          ),
          GoRoute(
            path: "product/add",
            //builder: (context, state) => ProductDetailScreen(),
            builder: (context, state)  {
              return ProductDetailScreen(product: state.extra as Product,);
            },
          ),
        ],
      ),
      GoRoute(
        path: "/login",
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: "/sign_up",
        builder: (context, state) => SignUpScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '플러터 마트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: HomeScreen(),  라우터를 사용하면 home 이 사라진다.
      routerConfig: router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
