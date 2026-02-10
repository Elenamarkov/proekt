import 'package:flutter/material.dart';
import '../providers/tabProvider.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/logo.dart';
import '../providers/travelFormProvider.dart';
import '../main.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage({super.key});

  @override
  State<TaxiPage> createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> {
  List<Taxi> taxis = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTaxis();
  }

  Future<void> _loadTaxis() async {
    try {
      final fetchedTaxis = await ApiService.getAllTaxis();

      setState(() {
        taxis = fetchedTaxis;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);

    return Consumer<TravelFormProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.blue[200],
          appBar: AppBar(
            backgroundColor: Colors.blue[200],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                tabProvider.setIndex(2); // Back to HotelsPage
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const LogoWidget(),
                  const SizedBox(height: 60),
                  const Text(
                    'Available Taxis',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 70),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: Column(
                        children: [
                          Text(
                            'Error loading taxis: $error',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTaxis,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  if (!isLoading && error == null && taxis.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 70),
                      child: Text(
                        'No taxis found for your search.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  if (!isLoading && error == null && taxis.isNotEmpty)
                    SizedBox(
                      height: 310,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 3),
                        itemCount: taxis.length,
                        itemBuilder: (context, index) {
                          final taxi = taxis[index];
                          return Container(
                            width: 228,
                            margin: const EdgeInsets.only(right: 24),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        taxi.imageUrl,
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      taxi.provider,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      taxi.type,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${taxi.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromRGBO(253, 177, 224, 1.0),
                                      ),
                                    ),
                                    Text(
                                      'ETA: ${taxi.estimatedTime}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          provider.setTaxiChosen(true);
                                          provider.setTaxiPrice(taxi.price);
                                          tabProvider
                                              .setIndex(4); // ReceiptPage
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              253, 177, 224, 1.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: const Text('Book Now'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 38),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.setTaxiChosen(false);
                          provider.setTaxiPrice(0);
                          tabProvider.setIndex(4); // ReceiptPage
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(253, 177, 224, 1.0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text(
                          'No Taxi',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
