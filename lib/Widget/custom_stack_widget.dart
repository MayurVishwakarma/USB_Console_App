import 'package:flutter/material.dart';

class CustomStackWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String image;
  const CustomStackWidget({
    required this.onTap,
    required this.title,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    print(width);
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 200,
        width: (width > 600) ? 200 : width / 2.2,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 3,
                spreadRadius: 1,
                offset: Offset(2, 2),
              )
            ],
            borderRadius: BorderRadius.circular(25),
            color: Colors.blueGrey.shade100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                //   boxShadow: [
                // BoxShadow(
                //   color: Colors.black,
                //   blurRadius: 10,
                //   spreadRadius: 3,
                //   offset: Offset(2, 2),
                // )
                // ],
              ),
              child: Image.asset(
                image,
                height: 80,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
