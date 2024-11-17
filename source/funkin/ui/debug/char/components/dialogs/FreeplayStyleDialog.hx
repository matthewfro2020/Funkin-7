package funkin.ui.debug.char.components.dialogs;

import funkin.data.freeplay.style.FreeplayStyleRegistry;
import funkin.data.freeplay.player.PlayerRegistry;
import haxe.ui.components.OptionBox;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;

@:access(funkin.ui.debug.char.pages.CharCreatorFreeplayPage)
@:xml('
<?xml version="1.0" encoding="utf-8"?>
<collapsible-dialog width="400" height="425" title="Freeplay Style Settings">
  <vbox width="100%" height="100%">
    <hbox width="100%" height="100%">

      <vbox width="65%" height="100%">
        <optionbox id="optionMakeNew" text="Use Custom" group="freepStypeGroup" selected="true"/>
        <scrollview width="100%" height="100%" contentWidth="100%">
            <vbox id="freeplayStyleNew" width="100%">

              <section-header text="Asset Paths"/>
              <hbox width="100%">
                <textfield id="fieldBGAsset" placeholder="Background Asset Path" width="75%"/>
                <button id="buttonBGAsset" text="Load" width="25%"/>
              </hbox>
              <hbox width="100%">
                <textfield id="fieldArrow" placeholder="Arrows Asset Path" width="75%"/>
                <button id="buttonArrow" text="Load" width="25%"/>
              </hbox>
              <hbox width="100%">
                <textfield id="fieldNumbers" placeholder="Numbers Asset Path" width="75%"/>
                <button id="buttonNumbers" text="Load" width="25%"/>
              </hbox>
              <hbox width="100%">
                <textfield id="fieldCapsule" placeholder="Capsule Asset Path" width="75%"/>
                <button id="buttonCapsule" text="Load" width="25%"/>
              </hbox>

               <section-header text="Capsule Colors"/>
               <hbox width="100%">
                  <label text="Select" width="35%" />
                  <color-picker-popup id="selectPicker" width="65%"/>
               </hbox>
               <hbox width="100%">
                  <label text="Deselect" width="35%" />
                  <color-picker-popup id="deselectPicker" width="65%"/>
               </hbox>

                <section-header text="Start Delay"/>
                <number-stepper id="delayStepper" pos="0" min="0"/>
            </vbox>
        </scrollview>
      </vbox>

      <vbox width="35%" height="100%">
        <optionbox id="optionUsePreset" text="Use Preset" group="freepStypeGroup"/>
        <scrollview width="100%" height="75%" contentWidth="100%">
            <vbox id="freeplayStylePresets" width="100%" disabled="true"/>
        </scrollview>

        <button id="buttonApplyStyle" text="Apply Style" horizontalAlign="center"/>
      </vbox>

    </hbox>
  </vbox>
</collapsible-dialog>
')
class FreeplayStyleDialog extends DefaultPageDialog
{
  var styleID:String;

  override public function new(daPage:CharCreatorFreeplayPage)
  {
    super(daPage);

    var entries = FreeplayStyleRegistry.instance.listEntryIds();
    var daPlayuh = PlayerRegistry.instance.fetchEntry(daPage.data.importedPlayerData);

    for (i in 0...entries.length)
    {
      var daBox = new OptionBox();
      daBox.text = entries[i];
      daBox.selected = (daPlayuh?.getFreeplayStyleID() != null ? daPlayuh.getFreeplayStyleID() == entries[i] : i == 0);
      if (daBox.selected) styleID = entries[i];
      daBox.onChange = _ -> {
        styleID = entries[i];
      }
      daBox.componentGroup = "freeplayStylePreset";
      freeplayStylePresets.addComponent(daBox);
    }

    optionMakeNew.onChange = optionUsePreset.onChange = function(_) {
      freeplayStyleNew.disabled = optionUsePreset.selected;
      freeplayStylePresets.disabled = optionMakeNew.selected;
    }

    optionUsePreset.selected = (daPlayuh != null);
    optionMakeNew.selected = (daPlayuh == null);

    buttonApplyStyle.onClick = function(_) {
      if (optionUsePreset.selected)
      {
        var daStyle = FreeplayStyleRegistry.instance.fetchEntry(styleID);

        daPage.bgDad.loadGraphic(daStyle?.getBgAssetGraphic() != null ? daStyle.getBgAssetGraphic() : Paths.image('freeplay/freeplayBGdad'));

        daPage.arrowLeft.frames = daPage.arrowRight.frames = Paths.getSparrowAtlas(daStyle?.getSelectorAssetKey() ?? 'freeplay/freeplaySelector');
        daPage.arrowLeft.animation.addByPrefix('shine', 'arrow pointer loop', 24);
        daPage.arrowRight.animation.addByPrefix('shine', 'arrow pointer loop', 24);
        daPage.arrowLeft.animation.play('shine');
        daPage.arrowRight.animation.play('shine');

        daPage.randomCapsule.applyStyle(daStyle);
      }
      else if (optionMakeNew.selected)
      {
        var dadBitmap = BitmapData.fromBytes(CharCreatorUtil.gimmeTheBytes(fieldBGAsset.text));
        var arrowBitmap = BitmapData.fromBytes(CharCreatorUtil.gimmeTheBytes(fieldArrow.text));
        var capsuleBitmap = BitmapData.fromBytes(CharCreatorUtil.gimmeTheBytes(fieldCapsule.text));

        var arrowXML = CharCreatorUtil.gimmeTheBytes(fieldArrow.text.replace(".png", ".xml"))?.toString() ?? "";
        var capsuleXML = CharCreatorUtil.gimmeTheBytes(fieldCapsule.text.replace(".png", ".xml"))?.toString() ?? "";

        daPage.bgDad.loadGraphic(dadBitmap != null ? dadBitmap : Paths.image('freeplay/freeplayBGdad'));

        daPage.arrowLeft.frames = daPage.arrowRight.frames = (arrowBitmap != null && arrowXML != "") ? FlxAtlasFrames.fromSparrow(arrowBitmap,
          arrowXML) : Paths.getSparrowAtlas('freeplay/freeplaySelector');

        daPage.arrowLeft.animation.addByPrefix('shine', 'arrow pointer loop', 24);
        daPage.arrowRight.animation.addByPrefix('shine', 'arrow pointer loop', 24);
        daPage.arrowLeft.animation.play('shine');
        daPage.arrowRight.animation.play('shine');

        // overcomplicating capsule stuff
        daPage.randomCapsule.capsule.frames = (capsuleBitmap != null && capsuleXML != "") ? FlxAtlasFrames.fromSparrow(capsuleBitmap,
          capsuleXML) : Paths.getSparrowAtlas('freeplay/freeplayCapsule/capsule/freeplayCapsule');
        daPage.randomCapsule.capsule.animation.addByPrefix('selected', 'mp3 capsule w backing0', 24);
        daPage.randomCapsule.capsule.animation.addByPrefix('unselected', 'mp3 capsule w backing NOT SELECTED', 24);

        @:privateAccess
        {
          trace(selectPicker.selectedItem);
          daPage.randomCapsule.songText.glowColor = daPage.randomCapsule.songText.blurredText.color = flixel.util.FlxColor.fromRGB(selectPicker.selectedItem?.r ?? 0,
            selectPicker.selectedItem?.g ?? 0, selectPicker.selectedItem?.b ?? 0);
          daPage.randomCapsule.songText.whiteText.textField.filters = [
            new openfl.filters.GlowFilter(daPage.randomCapsule.songText.glowColor, 1, 5, 5, 210, openfl.filters.BitmapFilterQuality.MEDIUM),
          ];
        }
      }
    }
  }
}
