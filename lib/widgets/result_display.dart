import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final String result;
  final String analysis;

  const ResultDisplay({
    super.key,
    required this.result,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle),
                SizedBox(width: 8),
                Text(
                  'Resultado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              result,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (analysis.isNotEmpty) ...[
              const Divider(height: 30),

              const Row(
                children: [
                  Icon(Icons.psychology),
                  SizedBox(width: 8),
                  Text(
                    'Radar Matemático',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                analysis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}