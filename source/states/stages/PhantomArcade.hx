package states.stages;

import states.stages.objects.*;
import backend.BaseStage;

class PhantomArcade extends BaseStage
{
	
var bgEvil:BGSprite;
var cabinetsEvil:BGSprite;
var pillarEvil:BGSprite;

override function create()
	{
	    bgEvil = new BGSprite('phantom-arcade/bg', -550, -560, 0.2, 0.2);
		bgEvil.setGraphicSize(Std.int(bgEvil.width * 0.8));
		bgEvil.updateHitbox();
		add(bgEvil);
		
		cabinetsEvil = new BGSprite('phantom-arcade/cabinets', -100, 240, 1, 1, ['cabinets']);
		add(cabinetsEvil);

		pillarEvil = new BGSprite('phantom-arcade/pillar', -410, -450, 0.3, 0.3);
		pillarEvil.setGraphicSize(Std.int(pillarEvil.width * 0.9));
		pillarEvil.updateHitbox();
		add(pillarEvil);

		super.create();
		
	}

}