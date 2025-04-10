import 'package:do_an/model/dangky.dart';
import 'package:do_an/screen/dangnhap_screen.dart';
import 'package:flutter/material.dart';

class DangKyScreen extends StatelessWidget {
  final TextEditingController tenController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController matKhauController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tenController,
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: matKhauController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            TextField(
              controller: soDienThoaiController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Gọi hàm đăng ký
                try {
                  await dangKyTaiKhoan(
                    tenController.text, // Tên
                    emailController.text, // Email
                    matKhauController.text, // Mật khẩu
                    soDienThoaiController.text, // Số điện thoại
                  );

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng ký thành công!')),
                  );

                  // Chuyển đến màn hình đăng nhập sau khi đăng ký thành công
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DangNhapScreen()),
                  );
                } catch (e) {
                  // Hiển thị thông báo lỗi nếu đăng ký thất bại
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đăng ký: $e')),
                  );
                }
              },
              child: Text('Đăng ký'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Quay lại màn hình Đăng nhập
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DangNhapScreen()),
                );
              },
              child: Text('Đã có tài khoản? Đăng nhập ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
