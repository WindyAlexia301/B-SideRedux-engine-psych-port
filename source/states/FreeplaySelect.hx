package states;

import flixel.FlxSprite;

class FreeplaySelect extends MusicBeatState
{
	public static var lastFreeplayWasLegacy:Bool = false;

	var spriteNames:Array<String> = ['FreeplayRedux', 'FreeplayClassic'];
	var animPrefixes:Array<String> = ['redux', 'classic'];

	var options:Array<FlxSprite> = [];
	var slotCenterY:Array<Float> = [];
	var curSelected:Int = 0;

	var idleScale:Array<Float> = [1, 1];
	var selectedScale:Array<Float> = [1, 1];

	var bgFlat:FlxSprite;
	var bgArt:FlxSprite;

	var reduxColor:FlxColor = 0xFFEAA8FF;
	var reduxColorDark:FlxColor = 0xFFBB41E2;
	var legacyColor:FlxColor = 0xFF6699FF;
	var legacyColorDark:FlxColor = 0xFF205DD5;

	var intendedColor:FlxColor;
	var intendedColorDark:FlxColor;
	var colorTween:FlxTween;
	var colorTweenDark:FlxTween;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		curSelected = lastFreeplayWasLegacy ? 1 : 0;
		intendedColor = (curSelected == 1) ? legacyColor : reduxColor;
		intendedColorDark = (curSelected == 1) ? legacyColorDark : reduxColorDark;

		bgFlat = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bgFlat.color = intendedColor;
		add(bgFlat);
		bgFlat.screenCenter();

		bgArt = new FlxSprite().loadGraphic(Paths.image('menubackgrounds/bgArtFreeplayMode'));
		bgArt.antialiasing = ClientPrefs.data.antialiasing;
		bgArt.color = intendedColorDark;
		add(bgArt);
		bgArt.screenCenter();

		for (i in 0...spriteNames.length)
		{
			var opt:FlxSprite = new FlxSprite();
			opt.antialiasing = ClientPrefs.data.antialiasing;
			opt.frames = Paths.getSparrowAtlas('mainmenu/' + spriteNames[i]);
			opt.animation.addByPrefix('idle', animPrefixes[i] + ' white', 24);
			opt.animation.addByPrefix('selected', animPrefixes[i] + ' basic', 24);
			opt.animation.play('selected');
			opt.scale.set(selectedScale[i], selectedScale[i]);
			opt.updateHitbox();
			opt.ID = i;
			options.push(opt);
		}

		var padding:Float = 30;
		var totalHeight:Float = padding * (options.length - 1);
		for (opt in options)
			totalHeight += opt.height;

		var yPos:Float = (FlxG.height - totalHeight) / 2;
		for (opt in options)
		{
			opt.y = yPos;
			opt.screenCenter(X);
			add(opt);
			slotCenterY.push(yPos + opt.height / 2);
			yPos += opt.height + padding;
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

		for (opt in options)
			opt.screenCenter(X);

		super.update(elapsed);
	}

	function updateOptions()
	{
		for (i in 0...options.length)
		{
			var opt:FlxSprite = options[i];
			var selected:Bool = (i == curSelected);

			opt.animation.play(selected ? 'selected' : 'idle');
			var s:Float = selected ? selectedScale[i] : idleScale[i];
			opt.scale.set(s, s);
			opt.updateHitbox();
			opt.centerOffsets();
			opt.y = slotCenterY[i] - (opt.height / 2);
			opt.alpha = 1; // full alpha - visibilidad
		}

		var newColor:FlxColor = (curSelected == 1) ? legacyColor : reduxColor;
		var newColorDark:FlxColor = (curSelected == 1) ? legacyColorDark : reduxColorDark;

		if (newColor != intendedColor)
		{
			if (colorTween != null)
				colorTween.cancel();

			intendedColor = newColor;
			colorTween = FlxTween.color(bgFlat, 0.4, bgFlat.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		if (newColorDark != intendedColorDark)
		{
			if (colorTweenDark != null)
				colorTweenDark.cancel();

			intendedColorDark = newColorDark;
			colorTweenDark = FlxTween.color(bgArt, 0.4, bgArt.color, intendedColorDark, {
				onComplete: function(twn:FlxTween)
				{
					colorTweenDark = null;
				}
			});
		}
	}
}
