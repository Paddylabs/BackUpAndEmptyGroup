# BackUpAndEmptyGroup

Export Members of an AD Group to file and then empty the group 

I was asked by a client to empty the membership of a particular group every night at midnight. I wrote this and
used a Scheduled Task to run it everynight at 23:59.

I added keeping 7 days worth of backups of the group membership just in case and some error logs and a result email.

Putting it here as it may come in handy for me again some time.

Just add the group name to the $Group variable and create the Script directory and subfolders required for the logs etc.
And edit the smtp server, recipient and to / from Variables for the email.
