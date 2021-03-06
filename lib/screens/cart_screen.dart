import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart' show CartProvider;
import '../providers/orders_provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(fontSize: 20)),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.headline6.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child: Text('ORDER NOW',
                        style: TextStyle(
                          color: cart.itemCount == 0
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        )),
                    onPressed: cart.itemCount == 0
                        ? null
                        : () {
                            print('Creating order.');

                            Provider.of<OrdersProvider>(context, listen: false)
                                .addOrder(
                              cart.items.values.toList(),
                              cart.totalAmount,
                            );

                            cart.clearCart();
                          },
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount: cart.itemCount,
                itemBuilder: (_, index) {
                  print('items: ${cart.items.length}');

                  var key = cart.items.keys.toList()[index];
                  var item = cart.items[key];

                  return CartItem(
                    id: item.id,
                    title: item.title,
                    quantity: item.quantity,
                    price: item.price,
                    productId: cart.items.keys.toList()[index],
                  );
                }),
          )
        ],
      ),
    );
  }
}
