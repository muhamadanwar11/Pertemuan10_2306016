import 'package:flutter/material.dart';
import 'package:pertemuan10_2306016/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<ProductModel> products =[];

  //===============
// loadd produk
//===============
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productsList = prefs.getStringList('products') ?? [];
        setState(() {
      products = productsList 
      .reversed
      .take(3)
      .map((item)=>ProductModel.fromJson(item))
      .toList();
    });
  }
  @override
  void initState() {
    super.initState();
       loadProducts();
  }

//===============
// save produk
//===============

  Future<void> saveProducts() async{
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((e) => e.tojson()).toList();
    await prefs.setStringList('products', productList);
  }

//adddd product
//======

  Future<void> addProduct(ProductModel product) async{
    setState(() {
      products.add(product);
    });
    await saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil ditambahkan")),
    );
  }

//update produk
//========

  Future<void> updateProduct(int index,ProductModel updatedProduct)async{
    setState(() {
      products[index]= updatedProduct;
    });
    await saveProducts();
  }

//delete produk
//======
  Future<void> deleteProduct(int index)async{
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil dihapus")),
    );
  }


void showForm({ProductModel? product, int? index}){
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? "");
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? "");
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? "Tambah Produk" : "Edit Produk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              if (product == null) {
                addProduct(
                  ProductModel(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: int.parse(priceController.text),
                  ),
                );
              } else {
                updateProduct(
                  index!,
                  ProductModel(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: int.parse(priceController.text),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("produk", style: TextStyle (color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(
           Icons.chevron_left,
           color: Colors.white,
        ),
      ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                    onPressed: () => showForm(),
                    child: const Text("Tambah Product"),
                  ),
                  ),
                ],
              )
          ],
        ),
          
      ),
       
    );
  }
}