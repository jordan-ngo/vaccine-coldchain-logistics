import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logistics/screens/hospital_page.dart';
import 'package:logistics/services/database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/district.dart';
import '../models/log.dart';
import 'profile_page.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

Future<List<District>> getUserDistrictsFromDb() async {
  final db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'districts',
    where: 'user_id = ?',
    whereArgs: [globals.userId],
  );

  return List.generate(maps.length, (i) {
    return District(
      id: maps[i]['id'],
      name: maps[i]['name'],
    );
  });
}

Future<List<District>> getUserDistrictsFromBackend() async {
  var url = Uri.parse(
      'https://sheltered-dusk-62147-56fb479b5ef3.herokuapp.com/logistics/updateLocal');
  var response = await http.get(url);
  var responseBody = jsonDecode(response.body);
  var districts = responseBody['districts'];
  await syncDataOnLogin(districts);

  final db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'districts',
    where: 'user_id = ?',
    whereArgs: [globals.userId],
  );

  return List.generate(maps.length, (i) {
    return District(
      id: maps[i]['id'],
      name: maps[i]['name'],
    );
  });
}

Future<List<District>> getOtherUserDistrictsFromDb() async {
  final db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'districts',
    where: 'user_id != ?',
    whereArgs: [globals.userId],
  );

  return List.generate(maps.length, (i) {
    return District(
      id: maps[i]['id'],
      name: maps[i]['name'],
    );
  });
}

class DistrictPage extends StatefulWidget {
  const DistrictPage({super.key});

  @override
  State<DistrictPage> createState() => _DistrictPageState();
}

class _DistrictPageState extends State<DistrictPage> {
  late Future<List<District>?> _districtsFuture;
  late Future<List<District>?> _accessFuture;
  bool _isOtherDistrictsExpanded = false;
  bool _hasInternetConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _districtsFuture = _loadDistricts();
    _accessFuture = _loadAccess();
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

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _hasInternetConnection = result != ConnectivityResult.none;
      });
    } as void Function(List<ConnectivityResult> event)?) as StreamSubscription<ConnectivityResult>?;
    
  }

  Future<List<District>?> _loadDistricts() async {
    try {
      List<District> districts = await getUserDistrictsFromDb();
      return districts;
    } catch (e) {
      print('Failed to fetch or save districts: $e');
      return Future.error('Failed to load data');
    }
  }

  Future<List<District>?> _loadDistrictsBackend() async {
    try {
      List<District> districts = await getUserDistrictsFromBackend();
      return districts;
    } catch (e) {
      print('Failed to fetch or save districts: $e');
      return Future.error('Failed to load data');
    }
  }

  Future<List<District>?> _loadAccess() async {
    try {
      List<District> districts = await getOtherUserDistrictsFromDb();
      return districts;
    } catch (e) {
      print('Failed to fetch or save access: $e');
      return Future.value();
    }
  }

  Future<void> _pushChanges() async {
    // Stub method for pushing changes
    print('Push changes button pressed');
  }

  @override
  Widget build(BuildContext context) {
    String username = globals.username;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Districts for $username',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<District>?>(
              future: _districtsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, idx) => Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      elevation: 2.0,
                      child: ListTile(
                        title: Text(snapshot.data![idx].name),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () async {
                          debugPrint('menu page to district page');
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HospitalPage(
                                  district: snapshot.data![idx],
                                  ownership: true),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No Data'));
              },
            ),
            ListTile(
              title: Text('Other Districts'),
              trailing: Icon(
                _isOtherDistrictsExpanded
                    ? Icons.expand_less
                    : Icons.expand_more,
              ),
              onTap: () {
                setState(() {
                  _isOtherDistrictsExpanded = !_isOtherDistrictsExpanded;
                });
              },
            ),
            if (_isOtherDistrictsExpanded)
              FutureBuilder<List<District>?>(
                future: _accessFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, idx) => Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        elevation: 2.0,
                        child: ListTile(
                          title: Text(snapshot.data![idx].name),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            debugPrint('menu page to district page');
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HospitalPage(
                                    district: snapshot.data![idx],
                                    ownership: false),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return const Center(child: Text('No Data'));
                },
              ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: _hasInternetConnection
                      ? 'Pull updates from backend database'
                      : 'No Internet connection',
                  child: FloatingActionButton(
                    heroTag: 'download',
                    onPressed: _hasInternetConnection
                        ? () async {
                            debugPrint('Download button pressed');
                            setState(() {
                              _districtsFuture = _loadDistrictsBackend();
                            });
                          }
                        : null,
                    backgroundColor: _hasInternetConnection
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    tooltip: 'Pull updates from backend database',
                    child: const Icon(Icons.cloud_download),
                  ),
                ),
                SizedBox(width: 16), // Add spacing between the buttons
                Tooltip(
                  message: _hasInternetConnection
                      ? 'Upload updates to backend database'
                      : 'No Internet connection',
                  child: FloatingActionButton(
                    heroTag: 'upload',
                    onPressed: _hasInternetConnection
                        ? () async {
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
                          }
                        : null,
                    backgroundColor: _hasInternetConnection
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    tooltip: 'Upload updates to backend database',
                    child: const Icon(Icons.cloud_upload),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
