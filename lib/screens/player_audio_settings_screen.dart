import 'package:flutter/material.dart';

class PlayerAudioSettingsScreen extends StatelessWidget {
  const PlayerAudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Player and Audio', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('STREAMING ENGINE'),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F29),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto-managed (NewPipe / YT Explode)',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Slothify now automatically selects the best extraction engine for your device to avoid 403 Forbidden errors. No manual configuration required.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
