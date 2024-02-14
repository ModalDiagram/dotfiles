import pandas as pd
import datetime as dt
# import matplotlib.pyplot as plt
# import matplotlib.ticker as ticker
# import os
import plotly.express as px

# def format_func(x, pos):
#     hours = int(x//3600)
#     minutes = int((x%3600)//60)
#     seconds = int(x%60)

#     return "{:d}:{:02d}".format(hours, minutes)
#     # return "{:d}:{:02d}:{:02d}".format(hours, minutes, seconds)

df = pd.read_csv("~/.local/share/survey/data.txt")
df.columns = ["timestamp", "mode", "count"]
df["date"] = df["timestamp"].apply(dt.datetime.fromtimestamp)
df2 = pd.DataFrame(df["mode"].groupby(df["date"].dt.date).sum())
df2["time"] = pd.to_datetime(df2["mode"], unit = 's')

fig = px.bar(y = df2["time"], x = df2.index)
fig.update_layout(yaxis_tickformat='%H:%M')
fig.update_xaxes(type="date", range=[dt.datetime.today().replace(day=1), dt.datetime.today() + dt.timedelta(days = 1)], tickmode = "linear")
fig.add_vline(x = dt.datetime.today(), line_dash="dash", line_color="red")
fig.show()


# df_day = df[df["date"].apply(lambda x: x.month == dt.datetime.now().month)].copy()
# df_day["day"] = df_day["date"].apply(lambda x: x.day)
# df2 = pd.DataFrame(df_day["mode"].groupby(df_day["day"]).sum())

# formatter = ticker.FuncFormatter(format_func)
# f = plt.figure()
# ax = f.add_subplot(1,1,1)
# ax.bar(df2.index, df2["mode"])

# f.suptitle("Hours worked in the month of " + dt.datetime.now().strftime("%B"))
# ax.yaxis.set_major_formatter(formatter)
# # this locates y-ticks at the hours
# ax.yaxis.set_major_locator(ticker.MultipleLocator(base=3600))
# # this ensures each bar has a 'date' label
# ax.xaxis.set_major_locator(ticker.MultipleLocator(base=1))
# plt.savefig(os.path.expanduser("~/.local/share/survey/images/month_hours.png"))
