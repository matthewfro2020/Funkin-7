package funkin.ui.debug.char.pages;

import haxe.ui.containers.Box;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.menus.MenuCheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.components.VerticalRule;
import funkin.data.stage.StageData;
import funkin.play.stage.Bopper;
import funkin.data.stage.StageData.StageDataCharacter;
import funkin.data.character.CharacterData;
import funkin.data.character.CharacterRegistry;
import funkin.play.character.BaseCharacter.CharacterType;
import funkin.play.stage.StageProp;
import funkin.data.stage.StageRegistry;
import funkin.ui.debug.char.components.dialogs.*;
import flixel.util.FlxColor;

using StringTools;

class CharCreatorGameplayPage extends CharCreatorDefaultPage
{
  // stage
  public var curStage(default, set):String;
  public var stageProps:Array<StageProp> = [];
  public var charStageDatas:Map<CharacterType, StageDataCharacter> = [];
  public var stageZoom:Float = 1.0;

  // char
  public var currentCharacter:CharCreatorCharacter;

  // dialogs
  public var dialogMap:Map<CharDialogType, DefaultPageDialog> = [];

  // onion skin/ghost
  public var ghostCharacter:CharCreatorCharacter;
  public var ghostId(default, set):String = ""; // empty string means current character

  override public function new(daState:CharCreatorState, wizardParams:WizardGenerateParams)
  {
    super(daState);
    curStage = Constants.DEFAULT_STAGE;

    Conductor.instance.onBeatHit.add(stageBeatHit);

    currentCharacter = new CharCreatorCharacter(wizardParams);
    if (wizardParams.importedCharacter != null) currentCharacter.fromCharacterData(CharacterRegistry.fetchCharacterData(wizardParams.importedCharacter));
    add(currentCharacter);

    ghostCharacter = new CharCreatorCharacter(wizardParams);
    if (wizardParams.importedCharacter != null) ghostCharacter.fromCharacterData(CharacterRegistry.fetchCharacterData(wizardParams.importedCharacter));
    ghostCharacter.visible = false;
    add(ghostCharacter);

    updateCharPerStageData();

    dialogMap.set(Animation, new AddAnimDialog(this, currentCharacter));
    dialogMap.set(Data, new CharMetadataDialog(this, currentCharacter));
    dialogMap.set(Ghost, new GhostSettingsDialog(this));
    dialogMap.set(Health, new HealthIconDialog(this, currentCharacter));

    generateUI();

    if (wizardParams.importedCharacter != null)
    {
      var animDialog = cast(dialogMap[Animation], AddAnimDialog);
      animDialog.updateDropdown();

      animDialog.charAnimDropdown.selectedIndex = 0;
      currentCharacter.playAnimation(currentCharacter.animations[0].name);
    }
  }

  override public function update(elapsed:Float)
  {
    labelAnimName.text = currentCharacter.getCurrentAnimation() ?? "None";
    labelAnimOffsetX.text = "" + (currentCharacter.getAnimationData(currentCharacter.getCurrentAnimation())?.offsets[0] ?? 0);
    labelAnimOffsetY.text = "" + (currentCharacter.getAnimationData(currentCharacter.getCurrentAnimation())?.offsets[1] ?? 0);

    super.update(elapsed);
  }

  public function stageBeatHit()
  {
    for (spr in stageProps)
    {
      if (Std.isOfType(spr, Bopper))
      {
        var bop = cast(spr, Bopper);

        if (Conductor.instance.currentBeatTime % bop.danceEvery == 0) bop.dance();
      }
    }
  }

  var labelAnimName:Label = new Label();
  var labelAnimOffsetX:Label = new Label();
  var labelAnimOffsetY:Label = new Label();
  var labelCharType:Label = new Label();
  var stageDropdown:DropDown = new DropDown();

  final RULE_HEIGHT:Int = 80;

  override public function fillUpBottomBar(left:Box, middle:Box, right:Box)
  {
    // ==================left==================
    var leftRule1 = new VerticalRule();
    var leftRule2 = new VerticalRule();

    leftRule1.percentHeight = leftRule2.percentHeight = RULE_HEIGHT;

    left.addComponent(labelAnimName);
    left.addComponent(leftRule1);
    left.addComponent(labelAnimOffsetX);
    left.addComponent(leftRule2);
    left.addComponent(labelAnimOffsetY);

    // ==================middle==================

    // ==================right==================
    var rightRule = new VerticalRule();
    rightRule.percentHeight = RULE_HEIGHT;

    right.addComponent(labelCharType);
    right.addComponent(rightRule);
    right.addComponent(stageDropdown);
  }

  function changeCharAnimOffset(changeX:Int = 0, changeY:Int = 0)
  {
    if (currentCharacter.animations.length == 0) return;

    // we get the anim idx from dropdown cuz its our way to store current animation
    var drop = cast(dialogMap[Animation], AddAnimDialog).charAnimDropdown;
    var animOffsets = currentCharacter.animations[drop.selectedIndex].offsets;
    var newOffsets = [animOffsets[0] + changeX, animOffsets[1] + changeY];

    currentCharacter.setAnimationOffsets(currentCharacter.animations[drop.selectedIndex].name, newOffsets[0], newOffsets[1]);
    currentCharacter.playAnimation(currentCharacter.animations[drop.selectedIndex].name);

    // GhostUtil.copyFromCharacter(ghostCharacter, currentCharacter); very costly for memory! we're just gonna update the offsets
    if (ghostId == "") ghostCharacter.setAnimationOffsets(ghostCharacter.animations[drop.selectedIndex].name, newOffsets[0], newOffsets[1]);

    // might as well update the text
    labelAnimOffsetX.text = "" + newOffsets[0];
    labelAnimOffsetY.text = "" + newOffsets[1];
  }

  var checkAnim:MenuCheckBox = new MenuCheckBox();
  var checkData:MenuCheckBox = new MenuCheckBox();
  var checkHealth:MenuCheckBox = new MenuCheckBox();
  var checkGhost:MenuCheckBox = new MenuCheckBox();

  override public function fillUpPageSettings(item:haxe.ui.containers.menus.Menu)
  {
    item.addComponent(checkAnim);
    item.addComponent(checkData);
    item.addComponent(checkHealth);
    item.addComponent(checkGhost);
  }

  public function refreshGhoulAnims()
  {
    var ghostDialog = cast(dialogMap[Ghost], GhostSettingsDialog);
    ghostDialog.ghostAnimDropdown.dataSource.clear();
    for (anim in ghostCharacter.animations)
      ghostDialog.ghostAnimDropdown.dataSource.add({text: anim.name});
  }

  function set_ghostId(value:String)
  {
    if (ghostId == value) return ghostId;
    this.ghostId = value;

    var animDialog = cast(dialogMap[Animation], AddAnimDialog);
    var ghostDialog = cast(dialogMap[Ghost], GhostSettingsDialog);

    if (ghostId == "")
    {
      ghostCharacter.fromCharacter(currentCharacter);
    }
    else
    {
      var data:CharacterData = CharacterRegistry.fetchCharacterData(ghostId);
      if (data == null) return ghostId;

      ghostCharacter.fromCharacterData(data);
    }

    refreshGhoulAnims();
    updateCharPerStageData(currentCharacter.characterType);

    return ghostId;
  }

  override public function performCleanup()
  {
    Conductor.instance.onBeatHit.remove(stageBeatHit);
  }

  static inline final GHOST_SKIN_ALPHA:Float = 0.3;

  public function updateCharPerStageData(type:CharacterType = BF)
  {
    if (charStageDatas[type] == null) return;

    currentCharacter.zIndex = charStageDatas[type].zIndex;
    currentCharacter.x = charStageDatas[type].position[0] - currentCharacter.characterOrigin.x + currentCharacter.globalOffsets[0];
    currentCharacter.y = charStageDatas[type].position[1] - currentCharacter.characterOrigin.y + currentCharacter.globalOffsets[1];
    currentCharacter.totalScale = currentCharacter.characterScale * charStageDatas[type].scale;
    currentCharacter.flipX = (type == BF ? !currentCharacter.characterFlipX : currentCharacter.characterFlipX);

    ghostCharacter.characterType = currentCharacter.characterType = type;

    ghostCharacter.alpha = GHOST_SKIN_ALPHA;
    ghostCharacter.zIndex = currentCharacter.zIndex + 1; // should onion skin be behind or in front?
    ghostCharacter.x = charStageDatas[type].position[0] - ghostCharacter.characterOrigin.x + ghostCharacter.globalOffsets[0];
    ghostCharacter.y = charStageDatas[type].position[1] - ghostCharacter.characterOrigin.y + ghostCharacter.globalOffsets[1];
    ghostCharacter.totalScale = ghostCharacter.characterScale * charStageDatas[type].scale;
    ghostCharacter.flipX = (type == BF ? !ghostCharacter.characterFlipX : ghostCharacter.characterFlipX);

    sortAssets();
  }

  function generateUI()
  {
    // defaults for UI
    labelAnimName.text = "None";
    labelAnimOffsetX.text = labelAnimOffsetY.text = "0";
    labelCharType.text = "BF";

    labelAnimName.styleNames = labelAnimOffsetX.styleNames = labelAnimOffsetY.styleNames = labelCharType.styleNames = "infoText";
    labelAnimName.verticalAlign = labelAnimOffsetX.verticalAlign = labelAnimOffsetY.verticalAlign = labelCharType.verticalAlign = "center";

    labelAnimName.tooltip = "Left Click to play the Next Animation";
    labelAnimOffsetX.tooltip = "Left/Right Click to Increase/Decrease the Horizontal Offset.";
    labelAnimOffsetY.tooltip = "Left/Right Click to Increase/Decrease the Vertical Offset.";
    labelCharType.tooltip = "Left Click/Right Click to switch to the Next/Previous Character Mode.";

    stageDropdown.text = "Select Stage";
    stageDropdown.dropdownVerticalPosition = "top";
    stageDropdown.width = 125;
    stageDropdown.selectedItem = curStage;

    var stages = StageRegistry.instance.listEntryIds();
    stages.sort(funkin.util.SortUtil.alphabetically);
    for (aught in stages)
      stageDropdown.dataSource.add({text: aught});

    checkAnim.text = "Animation Data";
    checkData.text = "Character Metadata";
    checkHealth.text = "Health Icon Data";
    checkGhost.text = "Ghost Settings";

    // ==================callback bs==================

    labelAnimName.onClick = function(_) {
      var drop = cast(dialogMap[Animation], AddAnimDialog).charAnimDropdown;
      if (drop.selectedIndex == -1) return;

      var id = drop.selectedIndex + 1;
      if (id >= drop.dataSource.size) id = 0;
      drop.selectedIndex = id;
      currentCharacter.playAnimation(currentCharacter.animations[drop.selectedIndex].name);
    }

    labelAnimName.onRightClick = function(_) {
      var drop = cast(dialogMap[Animation], AddAnimDialog).charAnimDropdown;
      if (drop.selectedIndex == -1) return;

      var id = drop.selectedIndex - 1;
      if (id < 0) id = drop.dataSource.size - 1;
      drop.selectedIndex = id;
      currentCharacter.playAnimation(currentCharacter.animations[drop.selectedIndex].name);
    }

    labelAnimOffsetX.onClick = _ -> changeCharAnimOffset(5);
    labelAnimOffsetX.onRightClick = _ -> changeCharAnimOffset(-5);
    labelAnimOffsetY.onClick = _ -> changeCharAnimOffset(0, 5);
    labelAnimOffsetY.onRightClick = _ -> changeCharAnimOffset(0, -5);

    var typesArray = [BF, GF, DAD];
    labelCharType.onClick = function(_) {
      var idx = typesArray.indexOf(currentCharacter.characterType);
      idx++;
      if (idx >= typesArray.length) idx = 0;
      updateCharPerStageData(typesArray[idx]);
      labelCharType.text = Std.string(currentCharacter.characterType);
    }
    labelCharType.onRightClick = function(_) {
      var idx = typesArray.indexOf(currentCharacter.characterType);
      idx--;
      if (idx < 0) idx = typesArray.length - 1;
      updateCharPerStageData(typesArray[idx]);
      labelCharType.text = Std.string(currentCharacter.characterType);
    }
    stageDropdown.onChange = function(_) {
      curStage = stageDropdown.selectedItem?.text ?? curStage;
      updateCharPerStageData(currentCharacter.characterType);
    }

    checkAnim.onChange = function(_) {
      dialogMap[Animation].hidden = !checkAnim.selected;
    }
    checkData.onChange = function(_) {
      dialogMap[Data].hidden = !checkData.selected;
    }
    checkHealth.onChange = function(_) {
      dialogMap[Health].hidden = !checkHealth.selected;
    }
    checkGhost.onChange = function(_) {
      dialogMap[Ghost].hidden = !checkGhost.selected;
    }
  }

  function sortAssets()
  {
    sort(funkin.util.SortUtil.byZIndex, flixel.util.FlxSort.ASCENDING);
  }

  function set_curStage(value:String)
  {
    this.curStage = value;

    // clear da assets
    while (stageProps.length > 0)
    {
      var memb = stageProps.pop();
      memb.kill();
      remove(memb, true);
      memb.destroy();
    }

    var data = StageRegistry.instance.parseEntryData(curStage);
    if (data == null) return curStage;

    Paths.setCurrentLevel(data.directory ?? "shared");
    openfl.utils.Assets.loadLibrary(data.directory ?? "shared").onComplete(_ -> generateStageFromData(data)); // loading shit may take a while cuz web!

    return curStage;
  }

  function generateStageFromData(data:StageData)
  {
    if (data == null) return;

    stageZoom = data.cameraZoom ?? 1.0;
    charStageDatas.set(BF, data.characters.bf);
    charStageDatas.set(GF, data.characters.gf);
    charStageDatas.set(DAD, data.characters.dad);

    for (prop in data.props)
    {
      var spr:StageProp = (prop.danceEvery ?? 0) == 0 ? new StageProp() : new Bopper(prop.danceEvery);

      if (prop.animations.length > 0)
      {
        switch (prop.animType)
        {
          case 'packer':
            spr.loadPacker(prop.assetPath);
          default:
            spr.loadSparrow(prop.assetPath);
        }
      }
      else if (prop.assetPath.startsWith("#"))
      {
        var width:Int = 1;
        var height:Int = 1;
        switch (prop.scale)
        {
          case Left(value):
            width = Std.int(value);
            height = Std.int(value);

          case Right(values):
            width = Std.int(values[0]);
            height = Std.int(values[1]);
        }
        spr.makeSolidColor(width, height, FlxColor.fromString(prop.assetPath));
      }
      else
      {
        spr.loadTexture(prop.assetPath);
        spr.active = false;
      }

      if (spr.frames == null || spr.frames.numFrames == 0)
      {
        @:privateAccess
        trace('    ERROR: Could not build texture for prop. Check the asset path (${Paths.currentLevel ?? 'default'}, ${prop.assetPath}).');
        continue;
      }

      if (!prop.assetPath.startsWith("#"))
      {
        switch (prop.scale)
        {
          case Left(value):
            spr.scale.set(value, value);

          case Right(values):
            spr.scale.set(values[0], values[1]);
        }
      }
      spr.updateHitbox();

      spr.setPosition(prop.position[0], prop.position[1]);
      spr.alpha = prop.alpha;
      spr.angle = prop.angle;
      spr.antialiasing = !prop.isPixel;
      spr.pixelPerfectPosition = spr.pixelPerfectRender = prop.isPixel;
      spr.scrollFactor.set(prop.scroll[0], prop.scroll[1]);
      spr.color = FlxColor.fromString(prop.color);
      @:privateAccess spr.blend = openfl.display.BlendMode.fromString(prop.blend);
      spr.zIndex = prop.zIndex;
      spr.flipX = prop.flipX;
      spr.flipY = prop.flipY;

      switch (prop.animType)
      {
        case CharacterRenderType.Packer:
          for (anim in prop.animations)
          {
            spr.animation.add(anim.name, anim.frameIndices, anim.frameRate, anim.looped, anim.flipX, anim.flipY);
            if (Std.isOfType(spr, Bopper)) cast(spr, Bopper).setAnimationOffsets(anim.name, anim.offsets[0], anim.offsets[1]);
          }
        default: // 'sparrow'
          funkin.util.assets.FlxAnimationUtil.addAtlasAnimations(spr, prop.animations);
          if (Std.isOfType(spr, Bopper))
          {
            for (anim in prop.animations)
              cast(spr, Bopper).setAnimationOffsets(anim.name, anim.offsets[0], anim.offsets[1]);
          }
      }

      add(spr);
      stageProps.push(spr);
    }

    sortAssets();
  }
}

enum CharDialogType
{
  Animation;
  Data;
  Ghost;
  Health;
}
