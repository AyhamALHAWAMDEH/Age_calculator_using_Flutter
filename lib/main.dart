import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'custom_field_text.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حاسبة العمر',
      locale: const Locale('ar', 'EG'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'EG')],
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MyHomePage(title: 'حاسبة العمر'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String _result = ""; // لعرض النتيجة

  BannerAd? _bannerAd;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-9370690318456336/3112404641',      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            // When the ad is loaded, add it to the widget tree.
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Print an error.
          print('Ad failed to load: $error');
          // Dispose the ad.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }


  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(1900, 1, 1),
        maxTime: DateTime.now(),
        onChanged: (date) {
          print('change $date');
        },
        onConfirm: (date) {
          controller.text = "${date.toLocal()}".split(' ')[0];
          print('confirm $date');
        },
        currentTime: DateTime.now(),
        locale: LocaleType.ar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "أهلا وسهلا بكم",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'ابدأ بحساب عمرك أو الفرق بين تاريخين من خلال إدخال التاريخ الأول والتاريخ الثاني',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context, _startDateController),
              child: IgnorePointer(
                child: TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: "تاريخ البداية:",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context, _endDateController),
              child: IgnorePointer(
                child: TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: "تاريخ النهاية:",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculateAgeDifference,
              child: const Text("احسب الآن"),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            if (_bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  void _calculateAgeDifference() {
    // تحقق من أن الحقول ليست فارغة وأن التاريخين صحيحين
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      // تحويل النصوص إلى أشياء من نوع DateTime
      DateTime startDate = DateTime.parse(_startDateController.text);
      DateTime endDate = DateTime.parse(_endDateController.text);

      // تحقق من أن تاريخ البداية يسبق تاريخ النهاية
      if (startDate.isBefore(endDate)) {
        // حساب الفارق بين التاريخين
        Duration ageDifference = endDate.difference(startDate);

        // حساب عدد السنوات، الشهور، والأيام
        int years = ageDifference.inDays ~/ 365;
        int months = (ageDifference.inDays % 365) ~/ 30;
        int days = (ageDifference.inDays % 365) % 30;

        // تحديث المتغير _result لعرض النتيجة
        setState(() {
          _result = 'الفارق هو: $years سنوات, $months شهور, و $days أيام.';
        });
      } else {
        // إظهار رسالة خطأ في حالة إدخال تاريخ بداية أحدث من تاريخ النهاية
        setState(() {
          _result = 'يرجى التأكد من أن تاريخ البداية يسبق تاريخ النهاية.';
        });
      }
    } else {
      // إظهار رسالة خطأ في حالة ترك حقول التاريخ فارغة
      setState(() {
        _result = 'يرجى إدخال التاريخين المطلوبين.';
      });
    }
  }

}