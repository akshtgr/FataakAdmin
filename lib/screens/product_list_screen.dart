import 'package:flutter/material.dart'; // Corrected import
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import './product_edit_screen.dart';
import 'product_search.dart';
import '../widgets/product_card.dart';

// Enum values changed to lowerCamelCase
enum SortOptions { defaultSort, nameAZ, nameZA, priceLowHigh, priceHighLow }

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  SortOptions _selectedSort = SortOptions.defaultSort;

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  void initState() {
    super.initState();
    _refreshProducts(context);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    var products = productProvider.products;

    // Sorting logic updated to use new enum values
    if (_selectedSort == SortOptions.defaultSort) {
      products.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else if (_selectedSort == SortOptions.nameAZ) {
      products.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedSort == SortOptions.nameZA) {
      products.sort((a, b) => b.name.compareTo(a.name));
    } else if (_selectedSort == SortOptions.priceLowHigh) {
      products.sort((a, b) => a.ourPrice.compareTo(b.ourPrice));
    } else if (_selectedSort == SortOptions.priceHighLow) {
      products.sort((a, b) => b.ourPrice.compareTo(a.ourPrice));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fataak Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate:
                ProductSearchDelegate(products, productProvider),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProductEditScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<SortOptions>(
            onSelected: (SortOptions result) {
              setState(() {
                _selectedSort = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOptions>>[
              const PopupMenuItem<SortOptions>(
                value: SortOptions.defaultSort,
                child: Text('Default'),
              ),
              const PopupMenuItem<SortOptions>(
                value: SortOptions.nameAZ,
                child: Text('Name: A to Z'),
              ),
              const PopupMenuItem<SortOptions>(
                value: SortOptions.nameZA,
                child: Text('Name: Z to A'),
              ),
              const PopupMenuItem<SortOptions>(
                value: SortOptions.priceLowHigh,
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem<SortOptions>(
                value: SortOptions.priceHighLow,
                child: Text('Price: High to Low'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3.5,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (ctx, i) {
            final product = products[i];
            return ProductCard(product: product);
          },
        ),
      ),
    );
  }
}