import 'package:flutter/material.dart';
import '../Screens/edit_product_screen.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class UserProductsItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  UserProductsItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return SingleChildScrollView(
      child: Container(
        height: 80,
        child: Card(
          shadowColor: Colors.purple,
          elevation: 4,
          child: Container(
            alignment: Alignment.center,
            child: ListTile(
              title: Text(title),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
              ),
              trailing: Container(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              EditProductScreen.routename,
                              arguments: id);
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            await Provider.of<Products>(context, listen: false)
                                .deleteprod(id);
                          } catch (error) {
                            scaffold.showSnackBar(SnackBar(
                                content: Text(
                              'Deleting failed',
                              textAlign: TextAlign.center,
                            )));
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
