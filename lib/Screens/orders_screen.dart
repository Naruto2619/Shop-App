import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order.dart' show Orders;
import '../Widgets/order_item.dart';
import '../Widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const String routename = '/orders';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).fetchOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (dataSnapshot.error != null) {
              return Center(
                child: Text('Error Occured'),
              );
            } else {
              return Consumer<Orders>(
                  builder: (ctx, orderdata, child) => ListView.builder(
                        itemBuilder: (ctx, i) => OrderItem(orderdata.orders[i]),
                        itemCount: orderdata.orders.length,
                      ));
            }
          },
        ));
  }
}
