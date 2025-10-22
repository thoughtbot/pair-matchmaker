# Pair Matchmaker

## Acknowledgement

This tool is based on TestDouble's Double Up tool and forked originally from https://github.com/testdouble/double-up in April 2022. As of October 2025, it remains separate and has not brought in any later changes from Double Up.

## System Requirements

This application uses Ruby 3.0

## App Setup Instructions

1. Follow instructions and [create a new slack app](https://api.slack.com/authentication/basics)
2. Add the following scopes to your slack app: `users:read`, `mpim:write`, `im:write`, `chat:write`, `channels:join`, `channels:manage`, `groups:write`, `groups:read`, `mpim:read`, `im:read`, and `channels:read`.
4. Create a new app in Heroku or your hosting service of choice. Go to wherever you can add environment variables.
5. Set `MIN_GROUP_SIZE` to 3.
6. Get your secret key base and the oauth token for your newly created slack app. Store those as `SLACK_SIGNING_SECRET` and `SLACK_OAUTH_TOKEN`.
7. Deploy app to Heroku (or your hosting service of choice).
8. If using Heroku, install Heroku Scheduler.
9. Schedule `rake create_groups` to run every day at a time of your choice. If you have a hosting service that will allow you to run cron jobs, you can remove the code mentioned above that checks that day and week and just use cron format. If using Heroku, just run daily and it will quit if it's not the right day 🙂
10. PROFIT!

## Matchmaking Approach

Some inspiration was taken from the following two problems

- [Stable Marriage Problem](https://en.wikipedia.org/wiki/Stable_marriage_problem)
- [Stable Roommates Problem](https://en.wikipedia.org/wiki/Stable_roommates_problem)

Some requirements this approach had to solve for

1. Individuals can join or leave a slack channel at any time to opt-in or opt-out respectively
2. Repeats for each cycle should be rare for a particular group
3. Duplicates should be rare between the various types of groups for which an individual is being matched

The approach starts with the a list of participants for a particular grouping, with the goal being that every participant is included in a single group. Each group size for a grouping can be configured, with a default of 2. For each participant, a score, starting at 0, is calculated for every other participant based upon a few factors.

1. Has this other participant been recently paired up with the current participant in this grouping?
2. Has this other participant been recently paired up with the current participant in any other grouping?

The score for the other participants is incremented by 1 for each grouping where "Yes" is the answer to those questions. That is repeated for each participant until eventually everyone has a score for every other participant.

Once scored, a threshold of 0 is set and for each participant, a random other participant is selected that has a score of 0. After running through each, the threshold is incremented by 1 if any unmatched participants exist. That repeats until eventually everyone is found within a particular group.

### Example

That was as fun to write as it was to read, so here is an example, hopefully breaking it down more practically.

Let's say we have Frodo, Sam, Pippin, and Meriadoc as participants in the grouping, Second Breakfast. In addition, let's say that we want "recent" to mean 1 group ago.

**First Time Matchmaking**

The first time the matchmaking runs, the scoring will conceptually look like

```
Frodo => {
  Sam with a score of 0
  Pippin with a score of 0
  Meriadoc with a score of 0
}

Sam => {
  Frodo with a score of 0
  Pippin with a score of 0
  Meriadoc with a score of 0
}

Pippin => {
  Frodo with a score of 0
  Sam with a score of 0
  Meriadoc with a score of 0
}

Meriadoc => {
  Frodo with a score of 0
  Sam with a score of 0
  Pippin with a score of 0
}
```

Since everyone has a score of 0 for everyone else, the matchmaking is simple. Someone is randomly selected for Frodo, so let's say, Pippin. Next up is Sam and he is detected to be ungrouped, so Meriadoc is "randomly" selected. Once we get to Pippin, we detect Pippin as being grouped, then Meriadoc finally is detected as grouped.

```
Group 1 is Frodo & Pippin

Group 2 is Sam & Meriadoc
```

**Second Time Matchmaking**

Here is where things get interesting. The scores change because the most recent group for each person will increase the score by 1.

```
Frodo => {
  Sam with a score of 0
  Pippin with a score of 1
  Meriadoc with a score of 0
}

Sam => {
  Frodo with a score of 0
  Pippin with a score of 0
  Meriadoc with a score of 1
}

Pippin => {
  Frodo with a score of 1
  Sam with a score of 0
  Meriadoc with a score of 0
}

Meriadoc => {
  Frodo with a score of 0
  Sam with a score of 1
  Pippin with a score of 0
}
```

Now when we look for a pair for Frodo, Pippin is excluded since his score is greater than the starting threshold of 0. Frodo cannot experience a repeat pair in this way, so he's paired up with Sam.

That concept continues until everyone is matched.

Once we get to the third time matchmaking, the score is reset from the first time because that was 2 times ago. If we wanted to simulate ensuring everyone gets paired up before repeating, then we could check 2 groups back, ensuring the score reset happens after everyone has been paired already, like round-robin.
