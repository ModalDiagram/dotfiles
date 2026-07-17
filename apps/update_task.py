#!/usr/bin/env python

from caldav import DAVClient
from icalendar import Calendar
import sys

URL = "http://127.0.0.1:5232"
USER = "root"
# PASS = "radical-chic"
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
        todo.save()
