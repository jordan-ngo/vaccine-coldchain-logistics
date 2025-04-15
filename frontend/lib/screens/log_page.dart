import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/log.dart';

String findDifferences(Map<String, dynamic> map1, Map<String, dynamic> map2, [String prefix = '']) {
  StringBuffer differences = StringBuffer();

  // Get the union of the keys in both maps
  Set<String> allKeys = {...map1.keys, ...map2.keys};

  for (String key in allKeys) {
    String currentPath = prefix.isEmpty ? key : '$prefix.$key';

    if (!map1.containsKey(key)) {
      differences.writeln('$currentPath: added ${map2[key]}');
    } else if (!map2.containsKey(key)) {
      differences.writeln('$currentPath: removed');
    } else {
      var value1 = map1[key];
      var value2 = map2[key];

      if (value1 is Map<String, dynamic> && value2 is Map<String, dynamic>) {
        var nestedDiff = findDifferences(value1, value2, currentPath);
        if (nestedDiff.isNotEmpty) {
          differences.write(nestedDiff);
        }
      } else if (value1 != value2) {
        differences.writeln('$currentPath: $value1  --->  $value2');
      }
    }
  }

  return differences.toString();
}

class LogPage extends StatefulWidget {
  final Log log;

  const LogPage({super.key, required this.log});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          flexibleSpace: Padding(
            padding: EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "${widget.log.id} user id: ${widget.log.user} "
                "district id: ${widget.log.district} hospital id: ${widget.log.hospital} "
                "refrigerator id: ${widget.log.refrigerator} timestamp: ${widget.log.timestamp}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                maxLines: 3, // Set the maximum number of lines you want to allow
                overflow: TextOverflow.ellipsis, // Handles overflow by adding ellipsis
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ListTile(
                title: Text("Before Change:"),
              ),
              SizedBox(height: 8,),
              // THIS IS FOR PREVIOUS VALUE AS LIST
              /*
              ListView(
                children: widget.log.previousValue.entries
                  .map((entry) => ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                    ))
                  .toList(),
              ),
              */
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  jsonEncode(widget.log.previousValue),
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              SizedBox(height: 16,),
              ListTile(
                title: Text("After Change:"),
              ),
              SizedBox(height: 8,),
              // THIS IS FOR NEW VALUE AS LIST
              /*
              ListView(
                children: widget.log.newValue.entries
                  .map((entry) => ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                    ))
                  .toList(),
              ),
              */
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  jsonEncode(widget.log.newValue),
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              SizedBox(height: 16,),
              ListTile(
                title: Text("Changes:"),
              ),
              SizedBox(height: 8,),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  findDifferences(widget.log.previousValue, widget.log.newValue),
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}