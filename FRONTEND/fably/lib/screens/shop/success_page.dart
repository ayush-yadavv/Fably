import 'package:fably/screens/auth/login.dart';
import 'package:fably/screens/home/home.dart';
import 'package:fably/utils/requests.dart';
import 'package:flutter/material.dart';

class SuccessPage extends StatefulWidget {
  final String email;
  final String name;
  final String address;
  final String phone;
  final String postalCode;
  final String cardNumber;
  final String expiration;
  final String cvv;
  final String paymentMethod;

  const SuccessPage({
    super.key,
    required this.email,
    required this.name,
    required this.address,
    required this.phone,
    required this.postalCode,
    required this.cardNumber,
    required this.expiration,
    required this.cvv,
    required this.paymentMethod,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  bool processingCheckout = true;
  bool success = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final requests = BackendRequests();
      if (!await requests.isLoggedIn()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      submitOrder();
      //_showMessage("Payment successful!");
    });
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> submitOrder() async {
    /*if (processingCheckout) {
      return;
    }*/
    setState(() {
      processingCheckout = true;
    });
    //_showMessage("Processing...");

    final requests = BackendRequests();
    try {
      final response = await requests.postRequest('checkout', body: {
        "email": widget.email,
        "name": widget.name,
        "address": widget.address,
        "phone": widget.phone,
        "postalCode": widget.postalCode,
        "card_number": widget.cardNumber,
        "expiration": widget.expiration,
        "cvv": widget.cvv,
        "payment_method": widget.paymentMethod,
      });
      if (response.statusCode == 201) {
        _showMessage("Order placed successfully!");

        setState(() {
          success = true;
          processingCheckout = false;
        });
      } else {
        _showMessage("Failed to place order.");
        setState(() {
          success = false;
        });
      }
    } catch (e) {
      _showMessage("Error: $e");
    }

    setState(() {
      processingCheckout = false;
    });
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
          "Payment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: !processingCheckout
              ? success
                  ? <Widget>[
                      const Icon(
                        //Success Screen
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Payment Successful!',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Return to Home'),
                      ),
                    ]
                  : <Widget>[
                      // Failed screen
                      const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 100.0,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Payment Failed',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          // Define what happens when the retry button is pressed
                          Navigator.pop(
                              context); // Navigates back to the previous page
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Retry'),
                      ),
                    ]
              : <Widget>[
                  // Loading Screen
                  CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Processing...',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
        ),
      ),
    );
  }
}
