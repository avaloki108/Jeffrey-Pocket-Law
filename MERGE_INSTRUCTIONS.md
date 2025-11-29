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

## Conflict Resolution

When merging these unrelated branches, you may encounter conflicts in these files:

### `.gitignore`
- **master** version: 330KB comprehensive Flutter/Android/iOS gitignore
- **main** version: 353 bytes minimal React/Node gitignore
- **Recommendation**: Keep master's version and append any React-specific entries from main that aren't already covered

### `.github/` directory
- **master**: Contains Qodana code quality workflow
- **main**: Contains `dependabot.yml` for npm package updates
- **Recommendation**: Keep both - they serve different purposes. Add main's dependabot.yml into master's .github/ directory

### Resolution Steps for Conflicts

```bash
# If git shows conflicts, open the conflicting files
# Look for conflict markers: <<<<<<< HEAD, =======, >>>>>>> main

# For .gitignore conflicts:
git checkout --ours .gitignore  # Keep master's comprehensive version

# For .github/ directory:
# Manually copy needed files from main's version

# Mark conflicts as resolved
git add .
git commit -m "Resolve merge conflicts"
```

## Merge Instructions

Since the branches have no common ancestor, use the `--allow-unrelated-histories` flag:

```bash
# Ensure you're on the master branch
git checkout master

# Merge main into master
git merge main --allow-unrelated-histories -m "Merge main branch into master to consolidate repository"

# Handle potential conflicts (see Conflict Resolution section above)

# Push the result
git push origin master
```

## After Merge

Once merged, you may want to:

1. **Verify the merge** - Check that all files from both branches are present:
   - React files: `src/`, `package.json`, `vite.config.ts`
   - Flutter files: `android-app/`, `pubspec.yaml`
   
2. **Delete the `main` branch** (only after verifying merge success):
   ```bash
   # First verify all content is preserved
   git log --oneline master..main  # Should be empty (all main commits now in master)
   ls src/ package.json vite.config.ts  # Verify React files exist
   ls android-app/  # Verify Flutter files still exist
   
   # Then safely delete
   git push origin --delete main
   ```
   
3. Update any CI/CD configurations
4. Update any documentation references

## Alternative: Keep Branches Separate

If these are intended to be separate projects:
1. Close the merge PR
2. Rename `main` to `web-app` or similar
3. Keep `master` as the Flutter mobile app
