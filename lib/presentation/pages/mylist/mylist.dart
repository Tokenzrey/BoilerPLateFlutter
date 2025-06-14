import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:flutter/material.dart';

const List<String> items = ["Reading", "Unfollow", "Completed", "Dropped", "Plan to Read"];
class MylistScreen extends StatelessWidget {
  const MylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Mycomiclist(),
      theme: AppThemeData.darkThemeData,
    );
  }
}


class Mycomiclist extends StatefulWidget {
  const Mycomiclist({super.key});

  @override
  State<Mycomiclist> createState() => _MycomiclistState();
}

class _MycomiclistState extends State<Mycomiclist> {
  String allVal = items.first;
  String searchVal = "";
  final List<String> comics = [
    "Attack on Titan",
  ];

  @override
  Widget build(BuildContext context) {
    List<String> filtered = comics.where((comics){
      return comics.toLowerCase().contains(searchVal.toLowerCase());
    }).toList();

    return Scaffold(
      // TODO: nambahin appbar
      appBar: EmptyAppBar(),
      // TODO: nambahin bottom nav
      // bottomNavigationBar: EmptyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: ((value) {
                        setState(() {
                          searchVal = value;
                        });
                      }),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search title",
                      ),
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // Button(
                  //   variant: ButtonVariant.outlined,
                  //   onPressed: () {},
                  //   colors: ButtonColors(background: Colors.transparent, border: Colors.white24),
                  //   child: Row(
                  //     children: const [
                  //       Icon(Icons.filter_list, color: Colors.white),
                  //       SizedBox(width: 8),
                  //       AppText("Filter"),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: const [
                        SizedBox(width: 240, child: Center(child: AppText("Title", color: Colors.blue))),
                        SizedBox(width: 120, child: AppText("Continue", color: Colors.blue)),
                        SizedBox(width: 120, child: AppText("Rating", color: Colors.blue)),
                        SizedBox(width: 120, child: AppText("All")),
                        SizedBox(width: 120, child: AppText("Status")),
                        SizedBox(width: 12),
                        SizedBox(width: 120, child: AppText("Last Read", color: Colors.blue)),
                        SizedBox(width: 120, child: AppText("Updated", color: Colors.blue)),
                        AppText("Added", color: Colors.blue),
                      ],
                    ),
                  ),
                  ...List.generate(filtered.length, (idx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 240,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      "https://meo.comick.pictures/ezXpBL-s.jpg",
                                      width: 50,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppText(
                                      filtered[idx],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                          )),
                          // SizedBox(width: 120, child: AppText(filtered[idx])),
                          SizedBox(width: 120, child: AppText("Continue $idx")),
                          SizedBox(width: 120, child: AppText("Rating $idx")),
                          SizedBox(width: 120, child: AppText("All content $idx")),
                          // SizedBox(width: 120, child: AppText("Status $idx")),
                          SizedBox(
                            width: 120,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: allVal,
                              items: items.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (value) {},
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 12),
                          SizedBox(width: 120, child: AppText("Last Read $idx")),
                          SizedBox(width: 120, child: AppText("Updated $idx")),
                          AppText("Added $idx"),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}