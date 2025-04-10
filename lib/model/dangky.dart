import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> dangKyTaiKhoan(String ten, String email, String matKhau, String soDienThoai) async {
  try {
    // Tạo tài khoản trên Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: matKhau,
    );

    // Lấy thông tin người dùng từ Auth
    User? nguoiDung = userCredential.user;

    if (nguoiDung != null) {
      // Lưu thông tin người dùng vào Firestore
      await FirebaseFirestore.instance.collection('nguoi_dung').doc(nguoiDung.uid).set({
        'id': nguoiDung.uid,
        'ten': ten,
        'email': email,
        'so_dien_thoai': soDienThoai,
        'vai_tro': 'nguoi_dung', // Mặc định vai trò là người dùng
        'ngay_tao': FieldValue.serverTimestamp(),
      });
      print('Đăng ký tài khoản thành công!');
    }
  } catch (e) {
    print('Lỗi khi đăng ký tài khoản: $e');
  }
}