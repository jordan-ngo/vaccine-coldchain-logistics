import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/district.dart';
import '../models/hospital.dart';
import '../models/log.dart';
import 'profile_page.dart';
import 'refrigerator_page.dart';
import '../services/database_service.dart';

Future<List<Hospital>> getHospitalsByDistrictIDFromDb(int districtID) async {
  final db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'hospitals',
    where: 'district_id = ?',
    whereArgs: [districtID],
  );

  return List.generate(maps.length, (i) {
    return Hospital(
      id: maps[i]['id'],
      name: maps[i]['name'],
      district: maps[i]['district_id'],
    );
  });
}

class HospitalPage extends StatefulWidget {
  final District district;
  final bool ownership;

  const HospitalPage({super.key, required this.district, required this.ownership});

  @override
  State<HospitalPage> createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  late Future<List<Hospital>?> _hospitalsFuture;
  bool _hasInternetConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = _loadHospitals();
    _checkInternetConnection();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _hasInternetConnection = connectivityResult != ConnectivityResult.none;
    });

    /*
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _hasInternetConnection = result != ConnectivityResult.none;
          });
        });

     */
  }

  Future<List<Hospital>?> _loadHospitals() async {
    print(widget.district.id!);
    try {
      List<Hospital> hospitals =
      await getHospitalsByDistrictIDFromDb(widget.district.id!);
      return hospitals;
    } catch (e) {
      print('Failed to fetch or save hospitals: $e');
      return Future.error('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.district.name,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              icon: const Icon(Icons.person),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Hospital>?>(
        future: _hospitalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, idx) => Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 2.0,
                child: ListTile(
                  title: Text(
                    snapshot.data![idx].name,
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    debugPrint('Hospital ListTile is tapped');
                    // navigate
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RefrigeratorPage(
                              hospital: snapshot.data![idx],
                              ownership: widget.ownership,
                              districtID: widget.district.id!)),
                    );
                  },
                ),
              ),
            );
          }
          return const Center(
            child: Text('No Data'),
          );
        },
      ),
      floatingActionButton: Tooltip(
        message: _hasInternetConnection ? 'Upload updates to backend database' : 'No Internet connection',
        child: FloatingActionButton(
          onPressed: _hasInternetConnection ? () async {
            debugPrint('Upload button pressed');
            // TODO: Mark, you should add logic here to upload logs to the backend database.
            final db = await getDatabase();
            final List<Map<String, dynamic>> logs = await db.query('logs');
            final List<Log> logList = logs.map((log) => Log.fromJson(log)).toList();
            final url = Uri.parse("https://sheltered-dusk-62147-56fb479b5ef3.herokuapp.com/logistics/addLog");
            final response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(logs),
            );
            if (response.statusCode == 200) {
              await db.delete('logs');
            }
          } : null,
          backgroundColor: _hasInternetConnection ? Theme.of(context).primaryColor : Colors.grey,
          tooltip: 'Upload updates to backend database',
          child: const Icon(Icons.cloud_upload),
        ),
      ),
    );
  }
}
