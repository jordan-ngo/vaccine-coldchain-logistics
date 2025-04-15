import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logistics/services/database_service.dart';
import '../models/log.dart';
import '../models/refrigerator.dart';
import '../models/hospital.dart';
import 'refrigerator_detail_page.dart';
import '../services/route_observer.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;

Future<List<Refrigerator>> getFridgesByHospitalIDFromDb(int hospitalID) async {
  final db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'refrigerators',
    where: 'hospital_id = ?',
    whereArgs: [hospitalID],
  );

  return List.generate(maps.length, (i) {
    return Refrigerator(
      id: maps[i]['id'],
      name: maps[i]['name'],
      modelId: maps[i]['model_id'],
      manufacturer: maps[i]['manufacturer'],
      tempMonitorInstalled: maps[i]['temp_monitor_installed'] == 1,
      monitorType: maps[i]['monitor_type'],
      monitorWorking: maps[i]['monitor_working'] == 1,
      voltageRegulatorInstalled: maps[i]['voltage_regulator_installed'] == 1,
      regulatorType: maps[i]['regulator_type'],
      vaccineCount: maps[i]['vaccine_count'],
      hospitalId: maps[i]['hospital_id'],
    );
  });
}

class RefrigeratorPage extends StatefulWidget {
  final Hospital hospital;
  final bool ownership;
  final int districtID;

  const RefrigeratorPage(
      {super.key,
      required this.hospital,
      required this.ownership,
      required this.districtID});

  @override
  State<RefrigeratorPage> createState() => _RefrigeratorPageState();
}

class _RefrigeratorPageState extends State<RefrigeratorPage> with RouteAware {
  late Future<List<Refrigerator>?> _refrigeratorsFuture;
  bool _hasInternetConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadRefrigerators();
    _checkInternetConnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    /*
    _connectivitySubscription?.cancel();

     */
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _loadRefrigerators() {
    setState(() {
      _refrigeratorsFuture = getFridgesByHospitalIDFromDb(widget.hospital.id!);
    });
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _hasInternetConnection = connectivityResult != ConnectivityResult.none;
    });


    /*
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _hasInternetConnection = result != ConnectivityResult.none;
      });
    });

     */
  }

  @override
  void didPopNext() {
    // Refresh the data when the page comes back into focus
    _loadRefrigerators();
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
              widget.hospital.name,
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
      body: FutureBuilder<List<Refrigerator>?>(
        future: _refrigeratorsFuture,
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
                  title: Text(snapshot.data![idx].name),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    debugPrint('Refrigerator ListTile is tapped');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RefrigeratorDetailPage(
                          refrigerator: snapshot.data![idx],
                          districtID: widget.districtID,
                          ownership: widget.ownership,
                        ),
                      ),
                    ).then((_) {
                      _loadRefrigerators();
                    });
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
        message: _hasInternetConnection
            ? 'Upload updates to backend database'
            : 'No Internet connection',
        child: FloatingActionButton(
          onPressed: _hasInternetConnection
              ? () async {
                  debugPrint('Upload button pressed');
                  // TODO: Mark, you should add logic here to upload logs to the backend database.
                  final db = await getDatabase();
                  final List<Map<String, dynamic>> logs =
                      await db.query('logs');
                  final List<Log> logList =
                      logs.map((log) => Log.fromJson(log)).toList();
                  final url = Uri.parse(
                      "https://sheltered-dusk-62147-56fb479b5ef3.herokuapp.com/logistics/addLog");
                  final response = await http.post(
                    url,
                    headers: {
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(logList),
                  );
                  if (response.statusCode == 200) {
                    await db.delete('logs');
                  }
                }
              : null,
          backgroundColor: _hasInternetConnection
              ? Theme.of(context).primaryColor
              : Colors.grey,
          tooltip: 'Upload updates to backend database',
          child: const Icon(Icons.cloud_upload),
        ),
      ),
    );
  }
}
