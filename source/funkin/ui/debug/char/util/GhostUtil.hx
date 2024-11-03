package funkin.ui.debug.char.util;

import funkin.data.character.CharacterData;
import funkin.data.character.CharacterData.CharacterRenderType;
import funkin.ui.debug.char.animate.CharSelectAtlasSprite;
import funkin.ui.debug.char.pages.CharCreatorGameplayPage;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import openfl.display.BitmapData;

// utilities for the onion skin/ghost character
class GhostUtil
{
  public static function copyFromCharacter(ghost:CharCreatorCharacter, player:CharCreatorCharacter)
  {
    ghost.generatedParams = player.generatedParams;
    ghost.animations = [];
    ghost.atlasCharacter = null;
    ghost.loadGraphic(null); // should remove all the frames and animations i think

    switch (player.renderType)
    {
      case CharacterRenderType.Sparrow | CharacterRenderType.MultiSparrow:
        if (ghost.generatedParams.files.length < 2) return; // img and data

        var combinedFrames = null;
        for (i in 0...Math.floor(ghost.generatedParams.files.length / 2))
        {
          var img = BitmapData.fromBytes(ghost.generatedParams.files[i * 2].bytes);
          var data = ghost.generatedParams.files[i * 2 + 1].bytes.toString();
          var sparrow = FlxAtlasFrames.fromSparrow(img, data);
          if (combinedFrames == null) combinedFrames = sparrow;
          else
            combinedFrames.addAtlas(sparrow);
        }
        ghost.frames = combinedFrames;

      case CharacterRenderType.Packer:
        if (ghost.generatedParams.files.length != 2) return; // img and data

        var img = BitmapData.fromBytes(ghost.generatedParams.files[0].bytes);
        var data = ghost.generatedParams.files[1].bytes.toString();
        ghost.frames = FlxAtlasFrames.fromSpriteSheetPacker(img, data);

      case CharacterRenderType.AnimateAtlas: // todo
        if (ghost.generatedParams.files.length != 1) return; // zip file with all the data
        ghost.atlasCharacter = new CharSelectAtlasSprite(0, 0, ghost.generatedParams.files[0].bytes);

        ghost.atlasCharacter.alpha = 0.0001;
        ghost.atlasCharacter.draw();
        ghost.atlasCharacter.alpha = 1.0;

        ghost.atlasCharacter.x = ghost.x;
        ghost.atlasCharacter.y = ghost.y;
        ghost.atlasCharacter.alpha *= ghost.alpha;
        ghost.atlasCharacter.flipX = ghost.flipX;
        ghost.atlasCharacter.flipY = ghost.flipY;
        ghost.atlasCharacter.scrollFactor.copyFrom(ghost.scrollFactor);
        @:privateAccess ghost.atlasCharacter.cameras = ghost._cameras; // _cameras instead of cameras because get_cameras() will not return null

      default: // nothing, what the fuck are you even doing
    }

    ghost.globalOffsets = player.globalOffsets.copy();

    for (anim in player.animations)
    {
      ghost.addAnimation(anim.name, anim.prefix, anim.offsets, anim.frameIndices, anim.frameRate, anim.looped, anim.flipX, anim.flipY);
    }
  }

  public static function copyFromCharacterData(ghost:CharCreatorCharacter, data:CharacterData)
  {
    // ghost.generatedParams = player.generatedParams;
    ghost.animations = [];
    ghost.atlasCharacter = null;
    ghost.loadGraphic(null); // should remove all the frames and animations i think

    switch (data.renderType)
    {
      case CharacterRenderType.Sparrow | CharacterRenderType.MultiSparrow:
        var combinedFrames = null;
        for (i => assetPath in data.assetPaths)
        {
          if (combinedFrames == null) combinedFrames = Paths.getSparrowAtlas(assetPath);
          else
            combinedFrames.addAtlas(Paths.getSparrowAtlas(assetPath));
        }
        ghost.frames = combinedFrames;

      case CharacterRenderType.Packer:
        ghost.frames = Paths.getPackerAtlas(data.assetPaths[0]);

      case CharacterRenderType.AnimateAtlas: // TODO, gonna think of smth

      default: // nuthin
    }

    ghost.globalOffsets = data.offsets ?? [0, 0];
    ghost.characterFlipX = data.flipX ?? false;
    ghost.characterScale = data.scale ?? 1;

    for (anim in data.animations)
    {
      ghost.addAnimation(anim.name, anim.prefix, anim.offsets, anim.frameIndices ?? [], anim.frameRate ?? 24, anim.looped ?? false, anim.flipX ?? false,
        anim.flipY ?? false);
    }
  }
}
