--[[ Copyright (c) 2010 Miika-Petteri Matikainen

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

local room = {}
room.id = "hair_restoration"
room.vip_must_visit = false
room.level_config_id = 19
room.class = "HairRestorationRoom"
room.name = _S.rooms_short.hair_restoration
room.long_name = _S.rooms_long.hair_restoration
room.tooltip = _S.tooltip.rooms.hair_restoration
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { hair_restorer = 1, console = 1 }
room.build_preview_animation = 5074
room.categories = {
  clinics = 4,
}
room.minimum_size = 4
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd016.wav"
room.handyman_call_sound = "maint007.wav"

class "HairRestorationRoom" (Room)

---@type HairRestorationRoom
local HairRestorationRoom = _G["HairRestorationRoom"]

function HairRestorationRoom:HairRestorationRoom(...)
  self:Room(...)
end

function HairRestorationRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local hair_restorer, pat_x, pat_y = self.world:findObjectNear(patient, "hair_restorer")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")

  local --[[persistable:hair_restoration_shared_loop_callback]] function loop_callback()
    if staff:getCurrentAction().name == "idle" and patient:getCurrentAction().name == "idle" then
      local loop_callback_restore = --[[persistable:hair_restoration_loop_callback]] function(action)
        action.prolonged_usage = false
      end

      local after_use_restore = --[[persistable:hair_restoration_after_use]] function()
        patient:setLayer(0, patient.layers[0] + 2) -- Change to normal hair
        staff:setNextAction(MeanderAction())
        self:dealtWithPatient(patient)
      end

      patient:setNextAction(UseObjectAction(hair_restorer)
          :setLoopCallback(loop_callback_restore):setAfterUse(after_use_restore))

      staff:setNextAction(UseObjectAction(console))
    end
  end

  patient:walkTo(pat_x, pat_y)
  patient:queueAction(IdleAction():setDirection(hair_restorer.direction == "north" and "east" or "south")
      :setLoopCallback(loop_callback))

  staff:walkTo(stf_x, stf_y)
  staff:queueAction(IdleAction():setDirection(console.direction == "north" and "east" or "south")
      :setLoopCallback(loop_callback))

  return Room.commandEnteringPatient(self, patient)
end

return room
