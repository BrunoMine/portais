--
-- Nodes
--

-- Calculando valores
-- Lugares
local string_de_lugares = ""
local id_lugares = {}

-- Fosmpec padrao
local formspec_p = ""

-- Atualizar lista de vilas
local atualizar_lista = function()
	if gestor then
		-- Pegar lugares do gestor
		if gestor then
			string_de_lugares = ""
			lista_de_pos = {}
			-- Minemacro
			string_de_lugares = string_de_lugares .. "Minemacro"
			table.insert(id_lugares, {nome="Minemacro",pos=gestor.bd:pegar("centro", "pos")})
			-- Vilas
			for _,vila in ipairs(minetest.get_dir_list(minetest.get_worldpath().."/gestor/vilas")) do
				local dados = gestor.bd:pegar("vilas", vila)
				string_de_lugares = string_de_lugares .. "," .. dados.nome
				table.insert(id_lugares, {nome=dados.nome,pos=dados.pos})
			end
			-- Atualiza formspec
			formspec_p = "size[6,5]"
				..default.gui_bg
				..default.gui_bg_img
				.."label[1,0.25;Escolha seu destino]"
				.."textlist[0.5,1;4.8,3;vila;"..string_de_lugares.."]"
		end
	end
end
atualizar_lista()

-- Exibir Formspec

local exibir_formspec = function(name, escolha)
	if escolha then
		minetest.show_formspec(name, "portais:bilheteria", formspec_p.."button_exit[0.5,4;5,1;viajar;Viajar]")
	else
		minetest.show_formspec(name, "portais:bilheteria", formspec_p)
	end
end

-- Bilheteria
minetest.register_node("portais:bilheteria", {
	description = "Bilheteria",
	tiles = {
		"default_wood.png", -- Cima
		"default_wood.png", -- Baixo
		"default_wood.png^portais_bilheteria.png", -- Lado direito
		"default_wood.png^portais_bilheteria.png", -- Lado esquerda
		"default_wood.png^portais_bilheteria.png", -- Fundo
		"default_wood.png^portais_bilheteria.png" -- Frente
	},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Bilheteria")
	end,
	on_rightclick = function(pos, node, player)
		exibir_formspec(player:get_player_name())
	end,
})

-- Receptor de campos
local escolha = {}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "portais:bilheteria" then
		if fields.vila then
			local name = player:get_player_name()
			local n = string.split(fields.vila, ":")
			escolha[name] = n[2]
			exibir_formspec(name, n[2])
		end
		if fields.viajar then
			local name = player:get_player_name()
			local id = tonumber(escolha[name])
			player:setpos(id_lugares[id].pos)
			minetest.chat_send_player(name, "Bem vindo a "..id_lugares[id].nome)
		end
	end
end)
