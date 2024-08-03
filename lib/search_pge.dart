import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'filter_page.dart'; // Ensure you have this import

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List internships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInternships();
  }

  fetchInternships({String? profile, String? city, String? duration}) async {
    Map<String, String> queryParams = {};
    if (profile != null && profile.isNotEmpty) {
      queryParams['profile'] = profile;
    }
    if (city != null && city.isNotEmpty) {
      queryParams['city'] = city;
    }
    if (duration != null && duration.isNotEmpty) {
      queryParams['duration'] = duration;
    }

    Uri uri = Uri.https('internshala.com', '/flutter_hiring/search', queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);  // Print the entire response to see the structure
        if (data.containsKey('internships_meta')) {
          final internshipsMeta = data['internships_meta'] as Map<String, dynamic>;
          setState(() {
            internships = internshipsMeta.values.toList();
            isLoading = false;
          });
        } else {
          // Handle the case where 'internships_meta' key is not present
          setState(() {
            internships = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load internships');
      }
    } catch (e) {
      print('Error fetching internships: $e');
      setState(() {
        isLoading = false;
        internships = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internships'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final filters = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FilterPage()),
              );
              if (filters != null) {
                fetchInternships(
                  profile: filters['profile'],
                  city: filters['city'],
                  duration: filters['duration'],
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : internships.isEmpty
              ? Center(child: Text('No internships found'))
              : ListView.builder(
                  itemCount: internships.length,
                  itemBuilder: (context, index) {
                    final internship = internships[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                internship['title'] ?? 'No Title',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                                  SizedBox(width: 4),
                                  Text(
                                    internship['location'] ?? 'No Location',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                                  SizedBox(width: 4),
                                  Text(
                                    'Duration: ${internship['duration'] ?? 'No Duration'}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                internship['company_name'] ?? 'No Company',
                                style: TextStyle(
                                  color: Colors.grey[900],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Add other fields as needed
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
