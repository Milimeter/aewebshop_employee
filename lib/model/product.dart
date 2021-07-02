import 'dart:convert';

class ProductDetailModel {
  String naziv;
  String marka;
  String model;
  String katBr;
  String id;
  String cijena;
  String kolicina;
  String lokacija;
  String opis;
  String image;
  String name;
  String brand;
  double price;
  List<String> images;
  ProductDetailModel({
    this.naziv,
    this.marka,
    this.model,
    this.katBr,
    this.id,
    this.cijena,
    this.kolicina,
    this.lokacija,
    this.opis,
    this.image,
    this.name,
    this.brand,
    this.price,
    this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'n': naziv,
      'm': marka,
      'mo': model,
      'kb': katBr,
      'id': id,
      'c': cijena,
      'ko': kolicina,
      'l': lokacija,
      'o': opis,
      'image': image,
      'name': name,
      'brand': brand,
      'price': price,
      'images': images,
    };
  }

  factory ProductDetailModel.fromMap(Map<String, dynamic> map) {
    return ProductDetailModel(
      naziv: map['n'],
      marka: map['m'],
      model: map['mo'],
      katBr: map['kb'],
      id: map['id'],
      cijena: map['c'],
      kolicina: map['ko'],
      lokacija: map['l'],
      opis: map['o'],
      image: List<String>.from(map['u'])[0],
      name: map['n'],
      brand: map['brand'],
      price: double.parse(map['c']),
      images: List<String>.from(map['u']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductDetailModel.fromJson(String source) =>
      ProductDetailModel.fromMap(json.decode(source));
}
