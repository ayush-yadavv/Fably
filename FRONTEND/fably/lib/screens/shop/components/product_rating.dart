import 'package:fably/screens/shop/review_page.dart';
import 'package:flutter/material.dart';

class RatingCard extends StatelessWidget {
  final String itemName;
  final String itemId;
  final int sumRating;
  final int reviewCount;

  const RatingCard({
    super.key,
    required this.itemName,
    required this.itemId,
    required this.sumRating,
    required this.reviewCount,
  });

  double get _averageRating => reviewCount == 0 ? 0.0 : sumRating / reviewCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              itemName: itemName,
              itemId: itemId,
              sumRating: sumRating,
              ratingCount: reviewCount,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.black,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          width: double.infinity,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Ratings ($reviewCount)",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      if (_averageRating == 0.0) {
                        return const Icon(Icons.star_border,
                            color: Colors.grey);
                      }
                      if (_averageRating % 1 >= 0.1) {
                        if (index < _averageRating - 1) {
                          return const Icon(Icons.star, color: Colors.amber);
                        } else if (index == _averageRating ~/ 1) {
                          return const Icon(Icons.star_half,
                              color: Colors.amber);
                        } else {
                          return const Icon(Icons.star_border,
                              color: Colors.grey);
                        }
                      } else {
                        if (index < _averageRating) {
                          return const Icon(Icons.star, color: Colors.amber);
                        } else {
                          return const Icon(Icons.star_border,
                              color: Colors.grey);
                        }
                      }
                    }),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniRatingCard extends StatelessWidget {
  final int reviewCount;
  final String itemName;
  final String itemId;
  final int sumRating;

  const MiniRatingCard({
    super.key,
    required this.reviewCount,
    required this.itemName,
    required this.itemId,
    required this.sumRating,
  });

  double get _averageRating => reviewCount == 0 ? 0.0 : sumRating / reviewCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              itemName: itemName,
              itemId: itemId,
              sumRating: sumRating,
              ratingCount: reviewCount,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.black,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _averageRating >= 1.0
                        ? Icons.star
                        : (_averageRating > 0.0
                            ? Icons.star_half
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 18,
                  ),
                ],
              ),
              Text(
                " ($reviewCount)",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
