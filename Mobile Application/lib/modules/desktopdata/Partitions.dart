
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../shared/cubit/cubit.dart';
import 'folderandfile.dart';

class partitionPage extends StatelessWidget {
  const partitionPage({super.key , required this.componentName , required this.ip});
  final String componentName;
  final String ip;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 400;
    AppCubit cubit = AppCubit.get(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                    Icons.account_tree_outlined,
                    color: Colors.white54,
                    size: min(25*scaleFactor, 35)
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  this.componentName,
                  style: TextStyle(
                    fontSize: min(22*scaleFactor, 25),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_circle_right_outlined,
                    size: min(25*scaleFactor, 35),
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    // print(this.componentName);
                    // print('==================');
                    cubit.setpath(this.componentName, 1);
                    Map<dynamic, dynamic> data = await cubit.getRequest(parameter: componentName.replaceAll("\\", ""), ip: ip);
                    //print(data['dir'].runtimeType);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FilesAndFolder(dataList: data, dataType: 'Folder', ip: ip, parName: this.componentName,),
                     ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
