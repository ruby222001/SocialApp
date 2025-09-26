import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String? username;
  final String? imageData;
  final void Function()? onTap;
  const UserTile(
      {super.key, required this.username, this.onTap, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade800),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: (imageData != null)
                        ? CachedNetworkImageProvider(
                            imageData ?? '',
                          )
                        : const AssetImage("assets/images/google.png"),
                    child: (imageData == null)
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    username ?? '',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
