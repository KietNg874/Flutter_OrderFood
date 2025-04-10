import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> themVaoGioHang(String userId, String foodId, Map<String, dynamic> foodData) async {
  final cartItemRef = FirebaseFirestore.instance
      .collection('gio_hang')
      .doc(userId)
      .collection('items')
      .doc(foodId);

  final cartItem = await cartItemRef.get();

  if (cartItem.exists) {
    // Nếu món ăn đã tồn tại, tăng số lượng
    cartItemRef.update({
      'so_luong': cartItem['so_luong'] + 1,
    });
  } else {
    // Nếu món ăn chưa có, thêm mới
    cartItemRef.set({
      'ten_mon': foodData['ten_mon'],
      'gia': foodData['gia'],
      'hinh_anh': foodData['hinh_anh'],
      'so_luong': 1,
    });
  }
}