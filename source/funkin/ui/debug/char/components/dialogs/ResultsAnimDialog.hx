package funkin.ui.debug.char.components.dialogs;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/results-anim-dialog.xml"))
class ResultsAnimDialog extends DefaultPageDialog
{
  override public function new(daPage:CharCreatorResultsPage)
  {
    super(daPage);

    rankDropdown.onChange = function(_) {
    }

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
