import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FollowedArtists extends StatelessWidget {
  final List<dynamic> artists;

  FollowedArtists(this.artists);

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) {
      return Text("Not following any artists");
    }

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text("Here's ${artists.length} artists you follow:"),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: artists.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final artist = artists[index];
                return ListTile(
                  title: Text(artist["name"]),
                  leading: artist["images"].length > 0
                      ? Container(
                          constraints: BoxConstraints.expand(width: 64),
                          child: Image.network(
                            artist["images"][0]["url"],
                            height: 64,
                          ),
                        )
                      : SizedBox.fromSize(
                          size: Size.square(64),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
