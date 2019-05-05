
import os
import collections
import re

folder_path = "./results_main/"

class Rectangle:
   def __init__(self, x1, y1, x2, y2):
      self.x1 = int(x1)
      self.x2 = int(x2)
      self.y1 = int(y1)
      self.y2 = int(y2)
   def collide(self, other):
      return (self.x2 > other.x1 and  # r1 right edge past r2 left
         self.x1 < other.x2 and     # r1 left edge past r2 right
         self.y2 > other.y1 and     # r1 top edge past r2 bottom
         self.y1 < other.y2)       # r1 bottom edge past r2 top
   def __str__(self):
      return "(%d,%d),(%d,%d)" % (self.x1, self.y1, self.x2, self.y2)

class wh:
   def __init__(self, rect):
      self.w = rect.x2-rect.x1
      self.h = rect.y2-rect.y1
   def __eq__(self, other):
      return other and self.w == other.w and self.h == other.h
   def __ne__(self, other):
      return not self.__eq__(other)
   def __hash__(self):
      return hash((self.w, self.h))
   def __str__(self):
      return "(%d,%d)" % (self.w, self.h)


def check_collides(ads, clickables):
   ret = ""
   for ad in ads:
      for c in clickables:
         if ad.collide(c):
            ret += "Hit - ad "+str(ad)+", clickable "+str(c)+"\n"
   return ret


def analyze_one(filename):
   global apps_with_ads, apps_total, apps_functional, hits, multiads
   f = open(folder_path+filename)
   state_count = 0
   total_ads = 0
   clickables = []
   ads = []
   total_ads = 0
   collide_str = ""
   tmp = 0
   for line in f:
      if line.find("UI_LOAD_DONE") >= 0:
         
         collide_str += check_collides(ads, clickables)
         state_count += 1
         total_ads += len(ads)
         if len(ads) > 1:
            tmp = 1
         clickables = []
         ads = []
         
      else:
         m = re.search(r'located at \((-?\d+),(-?\d+)\),\((-?\d+),(-?\d+)\)', line)
         rect = Rectangle(m.group(1),m.group(2),m.group(3),m.group(4))
         if line.find("Other Clickable") >= 0:
            clickables.append(rect)
         elif line.find("Webview ad") >= 0:
            s = wh(rect)
            all_ads[s]+=1
            if s.h < 400:
               ads.append(rect)
            else:
               clickables.append(rect)
               
         else:
            print("ERROR- line invalid")
   
   collide_str += check_collides(ads, clickables)
   state_count += 1
   total_ads += len(ads)
   if len(ads) > 1:
      tmp = 1
   clickables = []
   ads = []
   
   if total_ads > 0:
      multiads += tmp
      print(filename)
      print(collide_str+"--- states: %d, total ads:%d----"%(state_count, total_ads))
      apps_with_ads += 1
      if len(collide_str) > 5:
         hits += 1
   if state_count >= 1:
      apps_functional += 1
   apps_total += 1



all_ads = collections.Counter()
apps_with_ads = 0
apps_total = 0
apps_functional = 0
hits = 0
multiads = 0

for file in os.listdir(folder_path):
   analyze_one(file)
print("-------")
print("ad-apps: %d (%d hits, %d multi), apps: %d (%d functional)"%(apps_with_ads, hits, multiads,apps_total,apps_functional))
for item in all_ads:
   print("%s %d"%(item,all_ads[item]))
