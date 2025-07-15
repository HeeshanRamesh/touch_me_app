import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gift.dart';
import '../models/purchased_gift_card.dart';


Future<List<GiftCard>> fetchGiftCardsByMerchant(
  String merchantId,
  String token,
) async {
  final url = Uri.parse(
    'http://api.touchmeapp.com/api/gift-cards/merchant/$merchantId',
  );
  final res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', // Only if needed
      'Content-Type': 'application/json',
    },
  );
  print("Gift card API status code: ${res.statusCode}");
  print("Gift card API body: ${res.body}");

  if (res.statusCode == 200) {
    final List<dynamic> data = jsonDecode(res.body);
    print("Decoded data: $data");
    return data.map((e) => GiftCard.fromJson(e)).toList();
  } else {
    print(
      "Gift card API failed with status: ${res.statusCode}, body: ${res.body}",
    );
    throw Exception('Failed to load gift cards');
  }
}

Future<List<PurchasedGiftCard>> fetchMyGiftCards(String token) async {
  final url = Uri.parse('http://api.touchmeapp.com/api/purchased-gift-cards/my');
  final res = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.map((e) => PurchasedGiftCard.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load your gift cards');
  }
}
