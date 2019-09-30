DEBUG <- false;

DoIncludeScript("vs_rand/loadouts.nut", this);

function debugPrint(text){
    if(DEBUG == false)
        return;
    printl(text);
}

//Find players/bots
function FindPlayers(){
    local players = [];
    local player = null;
    while ((player = Entities.FindByClassname(player, "player")) != null){
        if(player.GetTeam() == 2 || player.GetTeam() == 3){
            debugPrint("Found player !");
            players.push(player);
        }
    }
    while ((player = Entities.FindByClassname(player, "cs_bot")) != null){
        debugPrint("Found bot player !");
        players.push(player);
    }
    return players;
}

//Strip weapons from player
function StripWeapons(player){
    local weapon = null;
    while((weapon = Entities.FindByClassname(weapon,"weapon_*")) != null){
        if (weapon.GetOwner()==player){
            weapon.Destroy();
        }
    }
}

//Give weapon to players
function GiveWeaponToPlayers(weapon, amount, players){
    debugPrint("Give to players: "+weapon+" x"+amount);
    local giver = Entities.CreateByClassname("game_player_equip");
    giver.__KeyValueFromInt("spawnflags", 1);
    giver.__KeyValueFromInt(weapon, 0);
    foreach(player in players){
        for(local i = 0; i < amount; i++){
            EntFireByHandle(giver, "Use", "", 0.0, player, null);
        }
    }
    giver.Destroy();
}

//Give P2000 to players (even if USP is in inventory)
function GiveP2000ToPlayers(amount, players){
    debugPrint("Give to players: weapon_hkp2000 x"+amount);
    local giver = Entities.FindByName(null, "hkp2000_spawner");
    foreach(player in players){
        EntFireByHandle(giver, "ForceSpawnAtEntityOrigin", "!activator", 0.0, player, null);
    }
}

function GiveTaserToPlayers(){
    activator.Destroy();
    debugPrint("Give to players: weapon_taser x1");
    local giver = Entities.FindByName(null, "taser_spawner");
    local players = FindPlayers();
    foreach(player in players){
        EntFireByHandle(giver, "ForceSpawnAtEntityOrigin", "!activator", 0.0, player, null);
    }
}

function GiveRandomLoadout(){
    //Strip all players
    local players = FindPlayers();
    for(local i = 0; i < players.len(); i++){
        StripWeapons(players[i]);
    }
    //Chose random loadout
    local chosenLoadout = loadouts[1.0 * (loadouts.len()-1) * rand() / RAND_MAX];
    // Is weapon_taser in loadout ?
    local giveTaser = false;
    //Give loadout to all players
    foreach(weapon in chosenLoadout){
        if(weapon[0] == "weapon_hkp2000"){
            GiveP2000ToPlayers(weapon[1], players);
        }else if(weapon[0] == "weapon_taser"){
            giveTaser = true;
        }else{
            GiveWeaponToPlayers(weapon[0], weapon[1], players);
        }
    }
    // Taser must be given in last
    if(giveTaser){
        local timer = Entities.CreateByClassname("logic_timer");
        EntFireByHandle(timer, "RefireTime", "1.0", 0.0, null, null);
        EntFireByHandle(timer, "AddOutput", "OnTimer random_weapon_script:RunScriptCode:GiveTaserToPlayers()", 0.0, null, null);
        EntFireByHandle(timer, "Enable", "", 0.0, null, null);
    }
    //Make melee weapons from DZ mode pickable
    EntFire("weapon_melee", "addoutput", "classname weapon_knifegg", 0.0, null);
}