AddCSLuaFile();
ENT.Type = "anim";
function ENT:SetupDataTables()
	self:NetworkVar("Bool", "IsProjectorCloned");
end;
function ENT:Initialize()
	if self:GetIsProjectorCloned() then
		self:SetModel("models/props_junk/PopCan01a.mdl");
		self:SetSolid(SOLID_NONE);
		self:PhysicsInitBox(Vector(0, 0, 0), Vector(0, 0, 0));
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS);
		self:SetColor(Color(255, 255, 255, 0));
		self:SetRenderMode(RENDERMODE_TRANSALPHA);
	else
		self:SetModel("models/props/wall_emitter.mdl");
	end;
	if SERVER then
		self:PhysicsInitStatic(SOLID_VPHYSICS);
		self:Enable();
	end;
end;
function ENT:KeyValue(k, v)
	if k == "StartEnabled" then
		self.StartEnabled = tobool(v);
	elseif k == "skin" then
		self:SetSkin(tonumber(v));
	end;
	if k:StartsWith("On") then
		self:StoreOutput(k, v);
	end;
end;
function ENT:AcceptInput(name, activator, caller, data)
	name = name:lower();
	if name == "enable" then
		self:Enable();
	elseif name == "disable" then
		self:Disable();
	end;
end;
if SERVER then
	local savedWallCollision = nil;
	function ENT:Enable()
		if self.WallEntity and IsValid(self.WallEntity) then
			savedWallCollision = {
				Solid = self.WallEntity:GetSolid(),
				CollisionGroup = self.WallEntity:GetCollisionGroup(),
				Color = self.WallEntity:GetColor(),
				RenderMode = self.WallEntity:GetRenderMode()
			};
			self.WallEntity:Remove();
			self.WallEntity = nil;
			self.ProjectedWall = nil;
		end;
		self.WallEntity = ents.Create("projected_wall_entity");
		local ang = self:GetAngles();
		if self:GetIsProjectorCloned() then
			self.WallEntity:SetIsProjectorCloned(true);
			print("[GP2] prop_wall_projector: Flag IsProjectorCloned propagé au mur");
		end;
		self.WallEntity:Spawn();
		self.WallEntity:SetPos(self:GetPos() + ang:Forward() * 8);
		self.WallEntity:SetParent(self);
		self.WallEntity:SetAngles(ang);
		if self:GetIsProjectorCloned() then
			print("[GP2] prop_wall_projector: Clone détecté, mais retardement de la création du mur");
			self.WallEntity:SetUpdated(false);
		end;
		if savedWallCollision then
			self.WallEntity:SetSolid(savedWallCollision.Solid);
			self.WallEntity:SetCollisionGroup(savedWallCollision.CollisionGroup);
			self.WallEntity:SetColor(savedWallCollision.Color);
			self.WallEntity:SetRenderMode(savedWallCollision.RenderMode);
		end;
		self.ProjectedWall = self.WallEntity;
	end;
	function ENT:Disable()
		if self.WallEntity and IsValid(self.WallEntity) then
			self.WallEntity:Remove();
			self.WallEntity = nil;
			self.ProjectedWall = nil;
		end;
	end;
	function ENT:Think()
		if SERVER and self.WallEntity and IsValid(self.WallEntity) then
			local curPos = self:GetPos() + (self:GetAngles()):Forward() * 8;
			local curAng = self:GetAngles();
			if not self._lastWallPos or (not self._lastWallAng) or self._lastWallPos ~= curPos or self._lastWallAng ~= curAng then
				self.WallEntity:SetPos(curPos);
				self.WallEntity:SetAngles(curAng);
				if self.WallEntity.CreateWall then
					self.WallEntity:SetUpdated(false);
					self.WallEntity:CreateWall();
				end;
				self._lastWallPos = curPos;
				self._lastWallAng = curAng;
			end;
		end;
		self:NextThink(CurTime() + 0.05);
		return true;
	end;
end;
