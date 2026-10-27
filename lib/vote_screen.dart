
import 'dart:convert';
import 'election_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'results_screen.dart';
import 'candidates_screen.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final TextEditingController voterController =
  TextEditingController();

  final List<Map<String, dynamic>> candidates = [
    {'name': 'Sarah', 'votes': 0},
    {'name': 'Juwairia', 'votes': 0},
    {'name': 'Ola', 'votes': 0},
  ];

  final Set<String> votersWhoVoted = {};

  String? registeredVoter;
  String message = '';
  bool isLoadingData = true;

  int get totalVotes {
    return candidates.fold<int>(
      0,
          (total, candidate) =>
      total + (candidate['votes'] as int),
    );
  }

  @override
  void initState() {
    super.initState();
    loadElectionData();
  }

  Future<void> loadElectionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedCandidates =
      prefs.getString('election_candidates');
      final savedVoters =
      prefs.getString('election_voters');

      if (savedCandidates != null) {
        final List<dynamic> decodedCandidates =
        jsonDecode(savedCandidates) as List<dynamic>;

        candidates
          ..clear()
          ..addAll(
            decodedCandidates.map((item) {
              final candidate =
              Map<String, dynamic>.from(item as Map);

              return {
                'name': candidate['name'] as String,
                'votes': (candidate['votes'] as num).toInt(),
              };
            }),
          );
      }

      if (savedVoters != null) {
        final List<dynamic> decodedVoters =
        jsonDecode(savedVoters) as List<dynamic>;

        votersWhoVoted
          ..clear()
          ..addAll(decodedVoters.cast<String>());
      }
    } catch (e) {
      message = 'Could not load saved election data.';
    }

    if (!mounted) return;

    setState(() {
      isLoadingData = false;
    });
  }

  Future<void> saveElectionData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'election_candidates',
      jsonEncode(candidates),
    );

    await prefs.setString(
      'election_voters',
      jsonEncode(votersWhoVoted.toList()),
    );
  }

  String cleanName(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    return words.map((word) {
      return word[0].toUpperCase() +
          word.substring(1).toLowerCase();
    }).join(' ');
  }

  void registerVoter() {
    final name = cleanName(voterController.text);

    if (name.isEmpty) {
      setState(() {
        registeredVoter = null;
        message = 'Please enter your name.';
      });
      return;
    }

    final voterKey = name.toLowerCase();

    if (votersWhoVoted.contains(voterKey)) {
      setState(() {
        registeredVoter = null;
        message = '$name has already voted.';
      });
      return;
    }

    setState(() {
      registeredVoter = name;
      voterController.text = name;
      message = 'Welcome, $name! You can now vote.';
    });
  }

  Future<void> castVote(int index) async {
    if (registeredVoter == null) {
      setState(() {
        message = 'Please register your name first.';
      });
      return;
    }

    final voterKey = registeredVoter!.toLowerCase();

    if (votersWhoVoted.contains(voterKey)) {
      setState(() {
        message = '$registeredVoter has already voted.';
      });
      return;
    }

    setState(() {
      candidates[index]['votes'] =
          (candidates[index]['votes'] as int) + 1;

      votersWhoVoted.add(voterKey);

      message =
      '$registeredVoter voted for ${candidates[index]['name']}.';

      registeredVoter = null;
      voterController.clear();
    });

    await saveElectionData();
  }

  Future<void> openCandidateManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatesScreen(
          candidates: candidates,
        ),
      ),
    );

    if (!mounted) return;

    await saveElectionData();

    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    voterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Election',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'View Results',
            onPressed: isLoadingData
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultsScreen(
                    candidates: candidates,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Manage Candidates',
            onPressed: isLoadingData
                ? null
                : openCandidateManagement,
          ),
        ],
      ),
      body: isLoadingData
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Register to Vote',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your name before choosing a candidate.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: voterController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Voter name',
                hintText: 'e.g. Aline Uwase',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => registerVoter(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registerVoter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text('Register'),
              ),
            ),
            const SizedBox(height: 12),
            if (message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: message.contains('already voted') ||
                      message.contains('Please') ||
                      message.contains('Could not')
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(message),
              ),
            const SizedBox(height: 28),
            const Text(
              'Choose Your Candidate',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No candidates available.'),
              ),
            ...List.generate(candidates.length, (index) {
              final candidate = candidates[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate['name'] as String,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Votes: ${candidate['votes']}',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => castVote(index),
                          icon: const Icon(Icons.how_to_vote),
                          label: const Text('Vote'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total votes',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalVotes',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),

                  ],
                ),
              ),
            ),
            const ElectionInfo(),
          ],
        ),
      ),
    );
  }
}
