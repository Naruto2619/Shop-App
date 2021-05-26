import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/cart_screen.dart';
import '../Widgets/app_drawer.dart';
import '../Widgets/Products_grid.dart';
import '../Widgets/badge.dart';
import '../providers/cart.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import '../providers/products.dart';

enum Filter {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isloading = false;
  var showfav = false;
  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isloading = true;
      });
      Provider.of<Products>(context, listen: false).fetchprod().then((_) {
        setState(() {
          _isloading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (Filter val) {
              setState(() {
                if (val == Filter.Favorites) {
                  showfav = true;
                } else {
                  showfav = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only fav'),
                value: Filter.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: Filter.All,
              )
            ],
          ),
          Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                    child: ch,
                    value: cart.itemCount.toString(),
                  ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routename);
                },
              )),
        ],
      ),
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(showfav),
    );
  }
}
