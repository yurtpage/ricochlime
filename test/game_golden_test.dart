import 'dart:convert';
import 'dart:math';

import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ricochlime/ads/ads.dart';
import 'package:ricochlime/flame/game_data.dart';
import 'package:ricochlime/flame/ricochlime_game.dart';
import 'package:ricochlime/nes/nes_theme.dart';
import 'package:ricochlime/pages/play.dart';
import 'package:ricochlime/utils/prefs.dart';
import 'package:ricochlime/utils/ricochlime_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Goldens', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    Prefs.testingMode = true;
    Prefs.init();
    AdState.init();

    RicochlimeGame.disableBgMusic = true;
    RicochlimeGame.reproducibleGoldenMode = true;
    setUp(() async {
      game.random = Random(123);
      await Future.wait([
        game.preloadSprites.future,
        GoogleFonts.pendingFonts([GoogleFonts.silkscreenTextTheme()]),
      ]);
    });

    Prefs.coins.value = 166;
    Prefs.currentGame.value = GameData.fromJson(jsonDecode(
        // ignore: lines_longer_than_80_chars
        '{"score":50,"monsters":[{"px":0.0,"py":16.0,"maxHp":50,"killReward":1},{"px":32.0,"py":16.0,"maxHp":50},{"px":64.0,"py":16.0,"maxHp":50,"killReward":2},{"px":80.0,"py":16.0,"maxHp":50},{"px":32.0,"py":32.0,"maxHp":49,"killReward":1},{"px":96.0,"py":32.0,"maxHp":49,"killReward":2},{"px":32.0,"py":48.0,"maxHp":48,"killReward":2},{"px":80.0,"py":48.0,"maxHp":48,"killReward":1},{"px":16.0,"py":64.0,"maxHp":47,"killReward":2},{"px":80.0,"py":64.0,"maxHp":47,"killReward":1},{"px":80.0,"py":80.0,"maxHp":46,"killReward":1},{"px":112.0,"py":80.0,"maxHp":46,"killReward":2},{"px":16.0,"py":96.0,"maxHp":45,"killReward":1},{"px":96.0,"py":96.0,"maxHp":45,"killReward":2},{"px":0.0,"py":112.0,"maxHp":44},{"px":80.0,"py":112.0,"maxHp":44,"killReward":2},{"px":96.0,"py":112.0,"maxHp":44,"killReward":1},{"px":32.0,"py":128.26667199999997,"maxHp":43,"killReward":1},{"px":64.0,"py":128.26667199999997,"maxHp":43}]}'));
    Prefs.highScore.value = 62;

    _testGame(
      screenSize: const Size(1440, 3120),
      pixelRatio: 10 / 3,
      goldenFile: '../metadata/en-US/images/phoneScreenshots/2_play.png',
    );

    _testGame(
      screenSize: const Size(1440, 900),
      pixelRatio: 1,
      goldenFile: '../metadata/en-US/images/tenInchScreenshots/game.png',
    );
  });
}

void _testGame({
  required Size screenSize,
  required double pixelRatio,
  required String goldenFile,
}) {
  testWidgets('$screenSize', (tester) async {
    final widget = GameEnvironment(
      game: game,
      screenSize: screenSize,
      pixelRatio: pixelRatio,
    );
    await tester.pumpWidget(widget);

    final context = tester.element(find.byType(PlayPage));
    await tester.runAsync(() =>
        precacheImage(const AssetImage('assets/images/coin.png'), context));

    // Aim towards the middle left of the game area
    final aspectRatio = screenSize.width / screenSize.height;
    if (aspectRatio < RicochlimeGame.aspectRatio || true) {
      game.onPanUpdate(DragUpdateInfo.fromDetails(
        game,
        DragUpdateDetails(
          globalPosition: const Offset(0, RicochlimeGame.expectedHeight * 0.39),
        ),
      ));
    }

    await tester.pumpFrames(widget, const Duration(seconds: 3));
    await expectLater(
      find.byType(PlayPage),
      matchesGoldenFile(goldenFile),
    );
  });
}

class GameEnvironment extends StatelessWidget {
  const GameEnvironment({
    super.key,
    required this.game,
    required this.screenSize,
    required this.pixelRatio,
  });

  final RicochlimeGame game;
  final Size screenSize;
  final double pixelRatio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: nesThemeFrom(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: RicochlimePalette.grassColor,
        ),
      ),
      themeAnimationDuration: Duration.zero,
      home: FittedBox(
        child: RepaintBoundary(
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: FittedBox(
              child: SizedBox(
                width: screenSize.width / pixelRatio,
                height: screenSize.height / pixelRatio,
                child: const PlayPage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
