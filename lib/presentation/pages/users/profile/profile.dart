import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Profilecomick(),
      theme: AppThemeData.darkThemeData,
    );
  }
}

class Profilecomick extends StatefulWidget {
  const Profilecomick({super.key});

  @override
  State<Profilecomick> createState() => _ProfilecomickState();
}

class _ProfilecomickState extends State<Profilecomick> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  int cur = 0;
  bool isobscure = true;

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [profileTabs(), settingTabs()];

    return Scaffold(
      // TODO: nambahin appbar
      appBar: EmptyAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                      onPressed: () => setState(() {
                        cur = 0;
                      }),
                      colors: ButtonColors(background: Colors.transparent),
                      child: Row(children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        AppText("Profile"),
                      ]),
                    ),
                    Button(
                      onPressed: () => setState(() {
                        cur = 1;
                      }),
                      colors: ButtonColors(background: Colors.transparent),
                      child: Row(children: [
                        Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        AppText("Settings")
                      ]),
                    ),
                  ],
                ),
              ),
              tabs[cur],
            ],
          ),
        ),
      ),
    );
  }

  Widget profileTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "Profile Settings",
          variant: TextVariant.titleLarge,
        ),
        const SizedBox(height: 24),
        AppText(
          "E-Mail",
          variant: TextVariant.titleMedium,
        ),
        TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: "tes@gmail.com",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppText(
          "Username",
          variant: TextVariant.titleMedium,
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          controller: usernameController,
        ),
        Button(
          text: "Save",
          colors:
              ButtonColors(background: Colors.blue[900], text: Colors.white),

          // TODO
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        AppText(
          "Change Password",
          variant: TextVariant.titleMedium,
        ),
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isobscure = !isobscure;
                  });
                },
                icon: Icon(isobscure ? Icons.visibility_off : Icons.visibility),
              )),
          controller: passwordController,
          obscureText: isobscure,
        ),
        Button(
          text: "Save",
          colors:
              ButtonColors(background: Colors.blue[900], text: Colors.white),
          // TODO
          onPressed: () {},
        ),
        const SizedBox(height: 24),
        AppText(
          "Delete account",
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.bold,
        ),
        AppText(
          "No longer want to use our service? You can delete your account here. This action is not reversible. All information related to this account will be deleted permanently.",
          variant: TextVariant.bodyMedium,
        ),
        AppText(
          "Note: Comick don't hold anything about your information but your email address. It is very safe even if you leave your account on Comick.",
          variant: TextVariant.bodySmall,
          color: Colors.red[700],
        ),
        AppText(
          "You can't register again for 7 days after deleting your account.",
          variant: TextVariant.bodySmall,
          color: Colors.red[700],
        ),
        const SizedBox(height: 12),
        AppText(
          "Enter your ID to delete your account.",
          variant: TextVariant.titleSmall,
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            hintText: "Your ID",
          ),
          controller: passwordController,
        ),
        Button(
          text: "Yes, delete my account",
          colors: ButtonColors(background: Colors.red[900], text: Colors.white),
          // TODO
          onPressed: () {},
        ),
      ],
    );
  }

  Widget settingTabs() {
    return AppText("ini halaman settings");
  }
}
