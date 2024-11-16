package funkin.ui.debug.char.pages;

import haxe.ui.components.Label;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.menus.MenuCheckBox;
import funkin.ui.freeplay.LetterSort;
import flixel.text.FlxText;
import funkin.ui.freeplay.FreeplayState.DifficultySprite;
import funkin.ui.debug.char.components.dialogs.*;
import funkin.graphics.FunkinSprite;
import funkin.data.freeplay.style.FreeplayStyleRegistry;
import funkin.graphics.shaders.AngleMask;
import funkin.graphics.shaders.StrokeShader;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.ui.freeplay.BGScrollingText;
import funkin.ui.AtlasText;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import openfl.display.BlendMode;

// mainly used for dj animations and style
class CharCreatorFreeplayPage extends CharCreatorDefaultPage
{
  public var bgText1(get, never):String;

  function get_bgText1():String
  {
    return cast(dialogMap[FreeplayDJSettings], FreeplayDJSettingsDialog).bgText1;
  }

  public var bgText2(get, never):String;

  function get_bgText2():String
  {
    return cast(dialogMap[FreeplayDJSettings], FreeplayDJSettingsDialog).bgText2;
  }

  public var bgText3(get, never):String;

  function get_bgText3():String
  {
    return cast(dialogMap[FreeplayDJSettings], FreeplayDJSettingsDialog).bgText3;
  }

  var dialogMap:Map<FreeplayDialogType, DefaultPageDialog>;

  var data:WizardGenerateParams;

  override public function new(state:CharCreatorState, data:WizardGenerateParams)
  {
    super(state);
    this.data = data;

    dialogMap = new Map<FreeplayDialogType, DefaultPageDialog>();
    dialogMap.set(FreeplayDJSettings, new FreeplayDJSettingsDialog(this));

    initBackingCard();
    initBackground();
  }

  override public function fillUpPageSettings(menu:Menu)
  {
    var settingsDialog = new MenuCheckBox();
    settingsDialog.text = "Freeplay DJ Settings";
    menu.addComponent(settingsDialog);

    settingsDialog.onClick = function(_) {
      dialogMap[FreeplayDJSettings].hidden = !settingsDialog.selected;
    }
  }

  var pinkBack:FunkinSprite;
  var orangeBackShit:FunkinSprite;

  function initBackingCard()
  {
    var cardGlow = new FlxSprite(-30, -30).loadGraphic(Paths.image('freeplay/cardGlow'));
    var confirmGlow = new FlxSprite(-30, 240).loadGraphic(Paths.image('freeplay/confirmGlow'));
    var confirmTextGlow = new FlxSprite(-8, 115).loadGraphic(Paths.image('freeplay/glowingText'));

    cardGlow.blend = confirmGlow.blend = confirmTextGlow.blend = BlendMode.ADD;

    pinkBack = FunkinSprite.create('freeplay/pinkBack');
    pinkBack.color = 0xFFFFD863;

    orangeBackShit = new FunkinSprite(84, 440).makeSolidColor(Std.int(pinkBack.width), 75, 0xFFFEDA00);
    FlxSpriteUtil.alphaMaskFlxSprite(orangeBackShit, pinkBack, orangeBackShit);

    var alsoOrangeLOL = new FunkinSprite(0, orangeBackShit.y).makeSolidColor(100, Std.int(orangeBackShit.height), 0xFFFFD400);
    var confirmGlow2 = new FlxSprite(confirmGlow.x, confirmGlow.y).loadGraphic(Paths.image('freeplay/confirmGlow2'));
    var backingTextYeah = new FlxAtlasSprite(640, 370, Paths.animateAtlas("freeplay/backing-text-yeah"),
      {
        FrameRate: 24.0,
        Reversed: false,
        // ?OnComplete:Void -> Void,
        ShowPivot: false,
        Antialiasing: true,
        ScrollFactor: new FlxPoint(1, 1),
      });

    confirmGlow.visible = confirmGlow2.visible = confirmTextGlow.visible = false;
    cardGlow.alpha = 0;

    add(pinkBack);
    add(orangeBackShit);
    add(alsoOrangeLOL);
    add(confirmGlow2);
    add(confirmGlow);
    add(confirmTextGlow);
    add(backingTextYeah);

    initScrollingTexts();

    add(cardGlow);
  }

  var text1:BGScrollingText;
  var text2:BGScrollingText;
  var text3:BGScrollingText;
  var text4:BGScrollingText;
  var text5:BGScrollingText;
  var text6:BGScrollingText;

  function initScrollingTexts()
  {
    var currentChar = PlayerRegistry.instance.fetchEntry(data.importedPlayerData);
    var dialog:FreeplayDJSettingsDialog = cast dialogMap[FreeplayDJSettings];

    var texts = currentChar != null ? [
      currentChar.getFreeplayDJText(1),
      currentChar.getFreeplayDJText(2),
      currentChar.getFreeplayDJText(3)
    ] : [
      bgText1 ?? "YO IM A PLACEHOLDER",
      bgText2 ?? "YOU SHOULD PUT UR TEXT IN THE DIALOG",
      bgText3 ?? "IT COULD LOOK LIKE THIS"
      ];

    // yanderev moment i think
    text1 = new BGScrollingText(0, 220, texts[0], FlxG.width / 2, false, 60);
    text2 = new BGScrollingText(0, 335, texts[0], FlxG.width / 2, false, 60);
    text3 = new BGScrollingText(0, 160, texts[1], FlxG.width, true, 43);
    text4 = new BGScrollingText(0, 397, texts[1], FlxG.width, true, 43);
    text5 = new BGScrollingText(0, 285, texts[2], FlxG.width / 2, true, 43);
    text6 = new BGScrollingText(0, orangeBackShit.y + 10, texts[0], FlxG.width / 2, 60);

    text1.funnyColor = text2.funnyColor = 0xFFFF9963;
    text3.funnyColor = text4.funnyColor = 0xFFFFF383;
    text6.funnyColor = 0xFFFEA400;

    text1.speed = text2.speed = text6.speed = -3.8;
    text3.speed = text4.speed = 6.8;
    text5.speed = 3.5;

    add(text1);
    add(text2);
    add(text3);
    add(text4);
    add(text5);
    add(text6);

    var glowDark = new FlxSprite(-300, 330).loadGraphic(Paths.image('freeplay/beatglow'));
    glowDark.blend = BlendMode.MULTIPLY;
    add(glowDark);

    var glow = new FlxSprite(-300, 330).loadGraphic(Paths.image('freeplay/beatglow'));
    glow.blend = BlendMode.ADD;
    add(glow);
  }

  var bgDad:FlxSprite;
  var arrowLeft:FlxSprite;
  var arrowRight:FlxSprite;

  function initBackground()
  {
    var currentChar = PlayerRegistry.instance.fetchEntry(data.importedPlayerData);
    var stylishSunglasses = FreeplayStyleRegistry.instance.fetchEntry(currentChar?.getFreeplayStyleID() ?? "");

    bgDad = new FlxSprite(pinkBack.width * 0.74)
      .loadGraphic(stylishSunglasses == null ? Paths.image('freeplay/freeplayBGdad') : stylishSunglasses.getBgAssetGraphic());
    bgDad.setGraphicSize(0, FlxG.height);
    bgDad.updateHitbox();

    var blackUnderlay = new FlxSprite(387.76).makeGraphic(Std.int(bgDad.width), Std.int(bgDad.height), FlxColor.BLACK);
    blackUnderlay.setGraphicSize(0, FlxG.height);
    blackUnderlay.updateHitbox();

    var angleMaskShader:AngleMask = new AngleMask();
    bgDad.shader = blackUnderlay.shader = angleMaskShader;
    angleMaskShader.extraColor = FlxColor.WHITE;

    var diffSprite = new DifficultySprite(Constants.DEFAULT_DIFFICULTY);
    diffSprite.setPosition(90, 80);

    var fnfFreeplay:FlxText = new FlxText(8, 8, 0, 'FREEPLAY PAGE', 48);
    fnfFreeplay.font = 'VCR OSD Mono';

    var ostName = new FlxText(8, 8, FlxG.width - 8 - 8, 'OFFICIAL OST', 48); // the text should be original ost methinks
    ostName.font = 'VCR OSD Mono';
    ostName.alignment = RIGHT;

    var sillyStroke:StrokeShader = new StrokeShader(0xFFFFFFFF, 2, 2);
    fnfFreeplay.shader = ostName.shader = sillyStroke;

    var fnfHighscoreSpr:FlxSprite = new FlxSprite(860, 70);
    fnfHighscoreSpr.frames = Paths.getSparrowAtlas('freeplay/highscore');
    fnfHighscoreSpr.animation.addByPrefix('highscore', 'highscore small instance 1', 24, false);
    fnfHighscoreSpr.setGraphicSize(0, Std.int(fnfHighscoreSpr.height * 1));
    fnfHighscoreSpr.updateHitbox();

    arrowLeft = new FlxSprite(20, diffSprite.y - 10);
    arrowRight = new FlxSprite(325, diffSprite.y - 10);
    arrowRight.flipX = true;

    arrowLeft.frames = arrowRight.frames = Paths.getSparrowAtlas(stylishSunglasses == null ? 'freeplay/freeplaySelector' : stylishSunglasses.getSelectorAssetKey());
    arrowLeft.animation.addByPrefix('shine', 'arrow pointer loop', 24);
    arrowRight.animation.addByPrefix('shine', 'arrow pointer loop', 24);
    arrowLeft.animation.play('shine');
    arrowRight.animation.play('shine');

    add(blackUnderlay);
    add(bgDad);
    add(diffSprite);
    add(fnfHighscoreSpr);

    add(new FlxSprite(1165, 65).loadGraphic(Paths.image('freeplay/clearBox')));
    add(new AtlasText(1185, 87, '69', AtlasFont.FREEPLAY_CLEAR));
    add(new LetterSort(400, 75));

    add(arrowLeft);
    add(arrowRight);

    add(new FlxSprite(0, -100).makeGraphic(FlxG.width, 164, FlxColor.BLACK));
    add(fnfFreeplay);
    add(ostName);

    new FlxTimer().start(FlxG.random.float(12, 50), function(tmr) {
      fnfHighscoreSpr.animation.play('highscore');
      tmr.time = FlxG.random.float(20, 60);
    }, 0);
  }
}

enum FreeplayDialogType
{
  FreeplayDJSettings;
}
