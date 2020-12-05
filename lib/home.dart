import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:overlap/getAuthToken.dart';
import 'package:overlap/widgets/FollowedArtists.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String accessToken;
  dynamic user;
  List<dynamic> followedArtists;

  void getUser() async {
    final userResponse = await http.get(
      "https://api.spotify.com/v1/me",
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    setState(() {
      this.user = jsonDecode(userResponse.body);
    });
  }

  void getFollowedArtists() async {
    final followedArtistsResponse = await http.get(
      "https://api.spotify.com/v1/me/following?type=artist",
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    final List<dynamic> followedArtists =
        jsonDecode(followedArtistsResponse.body)["artists"]["items"];

    setState(() {
      this.followedArtists = followedArtists;
    });
  }

  void logIn(BuildContext context) async {
    final accessTokenOrError = await getAccessToken();
    if (!(accessTokenOrError is String)) {
      var message = accessTokenOrError.error;
      if (accessTokenOrError["error_description"] != null) {
        message += ": " + accessTokenOrError["error_description"];
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      accessToken = accessTokenOrError;
      // TODO: Refresh token stuff
    });
    getUser();
    getFollowedArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spotify app???"),
      ),
      body: Center(
        child: accessToken == null
            ? Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => logIn(context),
                  child: Text("Log in"),
                ),
              )
            : user == null
                ? Text("Getting user info…")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user["images"].length > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 64, bottom: 16),
                          child: Image.network(
                            user["images"][0]["url"],
                            width: 128,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text("Hello, ${user["display_name"]}!"),
                      ),
                      if (followedArtists != null)
                        FollowedArtists(followedArtists),
                    ],
                  ),
      ),
    );
  }
}
