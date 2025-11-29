# Merge Main Branch into Master

This document provides instructions for merging the `main` branch into the `master` branch.

## Branch Analysis

The repository has two branches with completely different content:

### `main` branch (React/TypeScript PWA)
- React-based Progressive Web Application
- Files: `package.json`, `src/`, `vite.config.ts`, `tailwind.config.js`, etc.
- Purpose: Web-based legal assistant

### `master` branch (Flutter Mobile App) - Default Branch
- Flutter-based mobile application
- Files: `android-app/`, Firebase configs, `CLAUDE.md`, etc.
- Purpose: Mobile legal assistant app

## Merge Instructions

Since the branches have no common ancestor, use the `--allow-unrelated-histories` flag:

```bash
# Ensure you're on the master branch
git checkout master

# Merge main into master
git merge main --allow-unrelated-histories -m "Merge main branch into master to consolidate repository"

# Handle potential conflicts:
# - .gitignore: Keep master's version (more comprehensive)
# - .github/: May need to merge dependabot configs

# Push the result
git push origin master
```

## After Merge

Once merged, you may want to:
1. Delete the `main` branch: `git push origin --delete main`
2. Update any CI/CD configurations
3. Update any documentation references

## Alternative: Keep Branches Separate

If these are intended to be separate projects:
1. Close the merge PR
2. Rename `main` to `web-app` or similar
3. Keep `master` as the Flutter mobile app
