import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/component/DataComponent.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
class Choice{
  const Choice({required this.title, required this.icon});
  final String title;
  final IconData icon;
}
const List<Choice> listOfChoice = <Choice> [
  Choice(title: "Open", icon: Icons.file_open_outlined),
  Choice(title: "Delete", icon: Icons.delete_sweep_outlined),
  Choice(title: "Copy", icon: Icons.copy),
];

class FilesAndFolder extends StatelessWidget {
  const FilesAndFolder({super.key, required this.dataList, required this.dataType, required this.ip, required this.parName});
  final Map<dynamic,dynamic> dataList;
  final String dataType;
  final String ip;
  final String parName;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 400;
    AppCubit cubit = AppCubit.get(context);
    String text = cubit.path.toString();
    return BlocConsumer<AppCubit,States>(
        builder: (context,state){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.keyboard_backspace,
                  color: Colors.white,
                ),
                onPressed: (){
                  cubit.updatepath();
                  // text =cubit.path.toString();
                  Navigator.pop(context);
                },
              ),
              title: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            body:  SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: dataList["dir"].length,
                    physics:const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Expanded(
                                child: Container(
                                  width: 10.0,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Icon(
                                          Icons.folder_copy_outlined,
                                          color: Colors.white,
                                          size: min(25*scaleFactor, 35)
                                      ),

                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          dataList["dir"][index].toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: min(22*scaleFactor, 20),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),

                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  PopupMenuButton<Choice>(
                                    //padding: const EdgeInsets.symmetric(vertical: 10),
                                    icon: const Icon(
                                      Icons.more_horiz_rounded,
                                      color: Colors.white,
                                    ),
                                    color: Colors.white70,
                                    shadowColor: Colors.brown,
                                    itemBuilder: (BuildContext context) {
                                      return listOfChoice.map((Choice val) {
                                        return PopupMenuItem<Choice>(
                                            padding: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                                            value: val,
                                            child: Row(
                                              children: [
                                                Icon(val.icon),
                                                const SizedBox(width: 15),
                                                Text(val.title),
                                              ],
                                            )
                                        );
                                      }).toList();
                                    },
                                  ),

                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_circle_right_outlined,
                                        size: min(25*scaleFactor, 35),
                                        color: Colors.white,
                                      ),
                                      onPressed: () async{
                                        print('folder pressed : ${dataList["dir"][index]}');

                                        cubit.setpath(dataList["dir"][index], 0);
                                        Map<dynamic, dynamic> data = await cubit.getRequest(parameter: cubit.path, ip: ip);
                                        //print(data['dir'].runtimeType);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FilesAndFolder(dataList: data, dataType: 'Folder', ip: ip, parName: this.parName,),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: dataList["files"].length,
                    physics:const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Expanded(
                                child: Container(
                                  width: 10.0,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Icon(
                                          Icons.file_copy_outlined,
                                          color: Colors.white,
                                          size: min(25*scaleFactor, 35)
                                      ),

                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          dataList["files"][index].toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: min(22*scaleFactor, 20),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),

                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  PopupMenuButton<Choice>(
                                    //padding: const EdgeInsets.symmetric(vertical: 10),
                                    icon: const Icon(
                                      Icons.more_horiz_rounded,
                                      color: Colors.white,
                                    ),
                                    color: Colors.white70,
                                    shadowColor: Colors.brown,
                                    itemBuilder: (BuildContext context) {
                                      return listOfChoice.map((Choice val) {
                                        return PopupMenuItem<Choice>(
                                            padding: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                                            value: val,
                                            child: Row(
                                              children: [
                                                Icon(val.icon),
                                                const SizedBox(width: 15),
                                                Text(val.title),
                                              ],
                                            )
                                        );
                                      }).toList();
                                    },
                                  ),

                                  if (dataType == "Folder")
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_circle_right_outlined,
                                        size: min(25*scaleFactor, 35),
                                        color: Colors.white,
                                      ),
                                      onPressed: () async{
                                        print('files pressed : ${dataList["files"][index]}');

                                        cubit.setpath(dataList["files"][index], 0);
                                        Map<dynamic, dynamic> data = await cubit.getRequest(parameter: cubit.path, ip: ip);
                                        //print(data['dir'].runtimeType);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FilesAndFolder(dataList: data, dataType: 'Folder', ip: ip, parName: this.parName,),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

            ),
          );
        }
        , listener: (context,state){});
  }
}
