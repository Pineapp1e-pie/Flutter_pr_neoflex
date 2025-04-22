import 'package:flutter/material.dart';
import 'package:neoflex/src/quiz/screenshots/database_helper.dart';
import 'dart:io';
import 'product.dart';


class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _userPoints = 0;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    final db = DatabaseHelper.instance;
    final points = await db.getPoints();  // Получение сердец
    final products = await db.getAllProducts();  // Получение списка продуктов

    setState(() {
      _userPoints = points;
      _products = products;
    });
  }


  Future<void> _buyItem(Product product) async {
    if (_userPoints >= product.price && product.quantity > 0) {
      final db = DatabaseHelper.instance;

      setState(() {
        _userPoints -= product.price;
        product.quantity--;
      });

      await db.updatePoints(_userPoints);
      await db.decreaseProductQuantity(product.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Вы купили: ${product.name}!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Не хватает сердец или товара нет в наличии!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Магазин — ❤️ $_userPoints"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final canBuy = _userPoints >= product.price && product.quantity > 0;

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(
                product.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              title: Text(product.name),
              subtitle: Text("${product.description}\nЦена: ${product.price} ❤️\nОсталось: ${product.quantity}"),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: canBuy ? () => _buyItem(product) : null,
                child: const Text("Купить"),
              ),
            ),
          );
        },
      ),
    );
  }
}
