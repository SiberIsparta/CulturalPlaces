import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://your-supabase-url.supabase.co',
    anonKey: 'your-anon-key',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cultural Places',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CitySelectionPage(),
    );
  }
}

class CitySelectionPage extends StatefulWidget {
  @override
  _CitySelectionPageState createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  String selectedCity = 'Isparta#1';
  Map<String, List<String>> cityPhotos = {};

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    final response = await Supabase.instance.client
        .from('cities')
        .select('name, photo_url')
        .execute();

    if (response.error == null) {
      final List<dynamic> data = response.data;
      Map<String, List<String>> photos = {};
      for (var city in data) {
        String cityName = city['name'];
        String photoUrl = city['photo_url'];
        if (photos.containsKey(cityName)) {
          photos[cityName]!.add(photoUrl);
        } else {
          photos[cityName] = [photoUrl];
        }
      }

      setState(() {
        cityPhotos = photos;
      });
    } else {
      print('Error fetching cities: ${response.error!.message}');
    }
  }

  void _selectCity(String city) {
    setState(() {
      selectedCity = city;
    });
  }

  void _exploreCity() {
    switch (selectedCity) {
      case 'Isparta#1':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IspartaDetails(selectedCity: selectedCity, title: 'Isparta'),
          ),
        );
        break; // Switch case'ten çıkış yapmak için break eklemeyi unutmayın
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KÜLTÜREL YERLER',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white10,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage2()));
          },
        ),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Şehir Seç',
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 50),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCity = newValue;
                      });
                    }
                  },
                  items: cityPhotos.keys.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.split('#')[0]),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    labelText: 'Şehir Adı',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                if (selectedCity.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Seçili Şehir:',
                    style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    selectedCity.split('#')[0],
                    style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${selectedCity.split('#')[0]} Keşfet',
                    style: const TextStyle(fontSize: 29.0, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _exploreCity,
                    child: const Text('Keşfet'),
                  ),
                  const SizedBox(height: 25.0),
                  SizedBox(
                    width: 360,
                    height: constraints.maxHeight * 0.3,
                    child: CarouselSlider(
                      items: cityPhotos[selectedCity]?.map((photoUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(18.0),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                height: 150,
                                width: 120,
                              ),
                            );
                          },
                        );
                      }).toList() ?? [],
                      options: CarouselOptions(
                        enableInfiniteScroll: true,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class IspartaDetails extends StatelessWidget {
  final String selectedCity;
  final String title;

  const IspartaDetails({Key? key, required this.selectedCity, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Details for $selectedCity'),
      ),
    );
  }
}

class SettingsPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Settings'),
    ),
    body: Center(
    child: Text('Settings
