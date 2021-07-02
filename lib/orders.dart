import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HandleOrders extends StatelessWidget {
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
        title: Text("O R D E R S",
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
                .collection('orders')
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

                      return orderThread(
                        status: snapshot.data.docs[index].get("status"),
                        itemsInfo: snapshot.data.docs[index].get("itemsInfo"),
                        price: snapshot.data.docs[index].get("price") ??
                            "Click to send price to user",
                        orderId: snapshot.data.docs[index].get("orderId"),
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

  Widget orderThread(
      {String status, List itemsInfo, String price, String orderId}) {
    TextEditingController controller = TextEditingController();
    print(itemsInfo[0]["name"]);

    bool isNumericUsingRegularExpression(String string) {
      final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

      return numericRegex.hasMatch(string);
    }

    return Column(
      children: itemsInfo
          .map((item) => new Card(
                child: ExpansionTile(
                  title: Text(
                    item["name"],
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(price ?? "Click to send price to user"),
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
                                    borderSide:
                                        BorderSide(color: Colors.orange))),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty &&
                                isNumericUsingRegularExpression(
                                        controller.text.trim()) ==
                                    true) {
                              FirebaseFirestore.instance
                                  .collection("orders")
                                  .where("orderId", isEqualTo: orderId)
                                  .get()
                                  .then((value) {
                                var docId = value.docs.first.reference.id;
                                FirebaseFirestore.instance
                                    .collection("orders")
                                    .doc(docId)
                                    .update({
                                  "status": "confirmed",
                                  "price": "\$$value"
                                });
                              });
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
              ))
          .toList(),
    );
  }
}
