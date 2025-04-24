import 'package:flutter/material.dart';
import 'package:neoflex/src/quiz/screenshots/database_helper.dart';
import 'dart:io';
import 'product.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _userPoints = 0;
  String _email="";
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email'); // получаем email

    if (email == null) {
      // если email не найден — можно что-то показать или выйти
      print('Email не найден. Пользователь не авторизован.');
      return;
    }

    final db = DatabaseHelper.instance;
    int points = await db.getPoints(email);
    final products = await db.getAllProducts();// передаем email в запрос

    setState(() {
      _email =email;
      _userPoints = points;
      _products = products;
    });
  }


// В классе _ShopPageState, после покупки или при выходе
  Future<void> _buyItem(Product product) async {
    if (_userPoints >= product.price && product.quantity > 0) {
      final db = DatabaseHelper.instance;

      setState(() {
        _userPoints -= product.price;
        product.quantity--;
      });

      await db.updatePoints(_email, _userPoints);
      await db.decreaseProductQuantity(product.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Вы купили: ${product.name}!")),
      );

      // Возвращаем обновленное количество сердец
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
    leading: IconButton(
    icon: Icon(Icons.arrow_back), // Стрелка назад
    onPressed: () {
    // Здесь можно выполнить дополнительное действие
    // Например, показать диалог или выполнить логику
    Navigator.pop(context, _userPoints); // Ваша дополнительная логика

    // После выполнения действия, вернуться на предыдущий экран
    },
      ),
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
