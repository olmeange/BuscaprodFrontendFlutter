import 'dart:convert';

import 'package:flutter/material.dart';

class ImageDetailsPage extends StatefulWidget {
  const ImageDetailsPage({super.key, required this.item});
  final String item;

  @override
  State<ImageDetailsPage> createState() => _ImageDetailsPageState();
}

class _ImageDetailsPageState extends State<ImageDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Imagen del Producto',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(child: _showContent(widget.item)),
      backgroundColor: Colors.white,
    );
  }

  Widget _showContent(item) {
    return InteractiveViewer(
      clipBehavior: Clip.none,
      minScale: 1.0,
      maxScale: 4.0,
      panEnabled: false,
      child: Image.memory(base64.decode(item), errorBuilder: (_, __, ___) {
        return Image.asset('assets/not_found.png', fit: BoxFit.contain);
      }),
    );
  }
}
