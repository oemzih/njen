-- example.lua
-- Contoh file yang memuat framework dari raw GitHub via loadstring
-- Ganti RAW_FRAMEWORK_URL dengan link raw GitHub Anda (contoh: https://raw.githubusercontent.com/username/repo/branch/framework.lua)

local RAW_FRAMEWORK_URL = "https://raw.githubusercontent.com/USERNAME/REPO/BRANCH/framework.lua" -- <- ganti

local ok, framework = pcall(function()
    return loadstring(game:HttpGet(RAW_FRAMEWORK_URL))()
end)

if not ok or not framework then
    warn("Gagal memuat framework dari:", RAW_FRAMEWORK_URL)
    return
end

-- override bcrypt check jika executor Anda mendukung (contoh placeholder)
-- framework.BcryptCheck = function(input, hash)
--     -- panggil binding bcrypt asli di executor Anda
--     return some_bcrypt_check_function(input, hash)
-- end

local KeySettings = {
    Key = "myPlainKey123", -- jika ingin plain
    Type = "plain",
    Encryption = "" -- jika pakai bcrypt, isi 'bcrypt' dan override BcryptCheck
}

local window = framework.CreateWindow({
    KeySettings = KeySettings,
    GetKeyLink = "https://example.com/getkey",
    Whitelisted = {12345678},
    Theme = {
        Text = "00ff00",
        Border = "00ff00",
        Background = "000000"
    },
    Text = {
        Title = "Key System",
        Body = "Enter the key to access the contents of the script.",
        Fail = "Access denied",
        Pass = "Access granted"
    }
})

window.Failed(function()
    print("Wrong key")
end)

window.Passed(function()
    print("Correct key — running main script...")
    -- Setelah validasi berhasil, jalankan loadstring tambahan dari repo yang Anda minta
    pcall(function()
        local ok2, res = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"))()
        end)
        if not ok2 then
            warn("Gagal memuat evkey.lua dari remote:", res)
        end
    end)
