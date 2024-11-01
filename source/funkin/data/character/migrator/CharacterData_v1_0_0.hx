package funkin.data.character.migrator;

import funkin.data.character.CharacterData;

/**
 * The JSON data schema used to define a character.
 */
typedef CharacterData_v1_0_0 =
{
  /**
   * The sematic version number of the character data JSON format.
   */
  var version:String;

  /**
   * The readable name of the character.
   */
  var name:String;

  /**
   * The type of rendering system to use for the character.
   * @default sparrow
   */
  var renderType:CharacterRenderType;

  /**
   * Behavior varies by render type:
   * - SPARROW: Path to retrieve both the spritesheet and the XML data from.
   * - PACKER: Path to retrieve both the spritsheet and the TXT data from.
   */
  var assetPath:String;

  /**
   * The scale of the graphic as a float.
   * Pro tip: On pixel-art levels, save the sprites small and set this value to 6 or so to save memory.
   * @default 1
   */
  var scale:Null<Float>;

  /**
   * Optional data about the health icon for the character.
   */
  var healthIcon:Null<HealthIconData>;

  var death:Null<DeathData>;

  /**
   * The global offset to the character's position, in pixels.
   * @default [0, 0]
   */
  var offsets:Null<Array<Float>>;

  /**
   * The amount to offset the camera by while focusing on this character.
   * Default value focuses on the character directly.
   * @default [0, 0]
   */
  var cameraOffsets:Array<Float>;

  /**
   * Setting this to true disables anti-aliasing for the character.
   * @default false
   */
  var isPixel:Null<Bool>;

  /**
   * The frequency at which the character will play its idle animation, in beats.
   * Increasing this number will make the character dance less often.
   * Supports up to `0.25` precision.
   * @default `1.0` on characters
   */
  @:optional
  @:default(1.0)
  var danceEvery:Null<Float>;

  /**
   * The minimum duration that a character will play a note animation for, in beats.
   * If this number is too low, you may see the character start playing the idle animation between notes.
   * If this number is too high, you may see the the character play the sing animation for too long after the notes are gone.
   *
   * Examples:
   * - Daddy Dearest uses a value of `1.525`.
   * @default 1.0
   */
  var singTime:Null<Float>;

  /**
   * An optional array of animations which the character can play.
   */
  var animations:Array<AnimationData_v1_0_0>;

  /**
   * If animations are used, this is the name of the animation to play first.
   * @default idle
   */
  var startingAnimation:Null<String>;

  /**
   * Whether or not the whole ass sprite is flipped by default.
   * Useful for characters that could also be played (Pico)
   *
   * @default false
   */
  var flipX:Null<Bool>;
};

/**
 * A data structure representing an animation in a spritesheet.
 * This is a generic data structure used by characters, stage props, and more!
 * BE CAREFUL when changing it.
 */
typedef AnimationData_v1_0_0 =
{
  /**
   * The prefix for the frames of the animation as defined by the XML file.
   * This will may or may not differ from the `name` of the animation,
   * depending on how your animator organized their FLA or whatever.
   *
   * NOTE: For Sparrow animations, this is not optional, but for Packer animations it is.
   */
  @:optional
  var prefix:String;

  /**
   * Optionally specify an asset path to use for this specific animation.
   * ONLY for use by MultiSparrow characters.
   * @default The assetPath of the parent sprite
   */
  @:optional
  var assetPath:Null<String>;

  /**
   * Offset the character's position by this amount when playing this animation.
   * @default [0, 0]
   */
  @:default([0, 0])
  @:optional
  var offsets:Null<Array<Float>>;

  /**
   * Whether the animation should loop when it finishes.
   * @default false
   */
  @:default(false)
  @:optional
  var looped:Bool;

  /**
   * Whether the animation's sprites should be flipped horizontally.
   * @default false
   */
  @:default(false)
  @:optional
  var flipX:Null<Bool>;

  /**
   * Whether the animation's sprites should be flipped vertically.
   * @default false
   */
  @:default(false)
  @:optional
  var flipY:Null<Bool>;

  /**
   * The frame rate of the animation.
   * @default 24
   */
  @:default(24)
  @:optional
  var frameRate:Null<Int>;

  /**
   * If you want this animation to use only certain frames of an animation with a given prefix,
   * select them here.
   * @example [0, 1, 2, 3] (use only the first four frames)
   * @default [] (all frames)
   */
  @:default([])
  @:optional
  var frameIndices:Null<Array<Int>>;

  /**
   * The name for the animation.
   * This should match the animation name queried by the game;
   * for example, characters need animations with names `idle`, `singDOWN`, `singUPmiss`, etc.
   */
  var name:String;
}
