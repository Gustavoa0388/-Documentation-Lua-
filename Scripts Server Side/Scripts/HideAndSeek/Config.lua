-- ==========================================================
-- HideAndSeek (Esconde-Esconde) - CONFIG (Season 6 Louis)
-- ==========================================================
-- Este arquivo só retorna uma tabela de configuração.
-- O script principal carrega via:
--   local CONFIG = require("Scripts\\HideAndSeek\\Config")
--
-- IMPORTANTE:
-- - Os exemplos de GET_ITEM abaixo são ilustrativos. Ajuste para seu server.
-- - Use /classid in-game para descobrir o ID da classe (GetObjectClass).
-- ==========================================================

local Config = {
	-- Liga / Desliga geral do script
	Active = true,

	-- Command base (compatibilidade antiga)
	Command = "/hh",

	-- ======================================================
	-- STAFF / GM / ADMIN (WHITELIST MANUAL)
	-- ======================================================
	Staff = {
		Enabled = true,
		CaseInsensitive = true,

		CharNames = {
			"Admin",
			"GUDM",
			"BK01",
			"SM01",
			"ELF01",
			"MG01",
			"DL01",
			"SUM01",
			"RF01",
		},

		Accounts = {
			--"gustavo",
			--"admin",
		},

		OnlyAdmin = false,
		AdminCharNames = {
			-- "Admin",
		},
	},

	-- ======================================================
	-- AUTO SCHEDULE (vários horários + por dia da semana)
	-- ======================================================
	AutoSchedule = {
		Enabled = true,

		-- Opção A (mais avançada): horários por dia da semana
		-- 0=Domingo .. 6=Sábado
		ByDayOfWeek = {
			-- Segunda
			[1] = {
				{ Hour = 8, Minute = 0 },
				{ Hour = 10, Minute = 0 },
				{ Hour = 12, Minute = 0 },
				{ Hour = 14, Minute = 0 },
				{ Hour = 16, Minute = 0 },
			},

			-- Terça
			[2] = {
				{ Hour = 7, Minute = 0 },
				{ Hour = 9, Minute = 0 },
				{ Hour = 11, Minute = 0 },
				{ Hour = 13, Minute = 0 },
				{ Hour = 15, Minute = 0 },
			},

			-- Quarta
			[3] = {
				{ Hour = 17, Minute = 0 },
				{ Hour = 18, Minute = 0 },
				{ Hour = 19, Minute = 0 },
				{ Hour = 20, Minute = 0 },
			},
		},

		-- Opção B (fallback): horários todo dia
		-- Se ByDayOfWeek estiver vazio/nil, usa Times.
		Times = {
			{ Hour = 20, Minute = 0 },
		},
	},

	PreStartSeconds = 10,
	DurationSeconds = 300,

	-- NPC to find
	NpcClass = 240,
	NpcDir = 0,

	-- Spawn validation using MapCheckAttr
	SpawnFind = {
		Enabled = true,
		MaxTriesPerPoint = 200,
		MaxPointSwaps = 50,
		BlockedAttrs = { 1, 2, 4, 8, 16, 32, 64, 128, 256 },
	},

	-- Where NPC can spawn
	SpawnPoints = {
		{ map = 0, minX = 50, minY = 50, maxX = 200, maxY = 200, name = "Lorencia" },
		{ map = 3, minX = 50, minY = 50, maxX = 200, maxY = 200, name = "Noria" },
	},

	-- Announcements
	PreStartAnnouncements = { 60, 30, 10, 5, 3, 1 },
	RunningAnnouncements = { 180, 120, 60, 30, 10 },

	-- Hints
	Hints = {
		Enabled = true,
		StartAfterSeconds = 60,
		IntervalSeconds = 60,
		Masks = {
			{ x = "XXX", y = "XXX" }, -- map only
			{ x = "XX#", y = "XXX" },
			{ x = "XX#", y = "XX#" },
			{ x = "X##", y = "XX#" },
			{ x = "X##", y = "X##" },
			{ x = "###", y = "X##" }, -- most precise
		},
	},

	-- Fireworks (Louis)
	WinFireworks = {
		Enabled = true,
		Radius = 1,
		Count = 6,
		Spiral = {
			Enabled = false,
			Ticks = 1,
			Step = 1,
		},
	},

	-- ======================================================
	-- DELIVERY (Inventário ou Gremory)
	-- ======================================================
	Delivery = {
		PreferInventory = true,   -- tenta inventário primeiro
		FallbackToGremory = true, -- se não couber, manda pro Gremory
		DefaultDeliver = "gremory", -- se PreferInventory=false, usa isso

		GremoryType = 1,
		GremoryNumber = 10,
	},

	-- ======================================================
	-- REWARDS (flexível)
	-- ======================================================
	-- Tipos suportados:
	-- - zen, coin, buff, item, items
	-- - kit                 (kit genérico por "conteúdo")
	-- - classkit            (kit por classe)
	--
	-- Exemplo: premiar kit por classe (set+arma+asa+pet em uma linha)
	Rewards = {
		{ type = "coin", coin1 = 0, coin2 = 0, coin3 = 100 },
		{ type = "zen", amount = 10000000 },

		-- Kit por classe (o conteúdo vem de ClassKits.ByClassId)
		{ type = "classkit", kit = "default" },
	},

	-- ======================================================
	-- CLASS KITS (a parte flexível que você quer vender)
	-- ======================================================
	-- Como usar:
	-- - Rewards: { type="classkit", kit="default" }
	-- - Aqui você define o kit "default", e dentro dele define o que cada classe recebe.
	--
	-- Você pode criar múltiplos kits:
	--   kits = { "default", "pvp", "vip", "noob" ... }
	-- e trocar no reward.
	--
	-- Dentro de cada classe, você pode ligar/desligar módulos:
	--   setFull, weapons, shield, wings, pet, extras
	--
	ClassKits = {
		-- Defaults gerais de item (aplica nos itens do kit, pode sobrescrever em cada item)
		ItemDefaults = {
			level = 13,
			dur = 255,
			skill = 1,
			luck = 1,
			opt = 7,
			exc = 63,
			set = 0,
			jh = 0,
			exOpt = 0,
			socket = { 255, 255, 255, 255, 255 },
			socketBonus = 0,
			duration = 0,

			-- delivery
			deliver = "auto", -- "auto" respeita Delivery.PreferInventory. Ou "inventory"/"gremory"
			gremoryType = 1,
			gremoryNumber = 10,
			source = "[Esconde-Esconde]",
		},

		-- Lista de kits
		Kits = {
			default = {
				-- Por ClassID: você vai ajustar após usar /classid com cada classe.
				ByClassId = {
					-- EXEMPLOS (ajuste ClassID e GET_ITEM pro seu server)

					-- Dark Wizard (ex: 0)
					[0] = {
						setFull = {
							name = "Legendary",
							pieces = {
								GET_ITEM(7, 24),  -- helm
								GET_ITEM(8, 24),  -- armor
								GET_ITEM(9, 24),  -- pants
								GET_ITEM(10, 24), -- gloves
								GET_ITEM(11, 24), -- boots
							},
						},
						weapons = {
							-- pode ser 1 arma, 2 armas, etc.
							items = {
								GET_ITEM(5, 0), -- staff exemplo
							},
						},
						shield = nil,
						wings = { item = GET_ITEM(12, 3) }, -- asa 1st exemplo
						pet = { item = GET_ITEM(13, 64) },  -- pet exemplo
						extras = {
							-- extras é lista de itens
							{ index = GET_ITEM(14, 13), level = 0, dur = 1 }, -- jewel exemplo
						},
					},

					-- Dark Knight (ex: 16)
					[16] = {
						setFull = {
							name = "Dragon",
							pieces = {
								GET_ITEM(7, 0),
								GET_ITEM(8, 0),
								GET_ITEM(9, 0),
								GET_ITEM(10, 0),
								GET_ITEM(11, 0),
							},
						},
						weapons = {
							items = {
								GET_ITEM(0, 0), -- sword exemplo
								-- GET_ITEM(0, 1), -- segunda arma (se quiser dual)
							},
						},
						shield = { item = GET_ITEM(6, 0) }, -- shield exemplo (ajuste)
						wings = { item = GET_ITEM(12, 2) },
						pet = { item = GET_ITEM(13, 64) },
					},

					-- Elf (ex: 32)
					[32] = {
						setFull = {
							name = "Guardian",
							pieces = {
								GET_ITEM(7, 3),
								GET_ITEM(8, 3),
								GET_ITEM(9, 3),
								GET_ITEM(10, 3),
								GET_ITEM(11, 3),
							},
						},
						weapons = {
							items = {
								GET_ITEM(4, 0), -- bow exemplo
							},
						},
						shield = nil,
						wings = { item = GET_ITEM(12, 4) },
						pet = { item = GET_ITEM(13, 64) },
					},

					-- Dark Lord (ex: 64)
					[64] = {
						setFull = {
							name = "Light Plate",
							pieces = {
								GET_ITEM(7, 30),
								GET_ITEM(8, 30),
								GET_ITEM(9, 30),
								GET_ITEM(10, 30),
								GET_ITEM(11, 30),
							},
						},
						weapons = {
							items = {
								GET_ITEM(2, 0), -- scepter exemplo
							},
						},
						shield = nil,
						wings = { item = GET_ITEM(12, 5) },
						pet = { item = GET_ITEM(13, 4) }, -- dark horse exemplo (ajuste)
					},

					-- Magic Gladiator (ex: 48)
					[48] = {
						setFull = {
							name = "Thunder Hawk",
							pieces = {
								GET_ITEM(7, 40),
								GET_ITEM(8, 40),
								GET_ITEM(9, 40),
								GET_ITEM(10, 40),
								GET_ITEM(11, 40),
							},
						},
						weapons = {
							items = {
								GET_ITEM(0, 5), -- sword exemplo
							},
						},
						shield = nil,
						wings = { item = GET_ITEM(12, 6) },
						pet = { item = GET_ITEM(13, 64) },
					},
				},
			},
		},
	},

	-- SQL tables
	SQL = {
		Enabled = true,
		HistoryTable = "lua_hideandseek_history",
		RankMonthlyTable = "lua_hideandseek_rank_monthly",
	},

	MonthlyRank = {
		Enabled = true,
		Hour = 23,
		Minute = 59,
		TopN = 3,

		RewardsByPlace = {
			[1] = {
				{ type = "coin", coin1 = 30, coin2 = 30, coin3 = 30 },
				{ type = "item", index = GET_ITEM(14, 13), level = 0, dur = 1, deliver = "gremory", gremoryType = 1, gremoryNumber = 12, source = "[Rank Mensal Esc-Esc]" },
			},
			[2] = {
				{ type = "coin", coin1 = 20, coin2 = 20, coin3 = 20 },
				{ type = "item", index = GET_ITEM(14, 13), level = 0, dur = 1, deliver = "gremory", gremoryType = 1, gremoryNumber = 12, source = "[Rank Mensal Esc-Esc]" },
			},
			[3] = {
				{ type = "coin", coin1 = 10, coin2 = 10, coin3 = 10 },
				{ type = "item", index = GET_ITEM(14, 13), level = 0, dur = 1, deliver = "gremory", gremoryType = 1, gremoryNumber = 12, source = "[Rank Mensal Esc-Esc]" },
			},
		},
	},

	Log = {
		Enabled = true,
		Level = 3,
	},
}

return Config