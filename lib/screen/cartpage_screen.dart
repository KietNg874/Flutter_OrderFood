import 'dart:io';

import 'package:do_an/screen/thanhtoan_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  final String userId; // Truyền userId từ FirebaseAuth

  CartPage({required this.userId});

  Future<void> capNhatSoLuong(String foodId, int soLuongMoi) async {
    if (soLuongMoi > 0) {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(foodId)
          .update({'so_luong': soLuongMoi});
    } else {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(foodId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giỏ hàng")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carts')
            .doc(userId)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Giỏ hàng trống'));
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              var item = cartItems[index];
              return Card(
                child: ListTile(
                  leading: Image.file(
                    File(item['hinh_anh']),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons
                          .error); // Hiển thị biểu tượng lỗi nếu hình ảnh không tải được
                    },
                  ), // Hình ảnh món ăn
                  title: Text(item['ten_mon']),
                  subtitle: Text(
                      'Giá: ${item['gia']} VND\nSố lượng: ${item['so_luong']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          capNhatSoLuong(item.id, item['so_luong'] - 1);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          capNhatSoLuong(item.id, item['so_luong'] + 1);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Fetch cart items
          final cartItemsSnapshot = await FirebaseFirestore.instance
              .collection('carts')
              .doc(userId)
              .collection('items')
              .get();

          final cartItems = cartItemsSnapshot.docs.map((doc) {
            return {
              'ten_mon': doc['ten_mon'],
              'gia': doc['gia'],
              'so_luong': doc['so_luong'],
              'hinh_anh': doc['hinh_anh'],
            };
          }).toList();

          // Navigate to ThanhToanScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThanhToan(
                userId: userId,
                cartItems: cartItems,
              ),
            ),
          );
        },
        child: Icon(Icons.payment),
      ),
    );
  }
}
