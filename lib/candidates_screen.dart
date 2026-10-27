
import 'package:flutter/material.dart';

class CandidatesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> candidates;

  const CandidatesScreen({
    super.key,
    required this.candidates,
  });

  @override
  State<CandidatesScreen> createState() =>
      _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final TextEditingController candidateController =
  TextEditingController();

  String message = '';

  String cleanName(String name) {
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) =>
    word[0].toUpperCase() +
        word.substring(1).toLowerCase())
        .join(' ');
  }

  void addCandidate() {
    final String name = cleanName(candidateController.text);

    if (name.isEmpty) {
      setState(() {
        message = 'Please enter a candidate name.';
      });
      return;
    }

    final bool alreadyExists = widget.candidates.any(
          (candidate) =>
      (candidate['name'] as String).toLowerCase() ==
          name.toLowerCase(),
    );

    if (alreadyExists) {
      setState(() {
        message = '$name is already a candidate.';
      });
      return;
    }

    setState(() {
      widget.candidates.add({
        'name': name,
        'votes': 0,
      });

      candidateController.clear();
      message = '$name was added successfully.';
    });
  }

  void removeCandidate(int index) {
    final candidate = widget.candidates[index];

    if (candidate['votes'] > 0) {
      setState(() {
        message =
        '${candidate['name']} cannot be removed because they have votes.';
      });
      return;
    }

    setState(() {
      final String removedName = candidate['name'];
      widget.candidates.removeAt(index);
      message = '$removedName was removed.';
    });
  }

  @override
  void dispose() {
    candidateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Candidates',
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
            const Text(
              'Add a Candidate',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: candidateController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Candidate name',
                hintText: 'Enter a name',
                prefixIcon: const Icon(Icons.person_add),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => addCandidate(),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addCandidate,
                icon: const Icon(Icons.add),
                label: const Text('Add Candidate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ),

            if (message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(message),
              ),
            ],

            const SizedBox(height: 28),

            const Text(
              'Current Candidates',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (widget.candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No candidates added yet.'),
              ),

            ...List.generate(widget.candidates.length, (index) {
              final candidate = widget.candidates[index];
              final int votes = candidate['votes'] as int;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(
                      Icons.person,
                      color: Colors.deepOrange,
                    ),
                  ),
                  title: Text(
                    candidate['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Votes: $votes'),
                  trailing: IconButton(
                    tooltip: votes > 0
                        ? 'Cannot remove a candidate with votes'
                        : 'Remove candidate',
                    icon: Icon(
                      Icons.delete_outline,
                      color: votes > 0 ? Colors.grey : Colors.red,
                    ),
                    onPressed: () => removeCandidate(index),
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
