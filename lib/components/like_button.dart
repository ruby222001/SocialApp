import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

// ignore: must_be_immutable
class LikeButtons extends StatelessWidget {
  final bool isLiked;
  void Function()? onTap;
  LikeButtons({
    super.key,
    required this.isLiked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LikeButton(
        isLiked: isLiked,
        likeBuilder: (bool isLiked) {
          return Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          );
        },
      ),
    );
  }
}
