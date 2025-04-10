import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManagementPage extends StatelessWidget {
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('don_hang');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('nguoi_dung');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: _ordersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Không có dữ liệu'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return FutureBuilder<DocumentSnapshot>(
                future: _usersCollection.doc(order['nguoi_dung_id']).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final user = userSnapshot.data;

                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text('Mã đơn hàng: ${order.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tên người dùng: ${user?['ten'] ?? 'Không có'}'),
                          Text('Địa chỉ: ${order['dia_chi']}'),
                          Text(
                              'Ngày đặt: ${_formatTimestamp(order['ngay_dat'])}'),
                          Text('Tổng tiền: ${order['tong_tien']}'),
                          Text('Trạng thái: ${order['trang_thai']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditOrderDialog(context, order);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showEditOrderDialog(BuildContext context, DocumentSnapshot order) {
    String selectedStatus = order['trang_thai'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa trạng thái đơn hàng'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: [
              DropdownMenuItem(value: "Đang xử lý", child: Text('Đang xử lý')),
              DropdownMenuItem(
                  value: "Đang giao hàng", child: Text('Đang giao hàng')),
              DropdownMenuItem(
                  value: "Đã giao hàng", child: Text('Đã giao hàng')),
              DropdownMenuItem(value: "Hoàn thành", child: Text('Hoàn thành')),
              DropdownMenuItem(
                  value: "Đã thanh toán qua VNPay",
                  child: Text('Đã thanh toán qua VNPay')),
            ],
            onChanged: (value) {
              selectedStatus = value!;
            },
            decoration: InputDecoration(labelText: 'Trạng thái'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _ordersCollection.doc(order.id).update({
                  'trang_thai': selectedStatus,
                });
                Navigator.of(context).pop();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Không có dữ liệu';
    final DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
