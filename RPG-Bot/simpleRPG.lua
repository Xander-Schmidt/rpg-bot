local discordia = require("discordia")
local client = discordia.Client()
discordia.extensions()

local json = require("json")
local timer = require("timer")
local coro = require("coro-http")

local random, randomseed, ceil = math.random, math.randomseed, math.ceil
local insert, remove, concat = table.insert, table.remove, table.concat
local gmatch, sub, find = string.gmatch, string.sub, string.find
local open, time, clock = io.open, os.time, os.clock
local wrap, create, yield, resume = coroutine.wrap, coroutine.create, coroutine.yield, coroutine.resume
local parse, stringify, encode = json.parse, json.stringify, json.enc6ode

local goldBoxDrops = {
    "Attuned Ice Longsword",
    "Silver Bar",
    "Padded Shirt",
    "Weapon Item Sprite Sheet #1",
}

local silverBoxDrops = {
    "Green Lantern",
}

local bronzeBoxDrops = {
    "Upgraded Dagger",
    "Pie",
    "Eulogy",
    "Some Geezers Bow",
    ""
}

local items = {
    "Fortune of Archer",
    "Snail Shell",
    "Strawberry",
    "Defused Bomb",
    "Unreadable Scroll",
    "Warpwood Shield",
    "Strange Fossil",
    "Stein"
}

local lowEnemies = {
    "goblin",
    "wolf",
    "bandit",
    "zombie"
}

local dem = {
    "Rouge (red)",
    "Vert (green)",
    "Bleu (blue)",
    "Noir (black)",
    "Blanc (white)",
    "Jaune (gold)",
    "Violet (purple)"
}

local stepScenarios = {
    "As you take steps on your adventure,\nyou wonder why you live a hole, and exist.\n",
    "If only life was this straight-forward...\n",
    "You cook 1 minute rice in 59 seconds.\nYou pat yourself on the back for this accomplishment.\n",
    "You accidentally put together an IKEA shelf correctly.\nCongratulations.\n",
    "If you give a man a fire, he'll be warm for the night.\nSet the man on fire, and he's warm for the rest of his life.\n",
    "How can bread be real if our eyes aren't real?\n",
    "Trying is the first step towards failure, so don't try.\n",
    "You decided to be an emo for a day.\nYou failed miserably.\nYou saved someone from dying.\n",
    "It's impossible to pretend how to play the air guitar.\n",
    "You got to a place called the Virgin Islands.\nNow it's just called The Islands.\n",
    "You arrive at the crevice of doom.\nA wizard blocks the bridge and asked riddles\nHe does not know the flight speed of an unladed swallow.\nThe wizard falls into the crevice.\n",
    "A dodgy looking guy approaches you on a street corner.\nHe offers to fix your equipment for a huge discount.\nYou decline and walk away.\n",
    "You come across the ugliest bloke you have ever seen.\nYou say to him 'I never forget a face, but you're an exception.'\n",
    "You see in the distance, without the mountains, the words SOS.\nHowever the words are located that only the bot devs can access them.\nPerhaps it's a message from them.\n",
    "Your friend told you that you intimidate people...\nYou stare at him until he apologises.\n",
    "You stole money from an old woman.\nYou heartless person...\n",
    "You come across the most beautiful gir you've ever liad your eyes on.\nTruly a body sculted by the gods themselves.\nYou are about to say hello but notice she's wearing socks with sandals.\nYou run away.\n",
    "You lose your virginity before your dad...\n",
    "You think to yourself...\n'They don't think it be like this, but it do...\n",
    "What's the point in going out?\nYou're just gonna wind back home anyway...\n",
    "You stumble upon what seems to be a void in space.\nSensors readings offer no information of note.\nThere is a strong gravitation pull toward the hole.\nPerhaps it's a black hole?\n",
    "A dead pidgeon falls into the hole that you call home.\nAccording to locals, it was crushed by the police.\nIt was apparantly terrorising people for chips...\n",
    "A bandit approaches you, he states his master wants to see you.\nThe bandit wont take no for an answer.\n",
    "You attacked a chicken...\nYou were sent to high security prison.\n",
    "You tried making your friend laugh with puns.\nSadly no pun in ten did.\n",
}

function earnXP(message, allotment)
	local openx = open("xp.json", "r")
	local parsex = parse(openx:read())
	openx:close()

	local openm = open("max.json", "r")
	local parsem = parse(openm:read())
	openm:close()

	local openl = open("lvl.json", "r")
	local parsel = parse(openl:read())
	openl:close()

	local openh = open("health.json", "r")
	local parseh = parse(openh:read())
	openh:close()

	local openmh = open("maxhealth.json", "r")
	local parsemh = parse(openmh:read())
	openmh:close()

	parsex[message.author.id] = parsex[message.author.id] + allotment
	if parsex[message.author.id] >= parsem[message.author.id] then
		parsel[message.author.id] = parsel[message.author.id] + 1
		parsem[message.author.id] = parsem[message.author.id] * parsel[message.author.id]
		parsemh[message.author.id] = parsemh[message.author.id] * (parsel[message.author.id] * 1.5)
		parseh[message.author.id] = parsemh[message.author.id]

		message:reply {
			embed = {
				fields = {
					{
						name = message.author.id.." Levelled Up!",
						value = (parsel[message.author.id] - 1).." -> "..parsel[message.author.id],
						inline = false
					}
				},

				footer = {
					text = "You can check your stats by doing +profile"
				},

				color = 0xff
			}
		}
	end

	openx = open("xp.json", "w")
	openx:write(stringify(parsex))
	openx:close()

	openm = open("max.json", "w")
	openm:write(stringify(parsem))
	openm:close()

	opens = open("steps.json", "w")
	opens:write(stringify(parses))
	opens:close()

	openl = open("lvl.json", "w")
	openl:write(stringify(parsel))
	openl:close()

	openh = open("health.json", "w")
	openh:write(stringify(parseh))
	openh:close()

	openmh = open("maxhealth.json", "w")
	openmh:write(stringify(parsemh))
	openmh:close()
end

function earnGold(message, allotment)
	local openg = open("gold.json", "r")
	local parseg = parse(openg:read())
	openg:close()

	if parseg[message.author.id] then
		parseg[message.author.id] = parseg[message.author.id] + allotment
	else
		parseg[message.author.id] = allotment
	end

	openg = open("gold.json", "w")
	openg:write(stringify(parseg))
	openg:close()
end

function earnGems(message, allotment)
	local opend = open("diamonds.json", "r")
	local parsed = parse(opend:read())
	opend:close()

	if parsed[message.author.id] then
		parsed[message.author.id] = parsed[message.author.id] + allotment
	else
		parsed[message.author.id] = allotment
	end

	opend = open("diamonds.json", "w")
	opend:write(stringify(parsed))
	opend:close()
end

function register(message, class, de)
    if class == "demon" then
        message:reply {
            embed = {
                title = "- Demon Summoned into SimpleRPG -",
                fields = {
                    {
                        name = "Named demon has been summoned.",
                        value = "You are classified as a "..de.." Demon.",
                        inline = false
                    },

                    {
                        name = "Get adventuring!",
                        value = "Get started with `+step`",
                        inline = false
                    },

                    {
                        name = "Check Your profile!",
                        value = "To look, use `+profile`",
                        inline = false
                    },
                },

                footer = {
                    text = "\nThis bot was brought to you by Aegeus#1936.",
                },

                color = 0xff
            }
        }

        setup(message, de)
    else
        message:reply {
            embed = {
                title = "Great! Your account is now registered!",
                fields = {
                    {
                        name = "Your Class",
                        value = class,
                        inline = false
                    },

                    {
                        name = "Get adventuring!",
                        value = "Get started with `+step`",
                        inline = false
                    },

                    {
                        name = "Check Your profile!",
                        value = "To look, use `+profile`",
                        inline = false
                    },
                },

                footer = {
                    text = "\nThis bot was brought to you by Aegeus#1936.",
                },

                color = 0xff
            }
        }

        setup(message, class)
    end
end

function setup(message, class)
    local openg = open("gold.json", "r")
    local parseg = parse(openg:read())
    openg:close()

    local openx = open("xp.json", "r")
    local parsex = parse(openx:read())
    openx:close()

    local openm = open("max.json", "r")
    local parsem = parse(openm:read())
    openm:close()

    local opens = open("steps.json", "r")
    local parses = parse(opens:read())
    opens:close()

    local openr = open("registered.json", "r")
    local parser = parse(openr:read())
    openr:close()

    local openc = open("characters.json", "r")
    local parsec = parse(openc:read())
    openc:close()

    local openl = open("lvl.json", "r")
    local parsel = parse(openl:read())
    openl:close()

    local openh = open("health.json", "r")
    local parseh = parse(openh:read())
    openh:close()

    local openmh = open("maxhealth.json", "r")
    local parsemh = parse(openmh:read())
    openmh:close()

    local opena = open("attack.json", "r")
    local parsea = parse(opena:read())
    opena:close()

    local openat = open("attacking.json", "r")
    local parseat = parse(openat:read())
    openat:close()

    local opend = open("diamonds.json", "r")
    local parsed = parse(opend:read())
    opend:close()

    if class then
        parseg[message.author.id] = 1000
        parsem[message.author.id] = 100
        parseh[message.author.id] = 100
        parsemh[message.author.id] = 100
        parsel[message.author.id] = 1
        parsex[message.author.id] = 0
        parses[message.author.id] = 0
        parsed[message.author.id] = 50
        parser[message.author.id] = message.author.username
        parsec[message.author.id] = class
    end

    openg = open("gold.json", "w")
    openg:write(stringify(parseg))
    openg:close()

    opend = open("diamonds.json", "w")
    opend:write(stringify(parsed))
    opend:close()

    openl = open("lvl.json", "w")
    openl:write(stringify(parsel))
    openl:close()

    opena = open("attack.json", "w")
    opena:write(stringify(parsea))
    opena:close()

    openat = open("attacking.json", "w")
    openat:write(stringify(parseat))
    openat:close()

    openh = open("health.json", "w")
    openh:write(stringify(parseh))
    openh:close()

    openx = open("xp.json", "w")
    openx:write(stringify(parsex))
    openx:close()

    openm = open("max.json", "w")
    openm:write(stringify(parsem))
    openm:close()

    opens = open("steps.json", "w")
    opens:write(stringify(parses))
    opens:close()

    openc = open("characters.json", "w")
    openc:write(stringify(parsec))
    openc:close()

    openr = open("registered.json", "w")
    openr:write(stringify(parser))
    openr:close()

    openmh = open("maxhealth.json", "w")
    openmh:write(stringify(parsemh))
    openmh:close()
end

function wait(n)
    local s = tonumber(clock() + n)
    while (clock() < s) do end
end

function timeS(s,n)
    local dif = (((n-(s - io.time()))/60)/60)/24
    if dif < 1 then
        if (dif*24) < 1 then
            if ((dif*24)*60) < 1 then
                return (((dif*24)*60)*60).." seconds."
            else
                return ((dif*24)*60).." minutes."
            end
        else
            return (dif*24).." hours."
        end
    else
        return dif.." days."
    end
end


client:on("messageCreate", function(message)
	print((discordia.Date():toISO("T", "Z")).." :: "..message.author.username.." :: "..message.content)
    local content = message.content
    if content ~= nil or content ~= "" then
        local member = message.member

        if member ~= nil then
            local argsi = content:split(" ")
            local argsv = content:split("")

            --

            local openg = open("gold.json", "r")
            local parseg = parse(openg:read())
            openg:close()

            local openx = open("xp.json", "r")
            local parsex = parse(openx:read())
            openx:close()

            local openm = open("max.json", "r")
            local parsem = parse(openm:read())
            openm:close()

            local openr = open("registered.json", "r")
            local parser = parse(openr:read())
            openr:close()

            local openc = open("characters.json", "r")
            local parsec = parse(openc:read())
            openc:close()

            local openl = open("lvl.json", "r")
            local parsel = parse(openl:read())
            openl:close()

            local openh = open("health.json", "r")
            local parseh = parse(openh:read())
            openh:close()

            local openmh = open("maxhealth.json", "r")
            local parsemh = parse(openmh:read())
            openmh:close()

            local opena = open("attack.json", "r")
            local parsea = parse(opena:read())
            opena:close()

            local openat = open("attacking.json", "r")
            local parseat = parse(openat:read())
            openat:close()

            local opens = open("steps.json", "r")
            local parses = parse(opens:read())
            opens:close()

            local opent = open("timeStep.json", "r")
            local parset = parse(opent:read())
            opent:close()

            local opentd = open("timeDaily.json", "r")
            local parsetd = parse(opentd:read())
            opentd:close()

            local opentw = open("timeWeekly.json", "r")
            local parsetw = parse(opentw:read())
            opentw:close()

            local opentm = open("timeMonthly.json", "r")
            local parsetm = parse(opentm:read())
            opentm:close()

            local opend = open("diamonds.json", "r")
            local parsed = parse(opend:read())
            opend:close()

            --

            if argsi[1]:lower():sub(1, #"+step") == "+step" then
                if parser[message.author.id] then
                    if parses[message.author.id] then
                    	if parset[message.author.id] then
	                        local dif = time() - tonumber(parset[message.author.id])
	                        if dif >= 60 then
	                            parses[message.author.id] = parses[message.author.id] + 1
	                            parset[message.author.id] = time()

	                            local gallot = random(1,10)
	                            local xallot = random(1,10)

	                            earnGold(message,gallot)
	                            earnXP(message,xallot)

	                            message:reply {
									embed = {
										title = "You crawl out of the hole that you call \n home and set off on your journey.",
										fields = {
											{
												name = "Information",
												value = stepScenarios[math.ceil(random() * #stepScenarios)].."\n+:coin: "..gallot.." +:sparkles: "..xallot,
												inline = false
											}
										},

										footer = {
											text = "This person has taken a total of "..parses[message.author.id].." steps.\nThis bot was brought to you by Aegeus#1936."
										},

										color = 0xff
									}
								}

	                        else
	                            message:reply {
	                                embed = {
	                                    fields = {
	                                        {
	                                            name = "Action could not be completed.",
	                                            value = "User can step in "..(60 - dif).." seconds.",
	                                            inline = false
	                                        },
	                                    },

	                                    footer = {
	                                        text = "\nThis bot was brought to you by Aegeus#1936."
	                                    },

	                                    color = 0xff
	                                }
	                            }
	                        end
	                    else
	                    	parses[message.author.id] = parses[message.author.id] + 1
	                        parset[message.author.id] = time()

	                        local gallot = random(1,10)
	                        local xallot = random(1,10)

	                        earnGold(message,gallot)
	                        earnXP(message,xallot)

	                        message:reply {
								embed = {
									title = "You crawl out of the hole that you call \n home and set off on your journey.",
									fields = {
										{
											name = "Information",
											value = stepScenarios[math.ceil(random() * #stepScenarios)].."\n+:coin: "..gallot.." +:sparkles: "..xallot,
											inline = false
										}
									},

									footer = {
										text = "This person has taken a total of "..parses[message.author.id].." steps.\nThis bot was brought to you by Aegeus#1936."
									},

									color = 0xff
								}
							}
	                    end
                else
                	parses[message.author.id] = 1
                    parset[message.author.id] = time()

                    local gallot = random(1,10)
                    local xallot = random(1,10)

                    earnGold(message,gallot)
                    earnXP(message,xallot)

                    message:reply {
						embed = {
							title = "You crawl out of the hole that you call \n home and set off on your journey.",
							fields = {
								{
									name = "Information",
									value = stepScenarios[math.ceil(random() * #stepScenarios)].."\n+:coin: "..gallot.." +:sparkles: "..xallot,
									inline = false
								}
							},

							footer = {
								text = "This person has taken a total of "..parses[message.author.id].." steps.\nThis bot was brought to you by Aegeus#1936."
							},

							color = 0xff
						}
					}
				end
                end
            elseif argsi[1]:lower():sub(1, #"+register") == "+register" then
                if argsi[2] then
                    if parser[message.author.id] then
                        message:reply {
                            embed = {
                                fields = {
                                    {
                                        name = "Action could not be completed.",
                                        value = "User is already registered...",
                                        inline = false,
                                    },
                                },

                                footer = {
                                        text = "\nThis bot was brought to you by Aegeus#1936."
                                    },

                                color = 0xff
                            }
                        }
                    else
                        if argsi[2]:lower():sub(1, #"archer") == "archer" then
                            local sel = "archer"
                            register(message, sel)
                        elseif argsi[2]:lower():sub(1, #"assassin") == "assassin" then
                            local sel = "assassin"
                            register(message, sel)
                        elseif argsi[2]:lower():sub(1, #"shieldman") == "shieldman" then
                            local sel = "shieldman"
                            register(message, sel)
                        elseif argsi[2]:lower():sub(1, #"swordsman") == "swordsman" then
                            local sel = "swordsman"
                            register(message, sel)
                        elseif argsi[2]:lower():sub(1, #"mage") == "mage" then
                            local sel = "mage"
                            register(message, sel)
                        elseif argsi[2]:lower():sub(1, #"druid") == "druid" then
                            local sel = "druid"
                            register(message, sel)
                        elseif argsi[2]:lower():sub(1, #"demon") == "demon" then
                            local sel = "demon"
                            local de = dem[ceil(random() * #dem)]
                            register(message, sel, de)
                        else
                            message:reply {
                                embed = {
                                    fields = {
                                        {
                                            name = "Action could not be completed.",
                                            value = "User must select valid class.",
                                            inline = false,
                                        },
                                    },

                                    footer = {
                                        text = "\nThis bot was brought to you by Aegeus#1936.",
                                    },

                                    color =  0xff,
                                }
                            }
                        end
                    end
                end
            elseif argsi[1]:lower():sub(1, #"+profile") == "+profile" then
                if argsi[2] then
                    local mentioned_user = message.mentionedUsers.first or argsi[2]
                    local mentioned_member = message.guild:getMember(mentioned_user)
                    local mentioned = message.guild:getMember(mentioned_member)

                    if mentioned ~= nil then
                        if parser[mentioned.id] then
                            message:reply {
                                embed = {
                                    author = {
                                        name = mentioned.username,
                                        icon_url = mentioned.avatarURL,
                                    },

                                    title = mentioned.username.."'s Profile",

                                    fields = {
                                        {
                                            name = "Gold",
                                            value = ":coin: "..(parseg[mentioned.id] or 0),
                                            inline = true,
                                        },

                                        {
                                            name = "Class",
                                            value = parsec[mentioned.id],
                                            inline = true,
                                        },

                                        {
                                            name = "Gems",
                                            value = ":gem: "..(parsed[mentioned.id] or 0).."\n",
                                            inline = true,
                                        },

                                        {
                                            name = "Level",
                                            value = parsel[mentioned.id],
                                            inline = true,   
                                        },

                                        {
                                            name = "Steps",
                                            value = (parses[mentioned.id] or 0),
                                            inline = true,
                                        },

                                        {
                                            name = "XP",
                                            value = "["..(parsex[mentioned.id] or 0).." / "..parsem[mentioned.id].."]\n",
                                            inline = true
                                        },

                                        {
                                            name = "Health",
                                            value = "["..(parseh[mentioned.id] or 0).." / "..parsemh[mentioned.id].."]"
                                        },
                                    },

                                    footer = {
                                        text = "\nThis bot was brought to you by Aegeus#1936.",
                                    },

                                    color =  0xff,
                                }
                            }
                        else
                            message:reply {
                                embed = {
                                    fields = {
                                        {
                                            name = "Action could not be completed.",
                                            value = mentioned.username.." is not registered.",
                                            inline = false,
                                        },
                                    },

                                    footer = {
                                        text = "\nThis bot was brought to you by Aegeus#1936.",
                                    },

                                    color =  0xff,
                                }
                            }
                        end
                    else
                        message:reply {
                            embed = {
                                fields = {
                                    {
                                        name = "Action could not be completed.",
                                        value = "I",
                                        inline = false,
                                    },
                                },

                                footer = {
                                    text = "\nThis bot was brought to you by Aegeus#1936.",
                                },

                                color =  0xff,
                            }
                        }
                    end
                else
                    if parser[message.author.id] then
                                                    message:reply {
                                embed = {
                                    author = {
                                        name = message.author.username,
                                        icon_url = message.author.avatarURL,
                                    },

                                    title = message.author.username.."'s Profile",

                                    fields = {
                                        {
                                            name = "Gold",
                                            value = ":coin: "..(parseg[message.author.id] or 0),
                                            inline = true,
                                        },

                                        {
                                            name = "Class",
                                            value = parsec[message.author.id],
                                            inline = true,
                                        },

                                        {
                                            name = "Gems",
                                            value = ":gem: "..(parsed[message.author.id] or 0).."\n",
                                            inline = true,
                                        },

                                        {
                                            name = "Level",
                                            value = parsel[message.author.id],
                                            inline = true,   
                                        },

                                        {
                                            name = "Steps",
                                            value = (parses[message.author.id] or 0),
                                            inline = true,
                                        },

                                        {
                                            name = "XP",
                                            value = "["..(parsex[message.author.id] or 0).." / "..parsem[message.author.id].."]\n",
                                            inline = true
                                        },

                                        {
                                            name = "Health",
                                            value = "["..(parseh[message.author.id] or 0).." / "..parsemh[message.author.id].."]"
                                        },
                                    },

                                    footer = {
                                        text = "\nThis bot was brought to you by Aegeus#1936.",
                                    },

                                    color =  0xff,
                                }
                            }
                    else
                        message:reply {
                            embed = {
                                fields = {
                                    {
                                        name = "Action could not be completed",
                                        value = "User is not registered...",
                                        inline = false,
                                    },
                                },

                                footer = {
                                    text = "\nThis bot was brought to you by Aegeus#1936.",
                                },

                                color = 0xff
                            }
                        }
                    end
                end
            elseif argsi[1]:lower():sub(1, #"+help") == "+help" then
                message:reply {
                    embed = {
                        title = "Commands List",
                        fields = {
                            {
                                name = "Prefix",
                                value = "The bots prefix is `+`.",
                                inline = false,
                            },

                            {
                                name = "+register [class]",
                                value = "Get your account started to use SimpleRPG!",
                                inline = false,
                            },

                            {
                                name = "+classlist",
                                value = "Displays a list of classes you can register as.",
                                inline = false,
                            },

                            {
                                name = "+step",
                                value = "Go on a short journey, mayb meet some friends along the way.\n Fun fact, the step command gives you fun facts and jokes.",
                                inline = false,
                            },

                            {
                                name = "+profile [mention/nil]",
                                value = "Check out your accounts stats and information, you can learn more about yourself.\nMaybe even stalk someone else's account :eyes:",
                                inline = false,
                            },

                            {
                                name = "+collect [daily/weekly/monthly]",
                                value = "Get some cool rewards for free!",
                                inline = false,
                            },

                            {
                                name = "+botinfo",
                                value = "Displays bot information.",
                                inline = false,
                            },
                        },

                        footer = {
                            text = "\nThis bot was brought to you by Aegeus#1936."
                        },

                        color = 0xff
                    }
                }
            elseif argsi[1]:lower():sub(1, #"+botinfo") == "+botinfo" then
                message:reply {
                    embed = {
                        fields = {
                            {
                                name = "SimpleRPG",
                                value = "SimpleRPG is a text based RPG Discord bot.\nThe bot was made by Aegues#1936 & Deity#7209.\nUpdate info at the twitter link below.",
                                inline = false,
                            },

                            {
                                name = ":bar_chart: Servers :bar_chart:",
                                value = client.guilds:count(),
                                inline = true,
                            },

                            {
                                name = ":busts_in_silhouette: Accounts :busts_in_silhouette:",
                                value = client.users:count().."\n",
                                inline = true,
                            },

                            {
                                name = "Get Updates!",
                                value = "https://twitter.com/BreadDeity/",
                                inline = false,
                            },

                            {
                                name = "OAuth URL",
                                value = "https://discord.com/oauth2/authorize?client_id=799760899417047080&permissions=388160&scope=bot",
                                inline = false,
                            },
                        },

                        footer = {
                            text = "\nThis bot was brought to you by Aegeus#1936.",
                        },

                        color = 0xff
                    }
                }
            elseif argsi[1]:lower():sub(1, #"+collect") == "+collect" then
                if argsi[2] then
                    if argsi[2]:lower():sub(1, #"daily") == "daily" then
                        if parsetd[message.author.id] then
                            local dif = time() - parsetd[message.author.id]
                            if dif >= 86400 then
                                local xallot = random(1,10)
                                local gallot = random(1,10)

                                parsetd[message.author.id] = time()
                                earnXP(message,xallot)
                                earnGold(message,gallot)
                                earnGems(message,1)

                                message:reply {
                                    embed = {
                                        title = "- Daily Reward Collected -",
                                        fields = {
                                            {
                                                name = "information",
                                                value = "+:coin: "..gallot.." +:sparkles: "..xallot.." +:gem: 1",
                                                inline = false,
                                            },
                                        },

                                        footer = {
                                            text = "\n This bot was brough to you by Aegeus#1936.",
                                        },

                                        color = 0xff
                                    }
                                }
                            else
                                message:reply {
                                    embed = {
                                        fields = {
                                            {
                                                name = "Action could not be completed.",
                                                value = "You can do this again in tomorrow.",
                                                inline = false,
                                            },
                                        },

                                        footer = {
                                            text = "\nThis bot was brought to you Aegeus#1936.",
                                        },

                                        color = 0xff
                                    }
                                }
                            end
                        else
                            local xallot = random(1,10)
                            local gallot = random(1,10)

                            parsetd[message.author.id] = time()
                            earnXP(message,xallot)
                            earnGold(message,gallot)
                            earnGems(message,1)

                            message:reply {
                                embed = {
                                    title = "- Daily Reward Collected -",
                                    fields = {
                                        {
                                            name = "information",
                                            value = "+:coin: "..gallot.." +:sparkles: "..xallot.." +:gem: 1",
                                            inline = false,
                                       },
                                    },

                                    footer = {
                                        text = "\nThis bot was brough to you by Aegeus#1936.",
                                    },

                                    color = 0xff
                                }
                            }
                        end
                    elseif argsi[2]:lower():sub(1, #"weekly") == "weekly" then
                        if parsetw[message.author.id] then
                            local dif = time() - parsetw[message.author.id]
                            if dif >= 604800 then
                                local xallot = random(1,15)
                                local gallot = random(1,15)

                                parsetw[message.author.id] = time()
                                earnXP(message,xallot)
                                earnGold(message,gallot)
                                earnGems(message,5)

                                message:reply {
                                    embed = {
                                        title = "- Weekly Reward Collected -",
                                        fields = {
                                            {
                                                name = "information",
                                                value = "+:coin: "..gallot.." +:sparkles: "..xallot.." +:gem: 5",
                                                inline = false,
                                            },
                                        },

                                        footer = {
                                            text = "\n This bot was brough to you by Aegeus#1936.",
                                        },

                                        color = 0xff
                                    }
                                }
                            else
                                message:reply {
                                    embed = {
                                        fields = {
                                            {
                                                name = "Action could not be completed.",
                                                value = "You can do this again next week.",
                                                inline = false,
                                            },
                                        },

                                        footer = {
                                            text = "\nThis bot was brought to you Aegeus#1936.",
                                        },

                                        color = 0xff
                                    }
                                }
                            end
                        else
                            local xallot = random(1,15)
                            local gallot = random(1,15)

                            if parsed[message.author.id] then
                                parsed[message.author.id] = parsed[message.author.id] + 5
                            else
                                parsed[message.author.id] = 25
                            end

                            parsetw[message.author.id] = time()
                            earnXP(message,xallot)
                            earnGold(message,gallot)
                            earnGems(message,5)

                            message:reply {
                                embed = {
                                    title = "- Weekly Reward Collected -",
                                    fields = {
                                        {
                                            name = "information",
                                            value = "+:coin: "..gallot.." +:sparkles: "..xallot.." +:gem: 5",
                                            inline = false,
                                       },
                                    },

                                    footer = {
                                        text = "\nThis bot was brough to you by Aegeus#1936.",
                                    },

                                    color = 0xff
                                }
                            }
                        end
                    elseif argsi[2]:lower():sub(1, #"monthly") == "monthly" then
                        if parsetm[message.author.id] then
                            local dif = time() - parsetm[message.author.id]
                            if dif >= (604800*4) then
                                local xallot = random(1,20)
                                local gallot = random(1,20)

                                if parsed[message.author.id] then
                                    parsed[message.author.id] = parsed[message.author.id] + 25
                                else
                                    parsed[message.author.id] = 25
                                end

                                parsetd[message.author.id] = time()
                                earnXP(message,xallot)
                                earnGold(message,gallot)
                                earnGems(message,25)

                                message:reply {
                                    embed = {
                                        title = "- Monthly Reward Collected -",
                                        fields = {
                                            {
                                                name = "information",
                                                value = "+:coin: "..gallot.." +:sparkles: "..xallot.." +:gem: 25",
                                                inline = false,
                                            },
                                        },

                                        footer = {
                                            text = "\n This bot was brough to you by Aegeus#1936.",
                                        },

                                        color = 0xff
                                    }
                                }
                            else
                                message:reply {
                                    embed = {
                                        fields = {
                                            {
                                                name = "Action could not be completed.",
                                                value = "You can do this again next month.",
                                                inline = false,
                                            },
                                        },

                                        footer = {
                                            text = "\nThis bot was brought to you Aegeus#1936.",
                                        },

                                        color = 0xff
                                    }
                                }
                            end
                        else
                            local xallot = random(1,20)
                            local gallot = random(1,20)

                            if parsed[message.author.id] then
                                parsed[message.author.id] = parsed[message.author.id] + 25
                            else
                                parsed[message.author.id] = 25
                            end

                            parsetm[message.author.id] = time()
                            earnXP(message,xallot)
                            earnGold(message,gallot)
                            earnGems(message,25)

                            message:reply {
                                embed = {
                                    title = "- Monthly Reward Collected -",
                                    fields = {
                                        {
                                            name = "information",
                                            value = "+:coin: "..gallot.." +:sparkles: "..xallot.." +:gem: 25",
                                            inline = false,
                                       },
                                    },

                                    footer = {
                                        text = "\n This bot was brough to you by Aegeus#1936."
                                    },

                                    color = 0xff
                                }
                            }
                        end
                    end
                end
            elseif argsi[1]:lower():sub(1, #"+classlist") == "+classlist" then
           		message:reply {
           			embed = {
           				title = "Listed Classes",
           				fields = {
           					{
           						name = "Swordsman",
           						value = "That of a noble fighter.\nThey battle with honor.",
           						inline = false,
           					},

           					{
           						name = "Archer",
           						value = "A proud user of the bow.\nThey tend to be elves.",
           						inline = false,
           					},

           					{
           						name = "Assassin",
           						value = "Stealthy, and gets the job done.\nThey are built on pride.",
           						inline = false,
           					},

           					{
           						name = "Shieldman",
           						value = "They are one hell of a unit.\nKnown as the meat shield.",
           						inline = false,
           					},

           					{
           						name = "Mage",
           						value = "Explosion!\nThey make things go ***boom***.",
           						inline = false,
           					},

           					{
           						name = "Druid",
           						value = "They always surprise you.\nAn unsuspecting adventurer.",
           						inline = false,
           					},
           				},

           				footer = {
           					text = "\nThis bot was brought to you by Aegeus#1936.",
           				},


           				color = 0xff,
           			}
           		}
            end
            opens = open("steps.json", "w")
            opens:write(stringify(parses))
            opens:close()

            opent = open("timeStep.json", "w")
            opent:write(stringify(parset))
            opent:close()

            opentd = open("timeDaily.json", "w")
            opentd:write(stringify(parsetd))
            opentd:close()

            opentw = open("timeWeekly.json", "w")
            opentw:write(stringify(parsetw))
            opentw:close()

            opentm = open("timeMonthly.json", "w")
            opentm:write(stringify(parsetm))
            opentm:close()

            opend = open("diamonds.json", "r")
            opend:write(stringify(parsed))
            opend:close()
        end
    end
end)

client:on("ready", function()
    client:setGame("+register | https://twitter.com/BreadDeity/")
end)

client:run("Bot "..open("./token.txt"):read())






-- SOS