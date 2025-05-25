# This branch is still under development


# Boilerplate Project

A boilerplate project created in flutter using MobX and Provider. Boilerplate supports both web and mobile, clone the appropriate branches mentioned below:

* For Mobile: https://github.com/zubairehman/flutter-boilerplate-project/tree/master (stable channel)
* For Web: https://github.com/zubairehman/flutter-boilerplate-project/tree/feature/web-support (beta channel)

## Getting Started

The Boilerplate contains the minimal implementation required to create a new library or project. The repository code is preloaded with some basic components like basic app architecture, app theme, constants and required dependencies to create a new project. By using boiler plate code as standard initializer, we can have same patterns in all the projects that will inherit it. This will also help in reducing setup & development time by allowing you to use same code pattern and avoid re-writing from scratch.

## How to Use 

**Step 1:**

Download or clone this repo by using the link below:

```
https://github.com/zubairehman/flutter-boilerplate-project.git
```

**Step 2:**

Go to project root and execute the following command in console to get the required dependencies: 

```
flutter pub get 
```

**Step 3:**

This project uses `inject` library that works with code generation, execute the following command to generate files:

```
flutter packages pub run build_runner build --delete-conflicting-outputs
```

or watch command in order to keep the source code synced automatically:

```
flutter packages pub run build_runner watch
```

## Hide Generated Files

In-order to hide generated files, navigate to `Android Studio` -> `Preferences` -> `Editor` -> `File Types` and paste the below lines under `ignore files and folders` section:

```
*.inject.summary;*.inject.dart;*.g.dart;
```

In Visual Studio Code, navigate to `Preferences` -> `Settings` and search for `Files:Exclude`. Add the following patterns:
```
**/*.inject.summary
**/*.inject.dart
**/*.g.dart
```

## Boilerplate Features:

* Splash
* Login
* Home
* Routing
* Theme
* Dio
* Database
* MobX (to connect the reactive data of your application with the UI)
* Provider (State Management)
* Encryption
* Validation
* Code Generation
* User Notifications
* Logging
* Dependency Injection
* Dark Theme Support (new)
* Multilingual Support (new)
* Provider example (new)

### Up-Coming Features:

* Connectivity Support
* Background Fetch Support

### Libraries & Tools Used

* [Dio](https://github.com/flutterchina/dio)
* [Database](https://github.com/tekartik/sembast.dart)
* [MobX](https://github.com/mobxjs/mobx.dart) (to connect the reactive data of your application with the UI)
* [Provider](https://github.com/rrousselGit/provider) (State Management)
* [Encryption](https://github.com/xxtea/xxtea-dart)
* [Validation](https://github.com/dart-league/validators)
* [Logging](https://github.com/zubairehman/Flogs)
* [Notifications](https://github.com/AndreHaueisen/flushbar)
* [Json Serialization](https://github.com/dart-lang/json_serializable)
* [Dependency Injection](https://github.com/fluttercommunity/get_it)

### Folder Structure
Here is the core folder structure which flutter provides.

```
flutter-app/
|- android
|- build
|- ios
|- lib
|- test
```

Here is the folder structure we have been using in this project

```
lib/
|- constants/
|- data/
|- stores/
|- ui/
|- utils/
|- widgets/
|- main.dart
|- routes.dart
```

Now, lets dive into the lib folder which has the main code for the application.

```
1- constants - All the application level constants are defined in this directory with-in their respective files. This directory contains the constants for `theme`, `dimentions`, `api endpoints`, `preferences` and `strings`.
2- data - Contains the data layer of your project, includes directories for local, network and shared pref/cache.
3- stores - Contains store(s) for state-management of your application, to connect the reactive data of your application with the UI. 
4- ui — Contains all the ui of your project, contains sub directory for each screen.
5- util — Contains the utilities/common functions of your application.
6- widgets — Contains the common widgets for your applications. For example, Button, TextField etc.
7- routes.dart — This file contains all the routes for your application.
8- main.dart - This is the starting point of the application. All the application level configurations are defined in this file i.e, theme, routes, title, orientation etc.
```

### Constants

This directory contains all the application level constants. A separate file is created for each type as shown in example below:

```
constants/
|- app_theme.dart
|- dimens.dart
|- endpoints.dart
|- preferences.dart
|- strings.dart
```

### Data

All the business logic of your application will go into this directory, it represents the data layer of your application. It is sub-divided into three directories `local`, `network` and `sharedperf`, each containing the domain specific logic. Since each layer exists independently, that makes it easier to unit test. The communication between UI and data layer is handled by using central repository.

```
data/
|- local/
    |- constants/
    |- datasources/
    |- app_database.dart
   
|- network/
    |- constants/
    |- exceptions/
    |- rest_client.dart
    
|- sharedpref
    |- constants/
    |- shared_preference_helper.dart
    
|- repository.dart

```

### Stores

The store is where all your application state lives in flutter. The Store is basically a widget that stands at the top of the widget tree and passes it's data down using special methods. In-case of multiple stores, a separate folder for each store is created as shown in the example below:

```
stores/
|- login/
    |- login_store.dart
    |- form_validator.dart
```

### UI

This directory contains all the ui of your application. Each screen is located in a separate folder making it easy to combine group of files related to that particular screen. All the screen specific widgets will be placed in `widgets` directory as shown in the example below:

```
ui/
|- login
   |- login_screen.dart
   |- widgets
      |- login_form.dart
      |- login_button.dart
```

### Utils

Contains the common file(s) and utilities used in a project. The folder structure is as follows: 

```
utils/
|- encryption
   |- xxtea.dart
|- date
  |- date_time.dart
```

### Widgets

Contains the common widgets that are shared across multiple screens. For example, Button, TextField etc.

```
widgets/
|- app_icon_widget.dart
|- empty_app_bar.dart
|- progress_indicator.dart
```

### Routes

This file contains all the routes for your application.

```dart
import 'package:flutter/material.dart';

import 'ui/post/post_list.dart';
import 'ui/login/login.dart';
import 'ui/splash/splash.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
  };
}
```

### Main

This is the starting point of the application. All the application level configurations are defined in this file i.e, theme, routes, title, orientation etc.

```dart
import 'package:boilerplate/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/app_theme.dart';
import 'constants/strings.dart';
import 'ui/splash/splash.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Strings.appName,
      theme: themeData,
      routes: Routes.routes,
      home: SplashScreen(),
    );
  }
}
```

---

## 🔔 Notifikasi Lokal

### Penjelasan

Aplikasi ini menggunakan service `NotificationService` untuk menampilkan notifikasi lokal. Notifikasi lokal berguna untuk mengingatkan/menginformasikan user secara langsung dari perangkat, tanpa koneksi internet.

#### Fitur `NotificationService`
- Inisialisasi plugin sesuai platform (Android/iOS)
- Meminta izin notifikasi (Android 13+, iOS)
- Menampilkan notifikasi sederhana

#### Cara Pakai

1. **Inisialisasi** (pada saat aplikasi mulai, misal di `main()`):

    ```dart
    await NotificationService().init();
    ```

2. **Menampilkan Notifikasi**:

    ```dart
    NotificationService().showNotification(
      id: 0,
      title: 'Judul Notifikasi',
      body: 'Ini isi notifikasi',
    );
    ```

#### Catatan Penting

- **Android 13+**: Izin notifikasi (`POST_NOTIFICATIONS`) harus diminta secara eksplisit (sudah di-handle di service).
- **iOS**: Izin notifikasi juga diminta otomatis.
- Tambahkan permission terkait di `AndroidManifest.xml` dan `Info.plist` (iOS).

#### Contoh Implementasi Service

```dart
// Ringkasan implementasi NotificationService
await NotificationService().init();
await NotificationService().showNotification(
  id: 1,
  title: 'Hello!',
  body: 'Selamat datang di aplikasi ini.'
);
```

#### Screenshoot
<div align="center" style="display: flex; gap: 16px; flex-wrap: wrap; justify-content: center;">

<img src="https://github.com/user-attachments/assets/25308101-d064-4393-8c1a-84ae73020812" alt="Screenshot 1" width="230" style="margin: 8px; border-radius: 12px; box-shadow: 0 2px 8px #0001;">
<img src="https://github.com/user-attachments/assets/a45ce413-1c28-41bb-ab01-84e3fe1c5465" alt="Screenshot 2" width="230" style="margin: 8px; border-radius: 12px; box-shadow: 0 2px 8px #0001;">
<img src="https://github.com/user-attachments/assets/5b10c1ad-8bd7-482f-b51b-9759e6b10d7f" alt="Screenshot 3" width="230" style="margin: 8px; border-radius: 12px; box-shadow: 0 2px 8px #0001;">

</div>

## 🔥 Integrasi Firebase

### Penjelasan

Aplikasi ini telah terintegrasi dengan **Firebase** untuk kebutuhan otentikasi dan database cloud (Firestore).  
Konfigurasi multi-platform dikelola melalui file `firebase_options.dart` yang di-generate otomatis oleh FlutterFire CLI.

#### File Penting

- **lib/core/data/network/firebase/firebase_options.dart**  
  Berisi konfigurasi kredensial Firebase untuk Android, iOS, web, macOS, Windows (lihat contoh di bawah).

- **lib/data/di/module/network_module.dart**  
  Fungsi `_configureFirebase()` untuk inisialisasi dan registrasi singleton `FirebaseAuth` dan `FirebaseFirestore` pada service locator (getIt).

- **lib/data/local/models/user_model.dart**  
  Model user menggunakan [freezed](https://pub.dev/packages/freezed) & [Hive](https://pub.dev/packages/hive) untuk serialisasi & penyimpanan lokal.

- **lib/data/repository/auth/auth_firebase_repository_impl.dart**  
  Implementasi repository autentikasi: register, login, update profile, update password, logout, dsb.

### Cara Inisialisasi Firebase

1. **Konfigurasi firebase_options.dart**  
   (Sudah otomatis ter-generate, contoh cuplikan:)
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

2. **Registrasi di Service Locator**  
   (Di dalam `network_module.dart`)
   ```dart
   getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
   getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
   ```

3. **Penggunaan di Repository**  
   Lakukan operasi autentikasi atau database lewat repository, misal:
   ```dart
   final result = await authFirebaseRepository.login(email, password);
   result.fold(
     (failure) => ...,
     (user) => ...,
   );
   ```

### Contoh firebase_options.dart (ringkasan)

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => ...; // logic platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'xxx',
    appId: 'xxx',
    // dst
  );
  // platform lain...
}
```

---

## 📦 Struktur File Terkait

```
lib/
├─ core/
│   └─ widgets/
│       └─ notification.dart      # Service notifikasi lokal
│
├─ core/data/network/firebase/
│   └─ firebase_options.dart      # Konfigurasi multi-platform Firebase
│
├─ data/di/module/
│   └─ network_module.dart        # Inisialisasi & Registrasi Firebase
│
├─ data/local/models/
│   └─ user_model.dart            # Model user (freezed + Hive)
│
├─ data/repository/auth/
│   └─ auth_firebase_repository_impl.dart # Repository autentikasi
```

## Wiki

Checkout [wiki](https://github.com/zubairehman/flutter-boilerplate-project/wiki) for more info

## Conclusion

I will be happy to answer any questions that you may have on this approach, and if you want to lend a hand with the boilerplate then please feel free to submit an issue and/or pull request 🙂

Again to note, this is example can appear as over-architectured for what it is - but it is an example only. If you liked my work, don’t forget to ⭐ star the repo to show your support.

