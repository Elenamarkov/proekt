import 'package:flutter/material.dart';
import '../providers/tabProvider.dart';
import 'package:provider/provider.dart';
import '../widgets/logo.dart';
import '../providers/travelFormProvider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../main.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool isSubmitting = false;

  Future<void> _submitBooking() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final travelProvider =
          Provider.of<TravelFormProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isLoggedIn) {
        throw Exception('User not logged in');
      }

      // TODO: Replace with actual IDs from previous selections
      final booking = BookingRequest(
        flightId: 1, // Replace with actual flight ID
        userId: authProvider.loggedInUserId ?? 1,
        hotelId: null, // Replace if hotel is selected
        hotelNights:
            travelProvider.endDate != null && travelProvider.startDate != null
                ? travelProvider.endDate!
                    .difference(travelProvider.startDate!)
                    .inDays
                : null,
        taxiId: null, // Replace if taxi is selected
        seniorCount: travelProvider.seniorCount,
        adultCount: travelProvider.adultCount,
        childCount: travelProvider.childCount,
        contactEmail: authProvider.loggedInUserEmail!,
        contactPhone: '123456789', // TODO: Get from user profile
      );

      await ApiService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking created successfully!"),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating booking: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    final provider = Provider.of<TravelFormProvider>(context);

    const receiptTextStyle = TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 16,
      color: Colors.black87,
      height: 1.4,
    );

    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          onPressed: () {
            tabProvider.setIndex(3);
          },
        ),
        title: const Text(
          'Receipt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(253, 177, 224, 1.0),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: LogoWidget()),
                const SizedBox(height: 18),
                Divider(color: Colors.grey[300], thickness: 1),
                const SizedBox(height: 12),
                _buildReceiptRow('Name', 'Jon Doe', receiptTextStyle),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  'Flight',
                  '${provider.fromPlace ?? ''} → ${provider.toPlace ?? ''}',
                  receiptTextStyle,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  'Hotel',
                  provider.selectedHotel ?? '',
                  receiptTextStyle,
                ),
                const SizedBox(height: 10),
                Text('Tickets:',
                    style:
                        receiptTextStyle.copyWith(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildReceiptRow('Senior',
                          provider.seniorCount.toString(), receiptTextStyle,
                          isLabelOnly: true),
                      _buildReceiptRow('Adult', provider.adultCount.toString(),
                          receiptTextStyle,
                          isLabelOnly: true),
                      _buildReceiptRow('Children',
                          provider.childCount.toString(), receiptTextStyle,
                          isLabelOnly: true),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  'Taxi',
                  provider.taxiChosen ? 'Chosen' : 'Not chosen',
                  receiptTextStyle,
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey[300], thickness: 1),
                const SizedBox(height: 18),
                Text(
                  "Total price:",
                  style: receiptTextStyle.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "\$${(provider.flightPrice + (provider.taxiChosen ? provider.taxiPrice : 0)).toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[200],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Pay',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Thank you for your purchase!',
                    style: receiptTextStyle.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, TextStyle style,
      {bool isLabelOnly = false}) {
    if (isLabelOnly) {
      return Text(
        '$label: $value',
        style: style,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label + ':', style: style),
        Flexible(
          child: Text(
            value,
            style: style,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
