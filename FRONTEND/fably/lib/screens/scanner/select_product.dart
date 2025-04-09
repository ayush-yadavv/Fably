import 'dart:convert';
import 'dart:io';
import 'package:fably/screens/auth/login.dart';
import 'package:flutter/material.dart';
import '../../utils/requests.dart';
import 'tryon_result.dart';

class SelectProductPage extends StatefulWidget {
  @override
  _SelectProductPageState createState() => _SelectProductPageState();

  File? userImage;

  SelectProductPage({super.key, this.userImage});

}

class _SelectProductPageState extends State<SelectProductPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();

    final requests = BackendRequests();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(!await requests.isLoggedIn()){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      fetchProducts();
    });
  }

  Future<void> fetchProducts() async {
    final requests = BackendRequests(); // Replace with your backend URL
    try {
      final response = await requests.getRequest('products');

      if (response.statusCode == 200 || response.statusCode == 201 ) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
        backgroundColor: Colors.black,
        title: const Text(
          "Virtual Try-On Selection",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the title
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text('No products available'))
              : Padding(
                padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: products.length,// number of items in the cart
                          itemBuilder: (context, index) {
                            final item = products[index];
                            return Card(// cart item display card
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                leading: Image.network( // image
                                  item['photos'][0], // Replace this with your image URL
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover, // Ensures the image fills the space
                                ),
                                title: Text(item['name']),
                                onTap: () {
                                    _showMessage("Virtual Try-On function...");
                                    

                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => VirtualTryOnResultPage(inputImage:widget.userImage, id: item['_id']),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return child; // No animation, just return the new page
                                        },
                                      ),
                                    );
                                  },
                                /*subtitle:
                                    Text('Price: \$${item['price']} x ${item['quantity']} = \$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),*/
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
