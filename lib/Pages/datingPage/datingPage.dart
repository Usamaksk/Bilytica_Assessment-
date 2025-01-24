import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DatingPage extends StatefulWidget {
  @override
  _DatingPageState createState() => _DatingPageState();
}

class _DatingPageState extends State<DatingPage> {
  bool isSearching = false;
  String searchQuery = "";

  void _onSearch(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      searchQuery = query.toLowerCase();
      _filteredData = _applySearchFilter();
    });
  }

  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://randomuser.me/api/?page=$_page&results=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> newData = (data['results'] as List)
          .map((user) => {
        'name': '${user['name']['first']} ${user['name']['last']}',
        'age': user['dob']['age'],
        'email': user['email'],
        'location': user['location']['city'],
        'picture': user['picture']['thumbnail'],
      })
          .toList();

      setState(() {
        _data.addAll(newData);
        _filteredData = _applySearchFilter();
        _page++;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _applySearchFilter() {
    if (isSearching && searchQuery.isNotEmpty) {
      return _data
          .where((item) =>
      item['name'].toLowerCase().contains(searchQuery) ||
          item['location'].toLowerCase().contains(searchQuery))
          .toList();
    }
    return List.from(_data);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
        double screenheight = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _filteredData.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredData.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final item = _filteredData[index];

                return SizedBox(
                  height: screenheight * 0.60,
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.deepPurpleAccent,
                            backgroundImage: NetworkImage(item['picture']),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                   " ${item['name']} - ${ item['age']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.15,),
                                  Icon(Icons.mark_unread_chat_alt_sharp,color: Colors.deepPurpleAccent,),
                                  SizedBox(width: screenWidth * 0.01,),
                                  Icon(Icons.call,color: Colors.deepPurpleAccent,)

                                ],
                              ),
                              Text('Location: ${item['location']}'),
                              Text('Email: ${item['email']}'),
                            ],
                          ),
                        ],
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

  PreferredSize _appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(170),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: _boxDecoration(),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    "Dating List",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  centerTitle: true,
                  leading: BackButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                const SizedBox(height: 15),
                _searchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: screenWidth * 3.6,
        child: TextField(
          autofocus: false,
          onChanged: _onSearch,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return const BoxDecoration(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(25),
        top: Radius.circular(25),
      ),
      color: Colors.deepPurpleAccent,
    );
  }
}
