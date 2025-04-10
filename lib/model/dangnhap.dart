import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an/screen/adminpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:do_an/screen/homepage_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _dangNhap() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid; // Lấy userId của người dùng hiện tại
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      // Lấy userId của người dùng hiện tại
      User? user = userCredential.user;

      if (user != null) {
        // Kiểm tra vai trò của người dùng từ Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String vaiTro = userDoc['vai_tro'] ??
              'user'; // Mặc định là 'user' nếu không có vai_tro

          if (vaiTro == 'admin') {
            // Nếu vai_tro là admin, chuyển đến màn hình Admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else {
            // Nếu vai_tro là user, chuyển đến màn hình Trang chủ
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                    userId:
                        userId ?? ''), // Truyền userId hoặc chuỗi rỗng nếu null
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Tài khoản không tồn tại trong hệ thống')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _dangNhap,
              child: Text("Đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }
}
