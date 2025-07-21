import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/shopify_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';

class CustomParagraphBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        text.text,
        style: preferredStyle,
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class CustomImageBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String? src = element.attributes['src'];
    if (src == null) return null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          src,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey.shade100,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BlogScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String content;
  final String? publishedAt;
  final String? authorName;

  const BlogScreen({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.content,
    this.publishedAt,
    this.authorName,
  }) : super(key: key);

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  List<Map<String, dynamic>> _relatedArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedArticles();
  }

  Future<void> _loadRelatedArticles() async {
    try {
      final blogsData = await _shopifyService.getBlogs();
      if (blogsData != null && blogsData['blogs']?['edges'] != null) {
        final articles = [];
        for (var blog in blogsData['blogs']['edges']) {
          if (blog['node']?['articles']?['edges'] != null) {
            articles.addAll(blog['node']['articles']['edges']
                .map((e) => e['node'])
                .where((article) => article['title'] != widget.title)
                .take(2));
          }
        }
        setState(() {
          _relatedArticles = List<Map<String, dynamic>>.from(articles);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading related articles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.authorName != null || widget.publishedAt != null)
                    Row(
                      children: [
                        if (widget.authorName != null) ...[
                          const Icon(Icons.person_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.authorName!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        if (widget.authorName != null && widget.publishedAt != null)
                          const SizedBox(width: 16),
                        if (widget.publishedAt != null) ...[
                          const Icon(Icons.calendar_today_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.publishedAt!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MarkdownBody(
                      data: widget.content,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(
                          fontSize: 16,
                          height: 1.8,
                        ),
                        h1: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                        h2: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                        blockquote: GoogleFonts.poppins(
                          fontSize: 16,
                          height: 1.8,
                          color: Colors.grey.shade700,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 4,
                            ),
                          ),
                          color: Colors.grey.shade100,
                        ),
                        listBullet: GoogleFonts.poppins(
                          fontSize: 16,
                          height: 1.8,
                        ),
                      ),
                      selectable: true,
                      builders: {
                        'p': CustomParagraphBuilder(),
                        'img': CustomImageBuilder(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share this article',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSocialButton(Icons.facebook, 'Facebook'),
            const SizedBox(width: 16),
            _buildSocialButton(Icons.link, 'Copy Link'),
            const SizedBox(width: 16),
            _buildSocialButton(Icons.share, 'More'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildRelatedPosts() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_relatedArticles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Articles',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _relatedArticles.length,
          itemBuilder: (context, index) {
            final article = _relatedArticles[index];
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogScreen(
                        title: article['title'] ?? '',
                        imageUrl: article['image']?['url'] ?? AppConstants.blogPlaceholder,
                        content: article['content'] ?? '',
                        publishedAt: article['publishedAt'],
                        authorName: article['author']?['name'],
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          article['image']?['url'] ?? AppConstants.blogPlaceholder,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['title'] ?? '',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (article['publishedAt'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMMd().format(
                                DateTime.parse(article['publishedAt']),
                              ),
                              style: GoogleFonts.poppins(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 