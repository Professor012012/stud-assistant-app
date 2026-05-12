import 'package:flutter/material.dart';
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
class AppLoadingSkeleton extends StatelessWidget {
  const AppLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 38,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: SkeletonBox(width: 140, height: 16),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
                width: double.infinity, height: 100, borderRadius: 12),
            const SizedBox(height: 16),
            SkeletonBox(width: 120, height: 12),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: SkeletonBox(width: 120, height: 16),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 200, height: 20),
            const SizedBox(height: 8),
            SkeletonBox(width: 260, height: 14),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: List.generate(
                4,
                (_) => SkeletonBox(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 12),
              ),
            ),
            const SizedBox(height: 24),
            SkeletonBox(width: 160, height: 16),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
class ApplicationsListSkeleton extends StatelessWidget {
  const ApplicationsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: SkeletonBox(width: 120, height: 16),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            2,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SkeletonBox(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 12),
            ),
          ),
        ),
      ),
    );
  }
}
class StudentsListSkeleton extends StatelessWidget {
  const StudentsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: SkeletonBox(width: 100, height: 16),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SkeletonBox(
                width: double.infinity, height: 48, borderRadius: 8),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
class DetailScreenSkeleton extends StatelessWidget {
  const DetailScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: SkeletonBox(width: 140, height: 16),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
                width: double.infinity, height: 56, borderRadius: 12),
            const SizedBox(height: 20),
            SkeletonBox(width: 120, height: 16),
            const SizedBox(height: 10),
            SkeletonBox(
                width: double.infinity, height: 140, borderRadius: 12),
            const SizedBox(height: 20),
            SkeletonBox(width: 120, height: 16),
            const SizedBox(height: 10),
            SkeletonBox(
                width: double.infinity, height: 120, borderRadius: 12),
            const SizedBox(height: 20),
            SkeletonBox(width: 160, height: 16),
            const SizedBox(height: 10),
            ...List.generate(
              2,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SkeletonBox(
                    width: double.infinity,
                    height: 64,
                    borderRadius: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: SkeletonBox(width: 100, height: 16),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(
              child: SkeletonBox(
                  width: 90, height: 90, borderRadius: 45),
            ),
            const SizedBox(height: 12),
            const Center(
                child: SkeletonBox(width: 140, height: 16)),
            const SizedBox(height: 8),
            const Center(
                child: SkeletonBox(width: 180, height: 12)),
            const SizedBox(height: 24),
            SkeletonBox(
                width: double.infinity, height: 200, borderRadius: 12),
            const SizedBox(height: 20),
            SkeletonBox(
                width: double.infinity, height: 220, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}