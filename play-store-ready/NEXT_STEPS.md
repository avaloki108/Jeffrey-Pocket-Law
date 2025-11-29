# Pocket Lawyer - Launch Checklist

## 1. Upload Build to Google Play
Your latest release build is ready at:
`play-store-ready/app-release.aab`

**Action Items:**
1. Go to [Google Play Console](https://play.google.com/console).
2. Select your app (**Pocket Lawyer**).
3. Go to **Testing > Internal testing** (recommended for first verification) or **Production**.
4. Click **Create new release**.
5. Upload the `app-release.aab` file.
6. Update release notes.

## 2. Deploy Firebase Backend
Your app uses **Firebase Data Connect** for PostgreSQL integration. You must ensure the cloud schema matches your local definitions.

**Action Items:**
1. Open a terminal in the project root.
2. Run the deployment command:
   ```bash
   firebase deploy --only dataconnect
   ```
3. (Optional) Go to [Firebase Console > Data Connect](https://console.firebase.google.com/) to verify the service `jeffery-friendly-pocket-law-4-service` is running and schema is synced.

## 3. Verify Store Listing
Ensure your Store Listing in Play Console matches the info in `README.txt`:
- **Title:** Pocket Lawyer - AI Legal Assistant
- **Short Description:** Instant AI legal guidance grounded in real US laws and cases.
- **Full Description:** (See `README.txt` for the optimized text).

## 4. Post-Launch
- Monitor **Firebase Crashlytics** for stability issues.
- Check **Google Play Console** for user reviews and ratings.
