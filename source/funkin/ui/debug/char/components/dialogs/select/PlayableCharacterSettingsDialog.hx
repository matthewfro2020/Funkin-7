package funkin.ui.debug.char.components.dialogs.select;

import haxe.ui.containers.HBox;
import haxe.ui.components.Button;
import haxe.ui.components.DropDown;
import haxe.ui.components.VerticalScroll;
import haxe.ui.data.ArrayDataSource;
import funkin.data.character.CharacterRegistry;
import funkin.util.SortUtil;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/playable-character-settings-dialog.xml"))
class PlayableCharacterSettingsDialog extends DefaultPageDialog
{
  public var ownedCharacters(get, never):Array<String>;

  function get_ownedCharacters():Array<String>
  {
    return ownedCharBox.listOwnedCharacters();
  }

  var ownedCharBox:AddOwnedCharBox;

  override public function new(daPage:CharCreatorDefaultPage)
  {
    super(daPage);

    ownedCharBox = new AddOwnedCharBox();

    ownedCharsView.addComponent(ownedCharBox);
  }
}

private class AddOwnedCharBox extends HBox
{
  var dropDowns:Array<DropDown> = [];

  override public function new()
  {
    super();

    styleString = "border:1px solid $normal-border-color";
    percentWidth = 100;
    height = 25;
    verticalAlign = "center";

    var addButton = new Button();
    addButton.text = "Add New Box";
    var removeButton = new Button();
    removeButton.text = "Remove Last Box";

    addButton.percentWidth = removeButton.percentWidth = 50;
    addButton.percentHeight = removeButton.percentHeight = 100;

    addButton.onClick = function(_) {
      var parentList = this.parentComponent;
      if (parentList == null) return;

      var newDropDown = new DropDown();
      newDropDown.dataSource = new ArrayDataSource();
      newDropDown.height = 25;
      newDropDown.dropdownHeight = 100;
      newDropDown.percentWidth = 100;
      newDropDown.verticalAlign = "center";
      newDropDown.searchable = true;
      var ids = CharacterRegistry.listCharacterIds();
      ids.sort(SortUtil.alphabetically);
      for (id in ids)
      {
        newDropDown.dataSource.add({text: id, id: id});
      }
      dropDowns.push(newDropDown);

      parentList.addComponentAt(newDropDown, parentList.childComponents.length - 1); // considering this box is last
      removeButton.disabled = false;
    }

    removeButton.disabled = true;
    removeButton.onClick = function(_) {
      var parentList = this.parentComponent;
      if (parentList == null) return;

      dropDowns.pop();

      parentList.removeComponentAt(parentList.childComponents.length - 2);
      if (parentList.childComponents.length <= 2) removeButton.disabled = true;
    }

    addComponent(addButton);
    addComponent(removeButton);
  }

  public function listOwnedCharacters():Array<String>
  {
    return [
      for (dropDown in dropDowns)
        dropDown.selectedItem.id
    ];
  }
}
