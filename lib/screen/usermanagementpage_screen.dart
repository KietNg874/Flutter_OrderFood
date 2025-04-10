import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatefulWidget {
  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('nguoi_dung');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _usersCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Không có dữ liệu'));
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  title: Text(user['email']),
                  subtitle: Text(user['vai_tro'] ?? 'user'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditUserDialog(context, user);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _usersCollection.doc(user.id).delete();
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
          _showAddUserDialog(context); // Gọi dialog thêm tài khoản
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String selectedRole = 'user'; // Giá trị mặc định là 'user'

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm tài khoản'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'SĐT'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: 'Vai trò'),
                items: [
                  DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                  DropdownMenuItem(
                      value: 'admin', child: Text('Quản trị viên')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
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
                String email = emailController.text.trim();
                String name = nameController.text.trim();
                String phone = phoneController.text.trim();
                String role = selectedRole.toString().trim();

                if (email.isNotEmpty && role.isNotEmpty) {
                  await _usersCollection.add({
                    'email': email,
                    'ten': name,
                    'so_dien_thoai': phone,
                    'vai_tro': role,
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

  void _showEditUserDialog(BuildContext context, DocumentSnapshot user) {
    final TextEditingController emailController =
        TextEditingController(text: user['email']);
    final TextEditingController nameController =
        TextEditingController(text: user['ten']);
    final TextEditingController phoneController =
        TextEditingController(text: user['so_dien_thoai']);
    String selectedRole = user['vai_tro'] ?? 'user'; // Set vai_tro hiện tại

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa tài khoản'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'SĐT'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: 'Vai trò'),
                items: [
                  DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                  DropdownMenuItem(
                      value: 'admin', child: Text('Quản trị viên')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
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
                String email = emailController.text.trim();
                String name = nameController.text.trim();
                String phone = phoneController.text.trim();

                if (email.isNotEmpty && name.isNotEmpty && phone.isNotEmpty) {
                  await _usersCollection.doc(user.id).update({
                    'email': email,
                    'ten': name,
                    'so_dien_thoai': phone,
                    'vai_tro': selectedRole,
                  });

                  Navigator.of(context).pop();
                } else {
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
