import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/screens/hospital_page.dart';
import '../models/district.dart';
import 'district_page.dart';
import 'profile_page.dart';
import 'globals.dart' as globals;

Future<List<District>> getAllDistricts() async {
  final response = await http
      .get(Uri.parse("https://sheltered-dusk-62147-56fb479b5ef3.herokuapp.com/logistics/getAllDistricts"));
  if (response.statusCode == 200) {
    List<dynamic> districtsJson = json.decode(response.body);
    return districtsJson.map((json) {
      return District.fromJson(json);
    }).toList();
  } else {
    throw Exception('Failed to load districts');
  }
}

class AllDistrictPage extends StatefulWidget {
  const AllDistrictPage({super.key});

  @override
  State<AllDistrictPage> createState() => _AllDistrictPageState();
}

class _AllDistrictPageState extends State<AllDistrictPage> {
  late Future<List<District>?> _districtsFuture;

  @override
  void initState() {
    super.initState();
    _districtsFuture = _loadDistricts();
  }

  Future<List<District>?> _loadDistricts() async {
    try {
      // Fetch districts from the API
      List<District> districts = await getAllDistricts();
      return districts;
    } catch (e) {
      print('Failed to fetch or save districts: $e');
      return Future.error('Failed to load data');
    }
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
              'All Districts',
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<District>?>(
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
                            // Commented by Hans, might need to change ownership if needed, since I am not sure what this page is for.
                            MaterialPageRoute(
                                builder: (context) => HospitalPage(
                                      district: snapshot.data![idx],
                                  ownership: false,
                                    )),
                          );
                        },
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No Data'));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => DistrictPage()),
                );
              },
              child: Text('See My Assignments'),
            ),
          ),
        ],
      ),
    );
  }
}
