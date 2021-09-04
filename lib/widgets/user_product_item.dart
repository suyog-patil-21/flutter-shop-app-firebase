import 'package:flutter/material.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  const UserProductItem(
      {Key? key, required this.id, required this.imageUrl, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(EditProductScreen.routeName, arguments: id);
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                )),
            IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .deleteProduct(id);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Delete Failed!')));
                  }
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                )),
          ],
        ),
      ),
    );
  }
}
