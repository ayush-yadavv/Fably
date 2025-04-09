import 'package:fably/screens/shop/components/product_rating.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../utils/requests.dart';
import '../../utils/prefs.dart';
import 'cart.dart';
import '../auth/login.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String category;
  final int stockQuantity;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.category,
    required this.stockQuantity,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      images: List<String>.from(json['photos'] ?? []),
      category: json['category'] ?? 'No category',
      stockQuantity: json['stockQuantity'] ?? 0,
      description: json['description'] ?? 'No description',
    );
  }
}

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _selectedSize = "M";
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isWishlisted = false;
  bool _isLoading = true;
  double _averageRating = 0.0;
  int reviewCount = 0;
  int sumRating = 0;

  Future<bool> checkLoggedIn(BuildContext context) async {
    final prefs = Prefs();
    String? cookies = await prefs.getPrefs('cookies');
    String? userInfo = await prefs.getPrefs('userInfo');

    if (cookies == null || userInfo == null) {
      // Not logged in, navigate to login
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
      return false;
    }
    return true;
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> getReviewAverage() async {
    final request = BackendRequests();
    print("getReviewAverage");

    final response = await request.postRequest('get_review_average/', body: {
      'item_id': widget.product.id,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        reviewCount = data['review_count'];
        sumRating = data['rating_sum'];
        if (reviewCount == 0) {
          _averageRating = 0.0;
        } else {
          _averageRating = data['rating_sum'] / data['review_count'];
        }
      });
    } else {
      print("Failed to get review average: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  }

  Future<void> _checkWishlisted() async {
    try {
      final prefs = Prefs();
      String? userInfo = await prefs.getPrefs('userInfo');

      if (userInfo != null) {
        Map userData = jsonDecode(userInfo);
        final requests = BackendRequests();

        final response = await requests.postRequest(
            'in_wishlist/${userData['_id']}/',
            body: {'item_id': widget.product.id});

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _isWishlisted = response.body == "true";
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error checking wishlist: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _toggleWishlist() async {
    if (!await checkLoggedIn(context)) return false;

    try {
      final prefs = Prefs();
      String? userInfo = await prefs.getPrefs('userInfo');

      if (userInfo == null) {
        return false;
      }

      Map userData = jsonDecode(userInfo);
      final requests = BackendRequests();

      final response = await requests.postRequest(
          _isWishlisted
              ? 'remove_from_wishlist/${userData['_id']}/'
              : 'add_to_wishlist/${userData['_id']}/',
          body: {'item_id': widget.product.id});

      return response.statusCode == 200;
    } catch (e) {
      print("Error toggling wishlist: $e");
      return false;
    }
  }

  Future<bool> _addToCart() async {
    if (!await checkLoggedIn(context)) return false;

    try {
      final prefs = Prefs();
      String? userInfo = await prefs.getPrefs('userInfo');

      if (userInfo == null) {
        return false;
      }

      Map userData = jsonDecode(userInfo);
      final requests = BackendRequests();

      final response =
          await requests.postRequest('add_to_cart/${userData['_id']}/', body: {
        'item_id': widget.product.id,
        'quantity': 1, // Default to 1 since quantity selector is removed
      });

      if (response.statusCode == 200) {
        _showMessage("Added to cart successfully");
        return true;
      } else {
        _showMessage("Failed to add to cart");
        return false;
      }
    } catch (e) {
      print("Error adding to cart: $e");
      _showMessage("Error adding to cart");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getReviewAverage();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWishlisted();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header area with product image, back button, size selection
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        // Product image
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: widget.product.images.isEmpty
                              ? 1
                              : widget.product.images.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.white,
                              child: Image.network(
                                widget.product.images.isEmpty
                                    ? 'https://via.placeholder.com/400'
                                    : widget.product.images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey[400]),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        // Top bar with brand name and cart
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Fably",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Italiana',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.shopping_bag,
                                      size: 28, color: Colors.black),
                                  onPressed: () async {
                                    if (await checkLoggedIn(context)) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const CartPage()));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Back button
                        Positioned(
                          top: 60,
                          left: 16,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // Size selector
                        Positioned(
                          right: 16,
                          top: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                                child: const Text(
                                  "Size",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Italiana',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildSizeButton("S", "S"),
                              const SizedBox(height: 8),
                              _buildSizeButton("M", "M"),
                              const SizedBox(height: 8),
                              _buildSizeButton("L", "L"),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 400,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              MiniRatingCard(
                                  itemName: widget.product.name,
                                  itemId: widget.product.id,
                                  sumRating: sumRating,
                                  reviewCount: reviewCount),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Details area with product info, price, buttons
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            //maxLines: 1,
                            //overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),

                          // Product description
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                widget.product.description,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Price and Favorites
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Price",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Jura',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    "\$${widget.product.price.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jura',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: IconButton(
                                      icon: Icon(
                                        _isWishlisted
                                            ? Icons.favorite
                                            : Icons.add,
                                        color: _isWishlisted
                                            ? Colors.redAccent
                                            : Colors.white,
                                        size: 28,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      onPressed: () async {
                                        bool success = await _toggleWishlist();
                                        if (success) {
                                          setState(() {
                                            _isWishlisted = !_isWishlisted;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Wishlist",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Jura',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Buy Now button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () async {
                                bool success = await _addToCart();
                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const CartPage()),
                                  );
                                }
                              },
                              child: const Text(
                                "Buy Now",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
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

  Widget _buildSizeButton(String size, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = size;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _selectedSize == size ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _selectedSize == size ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
