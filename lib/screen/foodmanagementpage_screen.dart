import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FoodManagementPage extends StatefulWidget {
  @override
  _FoodManagementPageState createState() => _FoodManagementPageState();
}

class _FoodManagementPageState extends State<FoodManagementPage> {
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('mon_an');
  final CollectionReference _restaurantsCollection =
      FirebaseFirestore.instance.collection('nha_hang');
  String? selectedRestaurantId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: _foodCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Không có dữ liệu'));
            }

            final foods = snapshot.data!.docs;

            return ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                var food = foods[index];
                return ListTile(
                  title: Text(food['ten']),
                  subtitle: Text('Giá: ${food['gia']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditFoodDialog(context, food);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _foodCollection.doc(food.id).delete();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddFoodDialog(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<List<DropdownMenuItem<String>>> _fetchRestaurantDropdownItems() async {
    try {
      QuerySnapshot snapshot = await _restaurantsCollection.get();
      return snapshot.docs.map((doc) {
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(doc['ten']),
        );
      }).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách nhà hàng: $e');
      return [];
    }
  }

  void _showAddFoodDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final ImagePicker _picker = ImagePicker();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm món ăn'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Tên món ăn'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Giá'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Mô tả'),
                    ),
                    FutureBuilder<List<DropdownMenuItem<String>>>(
                      future: _fetchRestaurantDropdownItems(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return DropdownButton<String>(
                          value: selectedRestaurantId,
                          hint: Text('Chọn nhà hàng'),
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              selectedRestaurantId = newValue;
                            });
                          },
                          items: snapshot.data,
                        );
                      },
                    ),
                    selectedImage == null
                        ? Text('Chưa chọn ảnh')
                        : Image.file(selectedImage!, height: 100),
                    IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () async {
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        selectedRestaurantId == null ||
                        selectedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin')));
                      return;
                    }

                    // Lấy đường dẫn từ ảnh đã chọn
                    String imagePath = selectedImage!.path;

                    await _foodCollection.add({
                      'ten': nameController.text,
                      'gia': double.parse(priceController.text),
                      'mo_ta': descriptionController.text,
                      'hinh_anh': imagePath, // Lưu đường dẫn ảnh
                      'nha_hang_id': selectedRestaurantId,
                      'mon_an_id':
                          DateTime.now().millisecondsSinceEpoch.toString(),
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditFoodDialog(BuildContext context, DocumentSnapshot food) {
    final TextEditingController nameController =
        TextEditingController(text: food['ten']);
    final TextEditingController priceController =
        TextEditingController(text: food['gia'].toString());
    final TextEditingController descriptionController =
        TextEditingController(text: food['mo_ta']);
    String? imageUrl = food['hinh_anh'];
    String? selectedRestaurantId = food['nha_hang_id'];
    final ImagePicker _picker = ImagePicker();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Sửa món ăn'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Tên món ăn'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Giá'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Mô tả'),
                    ),
                    FutureBuilder<List<DropdownMenuItem<String>>>(
                      future: _fetchRestaurantDropdownItems(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return DropdownButton<String>(
                          value: selectedRestaurantId,
                          hint: Text('Chọn nhà hàng'),
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              selectedRestaurantId = newValue;
                            });
                          },
                          items: snapshot.data,
                        );
                      },
                    ),
                    selectedImage == null
                        ? (imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.file(File(imageUrl!),
                                height: 100) // Hiển thị ảnh từ đường dẫn
                            : Text('Chưa chọn ảnh')) // Nếu không có ảnh
                        : Image.file(selectedImage!, height: 100),
                    IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () async {
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        selectedRestaurantId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin')));
                      return;
                    }

                    // Lấy đường dẫn ảnh (nếu chọn ảnh mới)
                    if (selectedImage != null) {
                      imageUrl = selectedImage!.path;
                    }

                    await _foodCollection.doc(food.id).update({
                      'ten': nameController.text,
                      'gia': double.parse(priceController.text),
                      'mo_ta': descriptionController.text,
                      'hinh_anh': imageUrl, // Lưu đường dẫn ảnh
                      'nha_hang_id': selectedRestaurantId,
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
