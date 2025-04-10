import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantManagementPage extends StatefulWidget {
  @override
  State<RestaurantManagementPage> createState() =>
      _RestaurantManagementPageState();
}

class _RestaurantManagementPageState extends State<RestaurantManagementPage> {
  final CollectionReference _restaurantsCollection =
      FirebaseFirestore.instance.collection('nha_hang');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _restaurantsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Không có nhà hàng nào.'));
            }

            final restaurants = snapshot.data!.docs;

            return ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                var restaurant = restaurants[index];
                return ListTile(
                  title: Text(restaurant['ten']),
                  subtitle: Text(restaurant['dia_chi']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditRestaurantDialog(context, restaurant);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _restaurantsCollection.doc(restaurant.id).delete();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRestaurantDialog(context); // Gọi dialog thêm nhà hàng
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddRestaurantDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm nhà hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên nhà hàng'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Địa chỉ'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String address = addressController.text.trim();
                String phone = phoneController.text.trim();

                if (name.isNotEmpty && address.isNotEmpty && phone.isNotEmpty) {
                  await _restaurantsCollection.add({
                    'ten': name,
                    'dia_chi': address,
                    'so_dien_thoai': phone,
                    'chu_so_huu_id': FirebaseFirestore.instance
                        .collection('users')
                        .doc()
                        .id, // Tạo chu_so_huu_id tự động
                    'ngay_tao': Timestamp.now(), // Thời gian tạo
                  });

                  Navigator.of(context).pop();
                } else {
                  // Hiển thị thông báo lỗi nếu thông tin nhập không hợp lệ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                  );
                }
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _showEditRestaurantDialog(
      BuildContext context, DocumentSnapshot restaurant) {
    final TextEditingController nameController =
        TextEditingController(text: restaurant['ten']);
    final TextEditingController addressController =
        TextEditingController(text: restaurant['dia_chi']);
    final TextEditingController phoneController =
        TextEditingController(text: restaurant['so_dien_thoai']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa nhà hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên nhà hàng'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Địa chỉ'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String address = addressController.text.trim();
                String phone = phoneController.text.trim();

                if (name.isNotEmpty && address.isNotEmpty && phone.isNotEmpty) {
                  await _restaurantsCollection.doc(restaurant.id).update({
                    'ten': name,
                    'dia_chi': address,
                    'so_dien_thoai': phone,
                  });

                  Navigator.of(context).pop();
                } else {
                  // Hiển thị thông báo lỗi nếu thông tin nhập không hợp lệ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}
