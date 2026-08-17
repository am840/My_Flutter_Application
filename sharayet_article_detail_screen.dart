import 'package:flutter/material.dart';

import '../models/sharayet_models.dart';
import '../services/sharayet_database_service.dart';
import '../services/pdf_service.dart';

class SharayetArticleDetailScreen extends StatefulWidget {
  final Article article;

  const SharayetArticleDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<SharayetArticleDetailScreen> createState() =>
      _SharayetArticleDetailScreenState();
}

class _SharayetArticleDetailScreenState
    extends State<SharayetArticleDetailScreen> {
  final SharayetDatabaseService _dbService = SharayetDatabaseService();

  List<Article> _relatedArticles = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedArticles();
  }

  Future<void> _loadRelatedArticles() async {
    try {
      final related = await _dbService.getRelatedArticles(widget.article.id);

      if (!mounted) return;

      setState(() {
        _relatedArticles = related;
        _isLoadingRelated = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text('ظ…ط§ط¯ظ‡ ${widget.article.articleNumber}'),
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'ط®ط±ظˆط¬غŒ PDF',
              onPressed: () async {
                try {
                  await SharayetPdfService.shareOrPrint(widget.article);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ظپط§غŒظ„ PDF ط¨ط§ ظ…ظˆظپظ‚غŒطھ ط§غŒط¬ط§ط¯ ط´ط¯'),
                        backgroundColor: Color(0xFF00BFA5),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ط®ط·ط§ ط¯ط± ط§غŒط¬ط§ط¯ PDF: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header ط¨ط§ ع¯ط±ط§ط¯غŒط§ظ†
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1565C0),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ظپطµظ„ ${widget.article.chapterId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ظ…طھظ† ظ…ط§ط¯ظ‡
                    _buildSectionCard(
                      title: 'ظ…طھظ† ظ…ط§ط¯ظ‡',
                      content: widget.article.text,
                      icon: Icons.article_outlined,
                      color: const Color(0xFF0D47A1),
                    ),

                    const SizedBox(height: 16),

                    // طھظپط³غŒط±
                    if (widget.article.interpretation != null &&
                        widget.article.interpretation!.isNotEmpty)
                      _buildSectionCard(
                        title: 'طھظپط³غŒط±',
                        content: widget.article.interpretation!,
                        icon: Icons.lightbulb_outline,
                        color: const Color(0xFF00BFA5),
                      ),

                    const SizedBox(height: 16),

                    // ظ…ظˆط§ط¯ ظ…ط±طھط¨ط·
                    _buildRelatedArticlesCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            right: BorderSide(color: color, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.8,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedArticlesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            right: BorderSide(
              color: Color(0xFFFF6F00),
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.link,
                  color: Color(0xFFFF6F00),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'ظ…ظˆط§ط¯ ظ…ط±طھط¨ط·',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingRelated)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_relatedArticles.isEmpty)
              const Text(
                'ظ…ظˆط§ط¯ ظ…ط±طھط¨ط·غŒ غŒط§ظپطھ ظ†ط´ط¯',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Column(
                children: _relatedArticles.map((relatedArticle) {
                  return InkWell(
                    onTap: () async {
                      final article = await _dbService
                          .getArticleByNumber(
                        relatedArticle.articleNumber,
                      );

                      if (article != null && mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SharayetArticleDetailScreen(
                              article: article,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6F00),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ظ…ط§ط¯ظ‡ ${relatedArticle.articleNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              relatedArticle.title,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF424242),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_left,
                            color: Color(0xFFFF6F00),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}