--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║         BUILD A BOAT FOR TREASURE - SCRIPT                   ║
    ║                                                              ║
    ║  Author   : worlde131                                        ║
    ║  Version  : 2.0                                              ║
    ║                                                              ║
    ║  Özellikler:                                                 ║
    ║   • Auto Build     (base kopyala & yapıştır)                 ║
    ║   • Auto Farm      (tüm aşamalardan otomatik geç)            ║
    ║   • Waypoint Pilot (aşamalar arası otomatik uçuş)            ║
    ║   • Düz Pilot      (düz uçuş, üstünde yürünebilir çatı)     ║
    ║   • Araba Uçuşu    (manuel kamera yönlendirmeli araç uçuşu)  ║
    ║   • AFK Karşıtı    (sunucudan atılmama koruması)             ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ================================================================
-- SERVİSLER
-- ================================================================

local VIM               = game:GetService("VirtualInputManager")
local Oyuncular         = game:GetService("Players")
local TweenServis       = game:GetService("TweenService")
local CalismaAlani      = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunServis         = game:GetService("RunService")
local KullaniciGirisi   = game:GetService("UserInputService")

-- ================================================================
-- YEREL OYUNCU REFERANSLARI
-- ================================================================

local oyuncu   = Oyuncular.LocalPlayer
local karakter = oyuncu.Character or oyuncu.CharacterAdded:Wait()
local insani   = karakter:WaitForChild("Humanoid")
local HRP      = karakter:WaitForChild("HumanoidRootPart")

-- ================================================================
-- RAYFIELD UI YÜKLE
-- ================================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Pencere = Rayfield:CreateWindow({
    Name             = "BABFT | worlde131",
    Icon             = 0,
    LoadingTitle     = "BABFT Script",
    LoadingSubtitle  = "worlde131 tarafından",
    Theme            = "Default",
    ToggleUIKeybind  = "G",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "worlde131BABFT",
        FileName   = "BABFT_Ayarlar",
    },
})

-- ================================================================
-- PAYLAŞILAN DURUM & YOLLAR
-- ================================================================

local blokVeri       = oyuncu:WaitForChild("Data")
local blokKlasoru    = CalismaAlani:WaitForChild("Blocks")

-- Auto Build
local pano           = nil
local seciliBase     = nil
local yapistirYuzde  = 0
local kullanilanListe = {}
local anchorIgnore   = true

-- Auto Farm
local otomatikCiftlik = false
local asamaIndeksi    = 1
local arageciş        = false

-- Waypoint Pilot Config
local wpPilotAktif      = false
local wpPilotBaglanti   = nil
local apBV              = nil
local apBG              = nil
local AP_HIZ            = 120   -- stud/s seyir hızı
local AP_YUKSEKLIK      = 80    -- su üstü hedef Y
local AP_NOKTA_YARIÇAPI = 60    -- bu mesafede sonraki noktaya geç (düz arazi)
local AP_VARIS_YARIÇAPI = 100   -- göğse bu yakınlıkta otomatik pilotu durdur
local AP_DIKEY_GÜCÜ    = 4     -- dikey düzeltme çarpanı

-- Düz Pilot Config
local duzPilotAktif    = false
local duzPilotBaglanti = nil
local duzAPBV          = nil
local duzAPBG          = nil
local duzAPParcasi     = nil
local DUZ_AP_HIZ       = 70    -- stud/s

-- Araba Uçuşu
local arabaucus        = false
local arabaucusHiz     = 50
local arabaucusBaglanti = nil
local arabaBV          = nil

-- ================================================================
-- YARDIMCI FONKSİYONLAR
-- ================================================================

local function bildir(baslik, icerik, sure, resim)
    Rayfield:Notify({
        Title    = baslik,
        Content  = icerik,
        Duration = sure or 5,
        Image    = resim or "bilgi",
    })
end

local function blokIDGetir(isim)
    local bulundu = blokVeri:FindFirstChild(isim)
    return bulundu and bulundu.Value or 9 -- 9 = WoodBlock yedek
end

local function gercekAdGetir(goruntuAdi)
    for _, v in pairs(Oyuncular:GetChildren()) do
        if v.DisplayName == goruntuAdi then return v.Name end
    end
    return nil
end

local function oyuncuListesiGetir()
    local liste = {}
    for _, v in pairs(Oyuncular:GetChildren()) do
        table.insert(liste, v.Name)
    end
    return liste
end

local function oyuncuZonuGetir(oyuncuObj)
    for _, v in pairs(oyuncuObj.Character.HumanoidRootPart:GetChildren()) do
        if (v:IsA("Snap") or v:IsA("Weld")) and v.Part1 and v.Part1.Parent ~= oyuncuObj.Character then
            return v.Part1
        end
    end
    return nil
end

local function yeniBlokKonumuGetir(hisBase, blok, benimBase)
    if not blok or not blok:FindFirstChild("PrimaryPart") then
        warn("[worlde131] yeniBlokKonumuGetir: PrimaryPart eksik")
        return CFrame.new()
    end
    if not hisBase and not benimBase then
        return blok.PrimaryPart.CFrame
    end
    if hisBase then
        return benimBase.CFrame * hisBase.CFrame:ToObjectSpace(blok.PrimaryPart.CFrame)
    end
    return blok.PrimaryPart.CFrame
end

local function eklemiBul(model)
    for _, v in pairs(model.PrimaryPart:GetChildren()) do
        if (v:IsA("Snap") or v:IsA("Weld")) and v.Part1 and v.Part1.Parent ~= model then
            return v.Part1
        end
    end
    return oyuncuZonuGetir(oyuncu)
end

-- ================================================================
-- AUTO BUILD FONKSİYONLARI
-- ================================================================

local function eksikBloklariGetir(beklenen, olusturulan)
    local eksik = {}
    for i, v in ipairs(beklenen) do
        local bulundu = false
        for _, b in pairs(olusturulan) do
            if b:FindFirstChild("PrimaryPart") and b.Name == v.Name then
                bulundu = true; break
            end
        end
        if not bulundu then
            table.insert(eksik, { Dizin = i, Ad = v.Ad, Konum = v.Konum })
        end
    end
    return eksik
end

local function enYakinBloguGetir(beklenen, liste)
    local enIyi, enIyiMesafe = nil, math.huge
    for _, b in pairs(liste) do
        if b:FindFirstChild("PrimaryPart") and b.Name == beklenen.Name then
            local d = (b.PrimaryPart.Position - beklenen.Pos.Position).Magnitude
            if d < enIyiMesafe then enIyiMesafe = d; enIyi = b end
        end
    end
    return enIyi
end

local function bloguYeniBoyutaGetir(blok, yeniKonum, yeniBoyut)
    if not blok then warn("[worlde131] bloguYeniBoyutaGetir: blok boş"); return end
    local arac = getTool("ölçeklendirme Aracı")
    task.spawn(function()
        arac.RF:InvokeServer(blok, yeniBoyut, yeniKonum)
    end)
end

local function bloguBoya(blok, renk)
    if not blok then warn("[worlde131] bloguBoya: blok boş"); return end
    if blok.PrimaryPart and blok.PrimaryPart:FindFirstChild("FindFirstChild") then
        if blok.PrimaryPart.Color == renk then return end
    end
    local arac = getTool("Boyama Aracı")
    task.spawn(function()
        arac.RF:InvokeServer({ blok, renk })
    end)
end

local function saydamlikAyarla(istek, blok)
    if not blok then return end
    if blok.PrimaryPart.Transparency == istek then return end
    local arac = getTool("PropertiesTool")
    task.spawn(function()
        for _ = 1, 4 do
            arac.SetPropertiesRF:InvokeServer("Şeffaflık", { blok })
        end
    end)
end

local function ankrajAyarla(blok)
    if not blok then return end
    local arac = getTool("PropertiesTool")
    task.spawn(function()
        arac.SetPropertiesRF:InvokeServer("Anchored", { blok })
    end)
end

local function bloguYerlestir(isim, konum, goreceli, ankrajli)
    local arac = getTool("BuildingTool")
    local goreliye = goreceli or oyuncuZonuGetir(oyuncu)
    task.spawn(function()
        arac.RF:InvokeServer({
            isim,
            blokIDGetir(isim),
            goreliye and goreliye.CFrame:ToObjectSpace(konum) or CFrame.new(),
            goreliye and true or ankrajli,
            konum,
            false,
        })
    end)
end

local function baseyiKopyala(bloklar)
    pano = nil
    local t = {}
    local benimBase = oyuncuZonuGetir(oyuncu)
    local hisBase   = oyuncuZonuGetir(Oyuncular:FindFirstChild(bloklar.Name))
    for _, blok in ipairs(bloklar:GetChildren()) do
        if blok:FindFirstChild("PrimaryPart") then
            local kimlik   = blokIDGetir(blok.Name)
            local kullanilan = kullanilanListe[blok.Ad] or 0
            if kimlik == 0 or kullanilan >= kimlik then
                print("[worlde131] Yeterli değil:", blok.Name)
                continue
            end
            kullanilanListe[blok.Name] = kullanilan + 1
            local goreceli = eklemiBul(blok)
            if goreceli == benimBase then
                goreceli = benimBase
            end
            table.insert(t, {
                Ad        = blok.Ad,
                Konum     = yeniBlokKonumuGetir(hisBase, blok, benimBase),
                Goreceli  = goreceli,
                Seffaflik = blok.PrimaryPart.Transparency,
                Ankrajli  = blok.PrimaryPart.Anchored,
                Boyut     = blok.Parça.Boyutu,
                Renk      = blok.PrimaryPart.Color,
            })
        end
    end
    pano = t
    return t
end

local function baseYapistir(pano, oyuncuZonuGetirFn)
    yapistirYuzde = 0
    local yerlestirildi   = 0
    local toplam          = #pano
    local sonEklenen      = tick()
    local baglanti = blokKlasoru.ChildAdded:Connect(function()
        yerlestirildi += 1
        sonEklenen = tick()
    end)
    print("[worlde131] Yerleştirme", toplam, "blok…")
    for i, v in ipairs(pano) do
        bloguYerlestir(v.Ad, v.Konum, v.Goreceli, v.Ankrajli)
        yapistirYuzde = math.floor((i / toplam) * 50)
        if i % 20 == 0 then task.wait(0.05) end
    end
    task.wait(0.1) until tick() - sonEklenen > 5
    print("[worlde131] Yerleştirildi:", yerlestirildi, "/ Beklenen:", toplam)
    if toplam - yerlestirildi > 0 then
        local eksik = eksikBloklariGetir(pano, blokKlasoru:GetChildren())
        print("[worlde131] Eksik", #eksik, "blok:")
        for _, b in ipairs(eksik) do
            print("Dizin:", b.Dizin, "| Ad:", b.Ad, "| Konum:", b.Konum)
        end
    end
    print("[worlde131] Boyama ve yeniden ölçeklendirme…")
    local temelListe = blokKlasoru:GetChildren()
    for i, v in ipairs(pano) do
        local b = enYakinBloguGetir(v, temelListe)
        if b then
            bloguYeniBoyutaGetir(b, v.Konum, v.Boyut)
            bloguBoya(b, v.Renk)
            saydamlikAyarla(b, v.Seffaflik)
        end
        yapistirYuzde = 50 + math.floor((i / toplam) * 50)
        if i % 20 == 0 then task.wait(0.05) end
    end
    baglanti:Disconnect()
    yapistirYuzde = 0
    print("[worlde131] Yapıştırma işlemi tamamlandı.")
end

-- ================================================================
-- WAYPOINT OTOMATİK PİLOT
-- ================================================================

local function hedefNoktalarıOlustur()
    local tekneler = CalismaAlani:FindFirstChild("BoatStages")
    local normalAsama = tekneler and tekneler:FindFirstChild("NormalStages")
    if not normalAsama then return nil end
    local wps = {}
    for i = 1, 10 do
        local asama = normalAsama:FindFirstChild("MağaraAşaması" .. i)
        local karanlik = asama and asama:FindFirstChild("DarknessPart")
        if karanlik then
            table.insert(wps, Vector3.new(karanlik.Position.X, AP_YUKSEKLIK, karanlik.Position.Z))
        end
    end
    local sonAsama = normalAsama:FindFirstChild("TheEnd")
    local sandik   = sonAsama and sonAsama:FindFirstChild("GoldenChest")
    if sandik then
        table.insert(wps, sandik:GetPivot().Position + Vector3.new(0, 10, -10))
    end
    return #wps > 0 and wps or nil
end

local function waypointFizikEkle(parca)
    local eskiler = { parca:FindFirstChild("AP_BV"), parca:FindFirstChild("AP_BG") }
    for _, o in ipairs(eskiler) do if o then o:Destroy() end end
    apBV = Instance.new("BodyVelocity"); apBV.Name = "AP_BV"
    apBV.MaxForce = Vector3.new(9e9,9e9,9e9); apBV.Velocity = Vector3.zero
    apBV.Parent = parca
    apBG = Instance.new("BodyGyro"); apBG.Name = "AP_BG"
    apBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
    apBG.P = 3000; apBG.D = 300; apBG.CFrame = parca.CFrame
    apBG.Parent = parca
end

local function wpPilotDurdur()
    wpPilotAktif = false
    if wpPilotBaglanti then wpPilotBaglanti:Disconnect(); wpPilotBaglanti = nil end
    if apBV and apBV.Parent then apBV:Destroy() end
    if apBG and apBG.Parent then apBG:Destroy() end
    apBV = nil; apBG = nil
    bildir("Waypoint Pilotu", "Durduruldu — atlayın ve sandığı alın!", 6, "uçak")
end

local function wpPilotBaslat()
    local araba = oyuncuZonuGetir(oyuncu)
    if not araba then bildir("Waypoint Pilotu", "Önce bir araca oturun!", 5, "uyarı üçgeni"); wpPilotAktif = false; return end
    local parca = araba.PrimaryPart or araba:FindFirstChildWhichIsA("BasePart")
    if not parca then bildir("Waypoint Pilotu", "Aracın Birincil Parçası Yok.", 5, "uyarı üçgeni"); wpPilotAktif = false; return end
    local wps = hedefNoktalarıOlustur()
    if not wps then bildir("Waypoint Pilotu", "Aşamalar bulunamadı. Teknenizi suya indirin!", 8, "uyarı üçgeni"); wpPilotAktif = false; return end
    waypointFizikEkle(parca)
    wpPilotAktif = true
    local noktaIndeksi = 1
    bildir("Waypoint Pilotu", "Devrede — " .. #wps .. " yol noktasından uçuyor.", 5, "uçak")
    wpPilotBaglanti = RunServis.RenderStepped:Connect(function()
        if not wpPilotAktif then return end
        araba = oyuncuZonuGetir(oyuncu)
        if not araba or not araba.PrimaryPart then wpPilotDurdur(); return end
        parca = araba.PrimaryPart or araba:FindFirstChildWhichIsA("BasePart")
        if not apBV or not apBV.Parent then waypointFizikEkle(parca) end
        local konum = parca.Position
        local hedef = wps[noktaIndeksi]
        local hedefKonum = Vector3.new(hedef.X, AP_YUKSEKLIK, hedef.Z)
        local duzMesafe = Vector3.new(hedefKonum.X - konum.X, 0, hedefKonum.Z - konum.Z).Magnitude
        local sonMu     = noktaIndeksi == #wps
        local yariçap   = sonMu and AP_VARIS_YARIÇAPI or AP_NOKTA_YARIÇAPI
        if duzMesafe < yariçap then
            if sonMu then wpPilotDurdur(); return end
            noktaIndeksi += 1
            hedef      = wps[noktaIndeksi]
            hedefKonum = Vector3.new(hedef.X, AP_YUKSEKLIK, hedef.Z)
        end
        local yon      = (hedefKonum - konum)
        local dirNorm  = yon.Magnitude > 0 and yon.Unit or Vector3.new(0,0,-1)
        local yYuksek  = AP_YUKSEKLIK - konum.Y
        local yDuzelt  = Vector3.new(0, math.clamp(yYuksek * AP_DIKEY_GÜCÜ, -AP_HIZ * 0.5, AP_HIZ * 0.5), 0)
        local duz      = Vector3.new(dirNorm.X, 0, dirNorm.Z)
        apBV.Velocity  = duz * AP_HIZ + yDuzelt
        if duz.Magnitude > 0.01 then
            local perde    = math.clamp(yYuksek * 0.01, -0.3, 0.3)
            local bak      = Vector3.new(duz.X, perde, duz.Z).Unit
            apBG.CFrame = CFrame.new(konum, konum + bak)
        end
    end)
end

-- ================================================================
-- DÜZ OTOMATİK PİLOT
-- ================================================================

local function duzPilotDurdur()
    duzPilotAktif = false
    if duzPilotBaglanti then duzPilotBaglanti:Disconnect(); duzPilotBaglanti = nil end
    if duzAPBV and duzAPBV.Parent then duzAPBV:Destroy() end
    if duzAPBG and duzAPBG.Parent then duzAPBG:Destroy() end
    duzAPBV = nil; duzAPBG = nil; duzAPParcasi = nil
    bildir("Düz Pilot", "Durduruldu — uçak durdu.", 4, "uçak")
end

local function duzPilotBaslat()
    if wpPilotAktif then
        bildir("Düz Pilot", "Önce Waypoint Otomatik Pilotunu Durdurun!", 5, "uyarı üçgeni")
        duzPilotAktif = false; return
    end
    local koltuk = insani.SeatPart
    if not koltuk then bildir("Düz Pilot", "Önce bir araca oturun!", 5, "uyarı üçgeni"); duzPilotAktif = false; return end
    local araba = koltuk.Parent
    local parca = (araba and araba:FindFirstChildWhichIsA("BasePart")) or koltuk
    -- eski fizik temizle
    local eskiBV = parca:FindFirstChild("StraightAP_BV")
    local eskiBG = parca:FindFirstChild("StraightAP_BG")
    if eskiBV then eskiBV:Destroy() end
    if eskiBG then eskiBG:Destroy() end
    local kilitli = parca.CFrame
    duzAPBG = Instance.new("BodyGyro"); duzAPBG.Name = "StraightAP_BG"
    duzAPBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
    duzAPBG.P = 3000; duzAPBG.D = 250; duzAPBG.CFrame = kilitli
    duzAPBG.Parent = parca
    duzAPBV = Instance.new("BodyVelocity"); duzAPBV.Name = "StraightAP_BV"
    duzAPBV.MaxForce = Vector3.new(9e9,9e9,9e9)
    duzAPBV.Velocity  = kilitli.LookVector * DUZ_AP_HIZ
    duzAPBV.Parent = parca
    duzAPParcasi = parca
    duzPilotAktif  = true
    bildir("Düz Pilot", "Düz Otomatik Pilot Hızı " .. DUZ_AP_HIZ .. " stud/s hızında devreye girdi — yerinizden kalkabilirsiniz!", 5, "uçak")
    duzPilotBaglanti = RunServis.Heartbeat:Connect(function()
        if not duzPilotAktif then return end
        if not duzAPParcasi or not duzAPParcasi.Parent then duzPilotDurdur(); return end
        if duzAPBV and duzAPBV.Parent then
            duzAPBV.Velocity = duzAPParcasi.CFrame.LookVector * DUZ_AP_HIZ
        end
        if duzAPBG and duzAPBG.Parent then
            duzAPBG.Velocity = duzAPParcasi.CFrame.LookVector * DUZ_AP_HIZ
        end
    end)
end

-- ================================================================
-- ARABA UÇUŞ SİSTEMİ
-- ================================================================

local kamera   = CalismaAlani.CurrentCamera
local ctrlTuslari = { f = 0, b = 0, l = 0, r = 0 }

local girisBasladi = KullaniciGirisi.InputBegan:Connect(function(inp, islendi)
    if islendi then return end
    if inp.KeyCode == Enum.KeyCode.W then ctrlTuslari.f = 1 end
    if inp.KeyCode == Enum.KeyCode.S then ctrlTuslari.b = -1 end
    if inp.KeyCode == Enum.KeyCode.A then ctrlTuslari.l = -1 end
    if inp.KeyCode == Enum.KeyCode.D then ctrlTuslari.r = 1 end
end)

local girisHiMeledi = KullaniciGirisi.InputEnded:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.W then ctrlTuslari.f = 0 end
    if inp.KeyCode == Enum.KeyCode.S then ctrlTuslari.b = 0 end
    if inp.KeyCode == Enum.KeyCode.A then ctrlTuslari.l = 0 end
    if inp.KeyCode == Enum.KeyCode.D then ctrlTuslari.r = 0 end
end)

local function arabauçusTemizle()
    arabaucus = false
    if arabaBV and arabaBV.Parent then arabaBV:Destroy() end
    if arabaucusBaglanti then arabaucusBaglanti:Disconnect(); arabaucusBaglanti = nil end
    arabaBV = nil
end

local function arabauçusBaslat()
    if wpPilotAktif or duzPilotAktif then
        bildir("Araba Uçuşu", "Araba Uçuşu'nı kullanmadan önce tüm otomatik pilotları durdurun.", 4, "uyarı üçgeni")
        arabaucus = false; return
    end
    local araba = oyuncuZonuGetir(oyuncu)
    if not araba then arabaucus = false; return end
    local parca = araba.PrimaryPart or araba:FindFirstChildWhichIsA("BasePart")
    if not parca then arabaucus = false; return end
    if arabaBV and arabaBV.Parent then arabaBV:Destroy() end
    arabaBV = Instance.new("BodyVelocity"); arabaBV.Name = "FlyBV"
    arabaBV.MaxForce = Vector3.new(9e9,9e9,9e9); arabaBV.Velocity = Vector3.zero
    arabaBV.Parent = parca
    arabaucusBaglanti = RunServis.RenderStepped:Connect(function()
        if not arabaucus then arabauçusTemizle(); return end
        if not arabaBV or not arabaBV.Parent then arabaBV = Instance.new("BodyVelocity"); arabaBV.Name = "FlyBV"; arabaBV.MaxForce = Vector3.new(9e9,9e9,9e9); arabaBV.Parent = parca end
        local hareket = (kamera.CFrame.LookVector * (ctrlTuslari.f + ctrlTuslari.b))
                      + (kamera.CFrame.RightVector * ctrlTuslari.r)
        arabaBV.Velocity = hareket.Magnitude > 0 and hareket.Unit * arabaucusHiz or Vector3.zero
        parca.CFrame = CFrame.new(parca.Position, parca.Position + kamera.CFrame.LookVector)
    end)
    bildir("Araba Uçuşu", "Uçuş aktif! WASD ile yönlendir.", 4, "uçak")
end

-- ================================================================
-- OTOMATİK ÇİFTLİK (AUTO FARM)
-- ================================================================

task.spawn(function()
    while true do
        task.wait()
        if not otomatikCiftlik or not HRP then continue end
        if asamaIndeksi == 11 then
            -- Turun sonunda sandık bekle
            local sonAsama = CalismaAlani:FindFirstChild("BoatStages")
                         and CalismaAlani.BoatStages:FindFirstChild("NormalStages")
                         and CalismaAlani.BoatStages.NormalStages:FindFirstChild("TheEnd")
            local sandik   = sonAsama and sonAsama:FindFirstChild("GoldenChest")
            if not sandik then continue end
            HRP:PivotTo(sandik:GetPivot() + Vector3.new(0, 0, -10))
            local sayac = 0
            repeat task.wait(1); sayac += 1
                if sayac % 20 == 0 then HRP:PivotTo(sandik:GetPivot() + Vector3.new(0, 0, -10)) end
            until (HRP.Position - sandik:GetPivot().Position).Magnitude > 500
            asamaIndeksi = 1
        else
            local normalAsamalar = CalismaAlani:FindFirstChild("BoatStages")
                               and CalismaAlani.BoatStages:FindFirstChild("NormalStages")
            if not normalAsamalar then continue end
            local asama    = normalAsamalar:FindFirstChild("MağaraAşaması" .. asamaIndeksi)
            local karanlik = asama and asama:FindFirstChild("DarknessPart")
            if not karanlik then asamaIndeksi += 1; continue end
            karakter:PivotTo(karanlik.CFrame - Vector3.new(0, 0, 15))
            local animasyon = TweenServis:Create(HRP,
                TweenInfo.new(2, Enum.EasingStyle.Linear),
                { CFrame = karanlik.CFrame + Vector3.new(0, 0, 20) }
            )
            arageciş = true
            animasyon:Play(); animasyon.Completed:Wait()
            arageciş = false
            asamaIndeksi += 1
        end
    end
end)

-- ================================================================
-- KALP ATIŞI — ara geçişte HRP'yi sıfırla
-- ================================================================

RunServis.Heartbeat:Connect(function()
    if arageciş and HRP then
        HRP.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- ================================================================
-- KARAKTER YENİDEN DOĞMA
-- ================================================================

oyuncu.CharacterAdded:Connect(function(yeniKarakter)
    karakter = yeniKarakter
    HRP      = yeniKarakter:WaitForChild("HumanoidRootPart")
    insani   = yeniKarakter:WaitForChild("Humanoid")
    if wpPilotAktif   then wpPilotDurdur()  end
    if duzPilotAktif  then duzPilotDurdur() end
end)

-- ================================================================
-- AFK KARŞITI
-- ================================================================

task.spawn(function()
    while task.wait(100) do
        VIM:SendKeyEvent(true,  Enum.KeyCode.Tilde, false, nil)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.Tilde, false, nil)
    end
end)

-- ================================================================
-- RAYFIELD UI — SEKMELER VE KONTROLLER
-- ================================================================

-- ── SEKME: ANA ──────────────────────────────────────────────────
local anaSekme = Pencere:CreateTab("Ana", "ev")

anaSekme:CreateSection("Hakkında")
anaSekme:CreateParagraph({
    Title   = "worlde131 Script",
    Content = "Bu script worlde131 tarafından yazılmıştır.\nTüm özellikler Build A Boat For Treasure için sıfırdan geliştirilmiştir.",
})

anaSekme:CreateSection("Topluluk")
anaSekme:CreateParagraph({
    Title   = "Discord Sunucusu",
    Content = "Güncellemeler, destek ve daha fazla komut dosyası için Discord'a katılın.",
})

-- ── SEKME: BİNA ─────────────────────────────────────────────────
local binaSekmesi = Pencere:CreateTab("Bina", "çekiç")

local seciliOyuncuBaz = nil

binaSekmesi:CreateDropdown({
    Name             = "Kopyalanacak Oyuncu Tabanını Seç",
    Options          = oyuncuListesiGetir(),
    CurrentOption    = {"Hiçbiri Seçilmedi"},
    MultipleOptions  = false,
    Callback         = function(secenekler)
        local gercekAd = gercekAdGetir(secenekler[1])
        if not gercekAd then return end
        for _, klasor in pairs(blokKlasoru:GetChildren()) do
            if klasor.Name == gercekAd then seciliOyuncuBaz = klasor end
        end
    end,
})

Oyuncular.PlayerAdded:Connect(function()
    -- Dropdown güncelleme Rayfield'da manuel tetiklenir
end)

binaSekmesi:CreateButton({
    Name     = "Temel Kopyala",
    Callback = function()
        if not seciliOyuncuBaz then bildir("Kopyala", "Lütfen önce geçerli bir oyuncu seçin.", 5, "uyarı üçgeni"); return end
        pano = baseyiKopyala(seciliOyuncuBaz)
        bildir("Kopyala", "Base başarıyla kopyalandı!", 4, "onay")
    end,
})

binaSekmesi:CreateButton({
    Name     = "Yapıştırma Tabanı",
    Callback = function()
        if not pano then bildir("Yapıştır", "Henüz hiçbir şey kopyalanmadı — önce bir temel kopyalayın.", 5, "uyarı üçgeni"); return end
        baseYapistir(pano, oyuncuZonuGetir)
    end,
})

local yapiYuzdeGostergesi = binaSekmesi:CreateParagraph({ Title = "Yapıştırma İlerlemesi", Content = "Boşta" })

task.spawn(function()
    while task.wait(0.2) do
        local gosterge = yapistirYuzde > 0 and (yapistirYuzde .. "%") or "Boşta"
        yapiYuzdeGostergesi:Set({ Title = "Yapıştırma İlerlemesi", Content = gosterge })
    end
end)

binaSekmesi:CreateSection("Ayarlar")
binaSekmesi:CreateToggle({
    Name         = "Bağlı Durumu Yoksay",
    CurrentValue = true,
    Callback     = function(deger) anchorIgnore = deger end,
})

-- ── SEKME: OTOMATİK ÇİFTLİK ────────────────────────────────────
local ciftlikSekmesi = Pencere:CreateTab("Otomatik Çiftlik", "filiz")

ciftlikSekmesi:CreateParagraph({
    Title   = "Auto Farm Nasıl Çalışır",
    Content = "Karakterinizi sırayla her Mağara Aşaması'ndan geçirir, ardından tur sıfırlanana kadar Altın Sandık'ta bekler.",
})

ciftlikSekmesi:CreateToggle({
    Name         = "Otomatik Çiftliği Etkinleştir",
    CurrentValue = false,
    Callback     = function(deger) otomatikCiftlik = deger end,
})

-- ── SEKME: UÇAK AYARLARI ────────────────────────────────────────
local ucakSekmesi = Pencere:CreateTab("Uçak Ayarları", "uçak")

ucakSekmesi:CreateSection("Yol Noktası Otomatik Pilotu")

ucakSekmesi:CreateParagraph({
    Title   = "Kullanım",
    Content = "1) Uçağınıza oturun.\n2) Teknenin fırlatıldığından ve aşamaların görünür olduğundan emin olun.\n3) Etkinleştirin — uçak her aşama kapısından geçerek sandığa doğru kendi kendine uçacaktır.",
})

ucakSekmesi:CreateToggle({
    Name         = "Yol Noktası Otomatik Pilotunu Etkinleştir",
    CurrentValue = false,
    Callback     = function(deger)
        wpPilotAktif = deger
        if deger then wpPilotBaslat() else wpPilotDurdur() end
    end,
})

ucakSekmesi:CreateButton({
    Name     = "Acil Durdurma",
    Callback = wpPilotDurdur,
})

ucakSekmesi:CreateSection("Ayar")

ucakSekmesi:CreateSlider({
    Name         = "Seyir Hızı",
    Range        = {30, 300},
    Increment    = 10,
    CurrentValue = AP_HIZ,
    Suffix       = " saplama/lar",
    Callback     = function(deger) AP_HIZ = deger end,
})

ucakSekmesi:CreateSlider({
    Name         = "Seyir İrtifası",
    Range        = {30, 200},
    Increment    = 5,
    CurrentValue = AP_YUKSEKLIK,
    Suffix       = "çiviler",
    Callback     = function(deger) AP_YUKSEKLIK = deger end,
})

ucakSekmesi:CreateSlider({
    Name         = "Ara Nokta Varış Yarıçapı",
    Range        = {20, 150},
    Increment    = 5,
    CurrentValue = AP_NOKTA_YARIÇAPI,
    Suffix       = "çiviler",
    Callback     = function(deger) AP_NOKTA_YARIÇAPI = deger end,
})

-- ── SEKME: EĞLENCE ──────────────────────────────────────────────
local eglenceSekmesi = Pencere:CreateTab("Eğlence", "şimşek")

-- Düz Otomatik Pilot
eglenceSekmesi:CreateSection("Düz Otomatik Pilot (Yürünebilir)")

eglenceSekmesi:CreateParagraph({
    Title   = "Kullanım",
    Content = "Uçağınıza oturun, hızınızı ayarlayın, ardından düğmeyi açın. Uçak yönünü kilitler ve düz bir şekilde uçmaya devam eder; siz hareket halindeyken çatıda durabilirsiniz.",
})

eglenceSekmesi:CreateSlider({
    Name         = "Uçuş Hızı",
    Range        = {20, 200},
    Increment    = 5,
    CurrentValue = DUZ_AP_HIZ,
    Suffix       = " saplama/lar",
    Callback     = function(deger) DUZ_AP_HIZ = deger end,
})

eglenceSekmesi:CreateToggle({
    Name         = "Doğrudan Otomatik Pilotu Etkinleştir",
    CurrentValue = false,
    Callback     = function(deger)
        duzPilotAktif = deger
        if deger then duzPilotBaslat() else duzPilotDurdur() end
    end,
})

eglenceSekmesi:CreateButton({
    Name     = "Acil Durdurma",
    Callback = duzPilotDurdur,
})

-- Araba Uçuşu
eglenceSekmesi:CreateSection("Araba Uçuşu")

eglenceSekmesi:CreateButton({
    Name     = "Araba Uçuşunu Aç/Kapat",
    Callback = function()
        if wpPilotAktif or duzPilotAktif then
            bildir("Araba Uçuşu", "Araba Uçuşu'nı kullanmadan önce tüm otomatik pilotları durdurun.", 4, "uyarı üçgeni")
            return
        end
        arabaucus = not arabaucus
        if arabaucus then
            arabauçusBaslat()
        else
            arabauçusTemizle()
            bildir("Araba Uçuşu", "Araba uçuşu kapatıldı.", 3, "bilgi")
        end
    end,
})

eglenceSekmesi:CreateSlider({
    Name         = "Araba Uçuş Hızı",
    Range        = {10, 200},
    Increment    = 5,
    CurrentValue = arabaucusHiz,
    Suffix       = " saplama/lar",
    Callback     = function(deger) arabaucusHiz = deger end,
})

-- ================================================================
-- KAYDEDILMIŞ YAPILANDIRMAYI YÜKLE
-- ================================================================

Rayfield:LoadConfiguration()
