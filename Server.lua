-- Server.lua (minified)
local RS=game:GetService
local Rep=RS("ReplicatedStorage")
local Plrs=RS("Players")
local WS=RS("Workspace")
local Deb=RS("Debris")
local shoot=Rep:FindFirstChild("ShootEvent") or (function()local e=Instance.new("RemoteEvent");e.Name="ShootEvent";e.Parent=Rep;return e end)()
local round=Rep:FindFirstChild("RoundEvent") or (function()local e=Instance.new("RemoteEvent");e.Name="RoundEvent";e.Parent=Rep;return e end)()
local targets=WS:FindFirstChild("AimTargets") or (function()local f=Instance.new("Folder");f.Name="AimTargets";f.Parent=WS;return f end)()
local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Blacklist
local function mk(pos,s) local p=Instance.new("Part") p.Size=s or Vector3.new(2,2,0.5) p.Position=pos p.Anchored=true p.CanCollide=false p.Name="AimTarget" p.Parent=targets p:SetAttribute("IsAimTarget",true) p:SetAttribute("Pattern","Static") return p end
local function apply(p)
 local t=p:GetAttribute("Pattern") or "Static"
 if t=="Static" then return end
 if t=="Sine" then spawn(function()local o=p.Position;local tt=0;while p.Parent do tt=tt+0.03;p.Position=o+Vector3.new(math.sin(tt*2)*4,math.cos(tt*1.2)*1.5,0);wait(0.03)end end) end
 if t=="Erratic" then spawn(function()while p.Parent do local tgt=p.Position+Vector3.new(math.random(-6,6),math.random(-3,3),math.random(-4,4));local steps=math.random(12,30);local sPos=p.Position;for i=1,steps do if not p.Parent then break end; p.Position=sPos:Lerp(tgt,i/steps);wait(0.02+math.random()/200) end;wait(0.1) end end) end
 if t=="Vertical" then spawn(function()local o=p.Position;local tt=0;while p.Parent do tt=tt+0.04;p.Position=o+Vector3.new(0,math.sin(tt)*3,0);wait(0.03) end end) end
 if t=="Forsaken" then spawn(function()while p.Parent do p.Position=p.Position+Vector3.new((math.random()-0.5)*1.2,(math.random()-0.5)*1.2,(math.random()-0.5)*1.2);wait(0.04+math.random()/300) end end) end
end
local function clear() for _,v in pairs(targets:GetChildren()) do v:Destroy() end end
local function spawnMode(m)
 clear()
 local baseZ=-30
 if m=="Easy" then for i=1,5 do local p=mk(Vector3.new((i-3)*5,5+math.random(-1,1),baseZ+math.random(-3,3)));p:SetAttribute("Pattern","Static");apply(p) end
 elseif m=="Moving" then for i=1,6 do local p=mk(Vector3.new((i-3)*6,5+math.random(-2,2),baseZ+math.random(-5,5)));p:SetAttribute("Pattern",(i%2==0) and "Sine" or "Vertical");apply(p) end
 elseif m=="Erratic" then for i=1,7 do local p=mk(Vector3.new((i-4)*4,6+math.random(-2,2),baseZ+math.random(-6,6)));p:SetAttribute("Pattern","Erratic");apply(p) end
 elseif m=="Forsaken" then for i=1,8 do local p=mk(Vector3.new((i-4)*3.5,5+math.random(-2,2),baseZ+math.random(-8,8)));p:SetAttribute("Pattern","Forsaken");apply(p) end
 elseif m=="Mixed" then for i=1,9 do local p=mk(Vector3.new((i-5)*3.5,5+math.random(-3,3),baseZ+math.random(-10,10)));local pats={"Static","Sine","Erratic","Forsaken","Vertical"};p:SetAttribute("Pattern",pats[math.random(1,#pats)]);apply(p) end
 else spawnMode("Easy") end
end
Plrs.PlayerAdded:Connect(function(p)
 local f=Instance.new("Folder",p);f.Name="leaderstats"
 local function iv(n,v)local x=Instance.new("IntValue");x.Name=n;x.Value=v;x.Parent=f;return x end
 iv("Score",0);iv("Shots",0);iv("Hits",0);iv("Multiplier",1);iv("Streak",0);iv("Level",1);iv("TimeLeft",60)
end)
shoot.OnServerEvent:Connect(function(p,origin,dir)
 if typeof(origin)~="Vector3" or typeof(dir)~="Vector3" then return end
 local ch=p.Character
 rp.FilterDescendantsInstances = ch and {ch} or {}
 local ls=p:FindFirstChild("leaderstats")
 if ls and ls:FindFirstChild("Shots") then ls.Shots.Value=ls.Shots.Value+1 end
 local res=workspace:Raycast(origin,dir*500,rp)
 if res and res.Instance and res.Instance:GetAttribute("IsAimTarget") then
  if ls and ls:FindFirstChild("Hits") then ls.Hits.Value=ls.Hits.Value+1 end
  if ls and ls:FindFirstChild("Streak") and ls:FindFirstChild("Multiplier") then ls.Streak.Value=ls.Streak.Value+1;ls.Multiplier.Value=math.clamp(1+math.floor(ls.Streak.Value/3),1,5) end
  local levelFactor=(ls and ls:FindFirstChild("Level")) and (1+ (ls.Level.Value-1)*0.1) or 1
  if ls and ls:FindFirstChild("Score") and ls:FindFirstChild("Multiplier") then ls.Score.Value=ls.Score.Value+math.floor(10*ls.Multiplier.Value*levelFactor) end
  local inst=res.Instance;inst.Transparency=1;inst.CanCollide=false
  local fx=Instance.new("Part");fx.Size=Vector3.new(0.4,0.4,0.4);fx.Position=inst.Position;fx.Anchored=true;fx.CanCollide=false;fx.Parent=workspace;Deb:AddItem(fx,0.6)
  spawn(function()wait(0.5) if inst and inst.Parent then inst.Transparency=0;inst.CanCollide=false;inst.Position=inst.Position+Vector3.new(math.random(-2,2),math.random(-1,1),math.random(-2,2)) end end)
 else
  if ls and ls:FindFirstChild("Streak") and ls:FindFirstChild("Multiplier") then ls.Streak.Value=0;ls.Multiplier.Value=1 end
 end
end)
spawn(function() local modes={"Easy","Moving","Erratic","Forsaken","Mixed"};local idx=1;while true do spawnMode(modes[idx]); round:FireAllClients("Start",45,modes[idx],1); for t=45,1,-1 do for _,p in pairs(Plrs:GetPlayers()) do local ls=p:FindFirstChild("leaderstats"); if ls and ls:FindFirstChild("TimeLeft") then ls.TimeLeft.Value=t end end wait(1) end round:FireAllClients("End",0,modes[idx],1); idx=idx+1;if idx>#modes then idx=1 end;wait(3) end end)
