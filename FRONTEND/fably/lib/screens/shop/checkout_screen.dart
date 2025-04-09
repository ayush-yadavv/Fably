import 'package:flutter/material.dart';

import 'success_page.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _paymentFormKey = GlobalKey<FormState>();
  final _cardDetailsFormKey = GlobalKey<FormState>();
  final _reviewFormKey = GlobalKey<FormState>();

  int _currentStep = 0;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String selectedPaymentMethod = "Card";

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _nextStep() {
    setState(() {
      _currentStep += 1;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> submitOrder() async {
    if (_reviewFormKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            email: emailController.text.trim(),
            name: nameController.text.trim(),
            address: addressController.text.trim(),
            phone: phoneController.text.trim(),
            postalCode: postalCodeController.text.trim(),
            cardNumber: cardNumberController.text.trim(),
            expiration: expirationController.text.trim(),
            cvv: cvvController.text.trim(),
            paymentMethod: selectedPaymentMethod,
          ),
        ),
      );
    } else {
      _showMessage("Some form inputs are invalid.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black,
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Card(
                color: Colors.black.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep == 0) {
                      if (_paymentFormKey.currentState?.validate() ?? false) {
                        _nextStep();
                      } else {
                        _showMessage("Please fix the errors in this step.");
                      }
                    } else if (_currentStep == 1) {
                      if (_cardDetailsFormKey.currentState?.validate() ??
                          false) {
                        _nextStep();
                      } else {
                        _showMessage("Please fix the errors in this step.");
                      }
                    } else if (_currentStep == 2) {
                      submitOrder();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      _previousStep();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  steps: [
                    Step(
                      title: _stepTitle("Payment Method"),
                      content: Form(
                        key: _paymentFormKey,
                        child: _paymentMethodSelector(),
                      ),
                    ),
                    Step(
                      title: _stepTitle("Card Details"),
                      content: Form(
                        key: _cardDetailsFormKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              cardNumberController,
                              "Card Number",
                              r'^[0-9]{16}$',
                              "Enter a valid 16-digit card number",
                            ),
                            _buildTextField(
                              expirationController,
                              "Expiration (MM/YY)",
                              r'^(0[1-9]|1[0-2])/[0-9]{2}$',
                              "Enter a valid expiration date (MM/YY)",
                            ),
                            _buildTextField(
                              cvvController,
                              "CVV",
                              r'^[0-9]{3,4}$',
                              "Enter a valid CVV (3 or 4 digits)",
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: _stepTitle("Review & Confirm"),
                      content: Form(
                        key: _reviewFormKey,
                        child: Column(
                          children: [
                            _buildTextField(nameController, "Full Name"),
                            _buildTextField(
                              emailController,
                              "E-mail",
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              "Enter a valid email address",
                            ),
                            _buildTextField(addressController, "Address"),
                            _buildTextField(
                              phoneController,
                              "Phone Number",
                              r'^\+?[0-9]{10,15}$',
                              "Enter a valid phone number",
                            ),
                            _buildTextField(
                              postalCodeController,
                              "Postal Code",
                              r'^[0-9]{4,10}$',
                              "Enter a valid postal code",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _paymentMethodSelector() {
    return Column(
      children: [
        _customRadioTile("Card", Icons.credit_card, Colors.blue),
        _customRadioTile("PayPal", Icons.paypal, Colors.yellow),
        _customRadioTile("Apple Pay", Icons.apple, Colors.white),
      ],
    );
  }

  Widget _customRadioTile(String title, IconData icon, Color color) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      leading: Icon(icon, color: color),
      trailing: Radio(
        value: title,
        groupValue: selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            selectedPaymentMethod = value.toString();
          });
        },
        activeColor: color,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    String? pattern,
    String? errorMessage,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Enter your $label";
          value = value.trim(); // Remove leading and trailing spaces
          if (pattern != null && !RegExp(pattern).hasMatch(value)) {
            return errorMessage;
          }
          return null;
        },
      ),
    );
  }
}
