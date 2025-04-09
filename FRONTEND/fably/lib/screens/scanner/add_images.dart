import 'dart:io';
import 'package:fably/screens/home/widgets/common_appbar.dart';
import 'package:fably/screens/scanner/vton_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/prefs.dart';
import '../home/widgets/bottom_nav_bar.dart';
import '../home/widgets/common_drawer.dart';
import '../auth/login.dart';
import '../../utils/requests.dart';
import 'select_product.dart';
import 'tryon_result.dart';

class UploadImagesPage extends StatefulWidget {
  @override
  _UploadImagesPageState createState() => _UploadImagesPageState();

  final String? productId; // Optional input string

  const UploadImagesPage({super.key, this.productId});

}

class _UploadImagesPageState extends State<UploadImagesPage> {
  File? _userImage; // For storing the user image
  File? _clothingImage; // For storing the clothing image
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage(bool isUserImage) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        if (isUserImage) {
          _userImage = File(pickedImage.path);
        } else {
          _clothingImage = File(pickedImage.path);
        }
      });
    }
  }

  void showCustomPopup(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry; // Declare it as late so it can be initialized later

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.25, // Start 25% down from the top
          left: MediaQuery.of(context).size.width * 0.05, // 5% padding from the left
          width: MediaQuery.of(context).size.width * 0.9, // Cover 90% of the screen width
          child: Material(
            color: Colors.transparent,
            child:  SingleChildScrollView(
              child:Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Tips for Taking Your Personal Picture",
                      style: TextStyle(
                        fontFamily: "Ialiana",
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "1. Stand in a well-lit area with minimal shadows.\n"
                      "2. Make sure your entire body is visible in the frame.\n"
                      "3. Wear fitted clothes to ensure accurate virtual try-on.\n"
                      "4. Avoid wearing hats or large accessories.\n"
                      "5. Keep a neutral background to improve results.",
                      style: TextStyle(
                        height: 2.1,
                        fontSize: 16, 
                        color: Colors.black87,
                        fontFamily: "Kanit",
                        
                        fontStyle: FontStyle.italic),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        overlayEntry.remove(); // Remove the popup safely
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Got it!"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    // Automatically remove the popup after 10 seconds if not manually dismissed
    /*Future.delayed(Duration(seconds: 10), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });*/
  }
 

  // Function to take a picture
  Future<void> _takePicture(bool isUserImage) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        if (isUserImage) {
          _userImage = File(pickedImage.path);
        } else {
          _clothingImage = File(pickedImage.path);
        }
      });
    }
  }

  // Function to upload the images
  Future<void> _uploadImages() async {
    if (_userImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select or capture your image')),
      );
      return;
    }
    if (widget.productId == "") {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => SelectProductPage(userImage:_userImage),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; // No animation, just return the new page
          },
        ),
      );
    } else{
      //_showMessage("Virtual Try-On function...");

      Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => VirtualTryOnResultPage(inputImage:_userImage, id: widget.productId ?? ""),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child; // No animation, just return the new page
        },
      ),
    );

    }
    return;
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signOut() async {
    final requests = BackendRequests();
    final prefs = Prefs();

    try{
      final response = await requests.getRequest('logout');
      if (response.statusCode==200){
        await prefs.clearPrefs();
        _showMessage('Logged out successfully');
      }
    }catch (e) {
      _showMessage('Error Loging out: $e');
    }

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
      showCustomPopup(context);
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
        SystemNavigator.pop(); // For Android
      } else if (Platform.isIOS) {
        exit(0); // For iOS and other platforms
      }
      return false;
      },
      child:Scaffold(
        appBar: CommonAppBar(
          title: 'UPLOAD IMAGE',
        ),
        drawer: CommonDrawer(),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display user image
                    _userImage != null
                        ? Image.file(_userImage!, height: 450)
                        : Container(
                            height: 450,
                            width: 300,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.man,
                                size: 300,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(12),
                            fixedSize: const Size(120, 100),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.black,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Gallery',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Jura",
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 60),
                        ElevatedButton(
                          onPressed: () => _takePicture(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(12),
                            fixedSize: const Size(120, 100),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Capture',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Jura",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Upload Image button
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _uploadImages,
                        icon: Icon(
                          Icons.upload,
                          color: Colors.black,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: Text(
                          'Upload Image',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Jura",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // History button
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VtonHistoryPage(), // Replace with your history page widget
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.history,
                          color: Colors.black,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: Text(
                          'Try-On History',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Jura",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CommonBottomNavBar(
          currentIndex: 2,
        ),
      ),
    );
  }
}
