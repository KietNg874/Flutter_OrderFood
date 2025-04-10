import 'package:flutter/material.dart';
import 'package:do_an/screen/dangky_screen.dart';
import 'package:do_an/screen/dangnhap_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chào mừng!')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Chuyển tới màn hình Đăng nhập
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DangNhapScreen()),
                );
              },
              child: Text('Đăng nhập'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Chuyển tới màn hình Đăng ký
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DangKyScreen()),
                );
              },
              child: Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}