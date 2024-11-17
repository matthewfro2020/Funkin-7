package funkin.ui.debug.char.components.dialogs;

import funkin.data.freeplay.style.FreeplayStyleRegistry;
import funkin.data.freeplay.player.PlayerRegistry;
import haxe.ui.components.OptionBox;

@:access(funkin.ui.debug.char.pages.CharCreatorFreeplayPage)
@:xml('
<?xml version="1.0" encoding="utf-8"?>
<collapsible-dialog width="400" height="425" title="Freeplay Style Settings">
  <vbox width="100%" height="100%">
    <hbox width="100%" height="100%">

      <vbox width="50%" height="100%">
        <optionbox id="optionMakeNew" text="Use Custom" group="freepStypeGroup" selected="true"/>
        <scrollview width="100%" height="100%" contentWidth="100%">
            <vbox id="freeplayStyleNew" width="100%">

            </vbox>
        </scrollview>
      </vbox>

      <vbox width="50%" height="100%">
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
    }
  }
}
