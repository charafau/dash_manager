import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      height: 40,
      width: double.infinity,
      child: Row(
        children: const [
          Icon(Icons.refresh),
          Icon(Icons.arrow_back),
          Icon(Icons.arrow_forward),
          Icon(Icons.edit),
        ],
      ),
    );
  }
}
