package funkin.ui.debug.char.pages;

import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.menus.MenuCheckBox;
import funkin.audio.FunkinSound;
import funkin.data.freeplay.player.PlayerData;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.graphics.FunkinSprite;
import funkin.ui.debug.char.pages.subpages.CharSelectIndexSubPage;
import funkin.ui.debug.char.components.dialogs.*;
import funkin.util.FileUtil;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import openfl.display.BlendMode;
import openfl.filters.ShaderFilter;
import funkin.ui.charSelect.Lock;
import funkin.util.MathUtil;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;

using StringTools;

@:allow(funkin.ui.debug.char.pages.subpages.CharSelectIndexSubPage)
class CharCreatorSelectPage extends CharCreatorDefaultPage
{
  var data:WizardGenerateParams;

  var nametag:FlxSprite;
  var transitionGradient:FlxSprite;
  var autoFollow:Bool = false;
  var availableChars:Map<Int, String> = new Map<Int, String>();
  var fadeShader:funkin.graphics.shaders.BlueFade = new funkin.graphics.shaders.BlueFade();

  // used for `PlayableCharacter` generation
  var selectedIndexData:Int = 0;
  var pixelIconFiles:Array<WizardFile> = [];

  var dialogMap:Map<PlayCharDialogType, DefaultPageDialog>;

  var subPages:Map<CharCreatorSelectSubPage, FlxSpriteGroup>;

  var handleInput:Bool = true;

  override public function new(state:CharCreatorState, data:WizardGenerateParams)
  {
    super(state);

    loadAvailableCharacters();
    this.data = data;
    if (data.importedPlayerData != null)
    {
      var playuh = PlayerRegistry.instance.fetchEntry(data.importedPlayerData);
      if (playuh == null) return;

      selectedIndexData = playuh.getCharSelectData()?.position ?? 0;
    }

    // copied sum code LOL
    initBackground();

    initForeground();

    // gf and player code doodoo

    nametag = new FlxSprite();
    add(nametag);

    dialogMap = new Map<PlayCharDialogType, DefaultPageDialog>();
    dialogMap.set(SettingsDialog, new PlayableCharacterSettingsDialog(this));

    subPages = new Map<CharCreatorSelectSubPage, FlxSpriteGroup>();
    subPages.set(IndexSubPage, new CharSelectIndexSubPage(this));

    add(subPages[IndexSubPage]);
  }

  override public function fillUpPageSettings(menu:Menu)
  {
    var pixelStuff = new Menu();
    pixelStuff.text = "Pixel Icon";

    var openPos = new MenuItem();
    openPos.text = "Set Position";

    var openFile = new MenuItem();
    openFile.text = "Load from File";

    // additions
    menu.addComponent(pixelStuff);
    pixelStuff.addComponent(openFile);
    pixelStuff.addComponent(openPos);

    var settingsDialog = new MenuCheckBox();
    settingsDialog.text = "Playable Character Settings";
    menu.addComponent(settingsDialog);

    // callbacks
    openPos.onClick = function(_) {
      cast(subPages[IndexSubPage], CharSelectIndexSubPage).open();
    }

    openFile.onClick = function(_) {
      FileUtil.browseForBinaryFile("Load Pixel Icon File", [FileUtil.FILE_EXTENSION_INFO_PNG], function(_) {
        if (_?.fullPath == null) return;

        var daImgPath = _.fullPath;
        var daXmlPath = daImgPath.replace(".png", ".xml");

        pixelIconFiles = [
          {name: daImgPath, bytes: FileUtil.readBytesFromPath(daImgPath)}];

        if (FileUtil.doesFileExist(daXmlPath)) pixelIconFiles.push({name: daXmlPath, bytes: FileUtil.readBytesFromPath(daXmlPath)});

        openFile.tooltip = "File Path: " + daImgPath;

        cast(subPages[IndexSubPage], CharSelectIndexSubPage).resetIconTexture();
      });
    }

    settingsDialog.onClick = function(_) {
      dialogMap[SettingsDialog].hidden = !settingsDialog.selected;
    }
  }

  function initBackground():Void
  {
    var bg:FlxSprite = new FlxSprite(-153, -140);
    bg.loadGraphic(Paths.image('charSelect/charSelectBG'));
    add(bg);

    var crowd:FlxAtlasSprite = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/crowd"));
    crowd.anim.play();
    crowd.anim.onComplete.add(function() {
      crowd.anim.play();
    });
    add(crowd);

    var stageSpr:FlxSprite = new FlxSprite(-40, 391);
    stageSpr.frames = Paths.getSparrowAtlas("charSelect/charSelectStage");
    stageSpr.animation.addByPrefix("idle", "stage full instance 1", 24, true);
    stageSpr.animation.play("idle");
    add(stageSpr);

    var curtains:FlxSprite = new FlxSprite(-47, -49);
    curtains.loadGraphic(Paths.image('charSelect/curtains'));
    add(curtains);

    var barthing = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/barThing"));
    barthing.anim.play("");
    barthing.anim.onComplete.add(function() {
      barthing.anim.play("");
    });
    barthing.blend = BlendMode.MULTIPLY;
    add(barthing);

    var charLight:FlxSprite = new FlxSprite(800, 250);
    charLight.loadGraphic(Paths.image('charSelect/charLight'));
    add(charLight);

    var charLightGF:FlxSprite = new FlxSprite(180, 240);
    charLightGF.loadGraphic(Paths.image('charSelect/charLight'));
    add(charLightGF);
  }

  function initForeground():Void
  {
    var speakers:FlxAtlasSprite = new FlxAtlasSprite(0, 0, Paths.animateAtlas("charSelect/charSelectSpeakers"));
    speakers.anim.play("");
    speakers.anim.onComplete.add(function() {
      speakers.anim.play("");
    });
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

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (handleInput)
    {
      if (FlxG.keys.justPressed.B) {}
    }
  }

  public function toJSON():String
  {
    var playerData:PlayerData = new PlayerData();
    playerData.name = "Unknown";
    playerData.ownedChars = [];
    playerData.showUnownedChars = false;
    playerData.freeplayStyle = "bf";
    playerData.freeplayDJ = null;
    playerData.charSelect = new PlayerCharSelectData(selectedIndexData);
    playerData.results = null;
    playerData.unlocked = true;

    return playerData.serialize();
  }
}

enum CharCreatorSelectSubPage
{
  IndexSubPage;
}

enum PlayCharDialogType
{
  SettingsDialog;
}
