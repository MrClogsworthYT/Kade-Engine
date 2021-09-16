package;
import openfl.utils.AssetType;
import openfl.utils.Assets;
#if sys
import sys.io.File;
#end
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxBitmapDataUtil;
import flixel.FlxBasic;
import flixel.FlxObject;
import openfl.display.PNGEncoderOptions;
import lime.ui.FileDialog;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
class MusicBeatState extends FlxUIState
{
	private var topCam:FlxCamera;
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;
	var geom:flash.geom.Rectangle;
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		for (id in Assets.list(AssetType.SOUND))
			{
				Assets.cache.removeSound(id);
			}
		@:privateAccess
		for (id in Assets.list(AssetType.IMAGE))
			{
				Assets.cache.removeBitmapData(id);
				FlxG.bitmap._cache.remove(id);
			}
		
		 //lol huge shoutouts to haya btw
		
		topCam = new FlxCamera();
		topCam.bgColor.alpha = 0;
		FlxG.cameras.add(topCam, false);
		//FlxG.cameras.add(topCam);
		geom = new flash.geom.Rectangle(0, 0, FlxG.width, FlxG.height);
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		#if sys
		if(FlxG.keys.justPressed.F2){	
			var bitfile = FlxScreenGrab.grab();
			var finalresult = bitfile.bitmapData.encode(bitfile.bitmapData.rect, new PNGEncoderOptions(true));
			#if js
			new FileDialog().save(finalresult, "png", null, "file");
			#else
			File.saveBytes("assets/screenshots/Screenshot_"+DateTools.format(Date.now(), "%Y-%m-%d_%H_%M_%S")+".png", finalresult);
			#end
			var screenshot = new FlxSprite(450, -550);
			screenshot.pixels = bitfile.bitmapData;
			screenshot.antialiasing = true;
			screenshot.setGraphicSize(320, 180);
			screenshot.cameras = [topCam];
			add(screenshot);
			FlxTween.tween(screenshot, {x: 450, y: -250}, 1, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){
				new FlxTimer().start(1, function(tmr:FlxTimer){
					FlxTween.tween(screenshot, {x: 450, y: -550}, 1, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){
						remove(screenshot);
					}});
				});
			}});
		}
		#end
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}
	public function ccache()
		{
			//thanks haya for making this mindblowing discovery haha (it actually doesn't work lmao)
			Assets.cache.clear();
		}
	override function add(Object:FlxBasic):FlxBasic{
		ccache();
		return super.add(Object);
	}
	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function clearCache(){
		@:privateAccess
		for(key in FlxG.bitmap._cache.keys()){
			var bitmap = FlxG.bitmap._cache.get(key);
			if(bitmap != null){
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				bitmap.destroy();
			}
		}
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
