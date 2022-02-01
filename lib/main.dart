import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Pre Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _city = "London";

  Weather _weatherData = const Weather(
      location: "Kathmandu",
      region: "Kathmandu",
      country: "Nepal",
      tempC: 24,
      tempF: 54.6,
      condition: "Sunny",
      icon: "cdn.weatherapi.com/weather/64x64/day/113.png",
      time: 10,
      code: 1000
  );
  final List<String> cities = <String>['London', 'Kathmandu', 'Mumbai', 'Adelaide', 'Paris', 'New York'];


  @override
  void initState(){
    super.initState();
    onLoad();
  }

  void onLoad() async{
    Weather data = await getWeather(_city);
    setState(() {
      _weatherData = data;
    });
  }

  Future <Weather> getWeather(String city) async{
    final response = await http.get(Uri.parse('http://api.weatherapi.com/v1/current.json?key=2a82927faa6a49f2830185035223001&q=$city'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print("Weather loaded");
      return Weather.fromJSON(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather');
    }
  }

  void changeCity (String city) {
    setState(() {
      _city = city;
    });
    onLoad();
  }

  List<Color> weatherColors(int time, String condition){
    if (time >= 19 || time <= 4){
      return const [Colors.black87, Colors.black87];
    }else{
      if (_weatherData.condition == "Sunny") {
        return const [Color(0xfffbe176), Color(0xfffebe95)];
      }
      return const [Color(0xff6cf7e7), Color(0xff72efee)];
    }
  }

  Color textColor(){
    if (_weatherData.time >= 19 || _weatherData.time <= 4) return Colors.white;
    return Colors.black87;
  }

  ListTile eachTile(String currentCity, BuildContext context){
    if (_city == currentCity){
      return ListTile(
        // trailing: const Icon(Icons.check, color: Colors.blueAccent,),
        onTap: (){
          Navigator.pop(context);
        },
        title: Center(
          child: Text(
            currentCity,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: "Montserrat"
            ),
          ),
        ),
      );
    }
    return ListTile(
      onTap: (){
        changeCity(currentCity);
        Navigator.pop(context);
      },
      title: Center(
        child: Text(
          currentCity,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: "Montserrat"
          ),
        ),
      ),

    );
  }
  
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: weatherColors(_weatherData.time, _weatherData.condition)[0],
        elevation: 0,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Column(

          children: [
            const SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: textColor(), size: 20,),
                // const SizedBox(width: 15,),
                TextButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        // title: const Text('AlertDialog Title'),
                        content: SizedBox(
                          height: 300,
                          width: 500,
                          child: Stack(
                            children: [
                              const Positioned(
                                  top: 143,
                                  child: Icon(Icons.arrow_right_alt)
                              ),
                              const Positioned(
                                  top: 143,
                                  right: 0,
                                  child: Icon(Icons.done, size: 20, color: Colors.blue,)
                              ),
                              CarouselSlider(
                                items: cities.map((city) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 60,
                                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                          child: eachTile(city, context),
                                      );
                                    },
                                  );
                                }).toList(),
                                // carouselController: controller,

                                options: CarouselOptions(
                                  height: 400,
                                  aspectRatio: 1/9,
                                  viewportFraction: 0.2,
                                  initialPage: cities.indexOf(_city),
                                  enableInfiniteScroll: true,
                                  reverse: false,
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _city = cities[index];
                                    });
                                  },
                                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                                  scrollDirection: Axis.vertical,
                                )
                              )
                            ],
                          )
                        )
                      ),
                    ),
                  },

                  child: Text(
                    _city,
                    style: TextStyle(
                      color: textColor(),
                      fontFamily: "Montserrat"
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: Container(
        // height: MediaQuery.of(context).size.height,
        // color: textColor(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            // stops: [0.1, 0.5, 0.7, 0.9],
            colors: weatherColors(_weatherData.time, _weatherData.condition)
          ),
        ),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              WeatherImage(code: _weatherData.code, time: _weatherData.time,),
              // const SizedBox(height: 10,),
              Text(
                '${_weatherData.condition}, ${_weatherData.time}',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: textColor()
                ),
              ),
              // Text(
              //   '$_counter',
              //   style: Theme.of(context).textTheme.headline4,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 25,),
                  Text(
                    '${_weatherData.tempC.round()}',
                    style: TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: textColor()
                    ),
                  ),
                  Text(
                    '°C',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'Montserrat',
                        color: textColor()
                    ),
                  ),
                ],
              ),
              Text(
                '${_weatherData.location}, ${_weatherData.country}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: textColor()
                ),
              ),
              const SizedBox(height: 150,),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class WeatherImage extends StatelessWidget {
  const WeatherImage({Key? key, required this.code, required this.time}) : super(key: key);

  final int code;
  final int time;

  @override
  Widget build(BuildContext context) {
    // print(time);
    if(time > 19 || time < 4){
      return Image.asset("assets/moon_cloud.png", width: 175,);
    }
    switch(code){
      case 1000:  //Sunny/Clear
        return Image.asset("assets/sunny.png", width: 175,);
        break;
      case 1003: //Cloudy
      case 1006:
      case 1009:
        return Image.asset("assets/cloudy.png", width: 175,);
        break;
      case 1030: //Mist
        return Image.asset("assets/snowy.png", width: 175,);
        break;
      case 1063: //Light rain
      case 1150:
      case 1180:
      case 1183:
        return Image.asset("assets/rainy_light.png", width: 175,);
        break;
      case 1186: //Moderate rain
      case 1189:
        return Image.asset("assets/rainy.png", width: 175,);
        break;
      case 1192: //Heavy rain
      case 1195:
      case 1201:
        return Image.asset("assets/rainy.png", width: 175,);
        break;
      case 1069: //Fleet (both rain and snow)
      case 1204:
      case 1207:
      case 1252:
      case 1249:
        return Image.asset("assets/snow.png", width: 175,);
        break;
      case 1087: //Thundery outbreak
        return Image.asset("assets/thunder.png", width: 175,);
        break;
      case 1210: //Light Snow
      case 1213:
      case 1066:
        return Image.asset("assets/snowy_light.png", width: 175,);
        break;
      case 1216: //Moderate Snow
      case 1219:
        return Image.asset("assets/snowy.png", width: 175,);
        break;
      case 1117: //Snow/Blizzard
      case 1222:
      case 1225:
        return Image.asset("assets/snow.png", width: 175,);
        break;

      default:
        return Image.asset("assets/sunny.png", width: 175,);
        break;
    }
    // return Image.asset("");
  }
}


class Weather{
  /* {
        location: {name, region, country, latitude, longitude},
        current: {temp-celsius, temp-fahrenheit, condition, icon, code}
  } */
  final String location;
  final String region;
  final String country;
  final int time;

  final double tempC;
  final double tempF;
  final String condition;
  final String icon;
  final int code;

  const Weather({
    required this.location,
    required this.region,
    required this.country,
    required this.time,

    required this.tempC,
    required this.tempF,
    required this.condition,
    required this.icon,
    required this.code,
  });

  factory Weather.fromJSON(Map<String, dynamic> json){
    var location = json['location'];
    var current = json['current'];
    var condition = current['condition'];

    var tempTime = location['localtime'];
    var reducedTime = (tempTime.toString().length == 16)? tempTime : '${tempTime.toString().substring(0, 11)}0${tempTime.toString().substring(11, tempTime.toString().length)}';

    return Weather(
        location: location['name'],
        region: location['region'],
        country: location['country'],
        time: DateTime.parse(reducedTime).hour,
        tempC: current['temp_c'],
        tempF: current['temp_f'],
        condition: condition['text'],
        icon: condition['icon'],
        code: condition['code']
    );
  }
}
