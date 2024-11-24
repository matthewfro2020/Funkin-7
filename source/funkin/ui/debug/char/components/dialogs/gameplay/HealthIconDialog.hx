package funkin.ui.debug.char.components.dialogs.gameplay;

import funkin.play.components.HealthIcon;
import funkin.util.FileUtil;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/gameplay/icon-dialog.xml"))
class HealthIconDialog extends DefaultPageDialog
{
  var healthIcon:FlxSprite;

  override public function new(daPage:CharCreatorDefaultPage, char:CharCreatorCharacter)
  {
    super(daPage);

    if (char.healthIcon != null && char.healthIconFiles.length >= 1) // set the data considering we have all the stuff we need
    {
      healthIcon = new FlxSprite();
      var bitmap = openfl.display.BitmapData.fromBytes(char.healthIconFiles[0].bytes);

      if (char.healthIconFiles.length == 1) // legacy
      {
        var iconSize = HealthIcon.HEALTH_ICON_SIZE;
        @:privateAccess if (char.healthIcon.isPixel) iconSize = HealthIcon.PIXEL_ICON_SIZE;

        healthIcon.loadGraphic(bitmap, true, iconSize, iconSize);
        healthIcon.animation.add("idle", [0], 0, false, false);
        healthIcon.animation.add("losing", [1], 0, false, false);
        if (healthIcon.animation.numFrames >= 3)
        {
          healthIcon.animation.add("winning", [2], 0, false, false);
        }
      }
      else
      {
        healthIcon.frames = FlxAtlasFrames.fromSparrow(bitmap, char.healthIconFiles[1].bytes.toString());
        if (healthIcon.frames.frames.length == 0) return;

        healthIcon.animation.addByPrefix("idle", "idle", 24, true);
        healthIcon.animation.addByPrefix("winning", "winning", 24, true);
        healthIcon.animation.addByPrefix("losing", "losing", 24, true);
        healthIcon.animation.addByPrefix("toWinning", "toWinning", 24, false);
        healthIcon.animation.addByPrefix("toLosing", "toLosing", 24, false);
        healthIcon.animation.addByPrefix("fromWinning", "fromWinning", 24, false);
        healthIcon.animation.addByPrefix("fromLosing", "fromLosing", 24, false);

        if (healthIcon.animation.getNameList().length == 0) return;
      }

      // some cosmetic stuff
      healthIconPreviewImg.flipX = healthIconFlipX.selected = (char.healthIcon.flipX ?? false);
      healthIconPreviewImg.antialiasing = healthIconPixelated.selected = (char.healthIcon.isPixel ?? false);
      healthIconPreviewImg.imageScale = healthIconScale.pos = (char.healthIcon.scale ?? 1);
      healthIconPreviewImg.left = healthIconOffsetX.pos = (char.healthIcon.offsets[0] ?? 0);
      healthIconPreviewImg.top = healthIconOffsetY.pos = (char.healthIcon.offsets[1] ?? 0);

      healthIcon.animation.onFrameChange.add(function(animName:String, frameNumber:Int, frameIndex:Int) {
        healthIconPreviewImg.resource = healthIcon.frames.frames[frameIndex];
      });

      healthIcon.animation.play("idle");
    }

    healthIconLoadBtn.onClick = function(_) {
      FileUtil.browseForBinaryFile("Load File", [FileUtil.FILE_EXTENSION_INFO_PNG], function(_) {
        if (_?.fullPath != null) healthIconLoadField.text = _.fullPath;
      });
    }

    healthIconPreviewBtn.onClick = function(_) {
      if (healthIconLoadField.text == null || !healthIconLoadField.text.endsWith(".png")) return;
      if (CharCreatorUtil.gimmeTheBytes(healthIconLoadField.text) == null) return;

      // getting bitmap
      var imgBytes = CharCreatorUtil.gimmeTheBytes(healthIconLoadField.text);
      var xmlBytes = CharCreatorUtil.gimmeTheBytes(healthIconLoadField.text.replace(".png", ".xml"));

      var bitmap = openfl.display.BitmapData.fromBytes(imgBytes);
      if (bitmap == null) return;

      healthIconPreviewImg.resource = null;
      healthIcon?.destroy();
      healthIcon = new FlxSprite();

      if (xmlBytes == null) // legacy icon
      {
        var iconSize = HealthIcon.HEALTH_ICON_SIZE;
        @:privateAccess
        if (healthIconPixelated.selected) iconSize = HealthIcon.PIXEL_ICON_SIZE; // why is this private but normal one isn't???

        if (bitmap.width < (2 * iconSize) || bitmap.height < iconSize) return;

        healthIcon.loadGraphic(bitmap, true, iconSize, iconSize);
        healthIcon.animation.add("idle", [0], 0, false, false);
        healthIcon.animation.add("losing", [1], 0, false, false);
        if (healthIcon.animation.numFrames >= 3)
        {
          healthIcon.animation.add("winning", [2], 0, false, false);
        }
      }
      else
      {
        healthIcon.frames = FlxAtlasFrames.fromSparrow(bitmap, xmlBytes.toString());
        if (healthIcon.frames.frames.length == 0) return;

        healthIcon.animation.addByPrefix("idle", "idle", 24, true);
        healthIcon.animation.addByPrefix("winning", "winning", 24, true);
        healthIcon.animation.addByPrefix("losing", "losing", 24, true);
        healthIcon.animation.addByPrefix("toWinning", "toWinning", 24, false);
        healthIcon.animation.addByPrefix("toLosing", "toLosing", 24, false);
        healthIcon.animation.addByPrefix("fromWinning", "fromWinning", 24, false);
        healthIcon.animation.addByPrefix("fromLosing", "fromLosing", 24, false);

        if (healthIcon.animation.getNameList().length == 0) return;
      }

      // some cosmetic stuff
      healthIconPreviewImg.flipX = healthIconFlipX.selected;
      healthIconPreviewImg.antialiasing = healthIconPixelated.selected;
      healthIconPreviewImg.imageScale = healthIconScale.pos;
      healthIconPreviewImg.left = healthIconOffsetX.pos;
      healthIconPreviewImg.top = healthIconOffsetY.pos;

      healthIcon.animation.onFrameChange.add(function(animName:String, frameNumber:Int, frameIndex:Int) {
        healthIconPreviewImg.resource = healthIcon.frames.frames[frameIndex];
      });

      healthIcon.animation.play("idle");

      char.healthIconFiles = [
        {name: healthIconLoadField.text, bytes: imgBytes}];
      if (xmlBytes != null) char.healthIconFiles.push({name: healthIconLoadField.text.replace(".png", ".xml"), bytes: xmlBytes});
      char.healthIcon =
        {
          scale: healthIconScale.pos,
          id: char.characterId,
          offsets: [healthIconOffsetX.pos, healthIconOffsetY.pos],
          flipX: healthIconFlipX.selected,
          isPixel: healthIconPixelated.selected
        }
    }

    healthIconCurAnim.onChange = function(_) {
      healthIcon?.animation?.play(healthIconCurAnim.selectedItem.text);
    }
  }
}
