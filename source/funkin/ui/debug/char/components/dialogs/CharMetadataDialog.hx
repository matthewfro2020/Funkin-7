package funkin.ui.debug.char.components.dialogs;

@:xml('<?xml version="1.0" encoding="utf-8"?>
<collapsible-dialog title="Character Metadata" width="400" height="400">
  <vbox width="100%" height="100%">
    <hbox width="100%" height="100%">
      <vbox width="50%" height="100%">
        <frame text="Offsets" width="100%">
            <hbox>
                <number-stepper id="charOffsetsX" pos="0"/>
                <number-stepper id="charOffsetsY" pos="0"/>
            </hbox>
        </frame>

        <frame text="Camera Offsets" width="100%">
            <hbox>
                <number-stepper id="charCamOffsetsX" pos="0"/>
                <number-stepper id="charCamOffsetsY" pos="0"/>
            </hbox>
        </frame>

        <frame text="Scale" width="100%">
          <vbox>
              <number-stepper id="charScale" pos="1" min="0.05" step="0.05" precision="2"/>
          </vbox>
        </frame>

         <frame text="Hold Timer" width="100%">
          <vbox>
              <number-stepper id="charHoldTimer" pos="8" min="0" precision="2"/>
          </vbox>
        </frame>

        <frame text="Flip Horizontally" width="100%">
          <vbox>
              <checkbox id="charFlipX" text="Enabled"/>
          </vbox>
        </frame>

        <frame text="Pixelated" width="100%">
          <vbox>
              <checkbox id="charIsPixel" text="Enabled"/>
          </vbox>
        </frame>
      </vbox>

      <frame text="Death Data" width="50%" height="100%">
        <vbox width="100%">
            <checkbox id="charHasDeathData" text="Enabled" />
            <vbox id="charDeathBox" width="100%">

                <section-header text="Camera Offsets" />
                <hbox>
                  <number-stepper id="charDeathCamOffsetX" pos="0" />
                  <number-stepper id="charDeathCamOffsetY" pos="0" />
                </hbox>

                <section-header text="Camera Zoom" />
                <number-stepper id="charDeathCamZoom" pos="1" min="0.11" />

                <section-header text="Transition Delay" />
                <number-stepper id="charDeathTransDelay" pos="0" min="0" />
            </vbox>
        </vbox>
      </frame>
    </hbox>
  </vbox>
</collapsible-dialog>')
class CharMetadataDialog extends DefaultPageDialog
{
  override public function new(daPage:CharCreatorGameplayPage, char:CharCreatorCharacter)
  {
    super(daPage);

    charOffsetsX.pos = char.globalOffsets[0];
    charOffsetsY.pos = char.globalOffsets[1];
    charCamOffsetsX.pos = char.characterCameraOffsets[0];
    charCamOffsetsY.pos = char.characterCameraOffsets[1];
    charScale.pos = char.characterScale;
    charHoldTimer.pos = char.holdTimer;
    charFlipX.selected = char.characterFlipX;
    charIsPixel.selected = char.isPixel;
    charHasDeathData.selected = (char.deathData != null);
    charDeathBox.disabled = !charHasDeathData.selected;

    charDeathCamOffsetX.pos = char.deathData?.cameraOffsets[0] ?? 0;
    charDeathCamOffsetY.pos = char.deathData?.cameraOffsets[1] ?? 0;
    charDeathCamZoom.pos = char.deathData?.cameraZoom ?? 1;
    charDeathTransDelay.pos = char.deathData?.preTransitionDelay ?? 0;

    // callbaccd
    charOffsetsX.onChange = charOffsetsY.onChange = function(_) {
      char.globalOffsets = [charOffsetsX.pos, charOffsetsY.pos];
      daPage.updateCharPerStageData(char.characterType);
    }

    charCamOffsetsX.onChange = charCamOffsetsY.onChange = function(_) char.characterCameraOffsets = [charCamOffsetsX.pos, charCamOffsetsY.pos];

    charScale.onChange = function(_) {
      char.characterScale = charScale.pos;
      daPage.updateCharPerStageData(char.characterType);
    }

    charHoldTimer.onChange = function(_) char.holdTimer = charHoldTimer.pos;

    charFlipX.onChange = function(_) {
      char.characterFlipX = charFlipX.selected;
      daPage.updateCharPerStageData(char.characterType);
    }

    charIsPixel.onChange = function(_) {
      char.isPixel = charIsPixel.selected;

      char.antialiasing = !char.isPixel;
      char.pixelPerfectRender = char.isPixel;
      char.pixelPerfectPosition = char.isPixel;
    }

    // death
    charHasDeathData.onChange = function(_) {
      char.deathData = charHasDeathData.selected ?
        {
          cameraOffsets: [charDeathCamOffsetX.pos, charDeathCamOffsetY.pos],
          cameraZoom: charDeathCamZoom.pos,
          preTransitionDelay: charDeathTransDelay.pos
        } : null;

      charDeathBox.disabled = !charHasDeathData.selected;
    }

    charDeathCamOffsetX.onChange = charDeathCamOffsetY.onChange = function(_) {
      if (char.deathData != null) char.deathData.cameraOffsets = [charDeathCamOffsetX.pos, charDeathCamOffsetY.pos];
    }

    charDeathCamZoom.onChange = function(_) {
      if (char.deathData != null) char.deathData.cameraZoom = charDeathCamZoom.pos;
    }

    charDeathTransDelay.onChange = function(_) {
      if (char.deathData != null) char.deathData.preTransitionDelay = charDeathTransDelay.pos;
    }
  }
}
