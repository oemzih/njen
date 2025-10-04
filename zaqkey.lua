-- key.lua
-- Module sederhana untuk generate + validasi key (format: ZAQUE-<RAND>-<TIMESTAMP>)
-- Upload file ini ke GitHub dan ambil raw URL-nya.

local KeyGenerator = {}
KeyGenerator.__index = KeyGenerator

-- Config (boleh diubah)
local PREFIX = "ZAQUE"          -- prefix key
local RAND_MIN = 10000
local RAND_MAX = 99999
local VALID_SECONDS = 24 * 3600 -- 24 jam

-- Helper: buat angka random string
local function randnum()
	math.randomseed(tick() + os.time() + (math.random() * 1000))
	return tostring(math.random(RAND_MIN, RAND_MAX))
end

-- Generate key: "ZAQUE-<RAND>-<TIMESTAMP>"
function KeyGenerator:generate()
	local t = tostring(os.time())
	local r = randnum()
	return PREFIX .. "-" .. r .. "-" .. t
end

-- Validasi pola dasar dan range waktu (24 jam)
-- Mengembalikan true jika format cocok dan timestamp belum melewati batas valid
function KeyGenerator:isValid(key)
	if type(key) ~= "string" then return false end
	-- Cari numeric timestamp di akhir string
	local ts = string.match(key, "(%d+)$")
	if not ts then return false end
	local num = tonumber(ts)
	if not num then return false end
	-- Pastikan prefix match (opsional ketat)
	if not string.match(key, "^" .. PREFIX .. "%-%d+%-%d+$") then
		return false
	end
	-- Cek waktu
	if num + VALID_SECONDS < os.time() then
		return false -- expired
	end
	-- valid
	return true
end

-- Kembalikan modul
return KeyGenerator
