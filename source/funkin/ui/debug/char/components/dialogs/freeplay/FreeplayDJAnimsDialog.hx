package funkin.ui.debug.char.components.dialogs.freeplay;

import funkin.data.animation.AnimationData;

@:xml('
  <collapsible-dialog title="DJ Animation Settings" width="250" height="250">
    <vbox width="100%" height="100%">
      <dropdown id="djAnimList" width="100%" height="25" />

      <grid width="100%" columns="2">
        <label text="Name" />
        <textfield id="djAnimName" placeholder="Animation Name" />

        <label text="Prefix" />
        <textfield id="djAnimPrefix" placeholder="Animation Symbol" />

        <label text="Loop" />
        <checkbox id="djAnimLooped" text="Enabled" />

        <label text="Offsets" />
        <hbox>
          <number-stepper id="djAnimOffsetX" pos="0" precision="1" />
          <number-stepper id="djAnimOffsetY" pos="0" precision="1" />
        </hbox>
      </grid>

      <hbox width="100%" style="justify-content:space-evenly" continuous="true">
        <button id="djAnimSave" text="Save Anim"/>
        <button id="djAnimDelete" text="Remove Anim"/>
      </hbox>
    </vbox>
  </collapsible-dialog>
')
@:access(funkin.ui.debug.char.pages.CharCreatorFreeplayPage)
class FreeplayDJAnimsDialog extends DefaultPageDialog
{
  override public function new(daPage:CharCreatorFreeplayPage)
  {
    super(daPage);

    djAnimList.onChange = function(_) {
      daPage.changeDJAnimation(djAnimList.selectedIndex - daPage.currentDJAnimation);
    }

    djAnimSave.onClick = function(_) {
      if (!daPage.dj.hasAnimation(djAnimPrefix.text))
      {
        return;
      }

      if (djAnimList.safeSelectedItem.text == djAnimName.text) // update instead of add
      {
        var animData = daPage.djAnims[daPage.currentDJAnimation];

        animData.prefix = djAnimPrefix.text;
        animData.looped = djAnimLooped.selected;
        animData.offsets = [djAnimOffsetX.pos, djAnimOffsetY.pos];

        daPage.changeDJAnimation();
      }
      else
      {
        daPage.djAnims.push(
          {
            name: djAnimName.text,
            prefix: djAnimPrefix.text,
            looped: djAnimLooped.selected,
            offsets: [djAnimOffsetX.pos, djAnimOffsetY.pos]
          });

        djAnimList.dataSource.add({text: djAnimName.text});
        djAnimList.selectedIndex = daPage.djAnims.length - 1;
      }
    }
  }
}
