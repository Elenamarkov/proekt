import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';

  // =============== USERS - LOGIN ===============
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // =============== USERS - REGISTER ===============
  static Future<UserResponse> registerUser(
      UserRegistration registration) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registration.toJson()),
      );

      if (response.statusCode == 201) {
        return UserResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // =============== FLIGHTS ===============
  static Future<List<Flight>> searchFlights({
    String? departureIata,
    String? arrivalIata,
    DateTime? flightDate,
    int limit = 100,
  }) async {
    final queryParams = <String, String>{};
    if (departureIata != null) queryParams['departureIata'] = departureIata;
    if (arrivalIata != null) queryParams['arrivalIata'] = arrivalIata;
    if (flightDate != null)
      queryParams['flightDate'] = flightDate.toIso8601String().split('T')[0];
    queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$_baseUrl/flights/search')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Flight.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load flights: ${response.statusCode}');
    }
  }

  static Future<List<Flight>> getCheapestFlights({
    required String departureIata,
    required String arrivalIata,
    int limit = 10,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/flights/cheapest').replace(queryParameters: {
      'departureIata': departureIata,
      'arrivalIata': arrivalIata,
      'limit': limit.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Flight.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load cheapest flights: ${response.statusCode}');
    }
  }

  // =============== HOTELS ===============
  static Future<List<Hotel>> getAllHotels() async {
    final response = await http.get(Uri.parse('$_baseUrl/hotels'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  }

  static Future<List<Hotel>> getHotelsByCity(String city) async {
    final response = await http.get(Uri.parse('$_baseUrl/hotels/city/$city'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  }

  // =============== TAXIS ===============
  static Future<List<Taxi>> getAllTaxis() async {
    final response = await http.get(Uri.parse('$_baseUrl/taxis'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Taxi.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load taxis: ${response.statusCode}');
    }
  }

  static Future<List<Taxi>> getCheapestTaxis() async {
    final response = await http.get(Uri.parse('$_baseUrl/taxis/cheapest'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Taxi.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cheapest taxis: ${response.statusCode}');
    }
  }

  // =============== BOOKINGS ===============
  static Future<BookingResponse> createBooking(BookingRequest booking) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(booking.toJson()),
    );

    if (response.statusCode == 201) {
      return BookingResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error.values.first ?? 'Validation failed');
    } else {
      throw Exception('Failed to create booking: ${response.statusCode}');
    }
  }

  static Future<List<BookingResponse>> getUserBookings(int userId) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/bookings/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => BookingResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings: ${response.statusCode}');
    }
  }

  // =============== AIRPORTS ===============
  static Future<List<Airport>> getAllAirports() async {
    final response = await http.get(Uri.parse('$_baseUrl/airports'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Airport.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load airports: ${response.statusCode}');
    }
  }

  static Future<List<Airport>> searchAirports(String query) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/airports/search?q=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Airport.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search airports: ${response.statusCode}');
    }
  }
}

// =============== MODELS ===============
class Flight {
  final int id;
  final String flightNumber;
  final String flightIata;
  final String flightDate;
  final String flightStatus;
  final String airlineName;
  final String airlineIata;
  final String departureAirportName;
  final String departureAirportIata;
  final String departureCity;
  final String departureCountry;
  final String arrivalAirportName;
  final String arrivalAirportIata;
  final String arrivalCity;
  final String arrivalCountry;
  final double basePrice;
  final int availableSeats;
  final String imageUrl;
  final int durationMinutes;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.flightIata,
    required this.flightDate,
    required this.flightStatus,
    required this.airlineName,
    required this.airlineIata,
    required this.departureAirportName,
    required this.departureAirportIata,
    required this.departureCity,
    required this.departureCountry,
    required this.arrivalAirportName,
    required this.arrivalAirportIata,
    required this.arrivalCity,
    required this.arrivalCountry,
    required this.basePrice,
    required this.availableSeats,
    required this.imageUrl,
    required this.durationMinutes,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] as int,
      flightNumber: json['flightNumber'] as String,
      flightIata: json['flightIata'] as String,
      flightDate: json['flightDate'] as String,
      flightStatus: json['flightStatus'] as String,
      airlineName: json['airlineName'] as String,
      airlineIata: json['airlineIata'] as String,
      departureAirportName: json['departureAirportName'] as String,
      departureAirportIata: json['departureAirportIata'] as String,
      departureCity: json['departureCity'] as String,
      departureCountry: json['departureCountry'] as String,
      arrivalAirportName: json['arrivalAirportName'] as String,
      arrivalAirportIata: json['arrivalAirportIata'] as String,
      arrivalCity: json['arrivalCity'] as String,
      arrivalCountry: json['arrivalCountry'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      availableSeats: json['availableSeats'] as int,
      imageUrl: json['imageUrl'] ?? 'assets/images/flight_image.png',
      durationMinutes: json['durationMinutes'] as int? ?? 120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flightNumber': flightNumber,
      'flightIata': flightIata,
      'flightDate': flightDate,
      'flightStatus': flightStatus,
      'airlineName': airlineName,
      'airlineIata': airlineIata,
      'departureAirportName': departureAirportName,
      'departureAirportIata': departureAirportIata,
      'departureCity': departureCity,
      'departureCountry': departureCountry,
      'arrivalAirportName': arrivalAirportName,
      'arrivalAirportIata': arrivalAirportIata,
      'arrivalCity': arrivalCity,
      'arrivalCountry': arrivalCountry,
      'basePrice': basePrice,
      'availableSeats': availableSeats,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
    };
  }
}

class Hotel {
  final int id;
  final String name;
  final double pricePerNight;
  final String city;
  final String imageUrl;

  Hotel({
    required this.id,
    required this.name,
    required this.pricePerNight,
    required this.city,
    required this.imageUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as int,
      name: json['name'] as String,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      city: json['city'] as String,
      imageUrl: json['imageUrl'] ?? 'assets/images/hotel_image.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pricePerNight': pricePerNight,
      'city': city,
      'imageUrl': imageUrl,
    };
  }
}

class Taxi {
  final int id;
  final String provider;
  final String type;
  final double price;
  final String imageUrl;
  final String estimatedTime;

  Taxi({
    required this.id,
    required this.provider,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.estimatedTime,
  });

  factory Taxi.fromJson(Map<String, dynamic> json) {
    return Taxi(
      id: json['id'] as int,
      provider: json['provider'] as String,
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? 'assets/images/taxi_image.png',
      estimatedTime: json['estimatedTime'] ?? '10-15 min',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
      'estimatedTime': estimatedTime,
    };
  }
}

class BookingRequest {
  final int flightId;
  final int userId;
  final int? hotelId;
  final int? hotelNights;
  final int? taxiId;
  final int seniorCount;
  final int adultCount;
  final int childCount;
  final String contactEmail;
  final String contactPhone;

  BookingRequest({
    required this.flightId,
    required this.userId,
    this.hotelId,
    this.hotelNights,
    this.taxiId,
    this.seniorCount = 0,
    required this.adultCount,
    this.childCount = 0,
    required this.contactEmail,
    required this.contactPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'flightId': flightId,
      'userId': userId,
      if (hotelId != null) 'hotelId': hotelId,
      if (hotelNights != null) 'hotelNights': hotelNights,
      if (taxiId != null) 'taxiId': taxiId,
      'seniorCount': seniorCount,
      'adultCount': adultCount,
      'childCount': childCount,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
    };
  }
}

class BookingResponse {
  final int id;
  final String bookingReference;
  final String userFullName;
  final String userEmail;
  final double totalPrice;
  final String status;
  final String bookingDate;

  BookingResponse({
    required this.id,
    required this.bookingReference,
    required this.userFullName,
    required this.userEmail,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] as int,
      bookingReference: json['bookingReference'] as String,
      userFullName: json['userFullName'] as String,
      userEmail: json['userEmail'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      bookingDate: json['bookingDate'] as String,
    );
  }
}

class UserRegistration {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;

  UserRegistration({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

class UserResponse {
  final int id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final bool isActive;
  final String? token;

  UserResponse({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.isActive,
    this.token,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      isActive: json['isActive'] as bool,
      token: json['token'] as String?,
    );
  }
}

class Airport {
  final int id;
  final String iataCode;
  final String name;
  final String city;
  final String country;

  Airport({
    required this.id,
    required this.iataCode,
    required this.name,
    required this.city,
    required this.country,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'] as int,
      iataCode: json['iataCode'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
    );
  }
}
