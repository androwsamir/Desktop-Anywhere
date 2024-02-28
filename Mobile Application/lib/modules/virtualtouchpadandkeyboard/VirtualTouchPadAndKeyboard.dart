import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/cubit/cubit.dart';

class VirtualTouchpadAndKeyboard extends StatefulWidget {
  VirtualTouchpadAndKeyboard({Key? key, required this.ip}) : super(key: key);
  final String ip;

  @override
  _VirtualTouchpadAndKeyboardState createState() =>
      _VirtualTouchpadAndKeyboardState();
}

class _VirtualTouchpadAndKeyboardState
    extends State<VirtualTouchpadAndKeyboard> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance!.keyboard
        .addHandler((KeyEvent event) => _onKey(event, AppCubit.get(context)));
  }

  bool _onKey(KeyEvent event, AppCubit cubit) {
    final key = event.logicalKey.keyLabel;

    if (event is KeyDownEvent) {
      cubit.sendMessageKeyboard(key, widget.ip, 8888);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    AppCubit cubit = AppCubit.get(context);

    Map<String,double> coordinate = {
      "X" :0.0,
      "Y" :0.0
    };
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Desktop Anywhere",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Touchpad Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTapDown: (position){
                  print(position.globalPosition);
                },
                onPanUpdate: (x) {
                  print(x.globalPosition);
                  coordinate["X"] =x.globalPosition.dx;
                  coordinate["Y"] =x.globalPosition.dy;
                  cubit.sendMessageTouchpad(coordinate, widget.ip, 8888);
                  // cubit.delay();
               },
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Virtual Touchpad',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            // Keyboard Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child: Center(
                  child: TextField(
                      focusNode: _keyboardFocusNode,
                      maxLines: null,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        // filled: true,
                        // border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (val) {
                        cubit.sendMessageKeyboard(val, widget.ip, 8888);
                      }),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          // Request focus on the hidden text field
          FocusScope.of(context).requestFocus(_keyboardFocusNode);
        },
        child: Icon(Icons.keyboard, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }
}
