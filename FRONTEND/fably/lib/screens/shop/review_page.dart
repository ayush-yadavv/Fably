import 'dart:convert';

import 'package:fably/utils/prefs.dart';
import 'package:fably/utils/requests.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  final String itemName;
  final String itemId;
  final int sumRating;
  final int ratingCount;

  const ReviewPage({
    super.key,
    required this.itemName,
    required this.itemId,
    required this.sumRating,
    required this.ratingCount,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late double averageRating;
  final List<Map<String, dynamic>> reviews = [];
  int selectedRating = 0; // Rating input for new review
  int sumRating = 0;
  int ratingCount = 0;
  Map myReview = {};
  bool myReviewAdded = false;
  final TextEditingController commentController = TextEditingController();

  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    // Mock reviews for demonstration
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchReviews();
      setState(() {
        _isLoading = true;
      });
      await getReviewAverage();
      setState(() {
        _isLoading = false;
      });
      if (myReviewAdded) {
        setState(() {
          selectedRating = myReview['rating'];
          commentController.text = myReview['review'];
        });
      }
    });
    reviews.addAll([
      {"user_name": "User1", "rating": 4, "review": "Great product!"},
      {"user_name": "User2", "rating": 5, "review": "Exceeded expectations."},
      {"user_name": "User3", "rating": 3, "review": "Good but could improve."},
    ]);

    // Calculate the average rating from the passed sumRating and ratingCount
    averageRating = widget.ratingCount == 0
        ? 0.0
        : widget.sumRating / widget.ratingCount;
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  Future<void> getReviewAverage() async {
    final request = BackendRequests();
    print("getReviewAverage");
    
    final response = await request.postRequest(
      'get_review_average/',
      body: {
        'item_id': widget.itemId,
      }
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        ratingCount = data['review_count'];
        sumRating = data['rating_sum'];
        if (ratingCount == 0){
          averageRating = 0.0;
        } else {
          averageRating = data['rating_sum'] / data['review_count'];
        }
      });
    } else {
      print("Failed to get review average: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  }

  Future<void> fetchReviews() async {
    setState(() {
      _isLoading = true;
    });
    final requests = BackendRequests();
    final prefs = Prefs();
    final userInfo = jsonDecode(await prefs.getPrefs('userInfo') ?? '');
    // Fetch reviews from the backend
    final response = await requests.postRequest(
      '/get_reviews/',
      body: {
        "item_id": widget.itemId,
      },
    );
    if (response.statusCode == 200) {
      final reviewsResponse = jsonDecode(response.body);

      List<Map<String, dynamic>> reviewsData = [];
      for (String uid in reviewsResponse.keys) {
        if (uid == userInfo['_id']) {
          myReview = {
            "user_id": uid,
            "user_name": reviewsResponse[uid]['user_name'],
            "rating": reviewsResponse[uid]['rating'],
            "review": reviewsResponse[uid]['review'],
          };
          myReviewAdded = true;
        }
        reviewsData.add({
          "user_id": uid,
          "user_name": reviewsResponse[uid]['user_name'],
          "rating": reviewsResponse[uid]['rating'],
          "review": reviewsResponse[uid]['review'],
        });
      }
      setState(() {
        reviews.clear();
        reviews.addAll(reviewsData);
      });
    } else {
      _showMessage('Failed to fetch reviews: ${response.statusCode}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> sendReview() async {
    final requests = BackendRequests();
    final prefs = Prefs();
    final userInfo = jsonDecode(await prefs.getPrefs('userInfo') ?? '');
    if (selectedRating == 0) {
      _showMessage('Please provide a rating.');
      return;
    }
    //_showMessage('User ID: ${userInfo['_id']}');
    final response = await requests.postRequest(
      '/add_review/${userInfo['_id']}/',
      body: {
        "item_id": widget.itemId,
        "rating": selectedRating,
        "review": commentController.text,
      },
    );
    if (response.statusCode == 200) {
      _showMessage('Review added successfully!');
      await fetchReviews();
      setState(() {
        _isLoading = true;
      });
      await getReviewAverage();
      setState(() {
        _isLoading = false;
      });
    } else {
      _showMessage('Failed to add review: ${response.statusCode}');
    }
  }

  void addReview() {
    if (selectedRating > 0 && commentController.text.isNotEmpty) {
      setState(() {
        reviews.add({
          "user_id": "1", // Replace with actual user data
          "user_name": "NewUser", // Replace with actual user data
          "rating": selectedRating,
          "review": commentController.text,
        });
        // Update sumRating and ratingCount
        int newSumRating = sumRating + selectedRating;
        int newRatingCount = ratingCount + 1;

        // Recalculate average rating
        averageRating = newSumRating / newRatingCount;

        // Reset input fields
        selectedRating = 0;
        commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment.')),
      );
    }
  }

  Widget _buildStarsNonInter(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double rating = averageRating;
        if (averageRating==0.0){
          print("No reviews yet $averageRating $index $rating");
          return const Icon(Icons.star_border, color: Colors.grey);
        }
        if (averageRating % 1 >= 0.1){
          if (index < rating-1) {
            // Full stars
            return const Icon(Icons.star, color: Colors.amber);
          } else if (index == rating ~/ 1) {
            // Half star
            return const Icon(Icons.star_half, color: Colors.amber);
          } else {
            // Empty stars (not applicable here, but for future cases)
            return const Icon(Icons.star_border, color: Colors.grey);
          }
        } else{
          if (index < rating) {
            return const Icon(Icons.star, color: Colors.amber);
          } else{
            return const Icon(Icons.star_border, color: Colors.grey);
          }
        }
      }),
    );
  }

  Widget _buildStars(double rating, {double starSize = 20, bool interactive = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive
              ? () {
                  setState(() {
                    selectedRating = index + 1;
                  });
                }
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating ? Colors.amber : Colors.grey,
            size: starSize,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigates back when pressed
          },
        ),
        backgroundColor: Colors.transparent,
        title: const Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the AppBar text
      ),
      body: SafeArea(
        child: _isLoading? Center(child: CircularProgressIndicator()) :Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item name
              Text(
                widget.itemName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Average rating with stars
              Row(
                children: [
                  Text(
                    "Average Rating: ${averageRating.toStringAsFixed(1)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  _buildStarsNonInter(averageRating),
                ],
              ),
              Text(
                "Reviews Count: ${ratingCount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              // Reviews list
              Expanded(
                child: reviews.isEmpty ? Center(child: Text('No reviews yet')) : ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review["user_name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildStars(review["rating"].toDouble()),
                                const SizedBox(width: 8),
                                Text(
                                  "${review["rating"]}/5",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review["review"],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Add Review Section
              const Divider(),
              Text(
                "${myReviewAdded ? "Edit" : "Add"} Your Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStars(selectedRating.toDouble(), interactive: true),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Write your comment here...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: sendReview,
                child: const Text("Submit Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
