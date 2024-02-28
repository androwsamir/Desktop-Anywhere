import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:desktop_anywhere/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the library for encoding/decoding

class AppCubit extends Cubit<States> {
  AppCubit() : super(InitialState());

  static AppCubit get(context) => BlocProvider.of(context);


  late Database database;
  List<Map> desktops=[];

  bool isPassword = true;
  String path ='';
  String accessTime = "Not accessed yet.";

  String getCurrentTime() {
    DateTime currentTime = DateTime.now();

    // Format and display the current time as a string
    String formattedTime =
        '${currentTime.year}/${currentTime.month}/${currentTime.day} ${currentTime.hour}:${currentTime.minute}';

    return formattedTime;
  }




  void updateAccessTime() {
      accessTime = getCurrentTime();
  }

  void togglePassword(){
    isPassword = !isPassword;
    emit(TogglePasswordState());

  }

  void updatepath(){
    int lastSlashIndex = path.lastIndexOf('\\');
    if (lastSlashIndex != -1) {
      String result = path.substring(0, lastSlashIndex+1);
      path = result;
    }
    emit(poppagestate());
  }

  void setpath(foldername, flag)
  {
    if (flag == 1){
      path = foldername;
    }
    else {
      if (path[path.length - 1] != '\\') {
        String results = path + '\\' + foldername;
        path = results;
      }
      else{
        String results = path + foldername;
        path = results;
      }
    }
    emit(pushpagestate());
  }


  void createDatabase() async {

    openDatabase(
      'Desktop.db',
      version: 1,
      onCreate: (database, version) {

        print('database created');
        database.execute(
            'CREATE TABLE Desktop (id INTEGER PRIMARY KEY, name TEXT, ip TEXT, password TEXT)'
        ).then(
                (value) {
                  print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        print(getDatabasesPath());
        getDataFromDatabase(database);
        // dropTable(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(CreateDatabaseState());

    });

  }

  Future<void> printTableData() async {
    String tableName = 'Desktop'; // Replace with your actual table name

    // Query to retrieve all rows from the table
    List<Map<String, dynamic>> result = await database.query(tableName);

    // Print the data
    print('All data from $tableName:');
    result.forEach((row) {
      print(row);
    });
  }

  void insertToDatabase({
    required String name,
    required String password,
    required String ip,
  }) async {
    await database.transaction(
            (txn) =>
      txn.rawInsert(
        'INSERT INTO Desktop(name, ip, password) VALUES("$name", "$ip", "$password")',
      ).then((value) {
        print('$value inserted successfully');
        emit(InsertDatabaseState());

        getDataFromDatabase(database);

      }).catchError(
              (error)=> print('Error When Inserting New Record ${error.toString()}')
      )
    );
  }

  void getDataFromDatabase(database) async
  {
    desktops = [];
    emit(GetDatabaseLoadingState());
    database.rawQuery(
        'SELECT * FROM Desktop'
    ).then((value) {
        value.forEach((element) {
          desktops.add(element);

        });

        emit(GetDatabaseState());
    });

  }

  void updateData({
    required String status,
    required int id,
  }) async
  {
    database.rawUpdate(
      'UPDATE Desktop SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value)
    {
      getDataFromDatabase(database);
      emit(UpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    // Perform the delete operation
    await database.rawDelete('DELETE FROM Desktop WHERE id = ?', [id]);

    // Retrieve all records after deletion
    List<Map<String, dynamic>> records = await database.query('Desktop');

    // Update the IDs to make them contiguous
    for (int i = 0; i < records.length; i++) {
      int currentId = records[i]['id'];
      if (currentId != i + 1) {
        // If the current ID is not equal to the expected ID, update it
        await database.rawUpdate('UPDATE Desktop SET id = ? WHERE id = ?', [i + 1, currentId]);
      }
    }

    // Notify the listeners or emit a state indicating the deletion
    getDataFromDatabase(database);
    emit(DeleteDatabaseState());
  }

  void dropTable(database) async {
    try {
      await database.execute('DROP TABLE IF EXISTS Desktop');
      print('Table dropped successfully');
      emit(DropTableState());
    } catch (error) {
      print('Error when dropping table: $error');
    }
  }
  Future<int> checkPing({
    required String ip
  }) async {
    try{
      final response = await http.get(Uri.parse('http://$ip:8888'));
      http://197.49.218.242:8888/api/fetch_password
      if (response.statusCode == 200) {
        print('Ping successful! Status code: ${response.statusCode}');
        return 200;
      } else {
        print('Failed to ping. Status code: ${response.statusCode}');
        return response.statusCode;
      }
    }catch(e)
    {
      print('Failed to ping : $e');
      return 0;
    }
  }
  Future<int> sendDate({
    required String password,
    required String ip
  }) async {
    final url = Uri.parse("http://$ip:8888/api/fetch_password");
    Map<String, dynamic> request = {
      "password" : password,
    };
    try{
      final response = await http.post(
      url,
      headers: {
        "Content-Type" : "application/json"
      },
      body: jsonEncode(request),
      );
      if(response.statusCode==200)
        {
          print("data sent successfully! response : ${response.body}");
          return 200;
        }
      else
        {
          print("failed to send data! status code : ${response.statusCode}");
          return response.statusCode;
        }
    }catch(e)
    {
      print("error during data sent : $e");
      return 0;
    }
  }

  Future<List<dynamic>> fetchDataOfDesktop({
    required String parameter,
    required String ip,
  }) async {
    final response = await http.get(
      Uri.parse('http://$ip:8888/transfer_partition?target=$parameter'),
    );

    if (response.statusCode == 200) {
      // print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<Map<dynamic,dynamic>> getRequest({
    required String parameter,
    required String ip,
  }) async {
    print('parameter getRequest: $parameter');
    final response = await http.get(
      Uri.parse('http://$ip:8888/transfer_partition?target=$parameter'),
    );

    if (response.statusCode == 200) {
      // print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> initializeRequest({
    required Map<String, double> mobileResolution,
    required String ip,
  }) async {
    // print('parameter getRequest: $path');
    final response = await http.post(
      Uri.parse('http://$ip:8888/start-UDP'),
      headers: {
        "Content-Type" : "application/json"
      },
      body: jsonEncode(mobileResolution),
    );

    if (response.statusCode == 200) {
      print('Done');
    } else {
      throw Exception('Failed to load data');
    }
  }
  void sendMessageKeyboard(String data, String host, int port) {
    // Convert the Map to JSON
    String jsonString = json.encode({
      'Keyboard-Touchpad': data,
    });

    // Create a UDP socket
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((RawDatagramSocket socket) {
      // Encode the message as UTF-8 bytes
      List<int> dataBytes = utf8.encode(jsonString);

      // Send the UDP packet to the specified host and port
      socket.send(dataBytes, InternetAddress(host), port);

      // Close the socket after sending the message
      socket.close();
    });
  }
  void sendMessageTouchpad(Map<String,double> data, String host, int port) {
    // Convert the Map to JSON
    String jsonString = json.encode({
      'Keyboard-Touchpad': data,
    });

    // Create a UDP socket
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((RawDatagramSocket socket) {
      // Encode the message as UTF-8 bytes
      List<int> dataBytes = utf8.encode(jsonString);

      // Send the UDP packet to the specified host and port
      socket.send(dataBytes, InternetAddress(host), port);

      // Close the socket after sending the message
      socket.close();
    });
  }
  Future<void> delay() async {
    print('Start');
    await Future.delayed(Duration(seconds: 5)); // Delay for 2 seconds
    print('End');
  }
  // Future<List<dynamic>> startShare({
  //   required String ip,
  // }) async {
  //   final response = await http.get(
  //     Uri.parse('http://$ip:8888/'),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     // print(json.decode(response.body));
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }

}