import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:core';
import 'package:aewebshop/orders.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
/*
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
*/
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.bottomToTop,
                child: HomeScreen(),
                duration: Duration(milliseconds: 900))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 80.0),
                      ),
                      new Image.asset('assets/img/aelogo.png',
                          height: 180, width: 180),
                    ],
                  ))),
              Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.red[800])),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Padding(
                        padding: const EdgeInsets.only(top: 70.0),
                        child: Text("www.aecompany.ba",
                            style: TextStyle(
                              color: Colors.red[800],
                            )),
                      )
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Image.asset('assets/img/aelogo.png', height: 180, width: 180),
          SizedBox(height: 100),
          RaisedButton(
            child: Text("Unos novog artikla",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ImageUpload()));
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.red[800])),
            elevation: 5.0,
            color: Colors.red[800],
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            splashColor: Colors.grey,
          ),
          SizedBox(height: 20.0),
          RaisedButton(
            child: Text("Pregled svih artikala",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            onPressed: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PregledArtikala()));
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.red[800])),
            elevation: 5.0,
            color: Colors.red[800],
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            splashColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  String _chosenValue;
  String _chosenValue2;

  TextEditingController tcnaziv = new TextEditingController();
  TextEditingController tcsifra = new TextEditingController();
  TextEditingController tccijena = new TextEditingController();
  TextEditingController tckatBr = new TextEditingController();
  TextEditingController tcmarka = new TextEditingController();
  TextEditingController tcmodel = new TextEditingController();
  TextEditingController tckat = new TextEditingController();
  TextEditingController tcvrijeme = new TextEditingController();
  TextEditingController tclokacija = new TextEditingController();
  TextEditingController tcopis = new TextEditingController();
  TextEditingController tckolicina = new TextEditingController();

  bool uploading = false;
  double val = 0;
  firebase_storage.Reference ref;

  List<File> _image = [];
  final picker = ImagePicker();
  List<String> imageUrl = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Unos novog artikla',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Get.to(HandleOrders()),
            icon: Icon(
              Icons.notification_add,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: tcnaziv,
                decoration: InputDecoration(
                  labelText: "Unesite naziv dijela",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                    border: Border.all(color: Colors.red[800], width: 1.5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    focusColor: Colors.white,
                    value: _chosenValue,
                    //elevation: 5,
                    style: TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.black,
                    items: <String>[
                      'Alfa Romeo',
                      'Audi',
                      'BMW',
                      'Mercedes',
                      'Opel',
                      'Seat',
                      'Volkswagen',
                      'Honda',
                      'Hyundai',
                      'KIA',
                      'Renault',
                      'Peugeot',
                      'Dacia',
                      'Citroen',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            value,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                    hint: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "Izaberite marku vozila",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    onChanged: (String value) {
                      setState(() {
                        _chosenValue = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: tcmodel,
                decoration: InputDecoration(
                  labelText: "Unesite model vozila",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: tckatBr,
                decoration: InputDecoration(
                  labelText: "Unesite kataloški broj dijela",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                    border: Border.all(color: Colors.red[800], width: 1.5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    focusColor: Colors.white,
                    value: _chosenValue2,
                    //elevation: 5,
                    style: TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.black,
                    items: <String>[
                      'ABS sistemi',
                      'Airbagovi',
                      'Akumulatori',
                      'Alnaseri',
                      'Alternatori',
                      'Amortizeri i opruge',
                      'Automobili u dijelvima',
                      'Autokozmetika',
                      'Auto klime',
                      'Branici karambolke i spojleri',
                      'Brave za paljenje i kljucevi',
                      'Blatobrani',
                      'Brisaci',
                      'Bobine',
                      'Bregaste osovine',
                      'CD\/DVD\/MC\/Radio player',
                      'Crijeva',
                      'Cepovi za felge',
                      'Dizne',
                      'Diskovi\/Plocice',
                      'Diferencijali',
                      'Dobosi tocka\/kocioni',
                      'Displej',
                      'Elektronika i Akustika',
                      'Farovi',
                      'Felge s gumama',
                      'Felge',
                      'Filteri',
                      'Gume',
                      'Glavcine',
                      'Glavamotora',
                      'Grijaci',
                      'Hladnjaci',
                      'Haube',
                      'Instrument table',
                      'Izduvni sistemi',
                      'Kilometar satovi',
                      'Kocioni cilindri',
                      'Kompresori',
                      'Kvacila i dijelovi istih',
                      'Kablovi i konektori',
                      'Karteri',
                      'Kineticki zglobovi',
                      'Kardan',
                      'Kozice mjenjaca',
                      'Krajnice',
                      'Karburatori',
                      'Kederi',
                      'Klipovi',
                      'Kuciste osiguraca',
                      'Limarija',
                      'Letve volana',
                      'Lajsne i pragovi',
                      'Lafete',
                      'Lazajevi',
                      'Lamele',
                      'Motori',
                      'Mjenjaci',
                      'Maske',
                      'Maglenke',
                      'Motorici i klapne grijanja',
                      'Nosaci motora\/mjenjaca',
                      'Navigacija\/GPS',
                      'Nosaci i koferi',
                      'Naslonjaci',
                      'Osovine\/Mostovi',
                      'Ostalo',
                      'Prekidaci',
                      'Pumpe',
                      'Podizaci stakala',
                      'Plastika',
                      'Patosnice\/Podmetaci',
                      'Posude za tecnosti',
                      'Papucice',
                      'Protokomjeri zraka',
                      'Pakne',
                      'Pojasevi sigurnosni',
                      'Retrovizori',
                      'Ratkape',
                      'Remenovi',
                      'Rucice mjenjaca',
                      'Releji',
                      'Rezervoari',
                      'Rucice brisaca - zmigavaca - tempomat',
                      'Razni prekidaci',
                      'Radio i oprema',
                      'Sajbe i prozori',
                      'Senzori',
                      'Sijalice',
                      'Sjedista',
                      'Spaneri\/Remenice',
                      'Sajle',
                      'Stabilizatori',
                      'Stopke',
                      'Spulne',
                      'Turbine',
                      'Tuning',
                      'Tapacirung',
                      'Termostati',
                      'Unutrasnji izgled',
                      'Usisne grane',
                      'Vrata',
                      'Ventilatori',
                      'Volani',
                      'Ventili',
                      'Zmigavci',
                      'Znakovi',
                      'Zvucnici',
                      'Zamajci',
                    ].map<DropdownMenuItem<String>>((String value2) {
                      return DropdownMenuItem<String>(
                        value: value2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            value2,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                    hint: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "Izaberite kategoriju dijela",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    onChanged: (String value2) {
                      setState(() {
                        _chosenValue2 = value2;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Stack(
              children: [
                Container(
                  height: 250,
                  padding: EdgeInsets.all(4),
                  child: GridView.builder(
                      itemCount: _image.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Center(
                                child: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () =>
                                        !uploading ? chooseImage() : null),
                              )
                            : Container(
                                margin: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(_image[index - 1]),
                                        fit: BoxFit.cover)),
                              );
                      }),
                ),
                uploading
                    ? Center(
                        child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.grey, spreadRadius: 1),
                          ],
                        ),
                        width: 300,
                        height: 100,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Uploadovanje slika...',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            CircularProgressIndicator(
                              value: val,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red[800]),
                            )
                          ],
                        ),
                      ))
                    : Container(),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 90, right: 90),
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    uploading = true;
                  });
                  final snackBar =
                      SnackBar(content: Text('Slike su uspješno postavljene.'));
                  uploadFile().whenComplete(() =>
                      ScaffoldMessenger.of(context).showSnackBar(snackBar));
                },
                child: Text('Upload slika',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    )),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.red[800])),
                elevation: 5.0,
                color: Colors.red[800],
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                splashColor: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 70, right: 70),
              child: RaisedButton(
                child: Text("Dalje",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Scaffold(
                                backgroundColor: Colors.white,
                                appBar: AppBar(
                                  leading: IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    color: Colors.black,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  title: Text(
                                    'Unos novog artikla',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  centerTitle: true,
                                  elevation: 0.0,
                                  backgroundColor: Colors.white,
                                ),
                                body: Container(
                                  color: Colors.white,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 40.0,
                                              right: 40.0,
                                              top: 20.0),
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.black),
                                            controller: tclokacija,
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Unesite lokaciju dijela",
                                              labelStyle: TextStyle(
                                                  color: Colors.black),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 40.0,
                                              right: 40.0,
                                              top: 20.0),
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.black),
                                            controller: tcopis,
                                            decoration: InputDecoration(
                                              labelText: "Unesite opis dijela",
                                              labelStyle: TextStyle(
                                                  color: Colors.black),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 40.0,
                                              right: 40.0,
                                              top: 20.0),
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.black),
                                            controller: tckolicina,
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Unesite količinu dijela",
                                              labelStyle: TextStyle(
                                                  color: Colors.black),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 40.0,
                                              right: 40.0,
                                              top: 20.0),
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.black),
                                            controller: tccijena,
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Unesite cijenu dijela",
                                              labelStyle: TextStyle(
                                                  color: Colors.black),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide(
                                                    color: Colors.red[800],
                                                    width: 1.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: RaisedButton(
                                            child: Text(
                                                "Postavi artikal na OLX",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                            onPressed: () async {
                                              String postNaziv =
                                                  jsonEncode(tcnaziv.text);
                                              String postMarka =
                                                  jsonEncode(_chosenValue);
                                              String postKat =
                                                  jsonEncode(_chosenValue2);
                                              String postModel =
                                                  jsonEncode(tcmodel.text);
                                              String postKatbr =
                                                  jsonEncode(tckatBr.text);
                                              String postLok =
                                                  jsonEncode(tclokacija.text);
                                              String postOpis =
                                                  jsonEncode(tcopis.text);
                                              String postKol =
                                                  jsonEncode(tckolicina.text);
                                              double cijena = double.tryParse(
                                                  tccijena.text);
                                              print(cijena);
                                              String postCijena =
                                                  jsonEncode(cijena);
                                              int kategorija = 18;
                                              int grad = 3892;
                                              int vozilo = 75;

                                              Map<String, dynamic> body;
                                              //String postUrl = jsonEncode(imageUrl.toString());

                                              body = {
                                                "naslov": jsonDecode(postNaziv),
                                                "kategorija_id": kategorija,
                                                "vozilo_model": vozilo,
                                                "grad_id": grad,
                                                "cijena": cijena,
                                                //"slike" : imageUrl,
                                                "interna_sifra":
                                                    jsonDecode("112256666")
                                              };

                                              print(body);

                                              var olxurl =
                                                  "https://www.olx.ba/api/artikli/snimi";

                                              Uri url = Uri.parse(olxurl);

                                              final http.Response response =
                                                  await http.post(url,
                                                      headers: {
                                                        "OLX-CLIENT-ID":
                                                            '5820852085199',
                                                        "OLX-CLIENT-TOKEN":
                                                            'D4Ffjs95fSdkg59djsoZy9SG9335',
                                                        "Content-type":
                                                            'application/json'
                                                      },
                                                      body: jsonEncode(body));
                                              print(response.statusCode);
                                            },
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                side: BorderSide(
                                                    color: Colors.red[800])),
                                            elevation: 5.0,
                                            color: Colors.red[800],
                                            textColor: Colors.white,
                                            padding: EdgeInsets.fromLTRB(
                                                15, 15, 15, 15),
                                            splashColor: Colors.grey,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: RaisedButton(
                                            child: Text(
                                                "Unos artikla u bazu podataka",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                            onPressed: () async {
                                              String postNaziv =
                                                  jsonEncode(tcnaziv.text);
                                              String postMarka =
                                                  jsonEncode(_chosenValue);
                                              String postKat =
                                                  jsonEncode(_chosenValue2);
                                              String postModel =
                                                  jsonEncode(tcmodel.text);
                                              String postKatbr =
                                                  jsonEncode(tckatBr.text);
                                              String postLok =
                                                  jsonEncode(tclokacija.text);
                                              String postOpis =
                                                  jsonEncode(tcopis.text);
                                              String postKol =
                                                  jsonEncode(tckolicina.text);
                                              String postCijena =
                                                  jsonEncode(tccijena.text);

                                              String defaultImg =
                                                  "https://firebasestorage.googleapis.com/v0/b/ae-dijelovi-d060e.appspot.com/o/aelogo.png?alt=media&token=70e7b42b-73fa-46b7-b965-3e77d2b0cfef";

                                              Map<String, dynamic> body;
                                              //String postUrl = jsonEncode(imageUrl.toString());
                                              if (imageUrl.isEmpty) {
                                                imageUrl.add(defaultImg);
                                              }

                                              body = {
                                                "n": jsonDecode(postNaziv),
                                                "s_name": jsonDecode(
                                                    postNaziv.toLowerCase()),
                                                "s_model": jsonDecode(
                                                    postMarka.toLowerCase()),
                                                "c": jsonDecode(postCijena),
                                                "k": jsonDecode(postKat),
                                                "m": jsonDecode(postMarka),
                                                //"img" : jsonDecode(postUrl),
                                                "mo": jsonDecode(postModel),
                                                "s_brand": jsonDecode(
                                                    postModel.toLowerCase()),
                                                "kb": jsonDecode(postKatbr),
                                                "s_catalogue":
                                                    jsonDecode(postKatbr),
                                                "l": jsonDecode(postLok),
                                                "o": jsonDecode(postOpis),
                                                "ko": jsonDecode(postKol),
                                                "u":
                                                    imageUrl //Pass String Array Here
                                              };

                                              print("==>>> FS ADD INITATED \n" +
                                                  body.toString());
                                              print("=> Added at line 784");
                                              FirebaseFirestore.instance
                                                  .collection('artikli')
                                                  .add(body);
                                              print(body);

                                              if (tcnaziv.text == "" ||
                                                  tcmodel.text == "" ||
                                                  tccijena.text == "") {
                                                Alert(
                                                  context: context,
                                                  title: "Popunite sva polja.",
                                                  buttons: [
                                                    DialogButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      color: Colors.red[800],
                                                      child: Center(
                                                          child: Text(
                                                        "Nazad",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                    )
                                                  ],
                                                  style: AlertStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      titleStyle: TextStyle(
                                                          color: Colors.black)),
                                                ).show();
                                              } else {
                                                try {
                                                  final result =
                                                      await InternetAddress
                                                          .lookup('google.com');
                                                  if (result.isNotEmpty &&
                                                      result[0]
                                                          .rawAddress
                                                          .isNotEmpty)
                                                    //FirebaseFirestore.instance.collection('artikli').add(body);
                                                    Alert(
                                                      context: context,
                                                      title:
                                                          "Artikal uspješno unesen.",
                                                      buttons: [
                                                        DialogButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          color:
                                                              Colors.red[800],
                                                          child: Center(
                                                              child: Text(
                                                            "Nazad",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                        )
                                                      ],
                                                      style: AlertStyle(
                                                          backgroundColor:
                                                              Colors.white,
                                                          titleStyle: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                    ).show();
                                                } on SocketException catch (_) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: Text(
                                                                "Problem s konekcijom!"),
                                                            content: Text(
                                                                "Provjerite vašu internet konekciju."),
                                                          ));
                                                }
                                              }

                                              //var firebaseurl = "https://frizerski-58338-default-rtdb.firebaseio.com/artikli/${tckatBr.text}.json";

                                              //Uri url = Uri.parse(firebaseurl);
                                              //Uri url = Uri.parse(fireString postNaziv = jsonEncode(tcnaziv.textbaseurl);

                                              //final http.Response response = await http.put(url,headers: {"Content-type": 'application/json'}, body : jsonEncode(body));
                                            },
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                side: BorderSide(
                                                    color: Colors.red[800])),
                                            elevation: 5.0,
                                            color: Colors.red[800],
                                            textColor: Colors.white,
                                            padding: EdgeInsets.fromLTRB(
                                                15, 15, 15, 15),
                                            splashColor: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )));
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.red[800])),
                elevation: 5.0,
                color: Colors.red[800],
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                splashColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  chooseImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image.add(File(pickedFile?.path));
    });
    if (pickedFile.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file.path));
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    int i = 1;

    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${img.path}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          print(value);
          imageUrl.add(value.toString());
          i++;
        });
      });
    }

    uploading = false;
    setState(() {});
  }
}

class PregledArtikala extends StatefulWidget {
  @override
  _PregledArtikalaState createState() => _PregledArtikalaState();
}

class _PregledArtikalaState extends State<PregledArtikala> {
  //PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  bool isSearching = false;
  var firebase =
      "https://frizerski-58338-default-rtdb.firebaseio.com/artikli.json";
  var hrana;
  bool isSearchtext = true;
  String searchtext = "";
  List<String> itemlist = [
    'Part Name',
    'Catalogue Number',
    'Car Brand',
    'Car Model'
  ];
  String selectedItem = "Part Name";
  String searchhint = "Search by Part Name";
  TextEditingController searchtextEditingController =
      new TextEditingController();

  get documentSnapshot => null;

  List<DocumentSnapshot> products = []; // stores fetched products

  bool isLoading = false; // track if products fetching

  bool hasMore = true; // flag for more products available or not

  int documentLimit = 10; // documents to be fetched per request

  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched

  bool addedLastDoc = false;
  bool queryInitiated = false;

  ScrollController _scrollController =
      ScrollController(); // listener for listview scrolling
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    //fetchData();
    //fetchDataFromFireStore();
    getProducts(searchtextEditingController.text.trim(), 's_name', false);

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        String searchBy = "s_name";
        if (selectedItem == "Catalogue Number") {
          searchBy = "s_catalogue";
        } else if (selectedItem == "Car Brand") {
          searchBy = "s_model";
        } else if (selectedItem == "Car Model") {
          searchBy = "s_brand";
        }
        addedLastDoc = false;
        getProducts(searchtextEditingController.text.trim(), searchBy, false);
      }
    });
  }

  getProducts(
      String search_text, String search_type, bool hasSearchChanged) async {
    print("=============================================================");
    print("search text => " + search_text);
    print("search type => " + search_type);
    QuerySnapshot querySnapshot;

    if (search_text.length == 0) {
      if (!hasMore) {
        print('No More Products');
        return;
      }
      if (isLoading) {
        return;
      }
      setState(() {
        isLoading = true;
      });

      if (hasSearchChanged) {
        products = [];
      }
      if (lastDocument == null) {
        print('Initial DOC');
        if (_chosenValue == 'All') {
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .orderBy('s_name')
              .limit(documentLimit)
              .get();
        } else {
          print("CHOOSEN VALUE 1 => " + _chosenValue);
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .where('k', isEqualTo: _chosenValue)
              .orderBy('s_name')
              .limit(documentLimit)
              .get();
        }
      } else {
        print('Pagination DOC');
        if (_chosenValue == 'All') {
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .orderBy('s_name')
              .limit(documentLimit)
              .startAfterDocument(lastDocument)
              .get();
        } else {
          print("CHOOSEN VALUE 2 => " + _chosenValue);
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .where('k', isEqualTo: _chosenValue)
              .orderBy('s_name')
              .limit(documentLimit)
              .startAfterDocument(lastDocument)
              .get();
        }
      }
    } else {
      if (hasSearchChanged) {
        lastDocument = null;
        products = [];
      } else {
        setState(() {
          isLoading = true;
        });
      }
      if (lastDocument == null) {
        print('SEARCH: Initial DOC');
        if (_chosenValue == 'All') {
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .where(search_type,
                  isGreaterThanOrEqualTo: search_text.toLowerCase())
              .where(search_type,
                  isLessThanOrEqualTo: search_text.toLowerCase() + 'z')
              .orderBy(search_type)
              .limit(documentLimit)
              .get();
        } else {
          print("CHOOSEN VALUE 3 => " + _chosenValue);
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .where(search_type,
                  isGreaterThanOrEqualTo: search_text.toLowerCase())
              .where(search_type,
                  isLessThanOrEqualTo: search_text.toLowerCase() + 'z')
              .where('k', isEqualTo: _chosenValue)
              .orderBy(search_type)
              .limit(documentLimit)
              .get();
        }
      } else {
        print('SEARCH: Pagination DOC');
        if (_chosenValue == 'All') {
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .where(search_type,
                  isGreaterThanOrEqualTo: search_text.toLowerCase())
              .where(search_type,
                  isLessThanOrEqualTo: search_text.toLowerCase() + 'z')
              .orderBy(search_type)
              .limit(documentLimit)
              .startAfterDocument(lastDocument)
              .get();
        } else {
          print("CHOOSEN VALUE 4 => " + _chosenValue);
          queryInitiated = true;
          querySnapshot = await firestore
              .collection('artikli')
              .where(search_type,
                  isGreaterThanOrEqualTo: search_text.toLowerCase())
              .where(search_type,
                  isLessThanOrEqualTo: search_text.toLowerCase() + 'z')
              .where('k', isEqualTo: _chosenValue)
              .orderBy(search_type)
              .limit(documentLimit)
              .startAfterDocument(lastDocument)
              .get();
        }
      }
    }

    /*if (lastDocument == null) {
      print('Initial DOC');
      querySnapshot = await firestore
          .collection('artikli')
          //.where(search_type, isGreaterThanOrEqualTo: search_text).where(search_type, isLessThanOrEqualTo: search_text+'z')
          .orderBy(search_type)
          .limit(documentLimit)
          .get();
    } else {
      print('Pagination DOC');
      querySnapshot = await firestore
          .collection('artikli').where(search_type, isGreaterThanOrEqualTo: search_text).where(search_type, isLessThanOrEqualTo: search_text+'z')
          .orderBy(search_type)
          .limit(documentLimit)
          .startAfterDocument(lastDocument)
          .get();
    }*/
    var articleArray = querySnapshot.docs;
    if (articleArray.length < documentLimit) {
      hasMore = false;
      //lastDocument = null;
    }
    if (articleArray.length > 0 && !addedLastDoc) {
      print("Added LAST DOCUMENT");
      addedLastDoc = true;
      lastDocument = articleArray[articleArray.length - 1];

      if (queryInitiated) {
        print("Adding All ITEM ==> BEFORE :" + products.length.toString());
        products.addAll(articleArray);
        print("AFTER :" + products.length.toString());
        queryInitiated = false;
      }
    }

    if (products.length == 0 && queryInitiated) {
      print("Adding All ITEM ==> BEFORE :" + products.length.toString());
      products.addAll(articleArray);
      print("AFTER :" + products.length.toString());

      print("Added LAST DOCUMENT");
      addedLastDoc = true;
      lastDocument = articleArray[articleArray.length - 1];

      queryInitiated = false;
    }

    setState(() {
      isLoading = false;
    });
  }

  String _chosenValue = 'All';

  @override
  void dispose() {
    super.dispose();
  }

  onSearchTextchanged(String value) async {
    print("Inside ONCHANGE => " + value);
    String searchBy = "s_name";
    searchtext = value;
    if (searchtext.length == 0) {
      //Refresh all data
      isSearching = false;
      hasMore = true;
    } else {
      isSearching = true;
      //Query based on keyword
      if (selectedItem == "Catalogue Number") {
        searchBy = "s_catalogue";
      } else if (selectedItem == "Car Brand") {
        searchBy = "s_model";
      } else if (selectedItem == "Car Model") {
        searchBy = "s_brand";
      }
    }
    products = [];
    addedLastDoc = true;
    getProducts(value, searchBy, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Pregled artikala',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Center(
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Text('Izaberite vrstu pretrage'),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: Container(
                width: 312.727,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                    border: Border.all(color: Colors.red[800], width: 1.5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    focusColor: Colors.white,
                    value: _chosenValue,
                    //elevation: 5,
                    style: TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.black,
                    items: <String>[
                      'All',
                      'ABS sistemi',
                      'Airbagovi',
                      'Akumulatori',
                      'Alnaseri',
                      'Alternatori',
                      'Amortizeri i opruge',
                      'Automobili u dijelvima',
                      'Autokozmetika',
                      'Auto klime',
                      'Branici karambolke i spojleri',
                      'Brave za paljenje i kljucevi',
                      'Blatobrani',
                      'Brisaci',
                      'Bobine',
                      'Bregaste osovine',
                      'CD\/DVD\/MC\/Radio player',
                      'Crijeva',
                      'Cepovi za felge',
                      'Dizne',
                      'Diskovi\/Plocice',
                      'Diferencijali',
                      'Dobosi tocka\/kocioni',
                      'Displej',
                      'Elektronika i Akustika',
                      'Farovi',
                      'Felge s gumama',
                      'Felge',
                      'Filteri',
                      'Gume',
                      'Glavcine',
                      'Glavamotora',
                      'Grijaci',
                      'Hladnjaci',
                      'Haube',
                      'Instrument table',
                      'Izduvni sistemi',
                      'Kilometar satovi',
                      'Kocioni cilindri',
                      'Kompresori',
                      'Kvacila i dijelovi istih',
                      'Kablovi i konektori',
                      'Karteri',
                      'Kineticki zglobovi',
                      'Kardan',
                      'Kozice mjenjaca',
                      'Krajnice',
                      'Karburatori',
                      'Kederi',
                      'Klipovi',
                      'Kuciste osiguraca',
                      'Limarija',
                      'Letve volana',
                      'Lajsne i pragovi',
                      'Lafete',
                      'Lazajevi',
                      'Lamele',
                      'Motori',
                      'Mjenjaci',
                      'Maske',
                      'Maglenke',
                      'Motorici i klapne grijanja',
                      'Nosaci motora\/mjenjaca',
                      'Navigacija\/GPS',
                      'Nosaci i koferi',
                      'Naslonjaci',
                      'Osovine\/Mostovi',
                      'Ostalo',
                      'Prekidaci',
                      'Pumpe',
                      'Podizaci stakala',
                      'Plastika',
                      'Patosnice\/Podmetaci',
                      'Posude za tecnosti',
                      'Papucice',
                      'Protokomjeri zraka',
                      'Pakne',
                      'Pojasevi sigurnosni',
                      'Retrovizori',
                      'Ratkape',
                      'Remenovi',
                      'Rucice mjenjaca',
                      'Releji',
                      'Rezervoari',
                      'Rucice brisaca - zmigavaca - tempomat',
                      'Razni prekidaci',
                      'Radio i oprema',
                      'Sajbe i prozori',
                      'Senzori',
                      'Sijalice',
                      'Sjedista',
                      'Spaneri\/Remenice',
                      'Sajle',
                      'Stabilizatori',
                      'Stopke',
                      'Spulne',
                      'Turbine',
                      'Tuning',
                      'Tapacirung',
                      'Termostati',
                      'Unutrasnji izgled',
                      'Usisne grane',
                      'Vrata',
                      'Ventilatori',
                      'Volani',
                      'Ventili',
                      'Zmigavci',
                      'Znakovi',
                      'Zvucnici',
                      'Zamajci',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            value,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                    hint: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "Izaberite kategoriju dijela",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    onChanged: (String value) {
                      setState(() {
                        _chosenValue = value;
                        print(_chosenValue);
                        addedLastDoc = true;
                        getProducts("", "", true);
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                    border: Border.all(color: Colors.red[800], width: 1.5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    hint: Text('Please choose a type'),
                    isExpanded: true,
                    isDense: false,
                    iconEnabledColor: Colors.black,
                    underline: SizedBox(),
                    value: selectedItem,
                    onChanged: (newValue) {
                      setState(() {
                        selectedItem = newValue;
                        if (selectedItem == "Part Name") {
                          searchhint = "Pretraživanje po nazivu...";
                        } else if (selectedItem == "Catalogue Number") {
                          searchhint = "Pretraživanje po kat. broju...";
                        } else if (selectedItem == "Car Brand") {
                          searchhint = "Pretraživanje po brendu...";
                        } else if (selectedItem == "Car Model") {
                          searchhint = "Pretraživanje po modelu...";
                        }
                        print(selectedItem);
                        searchtextEditingController.text = "";
                      });
                    },
                    items: itemlist.map((location) {
                      return DropdownMenuItem(
                        child: new Container(
                          child: Text(
                            location,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        value: location,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(6))),
              margin: EdgeInsets.only(left: 10, right: 10),
              child: ListTile(
                contentPadding:
                    EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                //contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 0.0),
                dense: true,
                horizontalTitleGap: -5.0,
                leading: Icon(Icons.search, color: Colors.grey, size: 24),
                title: TextField(
                  controller: searchtextEditingController,
                  maxLines: 1,
                  cursorColor: Colors.grey,
                  enabled: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: searchhint,
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  onSubmitted: (value) {
                    print("ON SUBMIT EVENT");
                    if (searchtext != value) {
                      onSearchTextchanged(value);
                    }
                  },
                  onChanged: (value) async {},
                  //onSubmitted: onSearchTextchanged,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                trailing: searchtext.toString().trim().length > 0
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            searchtextEditingController.clear();
                            print("ON TAP EVENT");
                            onSearchTextchanged('');
                            searchtext = "";
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 24,
                        ),
                      )
                    : SizedBox(),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: //RefreshIndicator ( child:
                /*PaginateFirestore(
            //item builder type is compulsory.
            itemBuilderType: PaginateBuilderType.gridView, //Change types accordingly
            itemBuilder: (index, context, documentSnapshot) */ /*=> ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text("${documentSnapshot.id}"),
          subtitle: Text(documentSnapshot.id),
        )*/ /*{
              String title = "ABCD";
              String Sub_title = "ABCD";
              String image_url = "";
              if(documentSnapshot is DocumentSnapshot){
                title = documentSnapshot.get("n");
                Sub_title = documentSnapshot.get("m");

                List<String> array_list = List.from(documentSnapshot.get("u"));
                if (array_list != null && array_list.length > 0){
                  image_url = array_list[0];
                } else {
                }
              }
              return InkWell(
                child: Container(
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height : 10),
                      Container(height: 50, child:
                      CachedNetworkImage(
                        imageUrl: image_url,
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            SpinKitFadingCircle(
                              color: Colors.red,
                              size: 20,
                            ),
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),),
                      // FadeInImage(
                      //   placeholder: AssetImage("assets/img/car.png"),
                      //   image: NetworkImage(image_url),
                      //   fit: BoxFit.cover,
                      // ),),
                      SizedBox(height : 10),
                      // Text("${image_url}",
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     color : Colors.black,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 17.0,
                      //   ),),
                      Text("${title}",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                        ),),
                      SizedBox(height : 5),
                      Text("${Sub_title}",style: TextStyle(color : Colors.black, fontWeight : FontWeight.bold),)
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15)),
                ),
                onTap: (){
                  print("Item Tapped $index");
                  String allDetails = "Part Name: " + documentSnapshot.get("n") + "\nm: " + documentSnapshot.get("m")
                      + "\nCar Brand: " + documentSnapshot.get("m0") + "\nCatalogue Number: " + documentSnapshot.get("kb").toString()
                      + "\nb: " + documentSnapshot.get("b").toString() + "\nc: " + documentSnapshot.get("c").toString()
                      + "\ni: " + documentSnapshot.get("i").toString() + "\nid: " + documentSnapshot.get("id").toString()
                      + "\nk: " + documentSnapshot.get("k").toString() + "\nko: " + documentSnapshot.get("ko").toString()
                      + "\nl: " + documentSnapshot.get("l").toString() + "\no: " + documentSnapshot.get("o").toString()
                      + "\ns: " + documentSnapshot.get("s").toString() + "\nv: " + documentSnapshot.get("v").toString();
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(title),
                      content: Text(allDetails),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'DELETE');
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this article?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context, 'Yes');

                                      //Query Firestore to delete the part
                                      print("Delete Part at $index");
                                      await FirebaseFirestore.instance.runTransaction((transaction) async
                                      {
                                        DocumentReference doc = await FirebaseFirestore.instance.collection('artikli').doc(documentSnapshot.id);
                                        transaction.delete(doc);
                                      });
                                    },
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'No'),
                                    child: const Text('No'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('DELETE'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'CLOSE'),
                          child: const Text('CLOSE'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            itemsPerPage: 20,
            // orderBy is compulsory to enable pagination
            query: FirebaseFirestore.instance
                .collection('artikli')
                .where("m0", isGreaterThanOrEqualTo : "au")
                .where("m0", isLessThanOrEqualTo : "au" + '\uf8ff'),
              */ /*isSearching ? FirebaseFirestore.instance
                .collection('artikli')
                .where(selectedItem == "Catalogue Number" ? "kb" : (selectedItem == "Car Brand" ? "m0" : "n"), isGreaterThanOrEqualTo: searchtext.toLowerCase())
                .where(selectedItem == "Catalogue Number" ? "kb" : (selectedItem == "Car Brand" ? "m0" : "n"), isLessThanOrEqualTo: searchtext.toLowerCase() + '\uf8ff')
                : FirebaseFirestore.instance.collection('artikli'),*/ /*
            listeners: [
              refreshChangeListener,
            ],
            // to fetch real-time data
            isLive: true,
          )*/
                Column(children: [
              Expanded(
                  child: products.length == 0
                      ? Center(
                          child: isLoading
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(5),
                                  //color: Colors.yellowAccent,
                                  child: SpinKitFadingCircle(
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                )
                              : Text('No Data to display!'),
                        )
                      : GridView.count(
                          controller: _scrollController,
                          crossAxisCount: 2,
                          children: new List<Widget>.generate(products.length,
                              (index) {
                            String title = products[index].get("n");
                            String Sub_title = products[index].get("m");
                            String image_url = "";
                            List<String> array_list =
                                List.from(products[index].get("u"));
                            if (array_list != null && array_list.length > 0) {
                              image_url = array_list[0];
                            }
                            return InkWell(
                              child: Container(
                                margin: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      height: 80,
                                      child: CachedNetworkImage(
                                        imageUrl: image_url,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                SpinKitFadingCircle(
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                    // FadeInImage(
                                    //   placeholder: AssetImage("assets/img/car.png"),
                                    //   image: NetworkImage(image_url),
                                    //   fit: BoxFit.cover,
                                    // ),),
                                    SizedBox(height: 10),
                                    // Text("${image_url}",
                                    //   textAlign: TextAlign.center,
                                    //   style: TextStyle(
                                    //     color : Colors.black,
                                    //     fontWeight: FontWeight.bold,
                                    //     fontSize: 17.0,
                                    //   ),),
                                    Text(
                                      "${title}",
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "${Sub_title}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              onTap: () {
                                String naziv =
                                    products[index].get("n").toString();
                                String marka =
                                    products[index].get("m").toString();
                                String model =
                                    products[index].get("mo").toString();
                                String katBr =
                                    products[index].get("kb").toString();
                                String cijena =
                                    products[index].get("c").toString();
                                String kolicina =
                                    products[index].get("ko").toString();
                                String lokacija =
                                    products[index].get("l").toString();
                                String opis =
                                    products[index].get("o").toString();
                                String kat =
                                    products[index].get("k").toString();
                                List<String> array_list =
                                    List.from(products[index].get("u"));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                              backgroundColor: Colors.white,
                                              appBar: AppBar(
                                                leading: IconButton(
                                                  icon: Icon(Icons.arrow_back),
                                                  color: Colors.black,
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                title: Text(
                                                  'Detaljnije o artiklu',
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                centerTitle: true,
                                                elevation: 0.0,
                                                backgroundColor: Colors.white,
                                              ),
                                              body: Container(
                                                child: Center(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: Column(
                                                      children: [
                                                        SizedBox(height: 20.0),
                                                        CarouselSlider(
                                                          options:
                                                              CarouselOptions(),
                                                          items: array_list
                                                              .map(
                                                                  (item) =>
                                                                      Container(
                                                                        child: Center(
                                                                            child: Image.network(item,
                                                                                fit: BoxFit.cover,
                                                                                width: 300)),
                                                                      ))
                                                              .toList(),
                                                        ),
                                                        SizedBox(height: 20.0),
                                                        Text(
                                                          "Naziv artikla : $naziv",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Marka : $marka",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Model : $model",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Kataloski broj : $katBr",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Kategorija : $kat",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          cijena == "1"
                                                              ? "Cijena : Po dogovoru"
                                                              : "Cijena : $cijena KM",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Kolicina : $kolicina",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Lokacija : $lokacija",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Opis : $opis",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 20),
                                                        RaisedButton(
                                                          onPressed: () {
                                                            TextEditingController
                                                                tcnazivEdit =
                                                                new TextEditingController(
                                                                    text:
                                                                        naziv);
                                                            TextEditingController
                                                                tccijenaEdit =
                                                                new TextEditingController(
                                                                    text:
                                                                        cijena);
                                                            TextEditingController
                                                                tckatBrEdit =
                                                                new TextEditingController(
                                                                    text:
                                                                        katBr);
                                                            TextEditingController
                                                                tcmarkaEdit =
                                                                new TextEditingController(
                                                                    text:
                                                                        marka);
                                                            TextEditingController
                                                                tcmodelEdit =
                                                                new TextEditingController(
                                                                    text:
                                                                        model);
                                                            TextEditingController
                                                                tclokacijaEdit =
                                                                new TextEditingController(
                                                                    text:
                                                                        lokacija);
                                                            TextEditingController
                                                                tcopisEdit =
                                                                new TextEditingController(
                                                                    text: opis);
                                                            TextEditingController
                                                                tckolicinaEdit =
                                                                new TextEditingController(
                                                                    text:
                                                                        kolicina);
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Scaffold(
                                                                              backgroundColor: Colors.white,
                                                                              appBar: AppBar(
                                                                                leading: IconButton(
                                                                                  icon: Icon(Icons.arrow_back),
                                                                                  color: Colors.black,
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                ),
                                                                                title: Text(
                                                                                  'Detaljnije o artiklu',
                                                                                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                centerTitle: true,
                                                                                elevation: 0.0,
                                                                                backgroundColor: Colors.white,
                                                                              ),
                                                                              body: Container(
                                                                                  child: Center(
                                                                                child: SingleChildScrollView(
                                                                                  scrollDirection: Axis.vertical,
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tcnazivEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite naziv dijela",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tcmarkaEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite marku vozila",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tcmodelEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite model vozila",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tckatBrEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite kataloški broj dijela",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tclokacijaEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite lokaciju dijela",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tcopisEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite opis dijela",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tckolicinaEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite količinu dijela",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                                                                                        child: TextFormField(
                                                                                          style: TextStyle(color: Colors.black),
                                                                                          controller: tccijenaEdit,
                                                                                          decoration: InputDecoration(
                                                                                            labelText: "Unesite cijenu dijela",
                                                                                            labelStyle: TextStyle(color: Colors.black),
                                                                                            enabledBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                            focusedBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                              borderSide: BorderSide(color: Colors.red[800], width: 1.5),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 20),
                                                                                      RaisedButton(
                                                                                        onPressed: () async {
                                                                                          String postNaziv = jsonEncode(tcnazivEdit.text);
                                                                                          String postMarka = jsonEncode(tcmarkaEdit.text);
                                                                                          String postModel = jsonEncode(tcmodelEdit.text);
                                                                                          String postKatbr = jsonEncode(tckatBrEdit.text);
                                                                                          String postLok = jsonEncode(tclokacijaEdit.text);
                                                                                          String postOpis = jsonEncode(tcopisEdit.text);
                                                                                          String postKol = jsonEncode(tckolicinaEdit.text);
                                                                                          String postCijena = jsonEncode(tccijenaEdit.text);

                                                                                          Map<String, dynamic> body;
                                                                                          //String postUrl = jsonEncode(imageUrl.toString());

                                                                                          body = {
                                                                                            "n": jsonDecode(postNaziv),
                                                                                            "s_name": jsonDecode(postNaziv.toLowerCase()),
                                                                                            "s_model": jsonDecode(postMarka.toLowerCase()),
                                                                                            "c": jsonDecode(postCijena),
                                                                                            "m": jsonDecode(postMarka),
                                                                                            //"img" : jsonDecode(postUrl),
                                                                                            "mo": jsonDecode(postModel),
                                                                                            "s_brand": jsonDecode(postModel.toLowerCase()),
                                                                                            "kb": jsonDecode(postKatbr),
                                                                                            "s_catalogue": jsonDecode(postKatbr.toLowerCase()),
                                                                                            "l": jsonDecode(postLok),
                                                                                            "o": jsonDecode(postOpis),
                                                                                            "ko": jsonDecode(postKol),
                                                                                            "u": array_list //Pass String Array Here
                                                                                          };
                                                                                          var collection = FirebaseFirestore.instance.collection('artikli');
                                                                                          collection
                                                                                              .doc(products[index].id) // <-- Doc ID where data should be updated.
                                                                                              .update(body);

                                                                                          try {
                                                                                            final result = await InternetAddress.lookup('google.com');
                                                                                            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) print("=> Added at line 2001");
                                                                                            FirebaseFirestore.instance.collection('artikli').add(body);
                                                                                            Alert(
                                                                                              context: context,
                                                                                              title: "Artikal uspješno izmijenjen.",
                                                                                              buttons: [
                                                                                                DialogButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator.pop(context);
                                                                                                    Navigator.pop(context);
                                                                                                  },
                                                                                                  color: Colors.red[800],
                                                                                                  child: Center(
                                                                                                      child: Text(
                                                                                                    "Nazad",
                                                                                                    textAlign: TextAlign.center,
                                                                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                                  )),
                                                                                                )
                                                                                              ],
                                                                                              style: AlertStyle(backgroundColor: Colors.white, titleStyle: TextStyle(color: Colors.black)),
                                                                                            ).show();
                                                                                          } on SocketException catch (_) {
                                                                                            showDialog(
                                                                                                context: context,
                                                                                                builder: (context) => AlertDialog(
                                                                                                      title: Text("Problem s konekcijom!"),
                                                                                                      content: Text("Provjerite vašu internet konekciju."),
                                                                                                    ));
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          "Izmjena artikla",
                                                                                          style: TextStyle(color: Colors.white, fontSize: 15),
                                                                                        ),
                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: Colors.red[800])),
                                                                                        elevation: 5.0,
                                                                                        color: Colors.red[800],
                                                                                        textColor: Colors.white,
                                                                                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                                                                        splashColor: Colors.grey,
                                                                                      ),
                                                                                      SizedBox(height: 20),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )),
                                                                            )));
                                                          },
                                                          child: Text(
                                                            "Izmjena artikla",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15),
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                          .red[
                                                                      800])),
                                                          elevation: 5.0,
                                                          color:
                                                              Colors.red[800],
                                                          textColor:
                                                              Colors.white,
                                                          padding: EdgeInsets
                                                              .fromLTRB(15, 15,
                                                                  15, 15),
                                                          splashColor:
                                                              Colors.grey,
                                                        ),
                                                        SizedBox(height: 20),
                                                        RaisedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            showDialog<String>(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  AlertDialog(
                                                                title: Text(
                                                                    'Potvrda brisanja artikla'),
                                                                content: Text(
                                                                    'Da li želite izbrisati artikal \n' +
                                                                        products[index]
                                                                            .get("n")),
                                                                actions: <
                                                                    Widget>[
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context,
                                                                          'Da');

                                                                      //Query Firestore to delete the part
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .runTransaction(
                                                                              (transaction) async {
                                                                        DocumentReference doc = await FirebaseFirestore
                                                                            .instance
                                                                            .collection('artikli')
                                                                            .doc(products[index].id);
                                                                        transaction
                                                                            .delete(doc);
                                                                        setState(
                                                                            () {
                                                                          print(
                                                                              "Deleted Part at $index");
                                                                          products
                                                                              .removeAt(index);
                                                                        });
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                        'Da',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red[800])),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            'Ne'),
                                                                    child: Text(
                                                                        'Ne',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red[800])),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            "Brisanje artikla",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15),
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                          .red[
                                                                      800])),
                                                          elevation: 5.0,
                                                          color:
                                                              Colors.red[800],
                                                          textColor:
                                                              Colors.white,
                                                          padding: EdgeInsets
                                                              .fromLTRB(15, 15,
                                                                  15, 15),
                                                          splashColor:
                                                              Colors.grey,
                                                        ),
                                                        SizedBox(height: 20),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )));
                              },
                            );
                          }) /*ListView.builder(
                controller: _scrollController,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  String title = products[index].get("n");
                  String Sub_title = products[index].get("m");
                  String image_url = "";
                  List<String> array_list = List.from(products[index].get("u"));
                  if (array_list != null && array_list.length > 0){
                    image_url = array_list[0];
                  }
                  return InkWell(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height : 10),
                          Container(height: 80, child:
                          CachedNetworkImage(
                            imageUrl: image_url,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                SpinKitFadingCircle(
                                  color: Colors.red,
                                  size: 20,
                                ),
                            //placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),),
                          // FadeInImage(
                          //   placeholder: AssetImage("assets/img/car.png"),
                          //   image: NetworkImage(image_url),
                          //   fit: BoxFit.cover,
                          // ),),
                          SizedBox(height : 10),
                          // Text("${image_url}",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     color : Colors.black,
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 17.0,
                          //   ),),
                          Text("${title}",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              color : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                            ),),
                          SizedBox(height : 5),
                          Text("${Sub_title}",style: TextStyle(color : Colors.black, fontWeight : FontWeight.bold),)
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onTap: (){
                      print("Item Tapped $index");
                      String allDetails = "Part Name: " + products[index].get("n") + "\nm: " + products[index].get("m")
                          + "\nCar Brand: " + products[index].get("m0") + "\nCatalogue Number: " + products[index].get("kb").toString()
                          + "\nb: " + products[index].get("b").toString() + "\nc: " + products[index].get("c").toString()
                          + "\ni: " + products[index].get("i").toString() + "\nid: " + products[index].get("id").toString()
                          + "\nk: " + products[index].get("k").toString() + "\nko: " + products[index].get("ko").toString()
                          + "\nl: " + products[index].get("l").toString() + "\no: " + products[index].get("o").toString()
                          + "\ns: " + products[index].get("s").toString() + "\nv: " + products[index].get("v").toString();
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(title),
                          content: Text(allDetails),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'DELETE');
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text('Are you sure you want to delete this article?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context, 'Yes');

                                          //Query Firestore to delete the part
                                          print("Delete Part at $index");
                                          await FirebaseFirestore.instance.runTransaction((transaction) async
                                          {
                                            DocumentReference doc = await FirebaseFirestore.instance.collection('artikli').doc(documentSnapshot.id);
                                            transaction.delete(doc);
                                          });
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, 'No'),
                                        child: const Text('No'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('DELETE'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'CLOSE'),
                              child: const Text('CLOSE'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )*/
                          ,
                        )),
              isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(5),
                      //color: Colors.yellowAccent,
                      child: SpinKitFadingCircle(
                        color: Colors.red,
                        size: 20,
                      ),
                    )
                  : Container()
            ]),
            //   onRefresh: () async {
            //     //refreshChangeListener.refreshed = true;
            // },
            // )
          )
        ],
      ),
    );
  }
}
