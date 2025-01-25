# Connecting to your Personal GitHub account

FIRST, go to https://github.com/diskuv/scoutapps and click the "Fork" button on the top right side. Keep the defaults it gives you, and then press the "Fork" button again to complete the process. After a minute you will be redirected to your personal "fork" on GitHub.

SECOND, make a record of the `Code > Local > HTTPS` text box ... it should look something like `https://github.com/YOURGITHUBNAME/scoutapps.git`.

THIRD, in your Terminal (replace the "YOURGITHUBNAME" below!!!):

```powershell
git remote rename origin upstream
git remote add origin https://github.com/YOURGITHUBNAME/scoutapps.git
git fetch origin
```

FOURTH, go to https://github.com/settings/emails:

1. Make sure the `Keep my email addresses private` checkbox is **ENABLED**.
2. Copy the "private" email address. It should look like `BLAHBLAH+BLEEBLEE@users.noreply.github.com`.

FIFTH, in your Terminal (replace the "FirstName LastInitial" and "BLAHBLAH+BLEEBLEE@users.noreply.github.com" below!!!):

```powershell
git config user.name "FirstName LastInitial"
git config user.email "BLAHBLAH+BLEEBLEE@users.noreply.github.com"
```

SIXTH, in your Terminal:

```powershell
git push origin main
git branch --set-upstream-to origin/main
```
