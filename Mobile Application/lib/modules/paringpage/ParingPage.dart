import 'dart:math';

import 'package:desktop_anywhere/shared/component/GenericPopUpPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class ParingPage extends StatelessWidget {
  ParingPage({super.key});

  @override
  var formKey= GlobalKey<FormState>();
  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  var ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double scaleFactor = screenWidth / 400;

    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, Object? state) {
        if (state is InsertDatabaseState) {
          // Navigator.pop(context);
        }
      },
      builder: (BuildContext context, state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.black87,
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
              "Adding New Device",
              style: TextStyle(
                color: Colors.white,
                fontSize: min(22, 22 * scaleFactor),
              ),
            ),
            centerTitle: true,
          ),
          body: Form(
              key: formKey,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: min(500, screenWidth * 0.8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Device Name',
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: min(20 * scaleFactor, 20),
                            ),
                            prefixIcon: const Icon(
                              Icons.abc,
                              color: Colors.black,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black, width: 2.0),
                            ),
                          ),
                          validator: (value) {
                            if(value!.isEmpty)
                              {
                                return 'Device Name must not be empty';
                              }
                            return null;
                          }
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                          controller: ipController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'IP Address',
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: min(20 * scaleFactor, 20),
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.black,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black, width: 2.0),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          validator: (value) {
                            if(value!.isEmpty)
                            {
                              return 'IP Address must not be empty';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: min(20 * scaleFactor, 20),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_open,
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                cubit.togglePassword();
                              },
                              icon: Icon(
                                ((cubit.isPassword) ? Icons.visibility : Icons
                                    .visibility_off),
                                color: Colors.black,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black, width: 2.0),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: cubit.isPassword,
                          validator: (value) {
                            if(value!.isEmpty)
                            {
                              return 'Password must not be empty';
                            }
                            if(passwordController.text.length!=8)
                              {
                                return "Password length is incorrect";
                              }
                            return null;
                          }
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      MaterialButton(
                        onPressed: () async{
                          if (formKey.currentState!.validate()) {
                            if(await cubit.checkPing(ip: ipController.text)==200)
                              {
                                if(await cubit.sendDate(
                                    password: passwordController.text,
                                    ip: ipController.text)==200)
                                  {
                                    cubit.insertToDatabase(
                                      name: nameController.text,
                                      password: passwordController.text,
                                      ip: ipController.text,
                                    );
                                    Fluttertoast.showToast(
                                        msg: "You have Successfully paired to this device.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.green,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: min(18 * scaleFactor, 18));
                                  }
                                else{

                                  Fluttertoast.showToast(
                                      msg: "please check the password",
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.grey,
                                      textColor: Colors.red,
                                      gravity: ToastGravity.BOTTOM,
                                      fontSize: min(18 * scaleFactor, 18));

                                }
                              }
                            else{
                              Fluttertoast.showToast(msg: "Please check the IP",
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.grey,
                                  textColor: Colors.red,
                                  gravity: ToastGravity.BOTTOM,
                                  fontSize: min(18 * scaleFactor, 18));
                            }

                            // Navigator.of(context).pop();
                          }
                        },
                        textColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minWidth: min(500, screenWidth * 0.8),
                        height: 55,
                        color: Colors.black,
                        child: Text(
                          'Pair',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: min(25 * scaleFactor, 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        );
      },
    );
  }
}

