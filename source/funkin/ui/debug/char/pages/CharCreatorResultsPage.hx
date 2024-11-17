package funkin.ui.debug.char.pages;

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
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class CharCreatorResultsPage extends CharCreatorDefaultPage
{
  var data:WizardGenerateParams;

  var previewRank:ScoringRank = PERFECT_GOLD;

  var dialogMap:Map<ResultsDialogType, DefaultPageDialog>;

  override public function new(state:CharCreatorState, data:WizardGenerateParams)
  {
    super(state);
    this.data = data;

    dialogMap = new Map<ResultsDialogType, DefaultPageDialog>();
    dialogMap.set(RankAnims, new ResultsAnimDialog(this));

    initFunkinUI();
    initAnimations();

    refresh();
  }

  override public function fillUpPageSettings(menu:Menu):Void
  {
    var animDialog = new MenuCheckBox();
    animDialog.text = "Rank Animations";
    animDialog.onClick = function(_) {
      dialogMap[RankAnims].hidden = !animDialog.selected;
    }
    menu.addComponent(animDialog);
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.SPACE)
    {
      refresh(); // just to be sure

      for (atlas in characterAtlasAnimations[previewRank])
      {
        new FlxTimer().start(atlas.delay, _ -> {
          if (atlas.sprite == null) return;
          atlas.sprite.visible = true;
          atlas.sprite.playAnimation('');
        });
      }

      for (sprite in characterSparrowAnimations[previewRank])
      {
        new FlxTimer().start(sprite.delay, _ -> {
          if (sprite.sprite == null) return;
          sprite.sprite.visible = true;
          sprite.sprite.animation.play('idle', true);
        });
      }
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

  var characterAtlasAnimations:Map<ScoringRank, Array<
    {
      sprite:FlxAtlasSprite,
      delay:Float,
      forceLoop:Bool
    }>> = [];
  var characterSparrowAnimations:Map<ScoringRank, Array<
    {
      sprite:FunkinSprite,
      delay:Float
    }>> = [];

  function initAnimations():Void
  {
    if (data.importedPlayerData != null)
    {
      var charId = data.importedPlayerData;
      createAnimationsForRank(charId, PERFECT_GOLD);
      createAnimationsForRank(charId, PERFECT);
      createAnimationsForRank(charId, EXCELLENT);
      createAnimationsForRank(charId, GREAT);
      createAnimationsForRank(charId, GOOD);
      createAnimationsForRank(charId, SHIT);
    }
    else {}
  }

  function createAnimationsForRank(charId:String, rank:ScoringRank):Void
  {
    var currentChar = PlayerRegistry.instance.fetchEntry(charId);
    var playerAnimations = currentChar?.getResultsAnimationDatas(rank) ?? [];

    var atlasAnimations = [];
    var sparrowAnimations = [];
    for (animData in playerAnimations)
    {
      if (animData == null) continue;

      var animPath:String = Paths.stripLibrary(animData.assetPath);
      var animLibrary:String = Paths.getLibrary(animData.assetPath);
      var offsets = animData.offsets ?? [0, 0];
      switch (animData.renderType)
      {
        case 'animateatlas':
          var animation:FlxAtlasSprite = new FlxAtlasSprite(offsets[0], offsets[1], Paths.animateAtlas(animPath, animLibrary));
          animation.zIndex = animData.zIndex ?? 500;

          animation.scale.set(animData.scale ?? 1.0, animData.scale ?? 1.0);

          if (!(animData.looped ?? true))
          {
            // Animation is not looped.
            animation.onAnimationComplete.add((_name:String) -> {
              trace("AHAHAH 2");
              if (animation != null)
              {
                animation.anim.pause();
              }
            });
          }
          else if (animData.loopFrameLabel != null)
          {
            animation.onAnimationComplete.add((_name:String) -> {
              trace("AHAHAH 2");
              if (animation != null)
              {
                animation.playAnimation(animData.loopFrameLabel ?? '', true, false, true); // unpauses this anim, since it's on PlayOnce!
              }
            });
          }
          else if (animData.loopFrame != null)
          {
            animation.onAnimationComplete.add((_name:String) -> {
              if (animation != null)
              {
                trace("AHAHAH");
                animation.anim.curFrame = animData.loopFrame ?? 0;
                animation.anim.play(); // unpauses this anim, since it's on PlayOnce!
              }
            });
          }

          // Hide until ready to play.
          animation.visible = false;
          // Queue to play.
          atlasAnimations.push(
            {
              sprite: animation,
              delay: animData.delay ?? 0.0,
              forceLoop: (animData.loopFrame ?? -1) == 0
            });
          // Add to the scene.
          add(animation);
        case 'sparrow':
          var animation:FunkinSprite = FunkinSprite.createSparrow(offsets[0], offsets[1], animPath);
          animation.animation.addByPrefix('idle', '', 24, false, false, false);

          if (animData.loopFrame != null)
          {
            animation.animation.finishCallback = (_name:String) -> {
              if (animation != null)
              {
                animation.animation.play('idle', true, false, animData.loopFrame ?? 0);
              }
            }
          }

          // Hide until ready to play.
          animation.visible = false;
          // Queue to play.
          sparrowAnimations.push(
            {
              sprite: animation,
              delay: animData.delay ?? 0.0
            });
          // Add to the scene.
          add(animation);
      }
    }

    characterAtlasAnimations.set(rank, atlasAnimations);
    characterSparrowAnimations.set(rank, sparrowAnimations);
  }

  function refresh():Void
  {
    sort(SortUtil.byZIndex, FlxSort.ASCENDING);
  }
}

enum ResultsDialogType
{
  RankAnims;
}
