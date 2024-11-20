package funkin.ui.debug.char.pages;

import openfl.media.Sound;
import haxe.ui.components.Label;
import haxe.ui.components.CheckBox;
import haxe.ui.containers.Box;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.menus.MenuCheckBox;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.graphics.FunkinSprite;
import funkin.ui.debug.char.components.dialogs.*;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.play.components.TallyCounter;
import funkin.play.components.ClearPercentCounter;
import funkin.play.scoring.Scoring.ScoringRank;
import funkin.play.ResultScore;
import funkin.util.SortUtil;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.sound.FlxSound;
import funkin.audio.FunkinSound;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;
import flixel.FlxSprite;
import flixel.FlxG;
import lime.media.AudioBuffer;

using StringTools;

class CharCreatorResultsPage extends CharCreatorDefaultPage
{
  static final ALL_RANKS:Array<ScoringRank> = [PERFECT_GOLD, PERFECT, EXCELLENT, GREAT, GOOD, SHIT];

  var data:WizardGenerateParams;

  var dialogMap:Map<ResultsDialogType, DefaultPageDialog>;

  var rankMusicMap:Map<ScoringRank, ResultsMusic> = [];

  override public function new(state:CharCreatorState, data:WizardGenerateParams)
  {
    super(state);
    this.data = data;

    dialogMap = new Map<ResultsDialogType, DefaultPageDialog>();
    dialogMap.set(RankAnims, new ResultsAnimDialog(this));

    if (data.importedPlayerData != null)
    {
      var player = PlayerRegistry.instance.fetchEntry(data.importedPlayerData);

      for (rank in ALL_RANKS)
        rankMusicMap.set(rank, new ResultsMusic(player, rank));
    }

    generateUI();

    initFunkinUI();

    refresh();

    playAnimation();
  }

  var labelRank:Label = new Label();
  var checkPlayMusic:CheckBox = new CheckBox();

  override public function fillUpPageSettings(menu:Menu):Void
  {
    var animDialog = new MenuCheckBox();
    animDialog.text = "Rank Animations";
    animDialog.onClick = function(_) {
      dialogMap[RankAnims].hidden = !animDialog.selected;
    }
    menu.addComponent(animDialog);
  }

  override public function fillUpBottomBar(left:Box, middle:Box, right:Box):Void
  {
    var splitRule = new haxe.ui.components.VerticalRule();
    splitRule.percentHeight = 80;

    middle.addComponent(labelRank);
    middle.addComponent(splitRule);
    middle.addComponent(checkPlayMusic);
  }

  function generateUI():Void
  {
    var rankAnimDialog = cast(dialogMap[RankAnims], ResultsAnimDialog);

    labelRank.text = rankAnimDialog.currentRankText;
    labelRank.styleNames = "infoText";
    labelRank.verticalAlign = "center";

    checkPlayMusic.text = "Play Music";

    labelRank.onClick = function(_) {
      var drop = rankAnimDialog.rankDropdown;
      if (drop.selectedIndex == -1) return;

      var id = drop.selectedIndex + 1;
      if (id >= drop.dataSource.size) id = 0;
      drop.selectedIndex = id;
      playAnimation();
    }

    labelRank.onRightClick = function(_) {
      var drop = rankAnimDialog.rankDropdown;
      if (drop.selectedIndex == -1) return;

      var id = drop.selectedIndex - 1;
      if (id < 0) id = drop.dataSource.size;
      drop.selectedIndex = id;
      playAnimation();
    }
  }

  override public function performCleanup():Void
  {
    var animDialog:ResultsAnimDialog = cast dialogMap[RankAnims];
    rankMusicMap[animDialog.currentRank].stop();
    FlxG.sound.music.volume = 1;
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.SPACE)
    {
      playAnimation();
    }
  }

  var animTimers:Array<FlxTimer> = [];
  var previousMusic:Null<ResultsMusic> = null;

  public function playAnimation():Void
  {
    stopTimers();

    if (previousMusic != null) previousMusic.stop();

    refresh(); // just to be sure

    var animDialog:ResultsAnimDialog = cast dialogMap[RankAnims];

    var rank = animDialog.currentRank;

    labelRank.text = animDialog.currentRankText;

    var newMusic = rankMusicMap[rank];
    previousMusic = newMusic;

    if (checkPlayMusic.selected)
    {
      FlxG.sound.music.volume = 0;
      animTimers.push(new FlxTimer().start(rank.getMusicDelay(), _ -> {
        newMusic.play();
      }));
    }
    else
    {
      newMusic.stop();
      FlxG.sound.music.volume = 1;
    }

    for (atlas in animDialog.characterAtlasAnimations)
    {
      atlas.sprite.visible = false;
      animTimers.push(new FlxTimer().start(atlas.delay + rank.getBFDelay(), _ -> {
        if (atlas.sprite == null) return;
        atlas.sprite.visible = true;
        atlas.sprite.anim.play('', true);
      }));
    }

    for (sprite in animDialog.characterSparrowAnimations)
    {
      sprite.sprite.visible = false;
      animTimers.push(new FlxTimer().start(sprite.delay + rank.getBFDelay(), _ -> {
        if (sprite.sprite == null) return;
        sprite.sprite.visible = true;
        sprite.sprite.animation.play('idle', true);
      }));
    }
  }

  function stopTimers():Void
  {
    while (animTimers.length > 0)
    {
      var timer = animTimers.shift();
      timer.cancel();
      timer.destroy();
    }
  }

  var difficulty:FlxSprite;
  var songName:FlxBitmapText;
  var clearPercentSmall:ClearPercentCounter;
  var resultsAnim:FunkinSprite;
  var ratingsPopin:FunkinSprite;
  var scorePopin:FunkinSprite;
  var score:ResultScore;

  function initFunkinUI():Void
  {
    var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECC5C, 0xFFFDC05C], 90);
    bg.scrollFactor.set();
    bg.zIndex = 10;
    add(bg);

    difficulty = new FlxSprite(555, 122);
    difficulty.zIndex = 1000;
    difficulty.loadGraphic(Paths.image("resultScreen/diff_hard"));
    add(difficulty);

    var fontLetters:String = "AaBbCcDdEeFfGgHhiIJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz:1234567890";
    songName = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("resultScreen/tardlingSpritesheet"), fontLetters, FlxPoint.get(49, 62)));
    songName.text = "Playable Character Creator";
    songName.letterSpacing = -15;
    songName.angle = -4.4;
    songName.zIndex = 1000;
    songName.x = difficulty.x + difficulty.width + 60 + 94;
    songName.y = 122 - 25 - (10 * (songName.text.length / 15));
    add(songName);

    clearPercentSmall = new ClearPercentCounter(difficulty.x + difficulty.width + 60, 122 - 5, 100, true);
    clearPercentSmall.zIndex = 1000;
    add(clearPercentSmall);

    var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("resultScreen/topBarBlack"));
    blackTopBar.zIndex = 1010;
    add(blackTopBar);

    var soundSystem:FunkinSprite = FunkinSprite.createSparrow(-15, -180, 'resultScreen/soundSystem');
    soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
    soundSystem.animation.play("idle");
    soundSystem.zIndex = 1100;
    add(soundSystem);

    resultsAnim = FunkinSprite.createSparrow(-200, -10, "resultScreen/results");
    resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
    resultsAnim.animation.play("result");
    resultsAnim.zIndex = 1200;
    add(resultsAnim);

    ratingsPopin = FunkinSprite.createSparrow(-135, 135, "resultScreen/ratingsPopin");
    ratingsPopin.animation.addByPrefix("idle", "Categories", 24, false);
    ratingsPopin.animation.play("idle");
    ratingsPopin.zIndex = 1200;
    add(ratingsPopin);

    scorePopin = FunkinSprite.createSparrow(-180, 515, "resultScreen/scorePopin");
    scorePopin.animation.addByPrefix("score", "tally score", 24, false);
    scorePopin.animation.play("score");
    scorePopin.zIndex = 1200;
    add(scorePopin);

    var hStuf:Int = 50;

    var ratingGrp:FlxTypedSpriteGroup<TallyCounter> = new FlxTypedSpriteGroup<TallyCounter>();
    ratingGrp.zIndex = 1200;
    add(ratingGrp);

    /**
     * NOTE: We display how many notes were HIT, not how many notes there were in total.
     *
     */
    var totalHit:TallyCounter = new TallyCounter(375, hStuf * 3, 999);
    ratingGrp.add(totalHit);

    var maxCombo:TallyCounter = new TallyCounter(375, hStuf * 4, 999);
    ratingGrp.add(maxCombo);

    hStuf += 2;
    var extraYOffset:Float = 7;

    hStuf += 2;

    var tallySick:TallyCounter = new TallyCounter(230, (hStuf * 5) + extraYOffset, 999, 0xFF89E59E);
    ratingGrp.add(tallySick);

    var tallyGood:TallyCounter = new TallyCounter(210, (hStuf * 6) + extraYOffset, 999, 0xFF89C9E5);
    ratingGrp.add(tallyGood);

    var tallyBad:TallyCounter = new TallyCounter(190, (hStuf * 7) + extraYOffset, 999, 0xFFE6CF8A);
    ratingGrp.add(tallyBad);

    var tallyShit:TallyCounter = new TallyCounter(220, (hStuf * 8) + extraYOffset, 999, 0xFFE68C8A);
    ratingGrp.add(tallyShit);

    var tallyMissed:TallyCounter = new TallyCounter(260, (hStuf * 9) + extraYOffset, 999, 0xFFC68AE6);
    ratingGrp.add(tallyMissed);

    score = new ResultScore(35, 305, 10, 999);
    score.zIndex = 1200;
    add(score);
  }

  function refresh():Void
  {
    sort(SortUtil.byZIndex, FlxSort.ASCENDING);
  }
}

private class ResultsMusic
{
  var introMusic:Null<FunkinSound>;
  var music:Null<FunkinSound>;

  public function new(player, rank)
  {
    var path = player?.getResultsMusicPath(rank) ?? "";

    var musicPath = Paths.music('$path/$path');
    music = FunkinSound.load(musicPath, 1.0);

    var introMusicPath = Paths.music('$path/$path-intro');
    if (openfl.utils.Assets.exists(introMusicPath))
    {
      introMusic = FunkinSound.load(introMusicPath, 1.0, () -> {
        music?.play();
      });
    }
  }

  public function play():Void
  {
    if (introMusic != null) introMusic?.play();
    else
      music?.play();
  }

  public function stop():Void
  {
    introMusic?.stop();
    music?.stop();
  }
}

enum ResultsDialogType
{
  RankAnims;
}
