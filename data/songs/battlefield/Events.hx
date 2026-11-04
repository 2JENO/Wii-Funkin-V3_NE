var miiSword:Character;
var miiGun:Character;

var charToNoteTypeMap:Array<Array<String>> = [
  ['miiswordfighter', 'Darnote1'],
  ['miigunner', 'Darnote2'],
];

function postCreate() {
  miiSword = strumLines.members[2].characters[0];
  miiGun = strumLines.members[3].characters[0];
  miiSword.x = game.dad.x - 350;
  miiSword.y = game.dad.y - 70;
  miiGun.x = game.dad.x - 570;
  miiGun.y = game.dad.y - 30;
  miiSword.visible = false;
  miiGun.visible = false;
}