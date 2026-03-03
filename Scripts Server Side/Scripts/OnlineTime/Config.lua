return {
	Enable = 0,
	Command = "/horas",
	Timer = 60,
    Debug = 0,
	MESSAGES = {
    [1] = { ["Por"] = "[Sistema] Você possui %d minutos jogados no beta.",
            ["Eng"] = "[System] You have played %d minutes in the beta.",
            ["Spn"] = "[Sistema] Has jugado %d minutos en la beta.",
    },
	[2] = { ["Por"] = "[Sistema] Você possui %.2f horas jogadas no beta.",
            ["Eng"] = "[System] You have played %.2f hours in the beta.",
            ["Spn"] = "[Sistema] Has jugado %.2f horas en la beta.",
		},
    [3] = { ["Por"] = "[Sistema] Você possui %.2f Dias jogadas no beta.",
            ["Eng"] = "[System] You have played %.2f Days in the beta.",
            ["Spn"] = "[Sistema] Has jugado %.2f Dias en la beta.",
    },
}
}