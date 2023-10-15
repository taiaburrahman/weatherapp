import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? positon;

  var lat;
  var lon;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    positon = await Geolocator.getCurrentPosition();
    lat = positon!.latitude;
    lon = positon!.longitude;
    print("latitude : ${lat},longitude: ${lon}");
    fetchWeatherData();
  }

  Map<String, dynamic>? WeatherMap;
  Map<String, dynamic>? ForecastMap;

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=906c0c77ba8058de5f2455853703dc3e";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=906c0c77ba8058de5f2455853703dc3e";
    var weatherResponse = await http.get(Uri.parse(weatherApi));
    var forecastResponse = await http.get(Uri.parse(forecastApi));
    print(weatherResponse.body);
    setState(() {
      WeatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      ForecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  bool isInstructionView = false;
  @override
  Widget build(BuildContext context) {
    var celsius = ((WeatherMap!["main"]["temp"]) - 273.15);
    //  var maxcelsius = ((ForecastMap!["list"][index]["main"]["temp_min"]) - 273.15);
    // var mincelsius = ((ForecastMap!["list"][index]["main"]["temp_min"]) - 273.15);
    //var FeelsLike = ((WeatherMap!["main"]["feels_like"]) - 273.15);

    return SafeArea(
      child: WeatherMap == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFFFFFFFF),
                elevation: 0.0,
                title: Container(
                  child: Text(
                    'Weather App',
                    style: TextStyle(
                        color: Color(0xFF800000), fontWeight: FontWeight.w800),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search, color: Color(0xFF000000)),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: Icon(Icons.location_searching_sharp,
                        color: Color(0xFF000000)),
                  ),
                ],
              ),
              backgroundColor: Color.fromARGB(255, 229, 229, 229),
              body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Switch(
                            value: isInstructionView,
                            onChanged: (bool isOn) {
                              setState(() {
                                isInstructionView = isOn;
                                print(isInstructionView);
                              });
                            },
                            activeColor: Color(0xFF000080),
                            inactiveTrackColor: Color(0xFFFFFF00),
                            inactiveThumbColor: Color(0xFF000080),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Container(
                                padding: EdgeInsets.only(left: 150),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("${Jiffy.now().format()}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w200)),
                                    Text(
                                      "${WeatherMap!["name"]}",
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                WeatherMap!["main"]["feels_like"] == "clear sky"
                                    ? "https://cdn-icons-png.flaticon.com/128/869/869869.png"
                                    : WeatherMap!["main"]["feels_like"] ==
                                            "rainy"
                                        ? "https://cdn-icons-png.flaticon.com/128/2832/2832093.png"
                                        : WeatherMap!["main"]["feels_like"] ==
                                                "cloudy"
                                            ? "https://cdn-icons-png.flaticon.com/128/3093/3093390.png"
                                            : "https://cdn-icons-png.flaticon.com/128/869/869869.png",
                                height:
                                    MediaQuery.of(context).size.height * .20,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("${celsius.toInt()}°c",
                                style: TextStyle(
                                    fontSize: 35, fontWeight: FontWeight.bold)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "feels like: ${celsius.toInt()}°c",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  "${WeatherMap!["weather"][0]["description"]}",
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              " Humidity: ${WeatherMap!["main"]["humidity"]} Pressure : ${WeatherMap!["main"]["pressure"]}",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            // Text(
                            //   " Sunrise: ${Jiffy(DateTime.fromMillisecondsSinceEpoch(WeatherMap!["sys"]["sunrise"] * 1000)).format("h:mm a")}  , Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(WeatherMap!["sys"]["sunset"] * 1000)).format("h:mm a")}",
                            //   style: TextStyle(fontSize: 15),
                            // ),

                            Text(
                                "Sunrise: ${DateTime.fromMillisecondsSinceEpoch(WeatherMap!["sys"]["sunrise"] * 1000)}")
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: ForecastMap!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: MediaQuery.of(context).size.width * .4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white54),
                              margin: EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    // child: Text(
                                    //   "${Jiffy("${ForecastMap!["list"][index]["dt_txt"]}").format("EEE h:mm")}",
                                    //   style: TextStyle(fontSize: 20),
                                    // ),
                                  ),
                                  ClipRRect(
                                    //borderRadius:BorderRadius.circular(20),
                                    child: Image.network(
                                      WeatherMap!["main"]["feels_like"] ==
                                              "clear sky"
                                          ? "https://cdn-icons-png.flaticon.com/128/869/869869.png"
                                          : WeatherMap!["main"]["feels_like"] ==
                                                  "rainy"
                                              ? "https://cdn-icons-png.flaticon.com/128/2832/2832093.png"
                                              : WeatherMap!["main"]
                                                          ["feels_like"] ==
                                                      "cloudy"
                                                  ? "https://cdn-icons-png.flaticon.com/128/3093/3093390.png"
                                                  : "https://cdn-icons-png.flaticon.com/128/7865/7865939.png",
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .20,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "${ForecastMap!["list"][index]["main"]["temp_min"]} °C / ${ForecastMap!["list"][index]["main"]["temp_max"]} °C",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${WeatherMap!["weather"][0]["description"]}",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
