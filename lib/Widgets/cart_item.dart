import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String pid;
  final double price;
  int quantity;
  final String title;
  CartItem(this.id, this.pid, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    var cartobj = Provider.of<Cart>(context);
    var vquan = cartobj.items[pid].quantity;
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Are You Sure ?'),
                  content: Text('Do you want to remove the item from the cart'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(_).pop(false);
                        },
                        child: Text('No')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(_).pop(true);
                        },
                        child: Text('Yes'))
                  ],
                ));
      },
      direction: DismissDirection.endToStart,
      key: ValueKey(id),
      background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15)),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(pid);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FittedBox(child: Text('\$${price}')),
              ),
              maxRadius: 30,
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * vquan)}'),
            trailing: Container(
              width: 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.add),
                      onPressed: () {
                        cartobj.add(pid);
                      },
                    ),
                  ),
                  Expanded(
                      child: Text(
                    '${vquan}',
                    textAlign: TextAlign.center,
                  )),
                  (quantity > 1)
                      ? Expanded(
                          child: IconButton(
                            iconSize: 20,
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              cartobj.sub(pid);
                            },
                          ),
                        )
                      : SizedBox(
                          width: 20,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
