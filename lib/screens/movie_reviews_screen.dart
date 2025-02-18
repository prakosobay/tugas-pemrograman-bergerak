import 'package:flutter/material.dart';
import '../api_service.dart';
import 'add_edit_review_screen.dart';

class MovieReviewsScreen extends StatefulWidget {
  final String username;

  const MovieReviewsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _MovieReviewsScreenState createState() => _MovieReviewsScreenState();
}

class _MovieReviewsScreenState extends State<MovieReviewsScreen> {
  final _apiService = ApiService();
  List<dynamic> _reviews = [];
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await _apiService.getReviews(widget.username);
    setState(() {
      _reviews = reviews;
      // _isLiked = false;
    });
    print('REVIEW GLOBAL : $_reviews');
    print('REVIEW LOCAL : $reviews');
  }

  void _deleteReview(String id) async {
    final success = await _apiService.deleteReview(id);
    if (success) {
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus review')),
      );
    }
  }

  void _likeReview(String id) async {
    setState(() {
      _isLiked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review Liked')),
    );
  }

  void _dislike(String id) async {
    setState(() {
      _isLiked = false;
    });
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review Disliked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Film Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditReviewScreen(username: widget.username),
                ),
              );
              if (result == true) _loadReviews();
            },
          ),
        ],
      ),
      body: _reviews.isEmpty
          ? Center(child: Text('Belum ada review. Tambahkan sekarang!'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  title: Text(review['title']),
                  subtitle: Text('${review['rating']} / 10\n${review['comment']}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLiked) 
                        Column(
                          children: [
                            IconButton(
                            onPressed: () => _dislike(review['_id']), 
                            icon: Icon(Icons.thumb_up, color: Colors.yellow,)),
                          ],
                        )
                      else 
                        IconButton(
                          onPressed: () => _likeReview(review['_id']), 
                          icon: Icon(Icons.thumb_up, color: Colors.black,)),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditReviewScreen(
                                username: widget.username,
                                review: review,
                              ),
                            ),
                          );
                          if (result == true) _loadReviews();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteReview(review['_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
