package funkin.ui.debug.char.pages;

import funkin.audio.FunkinSound;
import funkin.data.freeplay.player.PlayerData;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.graphics.FunkinSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import openfl.display.BlendMode;
import openfl.filters.ShaderFilter;

class CharCreatorSelectPage extends CharCreatorDefaultPage
{
  var data:WizardGenerateParams;

  var nametag:FlxSprite;
  var transitionGradient:FlxSprite;
  var autoFollow:Bool = false;
  var availableChars:Map<Int, String> = new Map<Int, String>();
  var fadeShader:funkin.graphics.shaders.BlueFade = new funkin.graphics.shaders.BlueFade();

  override public function new(state:CharCreatorState, data:WizardGenerateParams)
  {
    super(state);
    loadAvailableCharacters();
    this.data = data;

    // copied sum code LOL
    initBackground();

    // gf and player code doodoo

    nametag = new FlxSprite();
    add(nametag);

    nametag.scrollFactor.set();

    initCursors();
    initSounds();

    initLocks();

    FlxTween.color(cursor, 0.2, 0xFFFFFF00, 0xFFFFCC00, {type: PINGPONG});

    // FlxG.debugger.track(cursor);

    var fadeShaderFilter:ShaderFilter = new ShaderFilter(fadeShader);
    FlxG.camera.filters = [fadeShaderFilter];

    var temp:FlxSprite = new FlxSprite();
    temp.loadGraphic(Paths.image('charSelect/placement'));
    add(temp);
    temp.alpha = 0.0;

    // FlxG.debugger.track(temp, "tempBG");

    transitionGradient = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/transitionGradient'));
    transitionGradient.scale.set(1280, 1);
    transitionGradient.flipY = true;
    transitionGradient.updateHitbox();
    FlxTween.tween(transitionGradient, {y: -720}, 1, {ease: FlxEase.expoOut});
    add(transitionGradient);

    fadeShader.fade(0.0, 1.0, 0.8, {ease: FlxEase.quadOut});

    var blackScreen = new FunkinSprite().makeSolidColor(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
    blackScreen.x = -(FlxG.width * 0.5);
    blackScreen.y = -(FlxG.height * 0.5);
    add(blackScreen);
  }

  function initBackground()
  {
    var bg:FlxSprite = new FlxSprite(-153, -140);
    bg.loadGraphic(Paths.image('charSelect/charSelectBG'));
    bg.scrollFactor.set(0.1, 0.1);
    add(bg);

    var crowd:FlxAtlasSprite = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/crowd"));
    crowd.anim.play();
    crowd.anim.onComplete.add(function() {
      crowd.anim.play();
    });
    crowd.scrollFactor.set(0.3, 0.3);
    add(crowd);

    var stageSpr:FlxSprite = new FlxSprite(-40, 391);
    stageSpr.frames = Paths.getSparrowAtlas("charSelect/charSelectStage");
    stageSpr.animation.addByPrefix("idle", "stage full instance 1", 24, true);
    stageSpr.animation.play("idle");
    add(stageSpr);

    var curtains:FlxSprite = new FlxSprite(-47, -49);
    curtains.loadGraphic(Paths.image('charSelect/curtains'));
    curtains.scrollFactor.set(1.4, 1.4);
    add(curtains);

    var barthing = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/barThing"));
    barthing.anim.play("");
    barthing.anim.onComplete.add(function() {
      barthing.anim.play("");
    });
    barthing.blend = BlendMode.MULTIPLY;
    barthing.scrollFactor.set(0, 0);
    add(barthing);

    var charLight:FlxSprite = new FlxSprite(800, 250);
    charLight.loadGraphic(Paths.image('charSelect/charLight'));
    add(charLight);

    var charLightGF:FlxSprite = new FlxSprite(180, 240);
    charLightGF.loadGraphic(Paths.image('charSelect/charLight'));
    add(charLightGF);
  }

  function initForeground()
  {
    var speakers:FlxAtlasSprite = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/charSelectSpeakers"));
    speakers.anim.play("");
    speakers.anim.onComplete.add(function() {
      speakers.anim.play("");
    });
    speakers.scrollFactor.set(1.8, 1.8);
    add(speakers);

    var fgBlur:FlxSprite = new FlxSprite(-125, 170);
    fgBlur.loadGraphic(Paths.image('charSelect/foregroundBlur'));
    fgBlur.blend = BlendMode.MULTIPLY;
    add(fgBlur);

    var dipshitBlur = new FlxSprite(419, -65);
    dipshitBlur.frames = Paths.getSparrowAtlas("charSelect/dipshitBlur");
    dipshitBlur.animation.addByPrefix('idle', "CHOOSE vertical offset instance 1", 24, true);
    dipshitBlur.blend = BlendMode.ADD;
    dipshitBlur.animation.play("idle");
    add(dipshitBlur);

    var dipshitBacking = new FlxSprite(423, -17);
    dipshitBacking.frames = Paths.getSparrowAtlas("charSelect/dipshitBacking");
    dipshitBacking.animation.addByPrefix('idle', "CHOOSE horizontal offset instance 1", 24, true);
    dipshitBacking.blend = BlendMode.ADD;
    dipshitBacking.animation.play("idle");
    add(dipshitBacking);

    var chooseDipshit = new FlxSprite(426, -13);
    chooseDipshit.loadGraphic(Paths.image('charSelect/chooseDipshit'));
    add(chooseDipshit);

    chooseDipshit.scrollFactor.set();
    dipshitBacking.scrollFactor.set();
    dipshitBlur.scrollFactor.set();
  }

  var cursor:FlxSprite;
  var cursorBlue:FlxSprite;
  var cursorDarkBlue:FlxSprite;
  var grpCursors:FlxTypedSpriteGroup<FlxSprite>; // using flxtypedgroup raises an error
  var cursorConfirmed:FlxSprite;
  var cursorDenied:FlxSprite;

  function initCursors()
  {
    grpCursors = new FlxTypedSpriteGroup<FlxSprite>();
    add(grpCursors);

    cursor = new FlxSprite(0, 0);
    cursor.loadGraphic(Paths.image('charSelect/charSelector'));
    cursor.color = 0xFFFFFF00;

    // FFCC00

    cursorBlue = new FlxSprite(0, 0);
    cursorBlue.loadGraphic(Paths.image('charSelect/charSelector'));
    cursorBlue.color = 0xFF3EBBFF;

    cursorDarkBlue = new FlxSprite(0, 0);
    cursorDarkBlue.loadGraphic(Paths.image('charSelect/charSelector'));
    cursorDarkBlue.color = 0xFF3C74F7;

    cursorBlue.blend = BlendMode.SCREEN;
    cursorDarkBlue.blend = BlendMode.SCREEN;

    cursorConfirmed = new FlxSprite(0, 0);
    cursorConfirmed.scrollFactor.set();
    cursorConfirmed.frames = Paths.getSparrowAtlas("charSelect/charSelectorConfirm");
    cursorConfirmed.animation.addByPrefix("idle", "cursor ACCEPTED instance 1", 24, true);
    cursorConfirmed.visible = false;
    add(cursorConfirmed);

    cursorDenied = new FlxSprite(0, 0);
    cursorDenied.scrollFactor.set();
    cursorDenied.frames = Paths.getSparrowAtlas("charSelect/charSelectorDenied");
    cursorDenied.animation.addByPrefix("idle", "cursor DENIED instance 1", 24, false);
    cursorDenied.visible = false;
    add(cursorDenied);

    grpCursors.add(cursorDarkBlue);
    grpCursors.add(cursorBlue);
    grpCursors.add(cursor);

    cursor.scrollFactor.set();
    cursorBlue.scrollFactor.set();
    cursorDarkBlue.scrollFactor.set();
  }

  var selectSound:FunkinSound;
  var lockedSound:FunkinSound;
  var staticSound:FunkinSound;

  function initSounds()
  {
    selectSound = new FunkinSound();
    selectSound.loadEmbedded(Paths.sound('CS_select'));
    selectSound.pitch = 1;
    selectSound.volume = 0.7;

    FlxG.sound.defaultSoundGroup.add(selectSound);
    FlxG.sound.list.add(selectSound);

    lockedSound = new FunkinSound();
    lockedSound.loadEmbedded(Paths.sound('CS_locked'));
    lockedSound.pitch = 1;
    lockedSound.volume = 1.;

    FlxG.sound.defaultSoundGroup.add(lockedSound);
    FlxG.sound.list.add(lockedSound);

    staticSound = new FunkinSound();
    staticSound.loadEmbedded(Paths.sound('static loop'));
    staticSound.pitch = 1;
    staticSound.looped = true;
    staticSound.volume = 0.6;

    FlxG.sound.defaultSoundGroup.add(staticSound);
    FlxG.sound.list.add(staticSound);
  }

  var grpIcons:FlxSpriteGroup;
  final grpXSpread:Float = 107;
  final grpYSpread:Float = 127;

  function initLocks():Void
  {
    grpIcons = new FlxSpriteGroup();
    add(grpIcons);

    for (i in 0...9)
    {
      if (availableChars.exists(i))
      {
        var path:String = availableChars.get(i);
        var temp:PixelatedIcon = new PixelatedIcon(0, 0);
        temp.setCharacter(path);
        temp.setGraphicSize(128, 128);
        temp.updateHitbox();
        temp.ID = 0;
        grpIcons.add(temp);
      }
    }

    updateIconPositions();
    grpIcons.scrollFactor.set();

    for (index => member in grpIcons.members)
    {
      member.y += 300;
      FlxTween.tween(member, {y: member.y - 300}, 1, {ease: FlxEase.expoOut});
    }
  }

  function updateIconPositions()
  {
    grpIcons.x = 450;
    grpIcons.y = 120;
    for (index => member in grpIcons.members)
    {
      var posX:Float = (index % 3);
      var posY:Float = Math.floor(index / 3);

      member.x = posX * grpXSpread;
      member.y = posY * grpYSpread;

      member.x += grpIcons.x;
      member.y += grpIcons.y;
    }
  }

  function loadAvailableCharacters():Void
  {
    var playerIds:Array<String> = PlayerRegistry.instance.listEntryIds();

    for (playerId in playerIds)
    {
      var player:Null<funkin.ui.freeplay.charselect.PlayableCharacter> = PlayerRegistry.instance.fetchEntry(playerId);
      if (player == null) continue;
      var playerData = player.getCharSelectData();
      if (playerData == null) continue;

      var targetPosition:Int = playerData.position ?? 0;
      while (availableChars.exists(targetPosition))
      {
        targetPosition += 1;
      }

      trace('Placing player ${playerId} at position ${targetPosition}');
      availableChars.set(targetPosition, playerId);
    }
  }
}
