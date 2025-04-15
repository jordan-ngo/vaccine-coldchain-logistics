// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'models/district.dart';
import 'models/hospital.dart';
import 'models/refrigerator.dart';
import 'models/vaccine.dart';
import 'services/route_observer.dart';
import "screens/login_page.dart";

void main() async {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Cold Chain App',
        theme: ThemeData(primarySwatch: Colors.cyan),
        home: SafeArea(
            child: LoginPage()
          // child: DistrictPage()
        ),
        navigatorObservers: [routeObserver],
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // lists for synchronization
  var districtList = <District>[];
  var hospitalList = <Hospital>[];
  var refrigeratorList = <Refrigerator>[];
  var vaccineList = <Vaccine>[];

  // not sure if these methods required or if we can update lists in screens codes
  void addDistrict(District district) {
    for (District item in districtList) {
      if (item.id == district.id) {
        districtList.remove(item);
        break;
      }
    }
    districtList.add(district);
    notifyListeners();
  }

  void addHospital(Hospital hospital) {
    for (Hospital item in hospitalList) {
      if (item.id == hospital.id) {
        hospitalList.remove(item);
        break;
      }
    }
    hospitalList.add(hospital);
    notifyListeners();
  }

  void addRefrigerator(Refrigerator refrigerator) {
    for (Refrigerator item in refrigeratorList) {
      if (item.id == refrigerator.id) {
        refrigeratorList.remove(item);
        break;
      }
    }
    refrigeratorList.add(refrigerator);
    notifyListeners();
  }

  void addVaccine(Vaccine vaccine) {
    for (Vaccine item in vaccineList) {
      if (item.id == vaccine.id) {
        vaccineList.remove(item);
        break;
      }
    }
    vaccineList.add(vaccine);
    notifyListeners();
  }
}
