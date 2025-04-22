import 'package:flutter/material.dart';

class Product {
  final String name;
  final String description;
  final int price; // в баллах!
  final String imageUrl;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}




final List<Product> products = [
Product(
name: "Стикерпак Neoflex",
description: "Крутые стикеры для ноутбука",
price: 3,
imageUrl: "https://example.com/stickers.png",
),
Product(
name: "Кепка Neoflex",
description: "Защищает от багов и солнца",
price: 7,
imageUrl: "https://example.com/cap.png",
),
Product(
name: "Футболка Neoflex",
description: "Фирменная футболка за успехи в квизах",
price: 10,
imageUrl: "https://example.com/tshirt.png",
),
];



class ShopPage extends StatefulWidget {
  final int userPoints;
  final Function(int) onPointsChanged;

  const ShopPage({super.key, required this.userPoints, required this.onPointsChanged});

  @override
  State<ShopPage> createState() => _ShopPageState();

}

class _ShopPageState extends State<ShopPage> {
  late int points;

  @override
  void initState() {
    super.initState();
    points = widget.userPoints;
  }

  void buyProduct(Product product) {
    if (points >= product.price) {
      setState(() {
        points -= product.price;
      });
      widget.onPointsChanged(points);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вы купили: ${product.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Магазин наград — Баллы: $points"),
        backgroundColor: Colors.black87,
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final canBuy = points >= product.price;

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(product.imageUrl, width: 50),
              title: Text(product.name),
              subtitle: Text("${product.description}\nЦена: ${product.price} баллов"),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: canBuy ? () => buyProduct(product) : null,
                child: const Text("Купить"),
              ),
            ),
          );
        },
      ),
    );
  }
}
