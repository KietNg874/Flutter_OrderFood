import 'package:flutter/material.dart';
import 'foodmanagementpage_screen.dart';
import 'ordermanagementpage_screen.dart';
import 'restaurantmanagementpage_screen.dart';
import 'usermanagementpage_screen.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return UserManagementPage();
      case 1:
        return FoodManagementPage();
      case 2:
        return RestaurantManagementPage();
      case 3:
        return OrderManagementPage();
      default:
        return Center(child: Text('Không tìm thấy trang'));
    }
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
        title: Text('Quản lý Admin'),
      ),
      body: _getPage(_selectedIndex), // Chạy trang hiện bật
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[900], // Ảnh nền
        selectedItemColor: Colors.amber, // Màu khi chọn
        unselectedItemColor: Colors.black87, // màu khi k chọn
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Món ăn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nhà hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Đơn hàng',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
