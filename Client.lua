-- Client.lua (minified)
local RS=game:GetService
local Rep=RS("ReplicatedStorage")
local Plrs=RS("Players")
local Deb=RS("Debris")
local UIS=RS("UserInputService")
local player=Plrs.LocalPlayer
local cam=workspace.CurrentCamera
local mouse=player:GetMouse()
local shoot=Rep:WaitForChild("ShootEvent")
local round=Rep:WaitForChild("RoundEvent")
local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"));gui.Name="AimTrainerUI";gui.ResetOnSpawn=false
local cross=Instance.new("TextLabel",gui);cross.Size=UDim2.new(0,20,0,20);cross.Position=UDim2.new(0.5,-10,0.5,-10);cross.BackgroundTransparency=1;cross.Text="+";cross.TextScaled=true;cross.Font=Enum.Font.ArialBold
local panel=Instance.new("Frame",gui);panel.Size=UDim2.new(0,220,0,140);panel.Position=UDim2.new(1,-230,0,10);panel.BackgroundTransparency=0.35
local function mk(t,y)local l=Instance.new("TextLabel",panel);l.Size=UDim2.new(1,-10,0,18);l.Position=UDim2.new(0,5,0,y);l.BackgroundTransparency=1;l.TextScaled=true;l.Font=Enum.Font.Arial;l.Text=t;return l end
local score=mk("Score: 0",6);local mult=mk("Mult: x1",28);local shots=mk("Shots: 0",50);local hits=mk("Hits: 0",72);local acc=mk("Accuracy: 0%",94);local roundLbl=mk("Round: --",116)
local timer=Instance.new("TextLabel",gui);timer.Size=UDim2.new(0,120,0,32);timer.Position=UDim2.new(0,10,0,10);timer.BackgroundTransparency=0.4;timer.TextScaled=true;timer.Text="Timer: --"
local function tracer(o,tpos)local dir=(tpos-o);local p=Instance.new("Part");p.Size=Vector3.new(0.12,0.12,dir.Magnitude);p.CFrame=CFrame.new(o+dir/2,o+dir);p.Anchored=true;p.CanCollide=false;p.Parent=workspace;Deb:AddItem(p,0.08) end
local function fire() local o=cam.CFrame.Position; local t=mouse.Hit.Position or (o+cam.CFrame.LookVector*500); local dir=(t-o); if dir.Magnitude==0 then return end tracer(o,t); shoot:FireServer(o,dir.Unit) end
mouse.Button1Down:Connect(fire)
local function upd()
 local ls=player:FindFirstChild("leaderstats")
 if not ls then return end
 local sc=ls:FindFirstChild("Score") and ls.Score.Value or 0
 local sh=ls:FindFirstChild("Shots") and ls.Shots.Value or 0
 local hi=ls:FindFirstChild("Hits") and ls.Hits.Value or 0
 local mu=ls:FindFirstChild("Multiplier") and ls.Multiplier.Value or 1
 local lv=ls:FindFirstChild("Level") and ls.Level.Value or 1
 score.Text="Score: "..sc;mult.Text="Mult: x"..mu;shots.Text="Shots: "..sh;hits.Text="Hits: "..hi;acc.Text="Accuracy: "..(sh>0 and math.floor((hi/sh)*100) or 0).."%";roundLbl.Text="Round: L"..lv
end
spawn(function() while true do upd() wait(0.2) end end)
round.OnClientEvent:Connect(function(cmd,timeLeft,mode,lv) if cmd=="Start" then timer.Text="Timer: "..timeLeft.."s ("..mode..")";local p=Instance.new("TextLabel",gui);p.Size=UDim2.new(0,300,0,50);p.Position=UDim2.new(0.5,-150,0.15,0);p.BackgroundTransparency=0.3;p.TextScaled=true;p.Text="Round Start: "..mode.." (L"..lv..")";Deb:AddItem(p,2.5);spawn(function() local t=timeLeft; while t>0 do timer.Text="Timer: "..t.."s ("..mode..")";wait(1);t=t-1 end timer.Text="Timer: 0s" end) elseif cmd=="End" then timer.Text="Round End";local p=Instance.new("TextLabel",gui);p.Size=UDim2.new(0,300,0,60);p.Position=UDim2.new(0.5,-150,0.15,0);p.BackgroundTransparency=0.25;p.TextScaled=true;p.Text="Round End! Check your score.";Deb:AddItem(p,3) end end)
UIS.InputBegan:Connect(function(i,proc) if proc then return end if i.KeyCode==Enum.KeyCode.R then local ls=player:FindFirstChild("leaderstats"); if ls then for _,n in pairs({"Score","Shots","Hits","Multiplier","Streak"}) do if ls:FindFirstChild(n) then ls[n].Value=(n=="Multiplier" and 1 or 0) end end end end end)
spawn(function() local last=0; while true do local ls=player:FindFirstChild("leaderstats"); if ls and ls:FindFirstChild("Hits") then local h=ls.Hits.Value; if h>last then cross.TextColor3=Color3.new(0,1,0);wait(0.08);cross.TextColor3=Color3.new(1,1,1); end last=h end wait(0.06) end end)
