import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myapps/pages/loading_Screen.dart';
import 'package:myapps/security/confAPI.dart';

Future<List<Map<String, String>>> getOrganizations() async {
  final String url = getApiUrl('/select/facility');
  // final String url;
  // if (Platform.isAndroid) {
  //   url = 'http://10.0.2.2/select/facility';
  // } else if (Platform.isIOS) {
  //   url = 'http://127.0.0.1/select/facility';
  // } else {
  //   throw UnsupportedError('지원되지 않는 환경입니다.');
  // }

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, String>> organizations = data
          .map<Map<String, String>>((item) => {
                'id': item['fa_id'].toString(),
                'name': item['fa_name'] as String,
                'address': item['fa_address'] as String,
              })
          .toList();
      return organizations;
    } else {
      throw Exception('기관정보를 불러오는데 실패했습니다.');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

class SearchOrganizationPage extends StatefulWidget {
  @override
  _SearchOrganizationPageState createState() => _SearchOrganizationPageState();
}

class _SearchOrganizationPageState extends State<SearchOrganizationPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _organizations = [];
  List<Map<String, String>> _filteredOrganizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    try {
      final List<Map<String, String>> organizations = await getOrganizations();
      if (mounted) {
        setState(() {
          _organizations = organizations;
          _filteredOrganizations = organizations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterOrganizations(String query) {
    final filtered = _organizations.where((organization) {
      return organization['name']!.toLowerCase().contains(query.toLowerCase());
    }).toList();
    if (mounted) {
      setState(() {
        _filteredOrganizations = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("소속 검색"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "기관 검색",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _filterOrganizations,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Expanded(child: LoadingScreen())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredOrganizations.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_filteredOrganizations[index]['name']!),
                          subtitle:
                              Text(_filteredOrganizations[index]['address']!),
                          onTap: () {
                            Navigator.pop(context, {
                              'name': _filteredOrganizations[index]['name']!,
                              'id': _filteredOrganizations[index]['id']!,
                            });
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
