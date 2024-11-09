package funkin.ui.debug.char.handlers;

import haxe.io.Path;
import funkin.data.character.CharacterRegistry;
import funkin.ui.debug.char.pages.CharCreatorGameplayPage;
import funkin.ui.debug.char.CharCreatorState;
import funkin.util.FileUtil;

using StringTools;

@:access(funkin.ui.debug.char.CharCreatorState)
class CharCreatorImportExportHandler
{
  public static function importCharacter(state:CharCreatorState, charId:String):Void
  {
    var gameplayPage:CharCreatorGameplayPage = cast state.pages[Gameplay];

    var data = CharacterRegistry.fetchCharacterData(charId);

    if (data == null)
    {
      trace('No character data for $charId (CharCreatorImportExportHandler.importCharacter)');
      return;
    }

    gameplayPage.currentCharacter.fromCharacterData(CharacterRegistry.fetchCharacterData(charId));
  }

  public static function exportCharacter(state:CharCreatorState):Void
  {
    var gameplayPage:CharCreatorGameplayPage = cast state.pages[Gameplay];

    var zipEntries = [];

    for (file in gameplayPage.currentCharacter.files)
    {
      // skip if the file is in a character path
      if (CharCreatorUtil.isPathProvided(file.name, "images/characters"))
      {
        continue;
      }

      zipEntries.push(FileUtil.makeZIPEntryFromBytes('images/characters/${Path.withoutDirectory(file.name)}', file.bytes));
    }

    // if the icon path isn't absolute, in the proper folder AND there already was an xml file (if we added one), then we don't save files and replace the typedef's id field
    if (gameplayPage.currentCharacter.healthIconFiles.length > 0)
    {
      var iconPath = gameplayPage.currentCharacter.healthIconFiles[0].name;
      if (CharCreatorUtil.isPathProvided(iconPath, "images/icons/icon-")
        && ((gameplayPage.currentCharacter.healthIconFiles.length > 1
          && CharCreatorUtil.isPathProvided(iconPath.replace(".png", ".xml"), "images/icons/icon-"))
          || gameplayPage.currentCharacter.healthIconFiles.length == 1))
      {
        var typicalPath = Path.withoutDirectory(iconPath).split(".")[0];
        gameplayPage.currentCharacter.healthIcon.id = typicalPath.replace("icon-", "");
      }
      else
      {
        for (file in gameplayPage.currentCharacter.healthIconFiles)
          zipEntries.push(FileUtil.makeZIPEntryFromBytes('images/icons/icon-${gameplayPage.currentCharacter.characterId}.${Path.extension(file.name)}',
            file.bytes));
      }
    }

    // we push this later in case we use a pre-existing icon
    zipEntries.push(FileUtil.makeZIPEntry('${gameplayPage.currentCharacter.characterId}.json', gameplayPage.currentCharacter.toJSON()));
    FileUtil.saveFilesAsZIP(zipEntries);
  }
}
