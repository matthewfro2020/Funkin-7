package funkin.ui.debug.char.components.dialogs;

import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Button;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/results-anim-dialog.xml"))
class ResultsAnimDialog extends DefaultPageDialog
{
  override public function new(daPage:CharCreatorResultsPage)
  {
    super(daPage);

    rankDropdown.onChange = function(_) {
    }

    rankAnimationView.addComponent(new AddRankAnimationDataBox());
  }
}

private class AddRankAnimationDataBox extends HBox
{
  public function new()
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
    <label text="Delay" verticalAlign="center"/>
    <number-stepper id="animDelay" min="0" step="0.1" verticalAlign="center"/>
  </hbox>
  <hbox width="100%" verticalAlign="center">
    <label text="Scale" verticalAlign="center"/>
    <number-stepper id="animScale" min="0" step="0.1" pos="1" verticalAlign="center"/>
  </hbox>
  <checkbox id="animLooped" text="Looped"/>
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
  public function new()
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
  }
}
