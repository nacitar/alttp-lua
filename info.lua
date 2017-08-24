#!/usr/bin/env lua

-- add pull mode (detect if you aren't actually at a statue, too)
local THIS_DIR = (... or '1'):match("(.-)[^%.]+$")
local var = require(THIS_DIR .. 'var')

function stored_eg_string()
  -- if you queue a layer change, the value is incremented rather than simply
  -- set to 1.  Therefore, if you queue it multiple times, the value will
  -- increase... and any nonzero value is treated at a single change.
  --
  -- When jumping a ledge, the player state is set to jumping, and a layer
  -- change is queued... however, there is one frame upon landing where the
  -- layer change is still queued but the player state is no longer jumping.
  -- Fortunately, the aux link state does still indicate that link was jumping
  -- during this frame, so we can instead use that value and avoid false
  -- positives.
  --
  -- Overworld jumps have no effect on the state, except if jumping northern
  -- ledges (as this is the same state as an interior ledge jump).  We can
  -- detect the loss of EG in this case upon landing, which is suitable
  -- enough.  This approach also prevents erroneously thinking the queued
  -- layer change was lost if mirror jumping a northern ledge.
  if var.queued_layer_change:read() >= 1 and (
          var.aux_link_state:read() ~= var.AuxLinkStateFlags.JUMPING or
          var.is_indoors:read() == 0) then
    if var.room_upper_layer:read() == 1 then
      return 'strong'
    else
      return 'weak'
    end
  end
  return 'disarmed'
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

return {
  stored_eg_string = stored_eg_string,
  spinspeed_string = spinspeed_string,
  waterwalk_string = waterwalk_string,
  bunny_string = bunny_string,
  tempbunny_string = tempbunny_string,
}
