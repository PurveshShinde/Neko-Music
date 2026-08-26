import 'package:flutter/material.dart';
import '../widgets/mini_player_widget.dart';
import 'listen_together_settings_screen.dart';

class ListenTogetherScreen extends StatefulWidget {
  const ListenTogetherScreen({super.key});

  @override
  State<ListenTogetherScreen> createState() => _ListenTogetherScreenState();
}

class _ListenTogetherScreenState extends State<ListenTogetherScreen> {
  int _selectedTabIndex = 0; // 0 for Create, 1 for Join

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
        title: const Text(
          'Listen Together',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Disconnect',
              style: TextStyle(
                color: Color(0xFFA5B4FC), // Light blue text color
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                // ── Note Text ──
                Text(
                  'Note: You may get disconnected if you create a room while no music is playing and then switch to another app.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ── Tab Container ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1F29),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Tab Switcher
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTab(
                                title: 'Create',
                                icon: Icons.add,
                                isSelected: _selectedTabIndex == 0,
                                onTap: () => setState(() => _selectedTabIndex = 0),
                              ),
                            ),
                            Expanded(
                              child: _buildTab(
                                title: 'Join',
                                icon: Icons.login_rounded,
                                isSelected: _selectedTabIndex == 1,
                                onTap: () => setState(() => _selectedTabIndex = 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tab Content
                      if (_selectedTabIndex == 0) _buildCreateForm() else _buildJoinForm(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Settings Tile ──
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListenTogetherSettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F29),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Settings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Configure server, username, and more',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── How it Works Section ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1F29),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Little drag handle indicator
                      Center(
                        child: Container(
                          width: 32,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Text(
                        'How it Works',
                        style: TextStyle(
                          color: Color(0xFFA5B4FC), // Light blue
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildHowItWorksItem(
                        title: '1. Create a Room',
                        description:
                            'Start a session and share the unique room code with your friends.',
                      ),
                      const SizedBox(height: 20),
                      _buildHowItWorksItem(
                        title: '2. Join a Friend',
                        description:
                            'Enter their room code to join their session instantly.',
                      ),
                      const SizedBox(height: 20),
                      _buildHowItWorksItem(
                        title: '3. Sync Playback',
                        description:
                            'The host controls the music. Everyone listens in perfect sync!',
                      ),
                    ],
                  ),
                ),

                // Bottom padding
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        child: MiniPlayerWidget(),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA5B4FC) : Colors.transparent, // Light blue if active
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.white.withValues(alpha: 0.6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          label: 'Username',
          initialValue: 'Ciel',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, color: Color(0xFF1E3A8A)),
          label: const Text(
            'Create',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA5B4FC), // Light blue
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          label: 'Username',
          initialValue: 'Ciel',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Room code',
          initialValue: '',
          icon: Icons.people_outline_rounded,
          showClear: false,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: null, // Disabled in screenshot
          icon: Icon(Icons.login_rounded, color: Colors.white.withValues(alpha: 0.3)),
          label: Text(
            'Join',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData icon,
    bool showClear = true,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFA5B4FC), size: 22), // Light blue icon
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: initialValue,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (showClear && initialValue.isNotEmpty)
                const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
        // Floating Label
        Positioned(
          left: 16,
          top: 0,
          child: Container(
            color: const Color(0xFF1E1F29), // Match container background
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksItem({required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
