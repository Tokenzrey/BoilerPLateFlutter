import 'dart:convert';

import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/navbar/navigation.dart';
import 'package:boilerplate/data/network/dio/configs/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ReaderScreen extends StatefulWidget {
  final String? hid;
  const ReaderScreen({super.key, this.hid="IXi2ivB6"});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int curChap = 1;
  bool isLoading = true;
  List<String> comicPicture = [];

  Future<void> getImagesChapter() async {
    try {
      final res = await http.get(Uri.parse('${Environment.current.apiBaseUrl}chapter/${widget.hid}/get_images'));
      if(res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        final urls = data.map<String>((item) {
          return  "https://meo.comick.pictures/${item["b2key"]}";
        }).toList();
        setState(() {
          comicPicture = urls;
          isLoading = false;
        });
      }
    } catch(e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getImagesChapter();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavBar(
      backgroundColor: AppColors.background,
      child: isLoading ?
        const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 24),
            ...comicPicture.map((url)
              => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(url, fit: BoxFit.fitWidth),
              ))
          ]
        )
      )
    );
  }
}