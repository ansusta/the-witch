class_name Town01Events

# Step map (for reference when editing):
#  0  narration  - intro
#  1  choice     - approach / leave
#
#  APPROACH PATH:
#  2  narration  - step forward
#  3  villager_a
#  4  villager_b
#  5  villager_a
#  6  villager_b
#  7  narration  - cough
#  8  choice     - mediate(9) / side_a(16) / side_b(23) / probe(30)
#
#  MEDIATE (9-15):
#  9  narration
#  10 you
#  11 narration
#  12 villager_a
#  13 villager_b
#  14 narration  - on the floor
#  15 peace_effect -8, go_to 33
#
#  SIDE_A (16-22):
#  16 narration
#  17 you
#  18 villager_b
#  19 villager_a
#  20 villager_a
#  21 narration
#  22 peace_effect +4, go_to 33
#
#  SIDE_B (23-29):
#  23 narration
#  24 you
#  25 villager_a
#  26 villager_b
#  27 villager_b
#  28 narration
#  29 peace_effect +4, go_to 33
#
#  PROBE (30-31):
#  30 narration
#  31 peace_effect 0, go_to 33
#
#  LEAVE (32):
#  32 narration  - walk past
#
#  CLOSE (33):
#  33 close

static func entrance_fight() -> Dictionary:
	return {
		"id": "town01_entrance_fight",
		"steps": [
			# 0
			{
				"type": "narration",
				"text": "Ahead of you, you see two villagers engaged in a heated argument. The people nearby look away."
			},
			# 1
			{
				"type": "choice",
				"text": "What do you do?",
				"options": [
					{ "label": "Approach",        "go_to": 2  },
					{ "label": "Leave them alone", "go_to": 32 }
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
				"text": "I say they're missing. It means they're missing. I'm not going crazy!"
			},
			# 4
			{
				"type": "villager_b",
				"text": "Well I'm starting to think you really are! You handed me 5 sheep, I gave you 5 sheep back. Are you saying I can't count right?"
			},
			# 5
			{
				"type": "villager_a",
				"text": "Oh you certainly can. Maybe you don't WANT to count right."
			},
			# 6
			{
				"type": "villager_b",
				"text": "Are you calling me a thief?"
			},
			# 7
			{
				"type": "narration",
				"text": "You make a small coughing sound. They both turn their enraged eyes to you."
			},
			# 8
			{
				"type": "choice",
				"text": "How do you intervene?",
				"options": [
					{ "label": "Try to mediate",    "go_to": 9  },
					{ "label": "Side with villager A", "go_to": 16 },
					{ "label": "Side with villager B", "go_to": 23 },
					{ "label": "Probe for more info",  "go_to": 30 }
				]
			},

			# --- MEDIATE branch (9-15) ---
			# 9
			{
				"type": "narration",
				"text": "You speak carefully, trying not to make things worse."
			},
			# 10
			{
				"type": "you",
				"text": "Let's all calm down. I'm sure it's all a misunderstanding."
			},
			# 11
			{
				"type": "narration",
				"text": "It doesn't seem to have the desired effect. They both get angrier."
			},
			# 12
			{
				"type": "villager_a",
				"text": "Who the hell are you? Do you think this is some game? Stay out of it!"
			},
			# 13
			{
				"type": "villager_b",
				"text": "Are you mocking me? Do you want to see what happens to those who mock me?"
			},
			# 14
			{
				"type": "narration",
				"text": "Next thing you know you are on the floor and your body hurts everywhere. You hear a few onlookers whispering, yet no one seems willing to help."
			},
			# 15
			{ "type": "peace_effect", "delta": -8, "town_id": "town_01", "go_to": 33 },

			# --- SIDE A branch (16-22) ---
			# 16
			{
				"type": "narration",
				"text": "You step up, raising your hand to shield the first villager."
			},
			# 17
			{
				"type": "you",
				"text": "The ploy this woman is playing is quite clear. I shall not stand by and watch it happen."
			},
			# 18
			{
				"type": "villager_b",
				"text": "Wha— WHO ARE—"
			},
			# 19
			{
				"type": "villager_a",
				"text": "That matters not. Whoever they are, it seems they can see the truth."
			},
			# 20
			{
				"type": "villager_a",
				"text": "Now will you pay me back for the sheep before things turn ugly?"
			},
			# 21
			{
				"type": "narration",
				"text": "The second villager seems to have more to say — but cornered by both of you and the first villager's menacing gaze, she has no choice but to back down."
			},
			# 22
			{ "type": "peace_effect", "delta": 4, "town_id": "town_01", "go_to": 33 },

			# --- SIDE B branch (23-29) ---
			# 23
			{
				"type": "narration",
				"text": "You step up, raising your hand to shield the second villager."
			},
			# 24
			{
				"type": "you",
				"text": "This woman is no thief. You are!"
			},
			# 25
			{
				"type": "villager_a",
				"text": "What are you doing!"
			},
			# 26
			{
				"type": "villager_b",
				"text": "Well now it seems the truth is coming to light."
			},
			# 27
			{
				"type": "villager_b",
				"text": "Stop this madness at once and I will let it go."
			},
			# 28
			{
				"type": "narration",
				"text": "The first villager seems to have more to say — but cornered by both of you and the second villager's menacing gaze, she has no choice but to back down."
			},
			# 29
			{ "type": "peace_effect", "delta": 4, "town_id": "town_01", "go_to": 33 },

			# --- PROBE branch (30-31) ---
			# 30
			{
				"type": "narration",
				"text": "You ask a few careful questions, trying to understand the full picture. Both villagers talk over each other — you can't make much sense of it. You'll need more context before you can do anything useful here."
			},
			# 31
			{ "type": "peace_effect", "delta": 0, "town_id": "town_01", "go_to": 33 },

			# --- LEAVE branch (32) ---
			# 32
			{
				"type": "narration",
				"text": "You walk past. Behind you, you hear the sound of something hitting the ground. You don't look back."
			},

			# --- CLOSE (33) ---
			# 33
			{ "type": "close" }
		]
	}
