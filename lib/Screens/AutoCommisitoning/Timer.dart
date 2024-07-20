// import 'dart:async';
// import 'package:flutter/material.dart';

// class CountdownTimerWidget extends StatefulWidget {
//   final Duration duration;

//   const CountdownTimerWidget({Key? key, required this.duration})
//       : super(key: key);

//   @override
//   _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
// }

// class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
//   late Timer _timer;
//   int? _secondsRemaining;

//   @override
//   void initState() {
//     super.initState();
//     _secondsRemaining = widget.duration.inSeconds;
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_secondsRemaining! > 0) {
//           _secondsRemaining = _secondsRemaining! - 1;
//         } else {
//           _timer.cancel();
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) {
//       if (n >= 10) return "$n";
//       return "0$n";
//     }

//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$twoDigitMinutes:$twoDigitSeconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       _formatDuration(Duration(seconds: _secondsRemaining!)),
//       style: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.blue,
//       ),
//     );
//   }
// }
