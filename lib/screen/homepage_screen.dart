import 'dart:io';
import 'dart:async'; // Để sử dụng StreamController
import 'package:do_an/screen/dangnhap_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an/screen/fooddetailpage_screen.dart';
import 'package:do_an/screen/cartpage_screen.dart';
import 'package:do_an/screen/userorder_screen.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final StreamController<String> _searchKeywordStream =
      StreamController<String>.broadcast();
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(_buildFoodList()); // Trang chủ
    _pages.add(
        UserOrdersScreen(userId: widget.userId)); // Đơn hàng của người dùng
    _pages.add(UserProfilePage(userId: widget.userId)); // Tài khoản người dùng
  }

  @override
  void dispose() {
    _searchKeywordStream.close(); // Đóng StreamController khi không sử dụng nữa
    super.dispose();
  }

  Widget _buildFoodList() {
    return Column(
      children: [
        // Thanh tìm kiếm
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Tìm kiếm món ăn",
                    hintText: "Nhập tên món ăn...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    _searchKeywordStream
                        .add(value.trim()); // Đẩy từ khóa vào Stream
                  },
                ),
              ),
              SizedBox(width: 8.0),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {}, // Không cần xử lý gì thêm ở đây
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<String>(
            stream: _searchKeywordStream.stream, // Stream từ khóa tìm kiếm
            initialData: "",
            builder: (context, searchSnapshot) {
              final keyword = searchSnapshot.data ?? "";

              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('mon_an').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Không có món ăn nào.'));
                  }

                  var data = snapshot.data!.docs;

                  // Lọc dữ liệu nếu có từ khóa tìm kiếm
                  var displayData = keyword.isNotEmpty
                      ? data.where((monAn) {
                          final ten = monAn['ten'] as String? ?? "";
                          return ten
                              .toLowerCase()
                              .contains(keyword.toLowerCase());
                        }).toList()
                      : data;

                  if (displayData.isEmpty) {
                    return Center(
                        child: Text('Không tìm thấy món ăn phù hợp.'));
                  }

                  return ListView.builder(
                    itemCount: displayData.length,
                    itemBuilder: (context, index) {
                      var monAn = displayData[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(monAn['ten']),
                          subtitle: Text(monAn['mo_ta']),
                          leading: Image.file(
                            File(monAn['hinh_anh']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodDetailPage(
                                  ten: monAn['ten'],
                                  moTa: monAn['mo_ta'],
                                  hinhAnh: monAn['hinh_anh'],
                                  gia: monAn['gia'].toDouble(),
                                  userId: widget.userId,
                                  foodId: monAn.id,
                                ),
                              ),
                            );
                          },
                          trailing: ElevatedButton(
                            onPressed: () {
                              themVaoGioHang(
                                widget.userId,
                                monAn.id,
                                {
                                  'ten': monAn['ten'],
                                  'gia': monAn['gia'],
                                  'hinh_anh': monAn['hinh_anh'],
                                },
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'Đã thêm "${monAn['ten']}" vào giỏ hàng!'),
                              ));
                            },
                            child: Text("Thêm"),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chủ - Các món ăn"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> themVaoGioHang(
      String userId, String foodId, Map<String, dynamic> foodData) async {
    final cartItemRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(foodId);

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
  }
}

class UserProfilePage extends StatelessWidget {
  final String userId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  UserProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('nguoi_dung').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('Không tìm thấy thông tin người dùng.'));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        _nameController.text = userData['ten'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['so_dien_thoai'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                enabled: false, // Không cho phép sửa email
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('nguoi_dung')
                      .doc(userId)
                      .update({
                    'ten': _nameController.text,
                    'so_dien_thoai': _phoneController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thông tin đã được cập nhật')));
                },
                child: Text('Cập nhật thông tin'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool? logout = await _showLogoutDialog(
                      context); // Sửa logout thành bool?
                  if (logout == true) {
                    // Kiểm tra logout có phải true không
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DangNhapScreen()), // Điều hướng đến trang đăng nhập
                    );
                  }
                },
                child: Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              )
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Đóng dialog và trả về false
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Đóng dialog và trả về true
              },
              child: Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }
}
