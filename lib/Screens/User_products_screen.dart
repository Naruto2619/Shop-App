import 'package:flutter/material.dart';
import '../Widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../Widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routename = "/userproduct";
  Future<void> _refresh(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchprod(true);
  }

  @override
  Widget build(BuildContext context) {
    // final prodsdata = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routename);
              })
        ],
      ),
      body: FutureBuilder(
        future: _refresh(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refresh(context),
                    child: Consumer<Products>(
                      builder: (ctx, prodsdata, _) => Padding(
                        child: ListView.builder(
                          itemBuilder: (ctx, i) => UserProductsItem(
                              prodsdata.items[i].id,
                              prodsdata.items[i].title,
                              prodsdata.items[i].imageUrl),
                          itemCount: prodsdata.items.length,
                        ),
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                  ),
      ),
    );
  }
}
