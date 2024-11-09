package funkin.ui.debug.char.components.wizard;

import funkin.data.character.CharacterData;
import funkin.data.character.CharacterRegistry;
import funkin.data.freeplay.player.PlayerRegistry;
import haxe.ui.components.OptionBox;

@:xml('
<?xml version="1.0" encoding="utf-8"?>
<dialog width="400" height="425" title="Character Creator - Import Data" closable="false">
  <vbox width="100%" height="100%">
    <label text="Choose the Optional Data to import." width="100%"/>
    <hbox width="100%" height="100%">

      <vbox id="importCharData" width="50%" height="100%">
        <checkbox id="importCharCheck" text="Use Characater Data"/>
        <scrollview width="100%" height="100%" contentWidth="100%">
          <vbox id="importCharList" width="100%" disabled="true"/>
        </scrollview>
      </vbox>

      <vbox id="importPlayer" width="50%" height="100%">
        <checkbox id="importPlayerCheck" text="Use Player Data"/>
        <scrollview width="100%" height="100%" contentWidth="100%">
          <vbox id="importPlayerList" width="100%" disabled="true"/>
        </scrollview>
      </vbox>

    </hbox>

  </vbox>
</dialog>
')
class ImportDataDialog extends DefaultWizardDialog
{
  override public function new()
  {
    super(IMPORT_DATA);

    importCharCheck.onChange = function(_) importCharList.disabled = !importCharCheck.selected;
    importPlayerCheck.onChange = function(_) importPlayerList.disabled = !importPlayerCheck.selected;

    for (id in CharacterRegistry.listCharacterIds())
    {
      var check = new OptionBox();
      check.text = id;
      check.componentGroup = "characterData";
      check.selected = (id == selectedData);
      check.onChange = _ -> {
        selectedData = id;
      }
      importCharList.addComponent(check);
    }

    for (id in PlayerRegistry.instance.listEntryIds())
    {
      var check = new OptionBox();
      check.text = id;
      check.componentGroup = "playerData";
      check.selected = (id == selectedPlayer);
      check.onChange = _ -> {
        selectedPlayer = id;
      }
      importPlayerList.addComponent(check);
    }
  }

  var selectedData:String = Constants.DEFAULT_CHARACTER;
  var selectedPlayer:String = "bf"; // eh

  override public function showDialog(modal:Bool = true)
  {
    super.showDialog(modal);

    // we dont want to import any data if we don't even generate the character to begin with
    importCharData.disabled = !params.generateCharacter;
    importPlayer.disabled = !params.generatePlayerData;
  }

  override public function isNextStepAvailable()
  {
    if (params.generateCharacter && importCharCheck.selected) params.importedCharacter = selectedData;
    else
      params.importedCharacter = null;

    if (params.importedCharacter != null) params.renderType = CharacterRegistry.parseCharacterData(params.importedCharacter)?.renderType ?? Sparrow;

    // same shit for the player, though it's currently not my priority

    return true;
  }
}
