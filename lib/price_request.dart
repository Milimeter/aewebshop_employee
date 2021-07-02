import 'dart:async';

import 'package:aewebshop/model/product.dart';
import 'package:aewebshop/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceRequest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text("P R I C E - R E Q U E S T",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('priceRequest')
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.docs.length == 0) {
                  return Center(child: Text("No order at the moment"));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      print(snapshot.data.docs[index].data());
                      print("===========================");
                      print(snapshot.data.docs[index].get("itemsInfo"));

                      return priceRequest(
                        customerName:
                            snapshot.data.docs[index].get("customerName"),
                        customerId: snapshot.data.docs[index].get("customerId"),
                        productName:
                            snapshot.data.docs[index].get("productName"),
                        productBrand:
                            snapshot.data.docs[index].get("productBrand"),
                        productId: snapshot.data.docs[index].get("productId"),
                        productModel:
                            snapshot.data.docs[index].get("productModel"),
                        productImage:
                            snapshot.data.docs[index].get("productImage"),
                      );
                    },
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  Widget priceRequest({
    String customerName,
    String customerId,
    String productName,
    String productBrand,
    String productId,
    String productModel,
    String productImage,
  }) {
    TextEditingController controller = TextEditingController();

    bool isNumericUsingRegularExpression(String string) {
      final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

      return numericRegex.hasMatch(string);
    }

    return Card(
      child: ExpansionTile(
        title: Text(
          productName,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        subtitle: Text("Click to send price to customer"),
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: "Send Price Feedback to user",
                      labelText: "Send Item price",
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange))),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (controller.text.isNotEmpty &&
                      isNumericUsingRegularExpression(controller.text.trim()) ==
                          true) {
                    showLoading();

                    addData(
                      customerId: customerId,
                      productId: productId,
                      customerName: customerName,
                      productName: productName,
                      productBrand: productBrand,
                      productImage: productImage,
                      price: controller.text.trim(),
                    );
                  } else {
                    Get.snackbar("Error", "Enter Numeric values");
                  }
                },
                icon: Icon(Icons.send, color: Colors.orange),
              ),
            ],
          )
        ],
      ),
    );
  }

  addData({
    String customerId,
    String productId,
    String customerName,
    String productName,
    String productBrand,
    String productImage,
    String price,
  }) {
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(customerId)
          .get()
          .then((value) {
        if (value.exists) {
          var cart = value.data()["cart"]; // gets the list of maps to local
          for (var map in cart) {
            if (map.containsKey("id")) {
              if (map["id"] == productId) {
                //looks for the productId
                // your list of map contains key "id" which has value of productId

                //delete the specific map from the local list
                cart.remove(map);
                //add the new map to the local list of maps
                cart.add({
                  "productId": productId,
                  "name": productName,
                  "quantity": 1,
                  "price": double.parse(price),
                  "image": productImage,
                  "cost": double.parse(price)
                });
                print(cart);
                // upload back to user cart
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(customerId)
                    .update({
                  "cart": cart,
                });
              }
              Timer(Duration(seconds: 3), () {
                dismissLoading();
              });
            }
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
