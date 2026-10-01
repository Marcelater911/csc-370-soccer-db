import os, urllib.request
mid = 3754237
base = "https://raw.githubusercontent.com/statsbomb/open-data/master/data"
os.makedirs("data", exist_ok=True)
urllib.request.urlretrieve(f"{base}/events/{mid}.json", f"data/events_{mid}.json")
urllib.request.urlretrieve(f"{base}/lineups/{mid}.json", f"data/lineups_{mid}.json")
urllib.request.urlretrieve(f"{base}/matches/2/27.json", "data/matches_2_27.json")
print("Downloaded events, lineups, and season matches for", mid)