local db, _, env = ConsolePort:DB(), ...; local L = db('Locale');
local CVARS_WIDTH, FIXED_OFFSET = 500, 8
---------------------------------------------------------------
-- Console variable fields
---------------------------------------------------------------
local Cvar = CreateFromMixins(CPIndexButtonMixin)
local Widgets = env.Widgets;

function Cvar:OnLoad()
	self:SetWidth(CVARS_WIDTH)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
end

function Cvar:Construct(data, newObj)
	if newObj then
		self:SetText(L(data.name))
		local controller = data.type(GetCVar(data.cvar))
		local constructor = Widgets[cvar] or Widgets[controller:GetType()];
		if constructor then
			constructor(self, data.cvar, data, controller, data.desc)
			controller:SetCallback(function(value)
				SetCVar(self.variableID, value)
				self:OnValueChanged(value)
			end)
		end
	end
	self:Hide()
	self:Show()
end

function Cvar:Get()
	local controller = self.controller;
	if controller:IsBool() then
		return GetCVarBool(self.variableID)
	elseif controller:IsNumber() then
		return tonumber(GetCVar(self.variableID))
	end
	return GetCVar(self.variableID)
end


---------------------------------------------------------------
-- Console variable fields
---------------------------------------------------------------
local Variables = CreateFromMixins(CPFocusPoolMixin, env.ScaleToContentMixin)
env.VariablesMixin = Variables;

function Variables:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:SetMeasurementOrigin(self, self, CVARS_WIDTH, 40)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Cvar, nil, self.Child)
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
end

function Variables:OnActiveDeviceChanged()
	self:ReleaseAll()
	local device = db('Gamepad/Active')
	if device then
		local prev;
		-- TODO: render cvars
		for i, data in db:For('Console') do
			local widget, newObj = self:TryAcquireRegistered(i)
			if newObj then
				widget.Label:ClearAllPoints()
				widget.Label:SetPoint('LEFT', 16, 0)
				widget.Label:SetJustifyH('LEFT')
				widget.Label:SetTextColor(1, 1, 1)
				widget:SetWidth(CVARS_WIDTH)
				widget:SetDrawOutline(true)
				widget:OnLoad()
			end
			widget:Construct(data, newObj)
			if prev then
				widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET)
			else
				widget:SetPoint('TOP', 0, -FIXED_OFFSET)
			end
			prev = widget;
		end
		self:SetHeight(nil)
		self:Show()
	else
		self:SetHeight(0)
		self:Hide()
	end
end