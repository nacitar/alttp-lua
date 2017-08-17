#!/usr/bin/env lua
local THIS_DIR = (... or '1'):match("(.-)[^%.]+$")
local var = require(THIS_DIR .. 'var')

local StoredEG = {
  DISARMED = 0,
  STRONG = 1,
  WEAK = 2,
}

local stored_eg = nil
local last_player_state = nil
function update_stored_eg()
  player_state = var.player_state:read()
  if last_player_state ~= nil then
    queued_layer_change = var.queued_layer_change:read()
    -- if we jump when we already have stored EG, the count will be > 1, keep
    -- the indicator in that case... but if it is only 1, we need to make sure
    -- it's not just a normal jump.  Also, the last frame of a jump to the
    -- ground swaps the state one frame prior to clearing the
    -- queued_layer_change, so we have to backlog one frame. =/
    if queued_layer_change > 1 or (queued_layer_change == 1 and
        last_player_state ~= nil and
        last_player_state ~= var.PlayerStateFlags.JUMPING and
        player_state ~= var.PlayerStateFlags.JUMPING) then
      room_upper_layer = var.room_upper_layer:read()
      if room_upper_layer == 1 then
        stored_eg = StoredEG.STRONG
      else
        stored_eg = StoredEG.WEAK
      end
    else
      stored_eg = StoredEG.DISARMED
    end
  end
  last_player_state = player_state
end

function stored_eg_string()
  if stored_eg == StoredEG.STRONG then
    return 'strong'
  elseif stored_eg == StoredEG.WEAK then
    return 'weak'
  elseif stored_eg == StoredEG.DISARMED then
    return 'disarmed'
  end
  return ''
end

function waterwalk_string()
  if var.falling_state:read() ~= var.FallingStateFlags.NORMAL and
      var.player_state:read() ~= var.PlayerStateFlags.FALLING_OR_NEAR_HOLE then
    return 'armed'
  end
  return 'disarmed'
end

function spinspeed_string()
  player_state = var.player_state:read()
  -- spinspeed sets dash_countdown to 29 as well, but not checking it
  if player_state ~= var.PlayerStateFlags.DASHING and
      player_state ~= var.PlayerStateFlags.FALLING_OR_NEAR_HOLE and
      var.bonk_wall:read() == 1 and
      var.hand_up_pose:read() == var.HandUpPoseFlags.NOT_UP then
      -- duck causes your hand to go up, but so do crystals/pendants/triforce
      -- however, crystals/pendants also clear spinspeed anyway.. (as do
      -- hearts), and who cares once you get triforce.  Works.
      -- Without this extra check, dashing and then getting picked up by the
      -- duck mid-dash will erroneously report spinspeed.
    return 'armed'
  end
  return 'disarmed'
end

function bunny_string()
  player_state = var.player_state:read()
  if var.bunny_mode:read() == 1 then
    if (
        player_state == var.PlayerStateFlags.GROUND  or
        player_state == var.PlayerStateFlags.DASHING or
        player_state == var.PlayerStateFlags.SPIN_ATTACKING) then
      return 'superbunny'
    elseif player_state == var.PlayerStateFlags.TEMPBUNNY then
      return 'tempbunny'
    end
    return 'bunny'
  else
    if player_state == var.PlayerStateFlags.PERMABUNNY then
      return 'lousylink'
    end
    -- if you set tempbunny w/ cheats, you end up in an infinite
    -- transformation.. so I don't think I need to check for this here.
  end
  -- when hit by a bunny beam you are considered link during the
  -- transformation
  return 'link'
end
function tempbunny_string()
  if var.bunny_mode:read() == 1 and
      var.tempbunny_timer:read() ~= 0 and
      var.player_state:read() ~= var.PlayerStateFlags.TEMPBUNNY then
    return 'armed'
  end
  return 'disarmed'
end

function main()
  update_stored_eg()
end

return {
  stored_eg_string = stored_eg_string,
  spinspeed_string = spinspeed_string,
  waterwalk_string = waterwalk_string,
  bunny_string = bunny_string,
  tempbunny_string = tempbunny_string,
  main = main,
}
