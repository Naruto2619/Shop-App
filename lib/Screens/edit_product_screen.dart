import 'package:flutter/material.dart';
import '../providers/Product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routename = '/editprod';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descripFocusNode = FocusNode();
  final _imagecontroller = TextEditingController();
  final _imageurl = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedprod =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  var _initvalues = {'title': '', 'desc': '', 'price': '', 'image': ''};
  var _isinit = true;
  var _isloading = false;
  @override
  void initState() {
    _imageurl.addListener(_updateimageurl);
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      final prodid = ModalRoute.of(context).settings.arguments as String;
      if (prodid != null) {
        _editedprod =
            Provider.of<Products>(context, listen: false).findbyid(prodid);
        _initvalues = {
          'title': _editedprod.title,
          'desc': _editedprod.description,
          'price': _editedprod.price.toString(),
          'image': ''
        };
        _imagecontroller.text = _editedprod.imageUrl;
      }
    }
    _isinit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageurl.removeListener(_updateimageurl);
    _priceFocusNode.dispose();
    _descripFocusNode.dispose();
    _imagecontroller.dispose();
    _imageurl.dispose();
    super.dispose();
  }

  void _updateimageurl() {
    if (!_imageurl.hasFocus) {
      if ((!_imagecontroller.text.startsWith('http') &&
              !_imagecontroller.text.startsWith('https')) ||
          (!_imagecontroller.text.endsWith('.png') &&
              !_imagecontroller.text.endsWith('.jpg') &&
              !_imagecontroller.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveform() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isloading = true;
    });
    if (_editedprod.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateprod(_editedprod.id, _editedprod);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedprod);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An Error Occurred'),
                  content: Text('Something Went Wrong'),
                  actions: [
                    TextButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      }
      // finally {
      //   setState(() {
      //     _isloading = true;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isloading = true;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveform)],
      ),
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initvalues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (val) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedprod = Product(
                            title: value,
                            price: _editedprod.price,
                            description: _editedprod.description,
                            imageUrl: _editedprod.imageUrl,
                            id: _editedprod.id,
                            isFavorite: _editedprod.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Please Provide a Title';
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initvalues['price'],
                      decoration: InputDecoration(labelText: 'Amount'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (val) {
                        FocusScope.of(context).requestFocus(_descripFocusNode);
                      },
                      onSaved: (value) {
                        _editedprod = Product(
                            title: _editedprod.title,
                            price: double.parse(value),
                            description: _editedprod.description,
                            imageUrl: _editedprod.imageUrl,
                            id: _editedprod.id,
                            isFavorite: _editedprod.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please Enter a Valid Number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Value too Low Must be >0';
                        }
                        return null;
                      },
                      focusNode: _priceFocusNode,
                    ),
                    TextFormField(
                      initialValue: _initvalues['desc'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descripFocusNode,
                      onSaved: (value) {
                        _editedprod = Product(
                            title: _editedprod.title,
                            price: _editedprod.price,
                            description: value,
                            imageUrl: _editedprod.imageUrl,
                            id: _editedprod.id,
                            isFavorite: _editedprod.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Description';
                        }
                        if (value.length < 10) {
                          return 'Descrption must be 10 Chars At least';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imagecontroller.text.isEmpty
                              ? Text('Enter a Url')
                              : FittedBox(
                                  child: Image.network(_imagecontroller.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image Url'),
                            keyboardType: TextInputType.url,
                            controller: _imagecontroller,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageurl,
                            onFieldSubmitted: (_) => _saveform,
                            onSaved: (value) {
                              _editedprod = Product(
                                  title: _editedprod.title,
                                  price: _editedprod.price,
                                  description: _editedprod.description,
                                  imageUrl: value,
                                  id: _editedprod.id,
                                  isFavorite: _editedprod.isFavorite);
                            },
                            validator: (value) {
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
