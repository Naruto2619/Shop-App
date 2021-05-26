import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../Widgets/Cart_item.dart';
import '../providers/order.dart';

class CartScreen extends StatelessWidget {
  static const routename = '/cart';
  @override
  Widget build(BuildContext context) {
    final cartdata = Provider.of<Cart>(context);
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
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Spacer(),
                  Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    label: Text('\$ ${cartdata.totalamt.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                  Order_button(cartdata: cartdata)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, index) => CartItem(
                cartdata.items.values.toList()[index].id,
                cartdata.items.keys.toList()[index],
                cartdata.items.values.toList()[index].price,
                cartdata.items.values.toList()[index].quantity,
                cartdata.items.values.toList()[index].title),
            itemCount: cartdata.items.length,
          )),
        ],
      ),
    );
  }
}

class Order_button extends StatefulWidget {
  const Order_button({
    Key key,
    @required this.cartdata,
  }) : super(key: key);

  final Cart cartdata;

  @override
  _Order_buttonState createState() => _Order_buttonState();
}

class _Order_buttonState extends State<Order_button> {
  var _isloading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cartdata.totalamt <= 0 || _isloading)
          ? null
          : () async {
              setState(() {
                _isloading = true;
              });
              await Provider.of<Orders>(context, listen: false).addorder(
                  widget.cartdata.items.values.toList(),
                  widget.cartdata.totalamt);
              setState(() {
                _isloading = false;
              });
              widget.cartdata.clear();
            },
      child: _isloading
          ? Center(child: CircularProgressIndicator())
          : Text('ORDER NOW'),
      textColor: Colors.purple,
    );
  }
}
