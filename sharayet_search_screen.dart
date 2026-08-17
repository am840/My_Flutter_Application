import 'package:flutter/material.dart';
import '../models/sharayet_models.dart';
import '../services/sharayet_database_service.dart';
import 'sharayet_article_detail_screen.dart';

class SharayetSearchScreen extends StatefulWidget {
  const SharayetSearchScreen({super.key});

  @override
  State<SharayetSearchScreen> createState() => _SharayetSearchScreenState();
}

class _SharayetSearchScreenState extends State<SharayetSearchScreen> {
  final SharayetDatabaseService _dbService = SharayetDatabaseService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Article> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final db = await _dbService.database;
      if (db != null) {
        // جستجو در عنوان و متن ماده‌ها
        final List<Map<String, dynamic>> maps = await db.query(
          'articles',
          where: 'title LIKE ? OR text LIKE ?',
          whereArgs: ['%$query%', '%$query%'],
        );

        setState(() {
          _searchResults = maps.map((map) => Article.fromMap(map)).toList();
        });
      }
    } catch (e) {
      debugPrint('خطا در جستجو: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'Vazirmatn'),
          decoration: const InputDecoration(
            hintText: 'جستجو در شرایط عمومی پیمان...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
          : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'عبارت مورد نظر را تایپ کنید'
                        : 'نتیجه‌ای یافت نشد!',
                    style: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final article = _searchResults[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          'ماده ${article.articleNumber}: ${article.title}',
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        subtitle: Text(
                          article.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Vazirmatn'),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SharayetArticleDetailScreen(article: article),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
