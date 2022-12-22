# SendEmail

Instructions at https://gravitylab.nz/send-email-alerts-and-log-the-email/



DEVELOPER NOTES

I don't think we can fix the contactId won't work on personal accounts, we don't do anything clever for this, we just pass it on and expect salesforce to handle it, so this is either a data issue or a salesforce issue

Might be issues in actioning inside a loop. Wanted this bulkifyable too, so a new separate version with lists will be needed.

Contentdoc id thingy is resolved in the pull request and in the org. it was just not handling a contentdoc id correctly

Treattargetobjectasrecipient is resolved. and that last one is what I was referring to about doco. I haven't actually verifed the issue myself
