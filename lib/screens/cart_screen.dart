import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  width: 10,
                ),
                Spacer(),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount.toString()}',
                    style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge
                            ?.color),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                TextButton(
                  child: Text('ORDER NOW'),
                  onPressed: () {
                    Provider.of<Orders>(context, listen: false).addOrder(
                      cart.items.values.toList(),
                      cart.totalAmount,
                    );
                    cart.clear();
                  },
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
            child: ListView.builder(
          itemBuilder: (ctx, i) => CartItem(
            id: cart.items.values.toList()[i].id,
            productId: cart.items.keys.toList()[i],
            title: cart.items.values.toList()[i].title,
            price: cart.items.values.toList()[i].price,
            quantity: cart.items.values.toList()[i].quantity,
          ),
          itemCount: cart.items.length,
        ))
      ]),
    );
  }
}
