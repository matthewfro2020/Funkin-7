package funkin.ui.debug.char.pages.subpages;

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
import funkin.ui.charSelect.Lock;
import funkin.util.MathUtil;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;

class CharSelectIndexSubPage extends FlxSpriteGroup
{
  static final ICON_SIZE:Float = 128;

  var parentPage:CharCreatorSelectPage;

  var cursor:FlxSprite;
  var cursorBlue:FlxSprite;
  var cursorDarkBlue:FlxSprite;
  var grpCursors:FlxTypedSpriteGroup<FlxSprite>; // using flxtypedgroup raises an error
  var cursorConfirmed:FlxSprite;
  var cursorDenied:FlxSprite;

  var cursorIndex:Int = 0;

  public function new(parentPage:CharCreatorSelectPage)
  {
    super();

    this.parentPage = parentPage;

    var bg = new FunkinSprite().makeSolidColor(FlxG.width, FlxG.height, 0xFF000000);
    bg.alpha = 0.6;
    add(bg);

    initCursors();
    initSounds();

    initLocks();

    FlxTween.color(cursor, 0.2, 0xFFFFFF00, 0xFFFFCC00, {type: PINGPONG});

    close();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    changeSelectedIcon();

    handleMousePress();

    handleCursorPosition(elapsed);

    if (FlxG.keys.justPressed.X)
    {
      close();
    }
  }

  public function open():Void
  {
    this.visible = true;
    this.active = true;

    parentPage.handleInput = false;
  }

  public function close():Void
  {
    this.visible = false;
    this.active = false;

    parentPage.handleInput = true;
  }

  function initCursors():Void
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
    cursorConfirmed.frames = Paths.getSparrowAtlas("charSelect/charSelectorConfirm");
    cursorConfirmed.animation.addByPrefix("idle", "cursor ACCEPTED instance 1", 24, true);
    cursorConfirmed.visible = false;
    add(cursorConfirmed);

    cursorDenied = new FlxSprite(0, 0);
    cursorDenied.frames = Paths.getSparrowAtlas("charSelect/charSelectorDenied");
    cursorDenied.animation.addByPrefix("idle", "cursor DENIED instance 1", 24, false);
    cursorDenied.visible = false;
    add(cursorDenied);

    grpCursors.add(cursorDarkBlue);
    grpCursors.add(cursorBlue);
    grpCursors.add(cursor);
  }

  var selectSound:FunkinSound;
  var lockedSound:FunkinSound;
  var staticSound:FunkinSound;

  function initSounds():Void
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
    lockedSound.volume = 1.0;

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

    // only the unused slots should be selectable
    // i dont know if i like using the lock sprite
    // maybe there is a different placeholder we could use
    // also, we should probably make the used slots
    // less visible or something like that
    for (i in 0...9)
    {
      if (parentPage.availableChars.exists(i))
      {
        var path:String = parentPage.availableChars.get(i);
        var temp:PixelatedIcon = new PixelatedIcon(0, 0);
        temp.setCharacter(path);
        temp.setGraphicSize(ICON_SIZE, ICON_SIZE);
        temp.updateHitbox();
        temp.ID = 0;
        grpIcons.add(temp);
      }
      else
      {
        var temp:Lock = new Lock(0, 0, i);
        temp.ID = 1;
        grpIcons.add(temp);
      }
    }

    updateIconPositions();

    for (index => member in grpIcons.members)
    {
      member.y += 300;
      FlxTween.tween(member, {y: member.y - 300}, 1, {ease: FlxEase.expoOut});
    }
  }

  function updateIconPositions():Void
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

  function changeSelectedIcon():Void
  {
    var mouseX:Float = FlxG.mouse.viewX - grpIcons.x;
    var mouseY:Float = FlxG.mouse.viewY - grpIcons.y;

    var cursorX:Int = Math.floor(mouseX / ICON_SIZE);
    var cursorY:Int = Math.floor(mouseY / ICON_SIZE);

    if (cursorX < 0 || cursorX >= 3 || cursorY < 0 || cursorY >= 3)
    {
      return;
    }

    var newIndex:Int = cursorY * 3 + cursorX;

    if (newIndex == cursorIndex)
    {
      return;
    }

    selectSound.play(true);

    cursorIndex = newIndex;
  }

  function handleMousePress():Void
  {
    if (!FlxG.mouse.justPressed)
    {
      return;
    }

    var selectedIcon = grpIcons.members[cursorIndex];

    // skip if the selected icon is already used
    if (selectedIcon.ID == 0)
    {
      lockedSound.play(true);
      return;
    }

    parentPage.selectedIndexData = cursorIndex;
    FlxG.sound.play(Paths.sound('CS_confirm'));
  }

  function handleCursorPosition(elapsed:Float):Void
  {
    var selectedIcon = grpIcons.members[cursorIndex];

    var cursorLocIntended:FlxPoint = FlxPoint.get(selectedIcon.x + ICON_SIZE / 2 - cursor.width / 2, selectedIcon.y + ICON_SIZE / 2 - cursor.height / 2);

    cursor.x = MathUtil.smoothLerp(cursor.x, cursorLocIntended.x, elapsed, 0.1);
    cursor.y = MathUtil.smoothLerp(cursor.y, cursorLocIntended.y, elapsed, 0.1);

    cursorBlue.x = MathUtil.coolLerp(cursorBlue.x, cursor.x, 0.95 * 0.4);
    cursorBlue.y = MathUtil.coolLerp(cursorBlue.y, cursor.y, 0.95 * 0.4);

    cursorDarkBlue.x = MathUtil.coolLerp(cursorDarkBlue.x, cursorLocIntended.x, 0.95 * 0.2);
    cursorDarkBlue.y = MathUtil.coolLerp(cursorDarkBlue.y, cursorLocIntended.y, 0.95 * 0.2);

    cursorLocIntended.put();
  }
}
