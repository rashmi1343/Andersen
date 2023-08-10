import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themify_flutter/themify_flutter.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';
import '../models/post_model.dart';

import '../responses/AllDiscussionResponse.dart';
import '../screens/post_screen.dart';
import 'package:andersonappnew/Localization/localization/language_constants.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Posts extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Posts({Key? key}) : super(key: key);

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  List<Discussionthread> _foundedPost = [];

  bool isLoading = true;
  List data = [];

  List<Discussionthread> discussionthreads = [];
  // List<User> _users = <User>[];

  // Future<List<Data>>? futureData;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<List<Discussionthread>> getDiscussionData(
      String url, Map jsonMap) async {
    print('$url , $jsonMap');
    var token = await getToken();

    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      //    data = json.decode(response.body);
      Map decoded = json.decode(response.body);
      //print(decoded);

      // print(decoded);
      //   print(decoded['Discussionthreads']);

      // for (var objdiscussion in decoded["Discussionthreads"]) {
      //   if (kDebugMode) {
      //     print(objdiscussion['user_id']);
      //     print(objdiscussion['channel_id']);
      //     print(objdiscussion['featured']);
      //     print(objdiscussion['title']);
      //     print(objdiscussion['slug']);
      //     print(objdiscussion['content']);
      //   }

      //   data.add(objdiscussion['title'].toString());
      //   data.add(objdiscussion['content'].toString());
      //   // discussionthreads.add(Discussionthread(
      //   //     featured: objdiscussion['featured'],
      //   //     channelId: objdiscussion['channel_id'],
      //   //     content: objdiscussion['content'],
      //   //     title: objdiscussion['title'],
      //   //     slug: objdiscussion['slug'],
      //   //     userId: objdiscussion['user_id']));

      // Iterable iterableAlbum = json.decode(response.body);
      // var discussion = <Discussionthread>[];
      // List<Map<String, dynamic>>.from(decoded).map((Map model) {
      //   // Add Album mapped from json to List<Album>
      //   discussionthreads.add(Discussionthread.fromJson(model));
      // }).toList();

      // return jsonResponse
      // var jsonlist = jsonDecode(response.body);
      // for (var e in decoded["Discussionthreads"]) {
      //   discussionthreads.add(Discussionthread.fromJson(e));
      // }
      // ignore: unused_local_variable
      // final Map<String, dynamic> jsonlist = jsonDecode(response.body);
      // discussionthreads =
      //     jsonlist.map((e) => Discussionthread.fromJson(e)).toList();

      // Discussionthread threadsObj =
      // Discussionthread.fromJson(Map.from(jsonDecode(response.body)));

      final threadsObj = parseJson(response.body);
      // for (var e in threadsObj.discussionthreads) {
      //   discussionthreads.add(Discussionthread.fromJson(e));
      // }

      discussionthreads = threadsObj.discussionthreads;

      setState(() {
        isLoading = false;
        _foundedPost = [];
        _foundedPost = threadsObj.discussionthreads;
        print(_foundedPost);
      });

      return discussionthreads;
      // }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Post Init Called in post.dart');
    setState(() {
      Map paramdiscussion = {"methodname": "getalldisucssionthread"};
      //encode Map to JSON
      getData(paramdiscussion);
    });
  }

  Future<List<Discussionthread>> getData(
      Map<dynamic, dynamic> paramdiscussion) {
    return getDiscussionData(
        ApiConstant.url + ApiConstant.Endpoint, paramdiscussion);
  }

  onSearch(String search) {
    setState(() {
      _foundedPost = discussionthreads
          .where((post) => post.title.toLowerCase().contains(search))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        bottom: PreferredSize(
            child: Container(
              color: Colors.red,
              height: 3.0,
            ),
            preferredSize: const Size.fromHeight(4.0)),
        title: SizedBox(
          height: 38,
          child: TextField(
            onChanged: (value) => onSearch(value),
            decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                contentPadding: const EdgeInsets.all(0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none),
                hintStyle: const TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 46, 46, 46)),
                hintText: "Search Post"),
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 249, 247, 247),
        child: _foundedPost.isNotEmpty
            ? ListView.builder(
                itemCount: _foundedPost.length,
                itemBuilder: (context, index) {
                  //child: new Text(wordPair.asPascalCase), // Change this line to...
                  return postComponent(post: _foundedPost[index]);
                  // ... this line.
                })
            : const Center(
                //   child: Text(
                //   "No post found",
                //   style: TextStyle(color: Colors.white),
                // )
                child: CircularProgressIndicator()),
      ),
    );
  }

  Widget postComponent({required Discussionthread post}) {
    return Column(
        children: questions
            .map((question) => GestureDetector(
                  onTap: () {
                    /* Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PostScreen(
                                  discussionthread: post,
                                  // question: question,
                                )));*/
                  },
                  child: Expanded(
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 5.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(66, 249, 247, 247)
                                    .withOpacity(0.05),
                                offset: const Offset(0.0, 6.0),
                                blurRadius: 10.0,
                                spreadRadius: 0.10)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              height: 70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      // CircleAvatar(
                                      //   backgroundImage:
                                      //       AssetImage(question.author.imageUrl),
                                      //   radius: 22,
                                      // ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              child: Text(
                                                post.title,
                                                // discussionthread.title,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: .4),
                                              ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            // Row(
                                            //   children: <Widget>[
                                            //     Text(
                                            //       question.author.name,
                                            //       style: TextStyle(
                                            //           color: Colors.grey
                                            //               .withOpacity(0.6)),
                                            //     ),
                                            //     SizedBox(width: 15),
                                            //     Text(
                                            //       question.created_at,
                                            //       style: TextStyle(
                                            //           color: Colors.grey
                                            //               .withOpacity(0.6)),
                                            //     )
                                            //   ],
                                            // )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Icon(
                                  //   Themify.bookmark,
                                  //   color: Colors.grey.withOpacity(0.6),
                                  //   size: 26,
                                  // )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 80,
                              child: Center(
                                child: Text(
                                  // "120",
                                  "${post.content}..",
                                  style: TextStyle(
                                      color: Colors.grey.withOpacity(0.8),
                                      fontSize: 16,
                                      letterSpacing: .3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Themify.themify_favicon,
                                      color: Colors.grey.withOpacity(0.6),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      // "${question.votes} votes",
                                      "20",
                                      // "20 ${getTranslated(context, 'views') ?? ""}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.withOpacity(0.6),
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Themify.heart,
                                      color: Colors.grey.withOpacity(0.6),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      //"${question.repliesCount} replies",
                                      "20",
                                      // "20 ${getTranslated(context, 'replies') ?? ""}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.withOpacity(0.6)),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    // Icon(
                                    //   Themify.eye,
                                    //   color: Colors.grey.withOpacity(0.6),
                                    //   size: 18,
                                    // ),
                                    const SizedBox(width: 24.0),
                                    Text(
                                      // "30 views",""
                                      "",
                                      // "30 ${getTranslated(context, 'views') ?? ""}",
                                      // "${question.views} views",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.withOpacity(0.6)),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
            .toList());
  }
}
