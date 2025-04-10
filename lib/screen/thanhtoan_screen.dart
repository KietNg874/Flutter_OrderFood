import 'package:do_an/screen/homepage_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnpay_flutter/vnpay_flutter.dart';

class ThanhToan extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> cartItems;

  ThanhToan({required this.userId, required this.cartItems});

  @override
  _ThanhToanState createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String responseCode = '';

  double calculateTotal() {
    double total = 0;
    for (var item in widget.cartItems) {
      total += item['gia'] * item['so_luong'];
    }
    return total;
  }

  Future<void> onVNPayPayment() async {
    final totalAmount = calculateTotal(); // VNPay tính theo đơn vị VND x100

    final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
      version: '2.0.1',
      tmnCode: 'IISEWHGH',
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: 'Thanh toán đơn hàng',
      amount: totalAmount,
      returnUrl: 'https://sandbox.vnpayment.vn/return',
      ipAdress: '192.168.10.10',
      vnpayHashKey: '3274T946O29V4WYZLH4UTPBTPO1ZC204',
      vnPayHashType: VNPayHashType.HMACSHA512,
      vnpayExpireDate: DateTime.now().add(const Duration(hours: 1)),
    );

    await VNPAYFlutter.instance.show(
      paymentUrl: paymentUrl,
      onPaymentSuccess: (params) {
        setState(() {
          responseCode = params['vnp_ResponseCode'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thanh toán thành công!')),
        );
        placeOrder(isVNPay: true);

        // Điều hướng về trang chủ món ăn
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: widget.userId),
          ),
          (route) => false,
        );
      },
      onPaymentError: (params) {
        setState(() {
          responseCode = 'Error';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thanh toán thất bại!')),
        );
      },
    );
  }

  Future<void> placeOrder({bool isVNPay = false}) async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên và địa chỉ')),
      );
      return;
    }

    double total = calculateTotal();

    final orderRef = FirebaseFirestore.instance.collection('don_hang').doc();
    await orderRef.set({
      'nguoi_dung_id': widget.userId,
      'tong_tien': total,
      'trang_thai': isVNPay ? 'Đã thanh toán qua VNPay' : 'Đang xử lý',
      'ten_nguoi_dung': _nameController.text,
      'dia_chi': _addressController.text,
      'ngay_dat': FieldValue.serverTimestamp(),
    });

    for (var item in widget.cartItems) {
      await orderRef.collection('chi_tiet_don_hang').add({
        'ten_mon': item['ten_mon'],
        'gia': item['gia'],
        'so_luong': item['so_luong'],
        'hinh_anh': item['hinh_anh'],
      });
    }

    await FirebaseFirestore.instance
        .collection('carts')
        .doc(widget.userId)
        .collection('items')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đặt hàng thành công!'),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh Toán'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng tiền: ${calculateTotal().toStringAsFixed(0)} VND',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên người nhận'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Địa chỉ giao hàng'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: placeOrder,
                child: Text('Thanh Toán COD'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: onVNPayPayment,
                child: Text('Thanh Toán VNPay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
