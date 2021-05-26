import 'package:flutter/material.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routename = '/product-detail';
  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context).settings.arguments;
    var loadedprod = Provider.of<Products>(context, listen: false).findbyid(id);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedprod.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              iconTheme: IconThemeData(color: Colors.black),
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  loadedprod.title,
                  style: TextStyle(color: Colors.white),
                ),
                background: Hero(
                  tag: loadedprod.id,
                  child: Image.network(
                    loadedprod.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedprod.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedprod.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            SizedBox(
              height: 800,
            )
          ])),
        ],
      ),
    );
  }
}
