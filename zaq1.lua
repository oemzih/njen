-- key.lua
-- Key generator + validator (format: ZAQUE-<RAND>-<ISSUE_TS>-<EXP_TS>)
-- DEFAULT: expirasi 24 jam (VALID_SECONDS = 86400)
-- NOTE: Untuk testing, ubah VALID_SECONDS sementara menjadi kecil (mis. 60)

local KeyGenerator = {}
KeyGenerator.__index = KeyGenerator

local PREFIX = "ZAQUE"
local RAND_MIN = 10000
local RAND_MAX = 99999
local VALID_SECONDS = 24 * 3600 -- ubah jadi 60 untuk testing 1 menit

local function randnum()
	math.randomseed(tick() + os.time() + (math.random() * 1000))
	return tostring(math.random(RAND_MIN, RAND_MAX))
end

-- Menghasilkan key: "ZAQUE-<RAND>-<ISSUE_TS>-<EXP_TS>"
function KeyGenerator:generate()
	local issue = os.time()
	local exp = issue + VALID_SECONDS
	local r = randnum()
	return string.format("%s-%s-%d-%d", PREFIX, r, issue, exp)
end

-- isValid: periksa format dan pastikan os.time() <= EXP_TS
function KeyGenerator:isValid(key)
	if type(key) ~= "string" then return false end
	-- pattern: PREFIX-RAND-ISSUE-EXP
	local pfx, rnd, issue_s, exp_s = string.match(key, "^([%w]+)%-(%d+)%-(%d+)%-(%d+)$")
	if not (pfx and rnd and issue_s and exp_s) then
		return false
	end
	if pfx ~= PREFIX then
		return false
	end
	local exp = tonumber(exp_s)
	if not exp then return false end
	-- jika sekarang <= exp -> valid
	if os.time() <= exp then
		return true
	end
	return false
end

-- util: ambil remaining seconds (nil jika invalid)
function KeyGenerator:remainingSeconds(key)
	if type(key) ~= "string" then return nil end
	local exp_s = string.match(key, "%-(%d+)$")
	if not exp_s then return nil end
	local exp = tonumber(exp_s)
	if not exp then return nil end
	return math.max(0, exp - os.time())
end

return KeyGenerator
