package states;

import flixel.FlxSprite;
import flixel.text.FlxText;

class FreeplaySelect extends MusicBeatState
{
	public static var lastFreeplayWasLegacy:Bool = false;

	var options:Array<String> = ['Redux Freeplay', 'Legacy Freeplay'];
	var optionsText:Array<Alphabet> = [];
	var curSelected:Int = 0;

	var bg:FlxSprite;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFF665AFF;
		add(bg);
		bg.screenCenter();

		curSelected = lastFreeplayWasLegacy ? 1 : 0;

		for (i in 0...options.length)
		{
			var optText:Alphabet = new Alphabet(0, 280 + (i * 120), options[i], true);
			optText.screenCenter(X);
			optionsText.push(optText);
			add(optText);
		}

		updateOptions();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P || controls.UI_DOWN_P || controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			curSelected = (curSelected + 1) % options.length;
			updateOptions();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		else if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			if (curSelected == 1)
			{
				lastFreeplayWasLegacy = true;
				MusicBeatState.switchState(new FreeplayLegacy());
			}
			else
			{
				lastFreeplayWasLegacy = false;
				MusicBeatState.switchState(new FreeplayState());
			}
		}

		super.update(elapsed);
	}

	function updateOptions()
	{
		for (i in 0...optionsText.length)
		{
			var selected:Bool = (i == curSelected);
			optionsText[i].alpha = selected ? 1 : 0.6;
		}
	}
}
