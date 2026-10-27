
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;

  const ResultsScreen({
    super.key,
    required this.candidates,
  });

  @override
  Widget build(BuildContext context) {
    final rankedCandidates =
    List<Map<String, dynamic>>.from(candidates);

    rankedCandidates.sort(
          (a, b) => (b['votes'] as int).compareTo(a['votes'] as int),
    );

    final int totalVotes = rankedCandidates.fold<int>(
      0,
          (total, candidate) => total + (candidate['votes'] as int),
    );

    final int highestVotes = rankedCandidates.isEmpty
        ? 0
        : rankedCandidates.first['votes'] as int;

    final leaders = rankedCandidates
        .where((candidate) =>
    (candidate['votes'] as int) == highestVotes)
        .toList();

    final bool isTie = totalVotes > 0 && leaders.length > 1;

    final String resultMessage;

    if (totalVotes == 0) {
      resultMessage = 'No votes have been cast yet.';
    } else if (isTie) {
      resultMessage = 'It is a tie!';
    } else {
      resultMessage = '${leaders.first['name']} is the winner!';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Election Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      totalVotes == 0
                          ? Icons.how_to_vote
                          : isTie
                          ? Icons.groups
                          : Icons.emoji_events,
                      size: 48,
                      color: Colors.deepOrange,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      resultMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (totalVotes > 0 && isTie) ...[
                      const SizedBox(height: 8),
                      Text(
                        leaders
                            .map((candidate) => candidate['name'])
                            .join(' and '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],

                    const SizedBox(height: 12),

                    Text(
                      'Total votes: $totalVotes',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Candidate Rankings',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (rankedCandidates.isEmpty)
              const Text('No candidates available.'),

            ...List.generate(rankedCandidates.length, (index) {
              final candidate = rankedCandidates[index];
              final int votes = candidate['votes'] as int;

              final double percentage = totalVotes == 0
                  ? 0
                  : votes / totalVotes * 100;

              final double barValue = totalVotes == 0
                  ? 0
                  : votes / highestVotes.clamp(1, double.infinity);

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            foregroundColor: Colors.deepOrange,
                            child: Text('${index + 1}'),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              candidate['name'] as String,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            '$votes votes',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Share of votes'),
                          Text('${percentage.toStringAsFixed(1)}%'),
                        ],
                      ),

                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: barValue,
                          minHeight: 12,
                          backgroundColor: Colors.orange.shade100,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Voting'),
            ),
          ],
        ),
      ),
    );
  }
}
