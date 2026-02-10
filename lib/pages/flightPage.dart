import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/logo.dart';
import '../providers/travelFormProvider.dart';
import '../providers/guestSelectorProvider.dart';
import '../providers/tabProvider.dart';
import '../flights.dart';
import '../providers/tabProvider.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({super.key});

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  List<Flight> flights = [];
  bool isLoading = true;
  String? error;
  int? selectedFlightId;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  String? _cityToIata(String? city) {
    if (city == null) return null;
    final Map<String, String> cityToIata = {
      'New York': 'JFK',
      'London': 'LHR',
      'Paris': 'CDG',
      'Tokyo': 'HND',
      'Sydney': 'SYD',
      'Skopje': 'SKP',
      'Amsterdam': 'AMS',
    };
    return cityToIata[city];
  }

  Future<void> _loadFlights() async {
    try {
      final provider = Provider.of<TravelFormProvider>(context, listen: false);

      final fromIata = _cityToIata(provider.fromPlace);
      final toIata = _cityToIata(provider.toPlace);

      if (fromIata == null || toIata == null || provider.startDate == null) {
        setState(() {
          isLoading = false;
          error = 'Please complete the search form first';
        });
        return;
      }

      try {
        final fetchedFlights = await ApiService.searchFlights(
          departureIata: fromIata,
          arrivalIata: toIata,
          flightDate: provider.startDate,
          limit: 100,
        );

        setState(() {
          flights = fetchedFlights;
          isLoading = false;
          error = null;
        });
      } catch (apiError) {
        print('API Error: $apiError');
        final filteredFlights = _filterStaticFlights(
          provider.fromPlace!,
          provider.toPlace!,
          provider.startDate!.toIso8601String().split('T')[0],
        );

        setState(() {
          flights = filteredFlights;
          isLoading = false;
          error = null;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  List<Flight> _filterStaticFlights(
      String fromCity, String toCity, String departureDate) {
    return flightRawData
        .where((flight) =>
            flight['From'] == fromCity &&
            flight['To'] == toCity &&
            flight['DepartureDate'] == departureDate)
        .map((flightData) => Flight(
              id: flightRawData.indexOf(flightData),
              flightNumber: 'FL${flightRawData.indexOf(flightData) + 100}',
              flightIata: 'FL${flightRawData.indexOf(flightData) + 100}',
              flightDate: departureDate,
              flightStatus: 'SCHEDULED',
              airlineName:
                  'Airline ${(flightRawData.indexOf(flightData) % 5) + 1}',
              airlineIata: 'AL${(flightRawData.indexOf(flightData) % 5) + 1}',
              departureAirportName: fromCity,
              departureAirportIata: _cityToIata(fromCity) ?? 'XXX',
              departureCity: fromCity,
              departureCountry: 'Country',
              arrivalAirportName: toCity,
              arrivalAirportIata: _cityToIata(toCity) ?? 'YYY',
              arrivalCity: toCity,
              arrivalCountry: 'Country',
              basePrice: (flightData['Price'] as num).toDouble(),
              availableSeats: 50 + (flightRawData.indexOf(flightData) % 50),
              imageUrl: flightData['ImageURL'] as String,
              durationMinutes: 120 + (flightRawData.indexOf(flightData) % 180),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final guestSel = Provider.of<GuestSelectorProvider>(context);
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
                Provider.of<TabProvider>(context, listen: false).setIndex(0);
              },
            ),
            title: null,
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
                    'Available Flights',
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
                      padding:
                          const EdgeInsets.only(top: 70, left: 20, right: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading flights:',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadFlights,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!isLoading && error == null && flights.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 70),
                      child: Text(
                        'No flights found for your search.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  if (!isLoading && error == null && flights.isNotEmpty)
                    SizedBox(
                      height: 310,
                      child: Stack(
                        children: [
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 3),
                            itemCount: flights.length,
                            itemBuilder: (context, index) {
                              final flight = flights[index];
                              final totalTickets = provider.seniorCount +
                                  provider.adultCount +
                                  provider.childCount;
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.asset(
                                            flight.imageUrl,
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '\$${flight.basePrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text('From: ${flight.departureCity}'),
                                        Text('To: ${flight.arrivalCity}'),
                                        Text('Date: ${flight.flightDate}'),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: totalTickets > 0
                                                ? () {
                                                    selectedFlightId =
                                                        flight.id;
                                                    final totalPrice =
                                                        flight.basePrice *
                                                            totalTickets;
                                                    provider.setFlightPrice(
                                                        totalPrice);
                                                    Provider.of<TabProvider>(
                                                            context,
                                                            listen: false)
                                                        .setIndex(2);
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.pinkAccent,
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
                        ],
                      ),
                    ),
                  const SizedBox(height: 38),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios,
                              color: Colors.white54, size: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _pill(
                                    context,
                                    guestSel,
                                    0,
                                    "Senior",
                                    provider.seniorCount,
                                    () => provider.setSeniorCount(
                                        provider.seniorCount + 1),
                                    () => provider.setSeniorCount(
                                        provider.seniorCount - 1),
                                    Colors.deepPurple,
                                    Icons.elderly,
                                  ),
                                  _pill(
                                    context,
                                    guestSel,
                                    1,
                                    "Adult",
                                    provider.adultCount,
                                    () => provider
                                        .setAdultCount(provider.adultCount + 1),
                                    () => provider
                                        .setAdultCount(provider.adultCount - 1),
                                    Colors.blue,
                                    Icons.person,
                                  ),
                                  _pill(
                                    context,
                                    guestSel,
                                    2,
                                    "Child",
                                    provider.childCount,
                                    () => provider
                                        .setChildCount(provider.childCount + 1),
                                    () => provider
                                        .setChildCount(provider.childCount - 1),
                                    Colors.orange,
                                    Icons.child_care,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white54, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pill(
    BuildContext context,
    GuestSelectorProvider guestSel,
    int idx,
    String label,
    int value,
    VoidCallback add,
    VoidCallback remove,
    Color color,
    IconData icon,
  ) {
    final bool selected = guestSel.selected == idx;
    return GestureDetector(
      onTap: () => guestSel.setSelected(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.5),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(.19),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: value > 0 ? remove : null,
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Text('$value'),
            IconButton(
              onPressed: add,
              icon: const Icon(Icons.add_circle, color: Colors.green),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
