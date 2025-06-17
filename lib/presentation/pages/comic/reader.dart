import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/navbar/navigation.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/store/history/history_store.dart';
import 'package:flutter/material.dart';


class ReaderScreen extends StatefulWidget {
  final String slug;
  final String hid;
  final String chap;

  const ReaderScreen({
    super.key,
    required this.slug,
    required this.hid,
    this.chap = '1',
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {

  late final HistoryStore _historyStore;
  
  @override
  void initState() {
    super.initState();
    _historyStore = getIt<HistoryStore>();

    _addHistory(widget.chap);
  }

  Future<void> _addHistory(String chap) async {
    await _historyStore.addOrUpdateHistory(
      widget.slug,
      widget.hid,
      chap,
    );

    print(_historyStore.historyList);
  }

  late int? curChap = int.tryParse(widget.chap);
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
    return ScaffoldWithNavBar(
      backgroundColor: AppColors.background,
      child: SingleChildScrollView(
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
                      _addHistory(curChap.toString());
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