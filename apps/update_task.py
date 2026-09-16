#!/usr/bin/env python

from caldav import DAVClient
from icalendar import Calendar, Alarm
from datetime import datetime,timedelta
import sys

URL = "http://127.0.0.1:5232"
# URL = "http://192.168.100.12:5232"
USER = "root"
PASS = sys.stdin.read().strip()
# print(f"Read pass: {PASS}")

MATCH = "Esci"

client = DAVClient(URL, username=USER, password=PASS)
principal = client.principal()

for calendar in principal.calendars():
    cal_name = calendar.get_display_name()
    print(f"Found calendar: {calendar}")
    if cal_name == "Personal":
        personal_calendar = calendar
        break

for todo in personal_calendar.todos():
    cal = Calendar.from_ical(todo.data)
    ical_component = todo.icalendar_component
    if ical_component['summary'].startswith(MATCH) and ical_component.get("priority") != 1:
        print(f"Updating task: {ical_component['summary']}")
        ical_component["PRIORITY"] = 1

        allarmi_esistenti = [c for c in ical_component.subcomponents if c.name == 'VALARM']
        for vecchio_allarme in allarmi_esistenti:
            ical_component.subcomponents.remove(vecchio_allarme)
        
        alarm = Alarm()
        alarm.add('action', 'AUDIO') # 'AUDIO' o 'DISPLAY'
        alarm.add('trigger', timedelta(minutes=0)) # Suona esattamente all'orario di scadenza
        alarm.add('description', 'Promemoria')
        
        ical_component.add_component(alarm)
        
        todo.save()
