import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final String userId;

  OrderDetailScreen({required this.orderId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('don_hang')
            .doc(orderId)
            .snapshots(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!orderSnapshot.hasData || !orderSnapshot.data!.exists) {
            return Center(child: Text('Đơn hàng không tồn tại.'));
          }

          final order = orderSnapshot.data!;
          final trangThai = order['trang_thai'];

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('don_hang')
                      .doc(orderId)
                      .collection('chi_tiet_don_hang')
                      .snapshots(),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!detailSnapshot.hasData ||
                        detailSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('Không có chi tiết đơn hàng.'));
                    }

                    final items = detailSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var item = items[index];
                        return ListTile(
                          title: Text(item['ten_mon']),
                          subtitle: Text(
                              'Số lượng: ${item['so_luong']} - Giá: ${item['gia']} VND'),
                          leading: Image.file(
                            File(item['hinh_anh']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (trangThai == 'Đã giao hàng')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // CHuyển trang_thai thành "Hoàn thành"
                      await FirebaseFirestore.instance
                          .collection('don_hang')
                          .doc(orderId)
                          .update({'trang_thai': 'Hoàn thành'});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Xác nhận thành công')),
                      );

                      Navigator.pop(context); // về trang trước
                    },
                    child: Text('Đã nhận hàng'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
