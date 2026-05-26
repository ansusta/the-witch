static func entrance_fight() -> Dictionary:
	return {
		"id": "town01_entrance_fight",
		"steps": [
			{
				"type": "narration",
				"text": "Ahead of you , you see two villagers engaded in a heated argument. The people nearby look away."
			},
			{
				"type": "choice",
				"text": "What do you do?",
				"options": [
					{ "label": "Approach",       "go_to": 2 },
					{ "label": "Leave them alone","go_to": 8 }
				]
			},
			# --- APPROACH branch (steps 2–7) ---
			{
				"type": "narration",
				"text": "You step forward. you hear what they're shouting"
			},
			{
				"type": "villager a",
				"text": "i say they're missing , it means they're missing. im not going crazy!"
			},
			
			{
				"type": "villager b",
				"text": "well i'm starting to think you really are ! u handed me 5 sheep i gave u 5 sheep back, are you saying i can't count right? "
			},
			{
				"type": "villager a",
				"text": "oh you certainly can ,maybe you don't WANT to count right "
			},
			{
				"type": "villager b",
				"text": "are u calling me a theif ?  "
			},
						{
				"type": "narration",
				"text": "you make a small coughing sound, they both turn their enraged eyes to you "
			},
			{
				"type": "choice",
				"text": "How do you intervene?",
				"options": [
					{ "label": "Try to mediate",  "go_to": 4 },
					{ "label": "side with a ",  "go_to": 6 },
					{ "label": "side with b",  "go_to": 8 },
					{ "label": "prob for more info",  "go_to": 10 },
				]
			},
			# Mediate (steps 4–5)
			{
				"type": "narration",
				"text": "You speak carefully, trying not to make things worse."
			},
			{
				"type": "you",
				"text": "let's all calm down i'm sure it's all a misunderstanding"
			},
			{
				"type": "narration",
				"text": "it doesn't seem to have the desired effect as they both get angrier."
			},
			{
				"type": "villager a",
				"text": "who the ### are you ? do you think this is some game? stay out of it!"
			},
			{
				"type": "villager b",
				"text": "are you mocking me? do you wanna see what happens to those who mock me?  "
			},
			{
				"type": "narration",
				"text": "next thing you know you are on the floor and your body hurts everywhere, you hear a few onlookers whispering, yet no one seems willing to help."
			},
			
			{ "type": "peace_effect", "delta": -8, "town_id": "town_01" },
			
			{
				"type": "narration",
				"text": "You step up raising your hand to shield the first villager ."
			},
			{
				"type": "narration",
				"text": "the ploy this woman is playing i quite clear i shall not stand by and watch it happen"
			},
			{
				"type": "villager b",
				"text": "wha- WHO ARE- ."
			},
			{
				"type": "villager a",
				"text": "that matters not, whoever they are it seems they can see the truth."
			},
			{
				"type": "villager a",
				"text": "now will you pay me back for the sheep before things turn ugly? "
			},
			{
				"type": "narration",
				"text": "it seems the second villager has more to say, but cornered by the two of you coupled with the other villagers menacing gaze she has no choice but to listen "
			},
			
			{ "type": "peace_effect", "delta": +4, "town_id": "town_01" },
			
			{
				"type": "narration",
				"text": "You step up raising your hand to shield the second villager ."
			},
			{
				"type": "you",
				"text": "this woman is no thief, you are!"
			},
			{
				"type": "villager a",
				"text": "what are you doing!"
			},
			{
				"type": "villager b",
				"text": "well now it seems the truth is coming to light"
			},
			{
				"type": "villager b",
				"text": "stop this madness at once and i will let it go  "
			},
			{
				"type": "narration",
				"text": "it seems the first villager has more to say, but cornered by the two of you coupled with the other villagers menacing gaze she has no choice but to listen "
			},
			
			{ "type": "peace_effect", "delta": +4, "town_id": "town_01" },
			
			
			
			
			
			
			
			
			
			
			
			
			{
				"type": "narration",
				"text": "You walk past. Behind you, you hear the sound of something hitting the ground. You don't look back."
			},
			{ "type": "close" }
		]
	}
