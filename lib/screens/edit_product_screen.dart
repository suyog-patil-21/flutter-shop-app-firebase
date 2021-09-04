import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  Product _editedProduct =
      Product(id: 'NULL', title: '', description: '', imageUrl: '', price: 0.0);
  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') ||
          !_imageUrlController.text.startsWith('https')) return;
      setState(() {});
    }
  }

  var _isInit = true;
  var _initVal = {
    'title': '',
    'price': '',
    'description': '',
  };
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      var productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != 'NULL') {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initVal = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != 'NULL') {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct)
          .then((value) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct)
          .catchError((error) {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text('An error Occured!'),
                    content: Text('Something When wrong\n$error'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Okay'))
                    ]));
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Edit Product',
          ),
          actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initVal['title'],
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Title.';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: value.toString(),
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initVal['price'],
                        decoration: const InputDecoration(
                          labelText: 'Price',
                        ),
                        focusNode: _priceFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please Enter a valid Number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please Enter number greater than Zero.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              price: double.parse(
                                  value!.isNotEmpty ? value.toString() : '0.0'),
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initVal['description'],
                        decoration: const InputDecoration(
                          label: Text('Description'),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              price: _editedProduct.price,
                              description: value.toString(),
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter a Description.';
                          }
                          if (value.length < 10) {
                            return 'Description must be atleast 10 charachter long.';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter A URL')
                                : FittedBox(
                                    child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Image URL',
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Enter an Image URL.';
                                }
                                if (!value.startsWith('http') ||
                                    !value.startsWith('https')) {
                                  return 'Please Enter a valid URL';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                    title: _editedProduct.title,
                                    price: _editedProduct.price,
                                    description: _editedProduct.description,
                                    imageUrl: value.toString(),
                                    id: _editedProduct.id,
                                    isFavorite: _editedProduct.isFavorite);
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
