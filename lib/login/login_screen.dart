import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market/main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(credential);
      userCredential = credential;  // 사용자 정보를 저장
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print(e.toString());
      } else if (e.code == "wrong-password") {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle() async{
    // 로그인을 구글로 하면 googleUser에 구글 계정이 들어온다
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
      // 이 둘 다 필요하다
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
    // 이렇게 해서 파이어베이스에 정보등록을 한다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/fastcampus_logo.png'),
              const Text(
                '플러터 마트',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                ),
              ),
              const SizedBox(
                height: 64,
              ),

              /// Form 은 키를 받는다. 위에 키를 정의해주자
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '이메일',
                      ),

                      /// form은 validator로 검증하기 위해 사용한다.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일 주소를 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    TextFormField(
                      controller: pwdTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '비밀번호',
                      ),
                      obscureText: true,
                      // 비밀번호가 안 보이게 한다.
                      keyboardType: TextInputType.visiblePassword,
                      // 비밀번호 입력에 맞는 키보드를 가져온다.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력하세요';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: MaterialButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final result = await signIn(
                          emailTextController.text.trim(),
                          pwdTextController.text.trim());
                      if (result == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("로그인 실패")));
                        }
                        return;
                      }

                      if (context.mounted) {
                        context.go("/");
                      }
                    }
                  },
                  height: 48,
                  minWidth: double.infinity,
                  color: Colors.red,
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push("/sign_up"),
                child: const Text("계정이 없나요? 회원가입"),
              ),
              const Divider(),
              InkWell(
                onTap: () async{
                  final userCredit = await signInWithGoogle();
                  // 이걸로 로그인 하면 위의 googleUser에 값이 들어온다.

                  if (userCredit == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("구글 로그인 실패"),
                    ));
                    return;
                  }
                  if (context.mounted) {
                    context.go("/");
                  }
                },
                child: Image.asset("assets/btn_google_signin.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
