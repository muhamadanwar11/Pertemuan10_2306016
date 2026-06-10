import 'package:flutter/material.dart';
import 'package:pertemuan10_2306016/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";

  //variabel utama dari daftar produk
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    getUser();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productsList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productsList 
      .map((item)=>ProductModel.fromJson(item))
      .toList();
    });
  }

  Future<void> saveProducts() async{
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((e) => e.tojson()).toList();
    await prefs.setStringList('products', productList);
  }

  Future<void> addProduct(ProductModel product) async{
    setState(() {
      products.add(product);
    });
    await saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil ditambahkan")),
    );
  }

  Future<void> updateProduct(int index,ProductModel updatedProduct)async{
    setState(() {
      products[index]= updatedProduct;
    });
    await saveProducts();
  }

  Future<void> deleteProduct(int index)async{
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil dihapus")),
    );
  }

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
    });
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 249, 250, 250),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.teal,
                      backgroundImage: const NetworkImage("https://picsum.photos/seed/picsum/450/300"),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "hii,selamat datang $username",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await logout();
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text("Belum ada produk"))
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ), 
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ), 
                              ), 
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text("Rp ${product.price}"),
                                  const SizedBox(height: 5),
                                  Text(product.description),
                                ],
                              ), 
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ), 
                                onPressed: () => showForm(product: products[index], index: index),
                              ), 
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ), 
                                onPressed: () => deleteProduct(index),
                              ), 
                            ), 
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}