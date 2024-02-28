import 'package:desktop_anywhere/shared/component/ActiveDevicesCard.dart';
import 'package:desktop_anywhere/modules/contactus/ContactUs.dart';
import 'package:desktop_anywhere/modules/paringpage/ParingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, Object? state) {
        if (state is InsertDatabaseState) {
          Navigator.pop(context);
        }
      },
      builder: (BuildContext context, state) {
        AppCubit cubit = AppCubit.get(context);

        var desktops = AppCubit.get(context).desktops;
        // print('===================================/////////////////////////////////');

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black87,
            leading: const Icon(
              Icons.desktop_windows_outlined,
              size: 28,
              color: Colors.white,
            ),
            leadingWidth: 58,
            title: const Text(
              'The Available Devices',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactUs()),
                    );
                  },
                  icon: const Icon(
                    Icons.info_outlined,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: desktops.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ActiveDevicesCard(
                        deviceName: desktops[index]['name'],
                        deviceid: desktops[index]['id'],
                        ip: desktops[index]['ip'],
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.add_sharp,
                      color: Colors.black,
                      size: 35,
                    ),
                    onPressed: () {
                      // cubit.printTableData();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ParingPage()
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

