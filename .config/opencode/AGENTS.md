# Pre-commit Checks

Before committing, run the relevant checks depending on which folders have changes.

## Frontend (`front/`)

```bash
cd front
yarn lint --quiet
yarn tsc
```

## Mobile (`mobile/`)

```bash
cd mobile
yarn lint --quiet
yarn tsc
yarn test
```

## Server (`server/`)

```bash
cd server
make test
```

---

# Pull Request Workflow

When the user says "make a PR", "create a PR", "open a PR", or similar:

1. **Checkout and update base branch:**
   - Run `git checkout develop && git pull origin develop`
2. **Create a new branch:**
   - If there is a Linear issue associated (the user mentions it or it can be inferred from context), use the Linear issue's branch name (e.g. `feature/YAA-123-short-description`)
   - Otherwise, create a descriptive branch name based on the changes
   - Run `git checkout -b <branch-name>`
3. **Stage and commit (if needed):**
   - If there are unstaged or uncommitted files, stage them with `git add` and create a descriptive commit
4. **Push and create PR:**
   - Run `git push -u origin <branch-name>`
   - Use `gh pr create --base develop` with a descriptive title and body

## Hotfix Exception

When the user says "make a hotfix PR", "hotfix pull request", or similar:

1. **Checkout and update base branch:**
   - Run `git checkout master && git pull origin master`
2. **Create a new branch:**
   - Same branch naming rules as above, but prefix with `hotfix/` if not already
   - Run `git checkout -b <branch-name>`
3. **Stage and commit (if needed):**
   - Same as above
4. **Push and create PR:**
   - Run `git push -u origin <branch-name>`
   - Use `gh pr create --base master` with a descriptive title and body
