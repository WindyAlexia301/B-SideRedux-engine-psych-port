package states;

import backend.WeekData;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var reduxEngine:String = '21H2 (Insider Build)'; //Version del Engine Redux
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	var camFollow:FlxObject;

	// Escala del frame "idle" (basic) de cada opción. Los sprites vienen de Adobe
	// Animate con proporciones inconsistentes entre sí; el único que se ve chico
	// de verdad en su tamaño normal es donate/LINK (~111px de alto vs ~135-193px
	// del resto). story_mode se deja tal cual, a propósito es más grande.
	var idleScale:Map<String, Float>;

	// Escala del frame "selected" (white) de cada opción. TODOS los sprites se
	// achican al pasar a este frame en Adobe Animate (entre 58% y 81% de su
	// tamaño idle, medido directo del atlas), así que sin compensar, cualquier
	// opción se ve más chica justo al preseleccionarla. Estos valores están
	// calculados para que, al seleccionar, el sprite quede ~8% MÁS grande que
	// su propio tamaño idle (en vez de encogerse), como en engines de referencia.
	var selectedScale:Map<String, Float>;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		var bgSprite:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width + 200, FlxG.height + 200, 0xFFFDE872);
		bgSprite.screenCenter();
		bgSprite.scrollFactor.set(0, yScroll);
		bgSprite.updateHitbox();
		add(bgSprite);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFFD87B24;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		idleScale = [
			'donate' => 1.15, // bajado de 1.4: ya se veía muy grande
			'awards' => 0.93  // ligeramente más grande que sus vecinos, se achica un poco
		];

		selectedScale = [
			'story_mode' => 1.43,
			'freeplay'   => 1.62,
			'mods'       => 1.33,
			'awards'     => 1.73,
			'credits'    => 1.40,
			'donate'     => 2.00,
			'options'    => 1.56
		];

		// Separación fija entre el borde de una opción y el borde de la siguiente.
		// Al ya no usar un paso fijo en px (antes 140/155), esto se suma al alto
		// REAL de cada sprite (ya escalado), así que las opciones grandes (story_mode)
		// generan más espacio automáticamente y las chicas (donate) no quedan
		// con espacio de sobra.
		var padding:Float = 10;

		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80 - 180;
		var yPos:Float = offset;

		for (i in 0...optionShit.length)
		{
			var optName:String = optionShit[i];
			var itemScale:Float = idleScale.exists(optName) ? idleScale.get(optName) : scale;

			var menuItem:FlxSprite = new FlxSprite(0, yPos);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optName);
			menuItem.animation.addByPrefix('idle', optName + " basic", 24);
			menuItem.animation.addByPrefix('selected', optName + " white", 24);
			menuItem.animation.play('idle');
			menuItem.scale.set(itemScale, itemScale);
			menuItem.updateHitbox();
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			// Mecánica original de psych/FNF: las opciones tienen un scrollFactor
			// reducido para que la lista se vea compacta y la cámara casi no se
			// mueva (así es como se ve "normal"). Estaba calibrada asumiendo menos
			// opciones que las 7 que tenemos acá (con mods/awards/donate sumados),
			// así que el 0.135 se quedaba corto y no comprimía lo suficiente para
			// que la última opción entrara en pantalla. Subí ese número a 0.19.
			// Si agregan/quitan opciones (mods) y vuelve a pasar, este es el único
			// valor que hay que tocar.
			var scr:Float = (optionShit.length - 4) * 0.19;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));

			var gapAdjust:Float = (optName == 'freeplay') ? -12 : 0;
			yPos += menuItem.height + padding + gapAdjust;
		}

		FlxG.camera.follow(camFollow, null, 0);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "B-Side Redux Engine " + reduxEngine, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://github.com/WindyAlexia301/B-SideRedux-engine-psych-way');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										LoadingState.loadAndSwitchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new OptionsState());
										OptionsState.onPlayState = false;
										if (PlayState.SONG != null)
										{
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
										}
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			var optName:String = optionShit[spr.ID];
			var baseScale:Float = idleScale.exists(optName) ? idleScale.get(optName) : 1;

			spr.animation.play('idle');
			spr.scale.set(baseScale, baseScale);
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');

				var selScale:Float = selectedScale.exists(optName) ? selectedScale.get(optName) : baseScale;
				spr.scale.set(selScale, selScale);
				spr.updateHitbox();
				spr.centerOffsets();

				// Cámara centrada directo en la opción seleccionada, sin sesgo.
				// Antes había un "add" que la subía, lo que empujaba la opción
				// seleccionada hacia abajo en pantalla; en la última opción eso
				// la cortaba porque no hay nada debajo para compensar.
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
		});
	}
}
