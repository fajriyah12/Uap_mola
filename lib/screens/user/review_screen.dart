// lib/screens/user/review_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:luxora_app/models/property_model.dart';
import 'package:luxora_app/models/review_model.dart';
import 'package:luxora_app/services/review_service.dart';
import 'package:luxora_app/services/auth_service.dart';

class ReviewScreen extends StatefulWidget {
  final PropertyModel property;
  final String bookingId;

  const ReviewScreen({
    super.key,
    required this.property,
    this.bookingId = '',
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  ReviewModel? _myReview;
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUser?.uid;
    _loadMyReview();
  }

  Future<void> _loadMyReview() async {
    if (_currentUserId == null) return;

    final reviews = await _reviewService.getPropertyReviews(widget.property.propertyId).first;
    final myReview = reviews.firstWhere(
      (r) => r.userId == _currentUserId,
      orElse: () => ReviewModel(
        reviewId: '',
        userId: '',
        propertyId: '',
        bookingId: '',
        rating: 0.0,
        comment: '',
        createdAt: DateTime.now(),
      ),
    );

    if (mounted) {
      setState(() {
        _myReview = myReview.reviewId.isNotEmpty ? myReview : null;
        if (_myReview != null) {
          _rating = _myReview!.rating;
          _commentController.text = _myReview!.comment;
        }
      });
    }
  }

  Future<void> _submitReview() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap login')));
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    final review = ReviewModel(
      reviewId: _myReview?.reviewId ?? '',
      userId: _currentUserId!,
      propertyId: widget.property.propertyId,
      bookingId: widget.bookingId,
      rating: _rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    String? error;
    if (_myReview != null) {
      error = await _reviewService.updateReview(review);
    } else {
      error = await _reviewService.createReview(review);
    }

    setState(() => _isLoading = false);

    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_myReview != null ? 'Ulasan diperbarui' : 'Ulasan ditambahkan')),
      );
      _loadMyReview(); // Refresh form
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal')));
    }
  }

  Future<void> _deleteReview() async {
    if (_myReview == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Ulasan?'),
        content: const Text('Yakin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final error = await _reviewService.deleteReview(_myReview!.reviewId);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan dihapus')));
        setState(() {
          _myReview = null;
          _commentController.clear();
          _rating = 5.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ulasan ${widget.property.name}'),
      ),
      body: StreamBuilder<List<ReviewModel>>(
        stream: _reviewService.getPropertyReviews(widget.property.propertyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // Header Rating
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviews.isEmpty ? '0.0' : (reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length).toStringAsFixed(1),
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          RatingBarIndicator(
                            rating: reviews.isEmpty ? 0.0 : reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length,
                            itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                            itemSize: 24,
                          ),
                          Text('${reviews.length} ulasan'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Form Review
              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _myReview != null ? 'Edit Ulasan Anda' : 'Beri Ulasan',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        RatingBar.builder(
                          initialRating: _rating,
                          minRating: 1,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (r) => _rating = r,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: const InputDecoration(hintText: 'Tulis ulasan Anda...', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitReview,
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_myReview != null ? 'Update' : 'Kirim'),
                            ),
                            const SizedBox(width: 8),
                            if (_myReview != null)
                              TextButton(
                                onPressed: _deleteReview,
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                        const Divider(height: 40),
                      ],
                    ),
                  ),
                ),

              // Daftar Ulasan
              reviews.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text('Belum ada ulasan untuk properti ini', style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final review = reviews[index];
                          final isMyReview = review.userId == _currentUserId;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        child: Text(review.userName?[0].toUpperCase() ?? 'U'),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(review.userName ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            RatingBarIndicator(
                                              rating: review.rating,
                                              itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                                              itemSize: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isMyReview)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 20),
                                              onPressed: () {
                                                _rating = review.rating;
                                                _commentController.text = review.comment;
                                                _myReview = review;
                                                // Scroll ke atas
                                                Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Hapus Ulasan?'),
                                                    content: const Text('Yakin?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await _reviewService.deleteReview(review.reviewId);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(review.comment),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: reviews.length,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}