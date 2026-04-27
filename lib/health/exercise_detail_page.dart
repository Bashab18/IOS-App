import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/exercise_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailPage({required this.exercise, Key? key}) : super(key: key);

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    final videoId = YoutubePlayerController.convertUrlToId(ex.videoUrl) ?? '';

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;

    return Scaffold(
      appBar: const CustomAppBar(title: "mHealth"),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayerScaffold(
              controller: _controller,
              builder: (context, player) => AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
            ),
            const SizedBox(height: 16),

            Text('Category: ${e.category1}', style: _titleStyle()),
            if (e.category2.isNotEmpty) Text('Secondary: ${e.category2}'),
            if (e.category3.isNotEmpty) Text('Tertiary: ${e.category3}'),
            const Divider(height: 24),

            Text('Accessories', style: _titleStyle()),
            if (e.Accessory_1.isNotEmpty) Text('Accessory 1: ${e.Accessory_1}'),
            if (e.accessory2.isNotEmpty) Text('Accessory 2: ${e.accessory2}'),
            if (e.accessory3.isNotEmpty) Text('Accessory 3: ${e.accessory3}'),
            const Divider(height: 24),

            Text('Muscles Involved', style: _titleStyle()),
            Text(e.musclesInvolved),
            const SizedBox(height: 8),

            Text('Repetitions', style: _titleStyle()),
            Text(e.repetitions),
            const Divider(height: 24),

            Text('Difficulty Levels', style: _titleStyle()),
            Text('Heuristic Level: ${e.heuristicLevel}'),
            Text('ACSM Level: ${e.acsmLevel}'),
            const Divider(height: 24),

            Text('Instructions', style: _titleStyle()),
            Text(e.Audience.isNotEmpty ? e.Audience : 'No description available.'),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle() => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  );
}
