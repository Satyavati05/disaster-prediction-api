import 'package:http/http.dart' as http;
import 'dart:convert';

Future getPrediction() async {
  final response = await http.post(
    Uri.parse("http://10.0.2.2:5000/predict"), // emulator
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "rainfall": 250,
      "river_level": 90
    }),
  );

  var data = jsonDecode(response.body);
  print(data['prediction']);
}
