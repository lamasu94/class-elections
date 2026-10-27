
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ElectionInfo extends StatefulWidget {
  const ElectionInfo({super.key});

  @override
  State<ElectionInfo> createState() => _ElectionInfoState();
}

class _ElectionInfoState extends State<ElectionInfo> {
  String? title;
  String? description;
  String? article;
  String? articleUrl;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchElectionInfo();
  }

  Future<void> fetchElectionInfo() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/Election',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data =
      jsonDecode(response.body) as Map<String, dynamic>;

      if (data['extract'] == null || data['title'] == null) {
        throw Exception('The article information is unavailable.');
      }

      if (!mounted) return;

      setState(() {
        title = data['title'] as String;
        description = data['description'] as String?;
        article = data['extract'] as String;
        articleUrl =
        (data['content_urls'] as Map<String, dynamic>?)?['desktop']
        ?['page'] as String?;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'Could not load election information. '
            'Check your internet connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.public,
                  color: Colors.deepOrange,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Election Information',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh information',
                  onPressed: isLoading ? null : fetchElectionInfo,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const Divider(),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                      SizedBox(height: 12),
                      Text('Loading election information...'),
                    ],
                  ),
                ),
              )
            else if (errorMessage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.deepOrange,
                    size: 32,
                  ),
                  const SizedBox(height: 10),
                  Text(errorMessage!),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: fetchElectionInfo,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Election',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description != null &&
                      description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    article ?? '',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Source: Wikipedia',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  if (articleUrl != null)
                    SelectableText(
                      articleUrl!,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
