import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({this.product, super.key});

  @override
  ProductEditScreenState createState() => ProductEditScreenState();
}

class ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _marketPrice;
  late double _ourPrice;
  late int _stock;
  late bool _isOutOfStock;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _marketPrice = widget.product?.marketPrice ?? 0.0;
    _ourPrice = widget.product?.ourPrice ?? 0.0;
    _stock = widget.product?.stock ?? 0;
    _isOutOfStock = widget.product?.isOutOfStock ?? false;
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final productProvider =
      Provider.of<ProductProvider>(context, listen: false);

      if (widget.product == null) {
        // Add new product
        productProvider.addProduct(
          Product(
            id: DateTime.now().toString(),
            name: _name,
            marketPrice: _marketPrice,
            ourPrice: _ourPrice,
            stock: _stock,
            isOutOfStock: _isOutOfStock,
          ),
        );
      } else {
        // Update existing product
        productProvider.updateProduct(
          Product(
            id: widget.product!.id,
            name: _name,
            marketPrice: _marketPrice,
            ourPrice: _ourPrice,
            stock: _stock,
            isOutOfStock: _isOutOfStock,
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _marketPrice.toString(),
                decoration: const InputDecoration(labelText: 'Market Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => _marketPrice = double.parse(value!),
              ),
              TextFormField(
                initialValue: _ourPrice.toString(),
                decoration: const InputDecoration(labelText: 'Our Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => _ourPrice = double.parse(value!),
              ),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter the stock' : null,
                onSaved: (value) => _stock = int.parse(value!),
              ),
              SwitchListTile(
                title: const Text('Out of Stock'),
                value: _isOutOfStock,
                onChanged: (value) {
                  setState(() {
                    _isOutOfStock = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}