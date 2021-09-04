import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../screens/cart_screen.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName ='products-screen';
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  List<Product>? loadedProducts;
  bool showFavorites = false;
  // bool _isLoading = false;
  // @override
  // void initState() {
  //   //   Future.delayed(Duration.zero).then((value) {
  //   // Provider.of<Products>(context,listen:false).fetchProduct();
  //   //   });
  //   super.initState();
  // }

  // var _initState = true;
  // @override
  // void didChangeDependencies() {
  //   if (_initState) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Products>(
  //       context,
  //     ).fetchProduct().catchError((error) {
  //       return showDialog(
  //           context: context,
  //           builder: (context) {
  //             return AlertDialog(
  //                 title: const Text(
  //                   'Error ',
  //                 ),
  //                 content: Text('Error encountered $error'),
  //                 actions: [
  //                   TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: Text('Okay'))
  //                 ]);
  //           });
  //     }).then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _initState = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('MyShop'),
          actions: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (FilterOptions selectedValue) {
                  setState(() {
                    if (selectedValue == FilterOptions.favorites) {
                      showFavorites = true;
                    } else {
                      showFavorites = false;
                    }
                  });
                },
                itemBuilder: (_) => [
                      const PopupMenuItem(
                        child: Text('Only Favorites'),
                        value: FilterOptions.favorites,
                      ),
                      const PopupMenuItem(
                          child: Text('Show All'), value: FilterOptions.all)
                    ]),
            Consumer<Cart>(
                builder: (_, cart, ch) => Badge(
                    child: ch as Widget, value: cart.itemCount.toString()),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                ))
          ],
        ),
        body: FutureBuilder(
          future: Provider.of<Products>(context,listen: false).fetchProduct(),builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text(
                    'Error',
                  ),
                  content: Text('Error encountered ${snapshot.error}'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Okay'))
                  ]);
            });
              return const Center(child: Text('Error Occured '));
            } else {
              return ProductsGrid(
                showFavs: showFavorites,
              );
            }
          }
        }));
  }
}
