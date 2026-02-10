import 'package:dream_scape/main.dart';
import '../providers/tabProvider.dart';
import 'package:dream_scape/pages/loginPage.dart';
import 'package:dream_scape/pages/registerPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/logo.dart';
import '../providers/travelFormProvider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<String> places = const [
    'New York',
    'London',
    'Paris',
    'Tokyo',
    'Sydney',
    'Skopje',
    'Amsterdam'
  ];

  Future<void> pickDate(BuildContext context, bool isStartDate) async {
    final provider = Provider.of<TravelFormProvider>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime? initialDate = isStartDate
        ? (provider.startDate ?? now)
        : (provider.endDate ?? provider.startDate ?? now);
    DateTime? firstDate = isStartDate ? now : (provider.startDate ?? now);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (isStartDate) {
        provider.setStartDate(pickedDate);
        if (provider.endDate != null &&
            provider.endDate!.isBefore(pickedDate)) {
          provider.setEndDate(null);
        }
      } else {
        provider.setEndDate(pickedDate);
      }
    }
  }

  Future<void> _handleBooking(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      bool registered = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          ) ??
          false;
      if (!registered) return;

      bool loggedIn = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ) ??
          false;
      if (!loggedIn) return;

      Provider.of<TabProvider>(context, listen: false).setIndex(1);
    } else {
      Provider.of<TabProvider>(context, listen: false).setIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelFormProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.blue[200],
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const LogoWidget(),
                  const SizedBox(height: 24),
                  Container(
                    width: 340,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(253, 177, 224, 1.0),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Make a reservation',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.lightBlueAccent,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _FormLabel('From:'),
                        _InputField(
                          child: DropdownButtonFormField<String>(
                            value: provider.fromPlace,
                            hint: const Text('Select a place'),
                            items: places
                                .map((place) => DropdownMenuItem(
                                      value: place,
                                      child: Text(place),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              provider.setFromPlace(value!);
                            },
                            decoration: _inputDecoration(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FormLabel('Destination:'),
                        _InputField(
                          child: DropdownButtonFormField<String>(
                            value: provider.toPlace,
                            hint: const Text('Select a place'),
                            items: places
                                .map((place) => DropdownMenuItem(
                                      value: place,
                                      child: Text(place),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              provider.setToPlace(value!);
                            },
                            decoration: _inputDecoration(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FormLabel('Choose a date from:'),
                        _InputField(
                          child: InkWell(
                            onTap: () => pickDate(context, true),
                            child: InputDecorator(
                              decoration: _inputDecoration(),
                              child: Text(
                                provider.startDate != null
                                    ? '${provider.startDate!.month}/${provider.startDate!.day}/${provider.startDate!.year}'
                                    : 'mm/dd/yyyy',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FormLabel('Choose a date to:'),
                        _InputField(
                          child: InkWell(
                            onTap: () => pickDate(context, false),
                            child: InputDecorator(
                              decoration: _inputDecoration(),
                              child: Text(
                                provider.endDate != null
                                    ? '${provider.endDate!.month}/${provider.endDate!.day}/${provider.endDate!.year}'
                                    : 'mm/dd/yyyy',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isFormValid
                                ? () {
                                    _handleBooking(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 133, 176, 232),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Search',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final Widget child;
  const _InputField({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: child);
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue.shade200),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
  );
}
