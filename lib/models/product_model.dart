import 'dart:convert';

class ProductModel {
  //inisialisasi variabel
  final String name;
  final String description;
  final int price;

  //constructor
  ProductModel({
    required this.name,
    required this.description,
    required this.price
  });

  //Merubah Objek ke Map
  Map<String, dynamic> toMap(){
    return{

      'name': name,
      'description': description,
      'price': price,
    };
    
  }

  //MAP ke Object
  factory ProductModel.fromMap(
  Map<String, dynamic> map,
  ){
    return ProductModel(
      name: map['name']?? '',
      description: map['description']?? '',
      price: map['price']?? 0,
    );
  }

  //Object ke json string
  String tojson() => jsonEncode(toMap());

  //json string ke objeck
  factory ProductModel.fromJson(String source){
    return ProductModel.fromMap(
      jsonDecode(source),
    );
  }

  
}