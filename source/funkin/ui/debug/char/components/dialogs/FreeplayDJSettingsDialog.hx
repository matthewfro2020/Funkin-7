package funkin.ui.debug.char.components.dialogs;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/freeplay-dj-settings-dialog.xml"))
class FreeplayDJSettingsDialog extends DefaultPageDialog
{
  public var bgText1(get, never):String;

  function get_bgText1():String
  {
    return bgTextField1.value ?? bgTextField1.placeholder;
  }

  public var bgText2(get, never):String;

  function get_bgText2():String
  {
    return bgTextField2.value ?? bgTextField2.placeholder;
  }

  public var bgText3(get, never):String;

  function get_bgText3():String
  {
    return bgTextField3.value ?? bgTextField3.placeholder;
  }

  override public function new(daPage:CharCreatorDefaultPage)
  {
    super(daPage);
  }
}
