package funkin.ui.debug.char.components.dialogs;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/playable-character-settings-dialog.xml"))
class PlayableCharacterSettingsDialog extends DefaultPageDialog
{
  override public function new(daPage:CharCreatorDefaultPage)
  {
    super(daPage);
  }
}
