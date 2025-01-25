# Resetting your local branch

```powershell
git fetch upstream
git stash
git reset --hard upstream/main
```

```powershell
git push -f
```

```powershell
git stash pop
```
