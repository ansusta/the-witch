class_name Town01Events


static func entrance_fight() -> Dictionary:
	return {
		"id": "town01_entrance_fight",
		"steps": [
			# 0
			{
				"type": "narration",
				"text": "Two villagers stand near the entrance, deep in a heated argument. People nearby have gone quiet and are pretending not to notice."
			},
			# 1
			{
				"type": "choice",
				"text": "What do you do?",
				"options": [
					{ "label": "Approach",        "go_to": 2  },
					{ "label": "Leave them alone", "go_to": 38 }
				]
			},
			# 2
			{
				"type": "narration",
				"text": "You step forward. You hear what they're shouting."
			},
			# 3
			{
				"type": "villager_a",
				"text": "I say they're missing, it means they're missing. I'm not going crazy!"
			},
			# 4
			{
				"type": "villager_b",
				"text": "Well, I'm starting to think you really are! You handed me 5 sheep, I gave you 5 sheep back. Are you saying I can't count right?"
			},
			# 5
			{
				"type": "villager_a",
				"text": "Oh, you certainly can — maybe you just don't WANT to count right."
			},
			# 6
			{
				"type": "villager_b",
				"text": "Are you calling me a thief?"
			},
			# 7
			{
				"type": "narration",
				"text": "You clear your throat. Both of them stop mid-sentence and turn their enraged eyes toward you."
			},
			# 8
			{
				"type": "you",
				"text": "Before this goes any further — how many sheep did you count before you handed them over?"
			},
			# 9
			{
				"type": "villager_a",
				"text": "Six. I counted them at the barn, right before I left. I always count twice. Six sheep."
			},
			# 10
			{
				"type": "you",
				"text": "And you — how many did you receive?"
			},
			# 11
			{
				"type": "villager_b",
				"text": "Five. I counted them as they came through my gate, one by one. There were five. I am certain of it."
			},
			# 12
			{
				"type": "narration",
				"text": "One sheep is missing somewhere between the barn and the gate. Both of them are certain of their count. Somebody is wrong — or lying."
			},
			# 13
			{
				"type": "choice",
				"text": "How do you handle it?",
				"options": [
					{ "label": "Try to mediate",      "go_to": 14 },
					{ "label": "Side with villager A", "go_to": 20 },
					{ "label": "Side with villager B", "go_to": 26 },
					{ "label": "Offer to investigate", "go_to": 32 }
				]
			},

			
			# 14
			{
				"type": "you",
				"text": "Let's all calm down. I'm sure there's a reasonable explanation."
			},
			# 15
			{
				"type": "narration",
				"text": "It doesn't have the desired effect. If anything, they both get angrier."
			},
			# 16
			{
				"type": "villager_a",
				"text": "Who in the world are you? Do you think this is a game? Stay out of it!"
			},
			# 17
			{
				"type": "villager_b",
				"text": "Are you mocking me? Do you want to find out what happens to people who mock me?"
			},
			# 18
			{
				"type": "narration",
				"text": "Next thing you know you are on the ground and your body hurts everywhere. A few onlookers are whispering. No one seems willing to help."
			},
			# 19
			{ "type": "peace_effect", "delta": -8, "town_id": "town_01", "go_to": 40 },

			
			# 20
			{
				"type": "narration",
				"text": "You step up and raise your hand to shield the first villager."
			},
			# 21
			{
				"type": "you",
				"text": "The ploy this woman is playing is quite clear. I will not stand by and watch it."
			},
			# 22
			{
				"type": "villager_b",
				"text": "Wha — WHO ARE —"
			},
			# 23
			{
				"type": "villager_a",
				"text": "That matters not. Whoever you are, it seems you can see the truth. Now — will you pay me back for the sheep before things turn ugly?"
			},
			# 24
			{
				"type": "narration",
				"text": "The shepherd girl seems to have more to say, but cornered by the two of you and the first villager's menacing gaze, she has little choice but to back down."
			},
			# 25
			{ "type": "peace_effect", "delta": 4, "town_id": "town_01", "go_to": 40 },

			
			# 26
			{
				"type": "narration",
				"text": "You step up and raise your hand to shield the shepherd girl."
			},
			# 27
			{
				"type": "you",
				"text": "This woman is no thief. You are the one who is mistaken."
			},
			# 28
			{
				"type": "villager_a",
				"text": "What do you think you're doing?!"
			},
			# 29
			{
				"type": "villager_b",
				"text": "Well. It seems the truth is finally coming to light. Stop this madness and I will let it go."
			},
			# 30
			{
				"type": "narration",
				"text": "The first villager seems to have more to say, but cornered by the two of you and the shepherd girl's cold stare, he has little choice but to back down."
			},
			# 31
			{ "type": "peace_effect", "delta": 4, "town_id": "town_01", "go_to": 40 },

			
			# 32
			{
				"type": "narration",
				"text": "You raise both hands and step between them."
			},
			# 33
			{
				"type": "you",
				"text": "I will look into this. Give me time to find out what actually happened to that sheep."
			},
			# 34
			{
				"type": "villager_a",
				"text": "...Fine. But be quick about it. I want what is mine."
			},
			# 35
			{
				"type": "villager_b",
				"text": "Fine. But if i find out you're working with him, I will remember your face."
			},
			# 36
			{
				"type": "narration",
				"text": "They separate, still glaring at each other across the road. Somewhere between a barn and a gate, a sheep vanished. You intend to find out where."
			},
			# 37
			{ "type": "quest_trigger", "quest_id": "missing_sheep", "go_to": 40 },

			
			# 38
			{
				"type": "narration",
				"text": "You walk past. Behind you, you hear the argument flare up again. You don't look back."
			},
			# 39
			{ "type": "peace_effect", "delta": -4, "town_id": "town_01", "go_to": 40 },

			
			# 40
			{ "type": "close" }
		]
	}
