-- Inofficial MetalPortfolio Extension for MoneyMoney
-- Fetches Metal price via goldapi.io API
-- Returns metal prices as securities
--
-- Username: Metal symbol [XAU - Gold, XAG - Silver, XPT - Platinum, XPD - Palladium, DJI - Dow Jones ] comma seperated with number of shares in brackets (Example: "XAU(2),XAG(1.4)")
-- Password: goldapi API-Key

-- MIT License

-- Original work Copyright (c) 2017 Jacubeit
-- Modified work Copyright 2020 tobiasdueser
-- Modified work Copyright 2021 svenadolph

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking{
  version = 2.00,
  country = "de",
  description = "Include your metal portfolio in MoneyMoney by providing the metal symbols and amount as username [Example: XAU(2),XAG(1.4)] and a free goldapi API-Key as password.",
  services= { "MetalPortfolio" }
}

local symbols
local connection = Connection()
local currency = "EUR"
local token

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "MetalPortfolio"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  symbols = username:gsub("%s+", "")
  token = password
end

function ListAccounts (knownAccounts)
  local account = {
    name = "MetalPortfolio",
    accountNumber = "MetalPortfolio",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}

  for metal in string.gmatch(symbols, '([^,]+)') do

    -- Pattern: XAU(1),XAG(1.2)
    quantity=metal:match("%((%S+)%)")
    name=metal:match('([^(]+)')

    currentPrice = requestCurrentPrice(name)

    s[#s+1] = {
      name = name,
      currency = nil,
      quantity = quantity,
      price = currentPrice,
    }

  end

  return {securities = s}
end

function EndSession ()
end


-- Query Functions
function requestCurrentPrice(symbol)
  headers = {}
  headers["x-access-token"] = token

  response = connection:request("GET",
                                currentPriceRequestUrl(symbol),
                                nil,
                                nil,
                                headers
                              )
  json = JSON(response)
  return json:dictionary()["price_gram_24k"]
end

-- Helper Functions
function currentPriceRequestUrl(symbol)
  return "https://www.goldapi.io/api/" .. symbol .. "/" .. currency
end

-- SIGNATURE: MC0CFDvYWUZKqDy+/pnYH+s3kzsRwWJhAhUAkDGBmuLmh5CF16j/pekW9LM5y7Q=
