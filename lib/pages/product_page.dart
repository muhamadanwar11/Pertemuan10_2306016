import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pertemuan10_2306016/models/product_model.dart';
import 'package:pertemuan10_2306016/widgets/product_card.dart';
import 'product_detail_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productList
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((e) => e.toJson()).toList();
    await prefs.setStringList('products', productList);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil ditambahkan")),
    );
  }

  Future<void> updateProduct(int index, ProductModel updatedProduct) async {
    setState(() {
      products[index] = updatedProduct;
    });
    await saveProducts();
  }

  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Produk berhasil dihapus")));
  }

  Future<String> convertImageToBase64(XFile image) async {
    Uint8List bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  void showForm({ProductModel? product, int? index}) {
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? "",
    );
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? "",
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? "",
    );
    TextEditingController imgController = TextEditingController(
      text: product?.image ?? "",
    );

    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage(StateSetter setDialogState) async {
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              setDialogState(() {
                selectedImage = image;
                imgController.text = image.path;
              });
            }
          }

          Widget buildPreviewImage() {
            if (selectedImage != null) {
              return FutureBuilder<Uint8List>(
                future: selectedImage!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Image.memory(
                    snapshot.data!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              );
            }
            if (product?.image.isNotEmpty ?? false) {
              return Image.memory(
                base64Decode(product!.image),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              );
            }
            return const SizedBox.shrink();
          }

          return AlertDialog(
            title: Text(product == null ? "Tambah Produk" : "Edit Produk"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama"),
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
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(setDialogState),
                    icon: const Icon(Icons.image),
                    label: const Text("Pilih Gambar"),
                  ),
                  const SizedBox(height: 10),
                  buildPreviewImage(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () async {
                  String imageBase64 = product?.image ?? "";
                  if (selectedImage != null) {
                    imageBase64 = await convertImageToBase64(selectedImage!);
                  }

                  final newProduct = ProductModel(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    image: imageBase64,
                  );

                  if (product == null) {
                    addProduct(newProduct);
                  } else {
                    updateProduct(index!, newProduct);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produk", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => showForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Tambah Produk"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text("Belum ada produk"))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onDelete: () => deleteProduct(index),
                          onEdit: () =>
                              showForm(product: product, index: index),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
