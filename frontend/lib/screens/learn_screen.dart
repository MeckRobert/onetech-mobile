import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Lesson> _lessons = [];
  List<Lesson> _filteredLessons = [];
  String _searchQuery = '';
  String _activeCategory = 'All';

  // Categories with matching emojis
  final List<Map<String, String>> _categories = [
    {"name": "All", "emoji": "📚"},
    {"name": "Business", "emoji": "🏢"},
    {"name": "Investing", "emoji": "📈"},
    {"name": "Saving", "emoji": "💰"},
    {"name": "Tax", "emoji": "🏛️"},
  ];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      final lessons = await _apiService.fetchLessons();
      setState(() {
        _lessons = lessons;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load lessons: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _applyFilters() {
    List<Lesson> temp = _lessons;

    // Apply Search Query
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((l) => l.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                              l.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply Category Filter
    if (_activeCategory != 'All') {
      temp = temp.where((l) => l.category.toLowerCase() == _activeCategory.toLowerCase()).toList();
    }

    setState(() {
      _filteredLessons = temp;
    });
  }

  void _openLessonReader(Lesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppStyles.accentGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lesson.level.toUpperCase(),
                      style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(lesson.title, style: AppStyles.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, color: AppStyles.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(lesson.duration, style: AppStyles.bodyMuted),
                  const SizedBox(width: 16),
                  Icon(Icons.label_outline_rounded, color: AppStyles.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(lesson.category, style: AppStyles.bodyMuted),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),

              // Content Reader Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.description,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        lesson.content,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppStyles.textMuted.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Financial Education", style: AppStyles.titleLarge),
                const Icon(Icons.school, color: AppStyles.accentGold),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applyFilters();
                });
              },
              decoration: AppStyles.inputDecoration(
                "Search lessons...",
                prefixIcon: const Icon(Icons.search, color: AppStyles.textMuted),
              ),
            ),
            const SizedBox(height: 16),

            // Category grids
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final bool isActive = _activeCategory == cat["name"];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeCategory = cat["name"]!;
                        _applyFilters();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? AppStyles.accentGold : const Color(0xFF1E1E22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? AppStyles.accentGold : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(cat["emoji"]!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            cat["name"]!,
                            style: GoogleFonts.outfit(
                              color: isActive ? Colors.black : Colors.white,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Lessons List
            Text("Popular Lessons", style: AppStyles.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.accentGold))
                  : _filteredLessons.isEmpty
                      ? const Center(child: Text("No lessons matching filter", style: TextStyle(color: AppStyles.textMuted)))
                      : ListView.builder(
                          itemCount: _filteredLessons.length,
                          itemBuilder: (context, index) {
                            final lesson = _filteredLessons[index];
                            Color levelColor = Colors.green;
                            if (lesson.level.toLowerCase() == 'intermediate') {
                              levelColor = Colors.orange;
                            } else if (lesson.level.toLowerCase() == 'advanced') {
                              levelColor = AppStyles.redExpense;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: AppStyles.cardDecoration,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: AppStyles.accentGold.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.bookmark_added_rounded, color: AppStyles.accentGold, size: 24),
                                ),
                                title: Text(
                                  lesson.title,
                                  style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      lesson.duration,
                                      style: AppStyles.bodyMuted,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: levelColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        lesson.level,
                                        style: GoogleFonts.outfit(color: levelColor, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, color: AppStyles.textMuted, size: 16),
                                onTap: () => _openLessonReader(lesson),
                              ),
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
