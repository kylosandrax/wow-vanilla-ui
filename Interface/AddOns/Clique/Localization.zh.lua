--[[---------------------------------------------------------------------------------
    Localisation for zhCN
----------------------------------------------------------------------------------]]

local L = AceLibrary("AceLocale-2.0"):new("Clique")

L:RegisterTranslations("zhCN", function()
    return {
        RANK						= "等级",
        MANA_PATTERN                = "(%d+)法力值",
        HEALTH_PATTERN              = "(%d+)到(%d+)",
        
        ["Lesser Heal"]             = "次级治疗术",
        ["Heal"]                    = "治疗术",
        ["Greater Heal"]            = "强效治疗术",
        ["Flash Heal"]              = "快速治疗",
        ["Healing Touch"]           = "治疗之触",
        ["Regrowth"]                = "愈合",
        ["Healing Wave"]            = "治疗波",
        ["Lesser Healing Wave"]     = "次级治疗波",
        ["Holy Light"]              = "圣光术",
        ["Flash of Light"]          = "圣光闪现",

        DUAL_HOLY_SHOCK		        = "\231\165\158\229\156\163\233\156\135\229\135\187",
        DUAL_MIND_VISION            = "\229\191\131\231\191\181\232\167\134\231\149\140",

        CURE_CURE_DISEASE  	        = "\231\165\155\231\151\133\230\156\175",
        CURE_ABOLISH_DISEASE        = "\233\169\177\233\153\164\231\150\190\231\151\133",
        CURE_PURIFY		    	    = "\231\186\175\229\135\128\230\156\175",
        CURE_CLEANSE  			    = "\230\184\133\230\180\191\230\156\175",
        CURE_DISPEL_MAGIC 		    = "\233\169\177\230\149\163\233\173\148\230\179\149",
        CURE_CURE_POISON	    	= "\230\182\136\230\175\146\230\156\175",
        CURE_ABOLISH_POISON    	    = "\233\169\177\230\175\146\230\156\175",
        CURE_REMOVE_LESSER_CURSE	= "\232\167\163\233\153\164\230\172\161\231\186\167\232\175\133\229\146\146",
        CURE_REMOVE_CURSE			= "\232\167\163\233\153\164\232\175\133\229\146\146",

        BUFF_PWF  				    = "\231\156\159\232\168\128\230\156\175\239\188\154\233\159\167",
        BUFF_PWS	    			= "\231\156\159\232\168\128\230\156\175\239\188\154\231\155\190",
        BUFF_SP		    		    = "\233\152\178\230\138\164\230\154\151\229\189\177",
        BUFF_DS			    	    = "\231\165\158\229\156\163\228\185\139\231\191\181",
        BUFF_RENEW    			    = "\230\191\162\229\164\191",
        BUFF_MOTW		    		= "\233\135\142\230\128\167\229\191\176\232\174\176",
        BUFF_THORNS		    	    = "\232\191\134\230\163\152\230\156\175",
        BUFF_REJUVENATION	    	= "\229\155\158\230\152\165\230\156\175",
        BUFF_REGROWTH	    		= "\230\132\136\229\191\136",
        BUFF_AI   				    = "\229\165\165\230\156\175\230\153\186\230\133\167",
        BUFF_DM	    			    = "\233\173\148\230\179\149\230\138\145\229\136\182",
        BUFF_AM		    		    = "\233\173\148\230\179\149\229\162\158\230\149\136",
        BUFF_BOM			    	= "\229\138\155\233\135\191\231\165\191\231\166\191",
        BUFF_BOP	    			= "\228\191\191\230\138\164\231\165\191\231\166\191",
        BUFF_BOW		    		= "\230\153\186\230\133\167\231\165\191\231\166\191",
        BUFF_BOS			    	= "\230\139\175\230\149\145\231\165\191\231\166\191",
        BUFF_BOL				    = "\229\133\137\230\152\142\231\165\191\231\166\191",
        BUFF_BOSFC			        = "\231\137\186\231\137\178\231\165\191\231\166\191",
    }
end)