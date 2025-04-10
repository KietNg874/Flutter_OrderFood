import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDetailPage extends StatelessWidget {
  final String ten;
  final String moTa;
  final String hinhAnh;
  final double gia;
  final String userId;
  final String foodId;

  FoodDetailPage({
    required this.ten,
    required this.moTa,
    required this.hinhAnh,
    required this.gia,
    required this.userId,
    required this.foodId,
  });

  // Thêm nhận xét vào Firestore
  Future<void> themNhanXet(String noiDung) async {
    final nhanXetRef = FirebaseFirestore.instance.collection('nhan_xet');
    try {
      await nhanXetRef.add({
        'food_id': foodId,
        'nguoi_dung_id': userId,
        'noi_dung': noiDung,
        'ngay': Timestamp.now(),
      });
    } catch (e) {
      print('Lỗi khi thêm nhận xét: $e');
      rethrow;
    }
  }

  // Hàm thêm món ăn vào giỏ hàng
  Future<void> themVaoGioHang(
      String userId, String foodId, Map<String, dynamic> foodData) async {
    final cartItemRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(foodId);

    try {
      final cartItem = await cartItemRef.get();

      if (cartItem.exists) {
        cartItemRef.update({
          'so_luong': cartItem['so_luong'] + 1,
        });
      } else {
        cartItemRef.set({
          'ten_mon': foodData['ten'],
          'gia': foodData['gia'],
          'hinh_anh': foodData['hinh_anh'],
          'so_luong': 1,
        });
      }
    } catch (e) {
      print('Lỗi khi thêm vào giỏ hàng: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController noiDungController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(ten),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh món ăn
            Center(
              child: Image.file(
                File(hinhAnh),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error);
                },
              ),
            ),
            SizedBox(height: 16.0),
            // Thông tin món ăn
            Text(
              ten,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Giá: ${gia.toStringAsFixed(0)} VND',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 8.0),
            Text(
              moTa,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Nút thêm vào giỏ hàng
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await themVaoGioHang(
                      userId,
                      foodId,
                      {
                        'ten': ten,
                        'gia': gia,
                        'hinh_anh': hinhAnh,
                      },
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm "$ten" vào giỏ hàng!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: Không thể thêm vào giỏ hàng.'),
                      ),
                    );
                  }
                },
                child: Text("Thêm vào giỏ hàng"),
              ),
            ),
            Divider(),
            // Danh sách nhận xét
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('nhan_xet')
                    .where('food_id', isEqualTo: foodId)
                    .orderBy('ngay', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi khi tải nhận xét: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Chưa có nhận xét nào.'));
                  }
                  final nhanXets = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: nhanXets.length,
                    itemBuilder: (context, index) {
                      final nhanXet = nhanXets[index];
                      final ngay = (nhanXet['ngay'] as Timestamp).toDate();
                      final nguoiDungId = nhanXet['nguoi_dung_id'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('nguoi_dung')
                            .doc(nguoiDungId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: Text("Đang tải..."),
                              subtitle: Text(nhanXet['noi_dung']),
                            );
                          }
                          if (userSnapshot.hasError ||
                              !userSnapshot.hasData ||
                              !userSnapshot.data!.exists) {
                            return ListTile(
                              title: Text("Người dùng không tồn tại"),
                              subtitle: Text(nhanXet['noi_dung']),
                            );
                          }
                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          final tenNguoiDung =
                              userData['ten'] ?? "Người dùng ẩn danh";

                          return ListTile(
                            title: Text(tenNguoiDung),
                            subtitle: Text(nhanXet['noi_dung']),
                            trailing: Text(
                              ngay.toString(),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Form nhập nhận xét
            TextField(
              controller: noiDungController,
              decoration: InputDecoration(
                labelText: 'Nhập nhận xét',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final noiDung = noiDungController.text.trim();
                    if (noiDung.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Nội dung không được để trống.')),
                      );
                      return;
                    }
                    try {
                      await themNhanXet(noiDung);
                      noiDungController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Nhận xét đã được gửi!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: Không thể gửi nhận xét.')),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
