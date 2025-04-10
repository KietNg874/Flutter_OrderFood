import 'package:do_an/screen/dangky_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'adminpage.dart'; // Import Admin Page
import 'homepage_screen.dart'; // Import Home Page

class DangNhapScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController matKhauController = TextEditingController();

  Future<void> _dangNhap(BuildContext context) async {
    try {
      // Đăng nhập bằng Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: matKhauController.text,
      );

      // Lấy thông tin người dùng hiện tại
      User? user = userCredential.user;

      if (user != null) {
        // Lấy vai trò của người dùng từ Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(
                'nguoi_dung') // Mặc định vai trò là 'nguoi_dung' nếu không có vai trò
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String vaiTro = userDoc['vai_tro'] ?? 'nguoi_dung';

          // Chuyển đến trang Admin hoặc người dùng dựa vào vaiTro
          if (vaiTro == 'admin') {
            // Chuyển đến trang Admin nếu vai trò là admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else {
            // Chuyển đến trang chủ nếu vai trò là người dùng
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(userId: user.uid),
              ),
            );
          }
        } else {
          // Hiển thị thông báo lỗi nếu tài khoản không tồn tại trong hệ thống
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tài khoản không tồn tại trong hệ thống')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi Firebase Auth
      String errorMessage = 'Lỗi đăng nhập: ';
      if (e.code == 'user-not-found') {
        errorMessage += 'Tài khoản không tồn tại.';
      } else if (e.code == 'wrong-password') {
        errorMessage += 'Mật khẩu không đúng.';
      } else {
        errorMessage += e.message ?? 'Lỗi không xác định.';
      }
      // Hiển thị thông báo lỗi nếu có lỗi xảy ra
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: matKhauController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _dangNhap(context);
              },
              child: Text('Đăng nhập'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Chuyển đến màn hình đăng ký
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DangKyScreen()),
                );
              },
              child: Text('Chưa có tài khoản? Đăng ký ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
