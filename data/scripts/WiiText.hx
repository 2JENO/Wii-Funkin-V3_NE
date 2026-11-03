import data.source.WiiCustomText;
import funkin.ui.MusicBeatState;
import funkin.backend.psychlua.LuaUtils;

using StringTools;

function create() {
  createGlobalCallback("makeLuaWiiText", function(tag:String, text:String, width:Int, x:Float, y:Float) {
    tag = tag.replace('.', '');
    LuaUtils.destroyObject(tag);
    var leText = new WiiCustomText(x, y, width, text, 1, null, camHUD, 0);
    MusicBeatState.getVariables().set(tag, leText);
  });
}