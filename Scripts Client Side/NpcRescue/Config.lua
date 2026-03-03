return {
NPC_RESCUE_ITEM_SWITCH = 1,
NPC_RESCUE_PACKET = 2,
NPC_RESCUE_PACKET_NAME_GET = 'NPC_RESCUE_ITEM_GET',
NPC_RESCUE_PACKET_GET_ITEM_RECV = 'NPC_RESCUE_GET_ITEM_RECV',

NpcRescueVisible = 0,

--Box item
 NpcRescueSelectedItem = 0,
 NpcRescueSelectedItemPosY = 0,
 NpcRescueSelectedItemClicked = 0,
 NpcRescueSelectedItemClickedPosY = 0,
 NpcRescueSelectedItemKey = -1,
 NpcRescueItemCount = 0,
--Scroll Bar
 NpcRescueScrollBarPosY = 0,
 NpcRescueScrollBarPosMouse = 0,
 NpcRescueScrollBarPosYMultiplier = 0,
 NpcRescueScrollBarCurrentLine = 0,
 NpcRescueScrollBarRenderMaxLines = 0,
 NpcRescueScrollBarRenderPageMax = 0,
 NpcRescueScrollMaxLine = 0,
 NpcRescueScrollBarMaxLines = 8,
 x = 0,
 y = 0,


MESSAGES = {
[1] = { 
    ["Por"] =  'Npc Resgate Item', 
    ["Eng"] = 'Npc Rescue Item',
    ["Spn"] = 'Objeto de rescate de Npc' },
[2] = { 
        ["Por"] =  'Disponível até:', 
        ["Eng"] = 'Available until:',
        ["Spn"] = 'Disponible hasta:' },
        [3] = { 
            ["Por"] =  'Pré vizualização do item:', 
            ["Eng"] = 'Item preview:',
            ["Spn"] = 'Vista previa del artículo:' },
            [4] = { 
                ["Por"] = 'Lista de Itens',
                ["Eng"] = 'List of Items',
                ["Spn"] = 'Lista de elementos' },    
                [5] = { 
                    ["Por"] = 'No momento você não tem itens!',
                    ["Eng"] = 'You currently have no items!',
                    ["Spn"] = '¡Actualmente no tienes artículos!' },
                    [6] = { 
                        ["Por"] = 'Resgatar Item',
                        ["Eng"] = 'Redeem Item',
                        ["Spn"] = 'Canjear artículo' },
                                    
    
},

}