import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

Future<dynamic> getAccessToken() async {
  const CLIENT_ID = "db67d8c4e02549969e75fc88dcb11d13";
  const REDIRECT_URI = "overlap://callback";

  const chars = "abcdefghijklmnopqrstuvwxyz0123456789_.-~";

  final rnd = Random();
  final codeVerifier = String.fromCharCodes(
    Iterable.generate(
      128,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ),
  );

  final codeHash = sha256.convert(utf8.encode(codeVerifier));
  final codeChallenge = base64Url
      .encode(codeHash.bytes)
      .replaceAll("=", "")
      .replaceAll("+", "-")
      .replaceAll("/", "_");

  final authCodeResponse = await FlutterWebAuth.authenticate(
    url: "https://accounts.spotify.com/authorize" +
        "?client_id=$CLIENT_ID" +
        "&response_type=code" +
        "&redirect_uri=${Uri.encodeComponent(REDIRECT_URI)}" +
        "&code_challenge_method=S256" +
        "&code_challenge=$codeChallenge" +
        "&scope=${Uri.encodeComponent(/*"user-read-private user-read-email " + */"user-follow-read")}",
    callbackUrlScheme: "overlap",
  );

  final error = Uri.parse(authCodeResponse).queryParameters["error"];
  if (error != null) {
    return {"error": error};
  }
  final code = Uri.parse(authCodeResponse).queryParameters["code"];

  // Use authorization code to get access token
  final accessTokenResponse = await http.post(
    "https://accounts.spotify.com/api/token",
    body: {
      "client_id": CLIENT_ID,
      "grant_type": "authorization_code",
      "code": code,
      "redirect_uri": REDIRECT_URI,
      "code_verifier": codeVerifier,
    },
  );
  if (accessTokenResponse.statusCode != 200) {
    return {
      "error": jsonDecode(accessTokenResponse.body)["error"],
      "error_description":
          jsonDecode(accessTokenResponse.body)["error_description"]
    };
  }

  final accessToken = jsonDecode(accessTokenResponse.body)["access_token"];

  return accessToken;
}
