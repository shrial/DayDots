import 'package:intl/intl.dart';

String formatTime(DateTime dt) => DateFormat('hh:mm a').format(dt);
String formatDate(DateTime dt) => DateFormat('EEE, MMM d').format(dt);