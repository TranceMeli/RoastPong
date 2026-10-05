extends Node

func score(text: String) -> int:
    var s = 0
    var t = text.to_lower()
    var words = t.split(" ")

    if words.size() <= 4: s += 4
    elif words.size() <= 6: s += 3
    elif words.size() <= 8: s += 2
    else: s += 1


    var tier3 = [
        "grandma", "pathetic", "embarrassing", "useless", "decoration",
        "crying", "disposable", "replaced", "ruins", "nowhere", "empty",
        "stuffed", "flies", "bucket", "packed", "popped"
    ]
    var tier2 = [
        "slow", "blind", "missed", "terrible", "awful", "worst", "asleep",
        "behind", "confused", "dead", "sad", "broken", "weak", "soft",
        "irrelevant", "forgotten", "limits", "missing"
    ]
    var tier1 = [
        "bad", "late", "wrong", "energy", "strategy", "performance",
        "down", "chart", "bubble", "umbrella", "resistance"
    ]

    for w in tier3: if w in t: s += 3
    for w in tier2: if w in t: s += 2
    for w in tier1: if w in t: s += 1

    if ". for" in t or ". but" in t or ". and" in t or ". not" in t: s += 2

    s += text.count("!")
    if text == text.to_upper(): s += 2

    if " like " in t or " than " in t or " as " in t: s += 1

    for w in ["you ", "your ", "bro", "dude"]: if w in t: s += 1

    if t.ends_with("sure.") or t.ends_with("watch.") or \
       t.ends_with("soon.") or t.ends_with("checks out."): s += 2

    return clamp(s, 1, 10)

func pick_weighted(list: Array) -> Dictionary:
    var pool = []
    for item in list:
        var s = score(item["text"])
        for i in range(s):
            pool.append(item)
    return pool[randi() % pool.size()]