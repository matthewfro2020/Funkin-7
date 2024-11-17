package funkin.ui.debug.char.components.dialogs;

import funkin.ui.debug.char.pages.CharCreatorFreeplayPage;
import funkin.data.freeplay.player.PlayerRegistry;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/freeplay-dj-settings-dialog.xml"))
@:access(funkin.ui.debug.char.pages.CharCreatorFreeplayPage)
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

  override public function new(daPage:CharCreatorFreeplayPage)
  {
    super(daPage);

    var data = daPage.data;

    var currentChar = PlayerRegistry.instance.fetchEntry(data.importedPlayerData);
    if (currentChar != null)
    {
      bgTextField1.value = currentChar.getFreeplayDJText(1);
      bgTextField2.value = currentChar.getFreeplayDJText(2);
      bgTextField3.value = currentChar.getFreeplayDJText(3);
    }

    bgTextField1.onChange = bgTextField2.onChange = bgTextField3.onChange = _ -> daPage.updateScrollingTexts();
  }
}
