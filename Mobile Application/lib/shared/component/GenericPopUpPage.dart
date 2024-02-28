import 'package:flutter/material.dart';

class ConfirmationPopup extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actionButtons;

  const ConfirmationPopup({
    Key? key,
    required this.title,
    required this.message,
    required this.actionButtons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 19),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: actionButtons,
        ),
      ],
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       body: Center(
//         child: MaterialButton(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) => ConfirmationPopup(
//                 title: 'Congratulations!',
//                 message: 'You have Successfully paired to this device.',
//                 actionButtons: [
//                   MaterialButton(
//                     onPressed: () {
//                       // Handle device pairing
//                       Navigator.pop(context); // Close the pop-up
//                     },
//                     child: Text(
//                       'Yes',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                   MaterialButton(
//                     onPressed: () {
//                       Navigator.pop(context); // Close the pop-up
//                     },
//                     child: Text(
//                       'No',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//           child: Text('Show Confirmation Popup'),
//         ),
//       ),
//     ),
//   )
// );
// }
