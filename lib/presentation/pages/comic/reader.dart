import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:flutter/material.dart';


class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int curChap = 1;
  final Map<int, List<String>> comicPicture = {
    1: [
      "https://meo.comick.pictures/0-e3bsK_El-7LFt.webp",
      "https://meo.comick.pictures/1-4KQtkJESrOG9o.webp"
    ],
    2: [
      "https://meo.comick.pictures/0-6z19572nGi62j.png"
    ]
  };

  @override
  Widget build(BuildContext context) {
    final List<String> images = comicPicture[curChap] ?? [];
    return Scaffold(
      appBar: EmptyAppBar(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                value: curChap,
                isExpanded: true,
                dropdownColor: AppColors.subtleBackground,
                items: comicPicture.keys.map((idx) {
                  return DropdownMenuItem<int>(
                    value: idx,
                    child: AppText("Ch $idx", color: AppColors.neutral, fontWeight: FontWeight.bold),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if(value != null) {
                    setState((){
                      curChap = value;
                    });
                  }
                },
              ),
            ),
            Column(
              children: images.map((url) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(
                    url,
                    fit: BoxFit.fitWidth,
                  ),
                );
              }).toList()
            )
          ],
        ),
      ),
    );
  }
}