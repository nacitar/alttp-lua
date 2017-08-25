local THIS_DIR = (... or ''):match("(.-)[^%.]+$") or '.'

local var = require(THIS_DIR .. 'var')
local util = require(THIS_DIR .. 'util.util')
local class = require(THIS_DIR .. 'util.class')

function at_duck_map()
  if var.mode:read() == var.ModeFlags.TEXT_ITEM_MAP and
    var.submode:read() == var.SubModeFlags.DUCK_MAP then
    return true
  end
  return false
end

function held_by_duck()
  for i=0,9 do
    if var.ancilla_type:read(i, false) == var.AncillaType.DUCK then
      if var.ancilla_effect_state:read(i, false) ==
          var.AncillaEffectState.HOLDING_PLAYER then
        return true
      end
      break
    end
  end
  return false
end

function using_duck()
  -- if we're in the duck map, the duck has us
  if at_duck_map() then
    return true
  end
  -- otherwise, check if the duck currently has us... either on the way up or
  -- on the way down, the state is the same
  return held_by_duck()
end

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

local SPINSPEED_BAD_STATES = util.Set({
  var.PlayerStateFlags.DASHING,
  var.PlayerStateFlags.FALLING_OR_NEAR_HOLE})
function spinspeed_string()
  -- spinspeed sets dash_countdown to 29 as well, but not checking it
  if not SPINSPEED_BAD_STATES[var.player_state:read()] and
      var.bonk_wall:read() == 1 and not using_duck() then
      -- Instead of using_duck(), one could check:
      --    var.hand_up_pose:read() == var.HandUpPoseFlags.NOT_UP
      -- duck causes your hand to go up, and its value as used elsewhere still
      -- works for this logic... but checking for it directly makes more sense
      -- than checking for a side effect.
      -- Without this extra check, dashing and then getting picked up by the
      -- duck mid-dash will erroneously report spinspeed.
    return 'armed'
  end
  return 'disarmed'
end

local SUPERBUNNY_STATES = util.Set({
  var.PlayerStateFlags.GROUND,
  var.PlayerStateFlags.DASHING,
  var.PlayerStateFlags.SPIN_ATTACKING})
function bunny_string()
  player_state = var.player_state:read()
  if var.bunny_mode:read() == 1 then
    if SUPERBUNNY_STATES[player_state] then
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

function buffered_buttons()
  pressed = {}
  main = var.joypad1_main:read()
  secondary = var.joypad1_secondary:read()
  for key, value in pairs(var.JoypadMain) do
    if bit.band(main, value) ~= 0 then
      pressed[key] = true
    end
  end
  for key, value in pairs(var.JoypadSecondary) do
    if bit.band(secondary, value) ~= 0 then
      pressed[key] = true
    end
  end
  return pressed
end

ScaledDrawer = class()
function ScaledDrawer:__init(x, y, scale)
  self.x = x
  self.y = y
  self.scale = scale
end

function ScaledDrawer:draw_rect(x, y, width, height, color)
  width = width * self.scale
  height = height * self.scale
  if width == 0 or height == 0 then
    return
  end
  x = self.x + x * self.scale
  y = self.y + y * self.scale
  if width == 1 and height == 1 then
    pixelFunc = gui.drawPixel or gui.pixel
    pixelFunc(x, y, color)
  else
    x2 = x + width - 1
    y2 = y + height - 1
    if width == 1 or height == 1 then
      lineFunc = gui.drawLine or gui.line
      lineFunc(x, y, x2, y2, color)
    else
      rectFunc = gui.drawBox or gui.rect
      rectFunc(x, y, x2, y2, color, color)
    end
  end
end
function ScaledDrawer:draw_cross(x, y, border_color,
    left_color, top_color, right_color, bottom_color)
  drawer:draw_rect(0+x, 2+y, 8, 4, border_color)
  drawer:draw_rect(2+x, 0+y, 4, 8, border_color)
  drawer:draw_rect(1+x, 3+y, 2, 2, left_color)
  drawer:draw_rect(3+x, 1+y, 2, 2, top_color)
  drawer:draw_rect(5+x, 3+y, 2, 2, right_color)
  drawer:draw_rect(3+x, 5+y, 2, 2, bottom_color)
end
function ScaledDrawer:draw_buttons(x, y, border_color,
    left_color, top_color, right_color, bottom_color)

  drawer:draw_rect(0+x, 4+y, 4, 2, border_color)
  drawer:draw_rect(1+x, 3+y, 2, 4, border_color)
  drawer:draw_rect(1+x, 4+y, 2, 2, left_color)

  drawer:draw_rect(4+x, 0+y, 2, 4, border_color)
  drawer:draw_rect(3+x, 1+y, 4, 2, border_color)
  drawer:draw_rect(4+x, 1+y, 2, 2, top_color)

  drawer:draw_rect(6+x, 4+y, 4, 2, border_color)
  drawer:draw_rect(7+x, 3+y, 2, 4, border_color)
  drawer:draw_rect(7+x, 4+y, 2, 2, right_color)

  drawer:draw_rect(4+x, 6+y, 2, 4, border_color)
  drawer:draw_rect(3+x, 7+y, 4, 2, border_color)
  drawer:draw_rect(4+x, 7+y, 2, 2, bottom_color)
end
function ScaledDrawer:draw_slanted_button(x, y, border_color, color)
  drawer:draw_rect(0+x, 2+y, 2, 2, border_color)
  drawer:draw_rect(1+x, 1+y, 2, 2, border_color)
  drawer:draw_rect(2+x, 0+y, 2, 2, border_color)
  drawer:draw_rect(1+x, 2+y, 1, 1, color)
  drawer:draw_rect(2+x, 1+y, 1, 1, color)
end
function ScaledDrawer:draw_shoulder_button(x, y, border_color, color)
  drawer:draw_rect(1+x, 0+y, 3, 3, border_color)
  drawer:draw_rect(0+x, 1+y, 5, 1, border_color)
  drawer:draw_rect(1+x, 1+y, 3, 1, color)
end

function RGBA(red, green, blue, alpha)
  if gui.drawBox then
    -- bizhawk wants the alpha at the other end..
    return (
        bit.band(blue, 0xFF) +
        bit.lshift(bit.band(green, 0xFF), 8) +
        bit.lshift(bit.band(red, 0xFF), 16) +
        bit.lshift(bit.band(alpha, 0xFF), 24))
  else
    -- snes9x
    return (
        bit.band(alpha, 0xFF) +
        bit.lshift(bit.band(blue, 0xFF), 8) +
        bit.lshift(bit.band(green, 0xFF), 16) +
        bit.lshift(bit.band(red, 0xFF), 24))
  end
end
function draw_input_hud(x, y, pressed)
  local COLOR_PRESSED = RGBA(0xE1, 0xE1, 0xE1, 0xFF)
  local COLOR_RELEASED = RGBA(0x48, 0x48, 0x48, 0xFF)
  local COLOR_Y = RGBA(0x42, 0xDF, 0x58, 0xFF)
  local COLOR_X = RGBA(0x69, 0x6C, 0xE8, 0xFF)
  local COLOR_A = RGBA(0xEC, 0x6F, 0x71, 0xFF)
  local COLOR_B = RGBA(0xF4, 0xE5, 0x77, 0xFF)

  drawer = ScaledDrawer(x, y, 1)

  left_color = pressed['LEFT'] and COLOR_PRESSED or COLOR_RELEASED
  top_color = pressed['UP'] and COLOR_PRESSED or COLOR_RELEASED
  right_color = pressed['RIGHT'] and COLOR_PRESSED or COLOR_RELEASED
  bottom_color = pressed['DOWN'] and COLOR_PRESSED or COLOR_RELEASED
  drawer:draw_cross(0, 1, 'black',
      left_color, top_color, right_color, bottom_color)

  color = pressed['L'] and COLOR_PRESSED or COLOR_RELEASED
  drawer:draw_shoulder_button(8, 0, 'black', color)

  color = pressed['SELECT'] and COLOR_PRESSED or COLOR_RELEASED
  drawer:draw_slanted_button(9, 5, 'black', color)

  color = pressed['START'] and COLOR_PRESSED or COLOR_RELEASED
  drawer:draw_slanted_button(14, 5, 'black', color)

  color = pressed['R'] and COLOR_PRESSED or COLOR_RELEASED
  drawer:draw_shoulder_button(14, 0, 'black', color)

  left_color = pressed['Y'] and COLOR_Y or COLOR_RELEASED
  top_color = pressed['X'] and COLOR_X or COLOR_RELEASED
  right_color = pressed['A'] and COLOR_A or COLOR_RELEASED
  bottom_color = pressed['B'] and COLOR_B or COLOR_RELEASED
  drawer:draw_buttons(19, 0, 'black',
      left_color, top_color, right_color, bottom_color)
end

function snes9x_button_string(pressed)
  --snes9x='<^>v ABYX Ss'
  -- TODO: bizhawk? practice hack?
  output = {}
  table.insert(output, pressed['LEFT'] and '<' or ' ')
  table.insert(output, pressed['UP'] and '^' or ' ')
  table.insert(output, pressed['RIGHT'] and '>' or ' ')
  table.insert(output, pressed['DOWN'] and 'v' or ' ')
  table.insert(output, ' ')
  table.insert(output, pressed['A'] and 'A' or ' ')
  table.insert(output, pressed['B'] and 'B' or ' ')
  table.insert(output, pressed['Y'] and 'Y' or ' ')
  table.insert(output, pressed['X'] and 'X' or ' ')
  table.insert(output, ' ')
  table.insert(output, pressed['L'] and 'L' or ' ')
  table.insert(output, pressed['R'] and 'R' or ' ')
  table.insert(output, ' ')
  table.insert(output, pressed['START'] and 'S' or ' ')
  table.insert(output, pressed['SELECT'] and 's' or ' ')

  return table.concat(output, '')
end

return {
  at_duck_map = at_duck_map,
  using_duck = using_duck,
  stored_eg_string = stored_eg_string,
  spinspeed_string = spinspeed_string,
  waterwalk_string = waterwalk_string,
  bunny_string = bunny_string,
  tempbunny_string = tempbunny_string,
  snes9x_button_string = snes9x_button_string,
  buffered_buttons = buffered_buttons,
  draw_input_hud = draw_input_hud,
}
