package funkin.ui.debug.char.components.dialogs.results;

import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Button;
import funkin.data.freeplay.player.PlayerData;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.play.scoring.Scoring.ScoringRank;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.graphics.FunkinSprite;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/results-anim-dialog.xml"))
@:access(funkin.ui.debug.char.pages.CharCreatorResultsPage)
class ResultsAnimDialog extends DefaultPageDialog
{
  public var currentRank(get, never):ScoringRank;

  var rankAnimationDataMap:Map<ScoringRank, Array<PlayerResultsAnimationData>> = [];

  var rankAnimationBox:AddRankAnimationDataBox;

  var previousRank:ScoringRank;

  override public function new(daPage:CharCreatorResultsPage)
  {
    super(daPage);

    var charId = daPage.data.importedPlayerData ?? "";
    var currentChar = PlayerRegistry.instance.fetchEntry(charId);
    for (rank in CharCreatorResultsPage.ALL_RANKS)
    {
      var playerAnimations = currentChar?.getResultsAnimationDatas(rank) ?? [];
      rankAnimationDataMap.set(rank, playerAnimations);
      createAnimations(rank, playerAnimations);
    }

    rankAnimationBox = new AddRankAnimationDataBox();
    rankAnimationView.addComponent(rankAnimationBox);

    rankDropdown.selectedIndex = 0;
    rankDropdown.onChange = function(_) {
      if (previousRank == currentRank) return;

      daPage.clearSprites();
      changeRankPreview();
      daPage.playAnimation();
    }

    rankAnimationBox.useAnimationData(rankAnimationDataMap[currentRank]);
    previousRank = currentRank;
  }

  public function changeRankPreview():Void
  {
    updateRankAnimations(previousRank);
    rankAnimationBox.useAnimationData(rankAnimationDataMap[currentRank]);
    previousRank = currentRank;
  }

  function updateRankAnimations(rank:ScoringRank):Void
  {
    var parentList = rankAnimationBox.parentComponent;
    if (parentList == null) return;

    var animations = [
      for (animData in parentList.childComponents)
        if (Std.isOfType(animData, RankAnimationData)) cast(animData, RankAnimationData).animData
    ];

    rankAnimationDataMap.set(rank, animations);
  }

  function createAnimations(rank:ScoringRank, playerAnimations:Array<PlayerResultsAnimationData>):Void
  {
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
          this.page.add(animation);
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
          this.page.add(animation);
      }
    }

    cast(page, CharCreatorResultsPage).characterAtlasAnimationsMap.set(rank, atlasAnimations);
    cast(page, CharCreatorResultsPage).characterSparrowAnimationsMap.set(rank, sparrowAnimations);
  }

  function get_currentRank():ScoringRank
  {
    if (rankDropdown.safeSelectedItem == null) return PERFECT_GOLD;

    switch (rankDropdown.safeSelectedItem.text)
    {
      case "Perfect Gold":
        return PERFECT_GOLD;
      case "Perfect":
        return PERFECT;
      case "Excellent":
        return EXCELLENT;
      case "Great":
        return GREAT;
      case "Good":
        return GOOD;
      case "Shit":
        return SHIT;
    }

    return PERFECT_GOLD;
  }
}

private class AddRankAnimationDataBox extends HBox
{
  var addButton:Button;
  var removeButton:Button;

  public function new()
  {
    super();

    styleString = "border:1px solid $normal-border-color";
    percentWidth = 100;
    height = 25;
    verticalAlign = "center";

    addButton = new Button();
    addButton.text = "Add New Box";
    removeButton = new Button();
    removeButton.text = "Remove Last Box";

    addButton.percentWidth = removeButton.percentWidth = 50;
    addButton.percentHeight = removeButton.percentHeight = 100;

    addButton.onClick = function(_) {
      var parentList = this.parentComponent;
      if (parentList == null) return;

      parentList.addComponentAt(new RankAnimationData(), parentList.childComponents.length - 1); // considering this box is last
      removeButton.disabled = false;
    }

    removeButton.disabled = true;
    removeButton.onClick = function(_) {
      var parentList = this.parentComponent;
      if (parentList == null) return;

      parentList.removeComponentAt(parentList.childComponents.length - 2);
      if (parentList.childComponents.length <= 2) removeButton.disabled = true;
    }

    addComponent(addButton);
    addComponent(removeButton);
  }

  public function useAnimationData(playerAnimations:Array<PlayerResultsAnimationData>):Void
  {
    var parentList = this.parentComponent;
    if (parentList == null) return;

    clearAnimationData();

    for (animData in playerAnimations)
    {
      parentList.addComponentAt(new RankAnimationData(animData), parentList.childComponents.length - 1);
    }

    removeButton.disabled = parentList.childComponents.length <= 2;
  }

  function clearAnimationData():Void
  {
    var parentList = this.parentComponent;
    if (parentList == null) return;

    while (parentList.childComponents.length > 1)
      parentList.removeComponentAt(parentList.childComponents.length - 2);
  }
}

@:xml('
<?xml version="1.0" encoding="utf-8"?>
<vbox width="100%" style="border:1px solid $normal-border-color; padding: 5px">
  <dropdown id="animRenderType" width="100%" height="25" dropdownHeight="50">
    <data>
      <item text="Animate Atlas" value="animateatlas"/>
      <item text="Sparrow" value="sparrow"/>
    </data>
  </dropdown>
  <textfield id="animAssetPath" placeholder="Asset Path" width="100%"/>
  <hbox width="100%" verticalAlign="center">
    <label text="Offsets" verticalAlign="center"/>
    <number-stepper id="animOffsetX" step="1" pos="0" verticalAlign="center"/>
    <number-stepper id="animOffsetY" step="1" pos="0" verticalAlign="center"/>
  </hbox>
  <hbox width="100%" verticalAlign="center">
    <label text="Z Index" verticalAlign="center"/>
    <number-stepper id="animZIndex" min="0" step="1" pos="500" verticalAlign="center"/>
  </hbox>
  <hbox width="100%" verticalAlign="center">
    <label text="Delay" verticalAlign="center"/>
    <number-stepper id="animDelay" min="0" step="0.01" verticalAlign="center"/>
  </hbox>
  <hbox width="100%" verticalAlign="center">
    <label text="Scale" verticalAlign="center"/>
    <number-stepper id="animScale" min="0" step="0.01" pos="1" verticalAlign="center"/>
  </hbox>
  <checkbox id="animLooped" text="Looped" selected="true"/>
  <hbox width="100%" verticalAlign="center">
    <checkbox id="animStartFrameLabelCheck" text="Start Frame Label" verticalAlign="center"/>
    <textfield id="animStartFrameLabel" placeholder="Frame Label" disabled="true" verticalAlign="center"/>
  </hbox>
  <hbox width="100%" verticalAlign="center">
    <checkbox id="animLoopFrameCheck" text="Loop Frame" verticalAlign="center"/>
    <number-stepper id="animLoopFrame" min="0" step="1" disabled="true" verticalAlign="center"/>
  </hbox>
  <hbox width="100%" verticalAlign="center">
    <checkbox id="animLoopFrameLabelCheck" text="Loop Frame Label" verticalAlign="center"/>
    <textfield id="animLoopFrameLabel" placeholder="Loop Frame Label" disabled="true" verticalAlign="center"/>
  </hbox>
</vbox>
')
private class RankAnimationData extends VBox
{
  public var animData(get, never):PlayerResultsAnimationData;

  function get_animData():PlayerResultsAnimationData
  {
    return {
      renderType: animRenderType.safeSelectedItem,
      assetPath: animAssetPath.text,
      offsets: [animOffsetX.value, animOffsetY.value],
      zIndex: animZIndex.value,
      delay: animDelay.value,
      scale: animScale.value,
      startFrameLabel: animStartFrameLabel.text,
      looped: animLooped.selected,
      loopFrame: animLoopFrame.value,
      loopFrameLabel: animLoopFrameLabel.text,
    };
  }

  public function new(?data:PlayerResultsAnimationData)
  {
    super();

    animStartFrameLabelCheck.onClick = function(_) {
      animStartFrameLabel.disabled = !animStartFrameLabelCheck.selected;
    }

    animLoopFrameCheck.onClick = function(_) {
      animLoopFrame.disabled = !animLoopFrameCheck.selected;
    }

    animLoopFrameLabelCheck.onClick = function(_) {
      animLoopFrameLabel.disabled = !animLoopFrameLabelCheck.selected;
    }

    if (data != null)
    {
      animRenderType.selectedIndex = data.renderType == "sparrow" ? 1 : 0;
      animAssetPath.value = data.assetPath;

      if (data.offsets != null)
      {
        animOffsetX.value = data.offsets[0];
        animOffsetY.value = data.offsets[1];
      }

      if (data.zIndex != null) animZIndex.value = data.zIndex;

      if (data.delay != null) animDelay.value = data.delay;

      if (data.scale != null) animScale.value = data.scale;

      if (data.looped != null) animLooped.selected = data.looped;

      if (data.startFrameLabel != null && data.startFrameLabel != "")
      {
        animStartFrameLabelCheck.selected = true;
        animStartFrameLabel.disabled = false;
        animStartFrameLabel.text = data.startFrameLabel;
      }

      if (data.loopFrame != null)
      {
        animLoopFrameCheck.selected = true;
        animLoopFrame.disabled = false;
        animLoopFrame.value = data.loopFrame;
      }

      if (data.loopFrameLabel != null)
      {
        animLoopFrameLabelCheck.selected = true;
        animLoopFrameLabel.disabled = false;
        animLoopFrameLabel.text = data.loopFrameLabel;
      }
    }
  }
}
