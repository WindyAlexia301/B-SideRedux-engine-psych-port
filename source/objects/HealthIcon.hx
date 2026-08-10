package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public var iconNumFrames:Int = 2; //cuantos frames trae el icono (2 = normal/perdiendo, 3 = normal/perdiendo/ganando)
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			
			var graphic = Paths.image(name, allowGPU);
			//Cada frame es cuadrado (mismo ancho que el alto). Se calcula cuantos frames trae la imagen
			//en vez de asumir siempre 2: asi soportamos iconos viejos (2 frames) y nuevos (3 frames, con cara de ganando).
			iconNumFrames = Math.round(graphic.width / graphic.height);
			if(iconNumFrames < 2) iconNumFrames = 2;
			var frameSize:Int = Math.floor(graphic.width / iconNumFrames);

			loadGraphic(graphic, true, frameSize, Math.floor(graphic.height));
			iconOffsets[0] = (frameSize - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
			updateHitbox();

			var frames:Array<Int> = [for (i in 0...iconNumFrames) i];
			animation.add(char, frames, 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
