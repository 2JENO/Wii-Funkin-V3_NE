package data.source;

import funkin.backend.ClientPrefs;
import flixel.text.FlxText.FlxTextAlign;
import funkin.backend.Paths;
import flixel.graphics.FlxGraphic;
import flixel.FlxObject;
import flixel.FlxSprite;

using StringTools;

class WiiCharacterData
{
	public var character:String;
	public var path:String;
	public var x:Float;
	public var y:Float;
	public var gapOffset:Float;
	public var graphic:FlxGraphic;
}

class WiiFontData
{
	public var characters:Array<WiiCharacterData>;
	public var lineOffset:Float;
}

class WiiCustomText extends FlxSprite
{
	var loadedCharacters:Array<FlxSprite> = [];
	var deadCharacters:Array<FlxSprite> = [];

	public var lineOffset:Float = 24;
	public var spaceGap:Float = 8;
	public var newlineGap:Float = 25;
	public var size:Float = 1;
	public var text(default, set):String = "";

	function set_text(Text:String):String
	{
		text = Text;
		regenText();
		return Text;
	}

	public var fieldWidth:Float = 0;
	public var font:String = "";
	public var alignment:FlxTextAlign = FlxTextAlign.CENTER;
	public var noAA:Bool = false;

	static var fontCache:Map<String, WiiFontData> = [];

	var fontData:WiiFontData = new WiiFontData();

	var line:FlxSprite;

	override public function new(X:Float, Y:Float, daFieldWidth:Float, daText:String = "", dasize:Float = 1, font:String = "boldWii", dacameras:FlxCamera = null, scrollV:Float = 1)
	{
		super(X, Y);
		final scrollF = scrollV;
		fieldWidth = daFieldWidth;
		size = dasize;
		if (size == null) size = 1;
		applyFont(font);
		if (font == "") font = "boldWii";
		text = daText;
		if (text == null) text = "";
		cameras = cast dacameras;
		if (cameras == null) cameras = [FlxG.camera];
		if (scrollF == null) scrollF = 1;
		scrollFactor.set(scrollF, scrollF);

		// line = new FlxSprite().makeGraphic(0, 0).makeGraphic(1280, 1, 0xFFFF0000);
	}

	private function loadFont(name:String, forceReload:Bool = false)
	{
		if (name == null || name == "")
		{
			trace('Font name is null or empty in loadFont');
			return;
		}
		font = name;

		if (fontCache.exists(name) && !forceReload)
		{
			fontData = fontCache.get(name);
			return;
		}

		var infoText = Paths.getTextFromFile('images/fonts/' + name + "/info.txt");
		if (infoText == null)
		{
			trace('Failed to load font info: images/fonts/' + name + "/info.txt");
			return;
		}

		var info = infoText.split("\n");

		// 여기를 수정:
		fontData = new WiiFontData();
		fontData.characters = [];
		fontData.lineOffset = Std.parseFloat(info[0]);

		var dataText = Paths.getTextFromFile('images/fonts/' + name + "/data.txt");
		if (dataText == null)
		{
			trace('Failed to load font data: images/fonts/' + name + "/data.txt");
			return;
		}

		for (l in dataText.split("\n"))
		{
			var d = l.split(" ");
			var char:WiiCharacterData = {
				character: d[0],
				path: d[1],
				x: Std.parseFloat(d[2]),
				y: Std.parseFloat(d[3]),
				gapOffset: Std.parseFloat(d[4]),
				graphic: null
			};
			fontData.characters.push(char);
		}
		fontCache.set(name, fontData);
	}

	public function applyFont(name:String, forceReload:Bool = false)
	{
		if (name == null || name == "")
		{
			trace('Font name is null or empty, using default font');
			name = "boldWii"; // 기본 폰트 사용
		}
		loadFont(name, forceReload);
		if (fontData == null)
		{
			trace('Font data is null for: ' + name);
			return;
		}
		lineOffset = fontData.lineOffset;
		for (char in fontData.characters)
		{
			char.graphic = Paths.image("fonts/" + name + "/" + char.path); // reload when changing
		}
	}

	private function getCharacterData(char:String)
	{
		for (d in fontData.characters)
		{
			if (d.character == char)
				return d;
		}
		return null;
	}

	var _text:String = "";

	public function regenText(force:Bool = false)
	{
		if (_text != text || force)
		{
			_text = text;

			for (char in loadedCharacters)
			{
				deadCharacters.push(char);
			}
			loadedCharacters = [];

			width = 1;
			height = 1;
			var curX:Float = 0;
			var curY:Float = 0;
			var split = text.split("");
			split.push("\n");

			var lineCharacters:Array<FlxSprite> = [];

			for (char in split)
			{
				if (char == " ")
				{
					curX += spaceGap * size;
				}
				else if (char != "\n")
				{
					var data = getCharacterData(char);
					if (data != null)
					{
						var spr:FlxSprite;
						if (deadCharacters[0] != null)
						{
							spr = deadCharacters[0];
							deadCharacters.remove(deadCharacters[0]);
						}
						else
						{
							spr = new FlxSprite();
							spr.antialiasing = ClientPrefs.data.antialiasing;
						}
						if (noAA)
							spr.antialiasing = false;

						spr.loadGraphic(data.graphic);
						spr.scale.set(size, size);
						spr.updateHitbox();
						spr.offset.set(spr.offset.x
							+ -(curX + (data.x * size)), spr.offset.y
							+ -(curY + (data.y * size) + ((lineOffset * size) - spr.height)));
						spr.color = this.color;
						spr.shader = this.shader;
						loadedCharacters.push(spr);
						lineCharacters.push(spr);
						curX += (spr.width + (data.gapOffset * size));
					}
					else
					{
						curX += spaceGap * size;
					}
				}

				width = Math.max(width, curX);

				if ((fieldWidth > 0 && curX > fieldWidth) || char == "\n")
				{
					var leftOverWidth = fieldWidth - curX;
					if (fieldWidth > 0)
					{
						switch (alignment)
						{
							case CENTER:
								for (char in lineCharacters)
									char.offset.x -= leftOverWidth / 2;
							case RIGHT:
								for (char in lineCharacters)
									char.offset.x -= leftOverWidth;
							case JUSTIFY: // idk who even uses this
							case LEFT: // do nothing cuz its already left
						}
					}

					curX = 0;
					curY += newlineGap * size;

					lineCharacters = [];
				}
			}

			height = curY;
		}
	}

	override public function draw()
	{
		if (visible)
		{
			/*line.setPosition(x, y + (lineOffset*size));
				line.scrollFactor.set(scrollFactor.x, scrollFactor.y);
				line.cameras = this._cameras;
				line.draw(); */

			for (char in loadedCharacters)
			{
				char.setPosition(x, y);
				char.scrollFactor.set(scrollFactor.x, scrollFactor.y);
				char.cameras = this._cameras;
				char.alpha = alpha;
				char.draw();
			}
		}
	}

	override public function destroy()
	{
		for (char in loadedCharacters)
			char.destroy();
		for (char in deadCharacters)
			char.destroy();
		loadedCharacters = [];
		deadCharacters = [];
		super.destroy();
	}
}
