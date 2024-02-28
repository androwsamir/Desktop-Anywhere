import 'package:desktop_anywhere/modules/desktopdata/Partitions.dart';
import 'package:desktop_anywhere/modules/virtualtouchpadandkeyboard/VirtualTouchPadAndKeyboard.dart';
import 'package:desktop_anywhere/shared/component/DataComponent.dart';
import 'package:desktop_anywhere/modules/Liveview/liveview.dart';
import 'package:desktop_anywhere/shared/cubit/cubit.dart';
import 'package:desktop_anywhere/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class ComponentData{
  late String componentName;
  late ComponentType componentType;
  ComponentData(this.componentName, this.componentType);
}
class DesktopData extends StatelessWidget {

   DesktopData({super.key, required this.ip , required this.listofpartitions});
  // List<ComponentData> dataList = [
  //   ComponentData("Data (D:)", ComponentType.Partition),
  //   ComponentData("Data (E:)", ComponentType.Partition),
  //   ComponentData("Data (C:)", ComponentType.Partition),
  //   ComponentData("Data (K:)", ComponentType.Partition),
  //   ComponentData("FCIS", ComponentType.Folder),
  //   ComponentData("Work", ComponentType.Folder),
  //   ComponentData("DSP_Task1", ComponentType.File),
  //   ComponentData("DSP_Task2", ComponentType.File),
  // ];
   final String ip ;
   bool flag = false;
   List<dynamic> listofpartitions;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,States>(
        builder: (context,state){
          AppCubit cubit = AppCubit.get(context);
          // Get the size of the screen
          Size screenSize = MediaQuery.of(context).size;
          // Get the width and height
          double screenWidth = screenSize.width;
          double screenHeight = screenSize.height;
          // Initialize the mobileResolution map
          Map<String, double> mobileResolution = {
            'width': screenWidth,
            'height': screenHeight,
          };
          if (!flag) {
            cubit.initializeRequest(mobileResolution: mobileResolution, ip: ip);
            flag = true;
          }
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
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                "Desktop Anywhere",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VirtualTouchpadAndKeyboard(ip: ip,)),
                      );
                    },
                    icon: const Icon(
                      Icons.mouse_outlined,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  LiveView(
                          ip: ip,
                        )
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.live_tv,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: listofpartitions.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: partitionPage(componentName: listofpartitions[index],ip: ip,)
                  );
                },
              ),
            ),
          );
        }
        , listener: (context,state){});
  }
}

