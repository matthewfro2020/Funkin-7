package funkin.ui.debug.char.handlers;

import haxe.io.Path;
import funkin.ui.debug.char.pages.CharCreatorGameplayPage;
import funkin.ui.debug.char.CharCreatorState;
import funkin.util.FileUtil;

@:access(funkin.ui.debug.char.CharCreatorState)
class CharCreatorImportExportHandler
{
  public static function importCharacter(state:CharCreatorState):Void {}

  public static function exportCharacter(state:CharCreatorState):Void
  {
    var gameplayPage:CharCreatorGameplayPage = cast state.pages[Gameplay];

    var zipEntries = [];
    zipEntries.push(FileUtil.makeZIPEntry('${gameplayPage.currentCharacter.characterId}.json', gameplayPage.currentCharacter.toJSON()));

    for (file in gameplayPage.currentCharacter.files)
    {
      // skip if the file is in a character path
      if (CharCreatorUtil.isCharacterPath(file.name))
      {
        continue;
      }

      zipEntries.push(FileUtil.makeZIPEntryFromBytes('images/characters/${Path.withoutDirectory(file.name)}', file.bytes));
    }

    FileUtil.saveFilesAsZIP(zipEntries);
  }
}
