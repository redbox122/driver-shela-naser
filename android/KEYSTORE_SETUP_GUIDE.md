# Keystore Setup Guide

## Current Issue
- **Expected SHA1:** `7F:BC:B0:C8:55:57:59:38:7F:B1:1B:D9:B5:11:92:AD:F0:DE:4E:96`
- **Current SHA1:** `D4:4D:F6:1F:C1:33:00:DB:4B:E6:01:F6:81:91:8B:C7:AC:21:2C:75`

## Step 1: Identify the Correct Keystore

### Using Java keytool:

1. Find your Java JDK installation path (usually: `C:\Program Files\Java\jdk-XX\bin\`)

2. Check the captain-delivery keystore:
```bash
"C:\Path\To\Java\bin\keytool.exe" -list -v -keystore captain-delivery-keystore.jks -storepass Captain123! -alias captain-release
```
Look for the SHA1 fingerprint in the output.

3. Check the Food-shala keystore:
```bash
# First, list all aliases in the keystore
"C:\Path\To\Java\bin\keytool.exe" -list -keystore Food-shala-keystore.jks -storepass [PASSWORD]

# Then check the SHA1 for the correct alias
"C:\Path\To\Java\bin\keytool.exe" -list -v -keystore Food-shala-keystore.jks -storepass [PASSWORD] -alias [ALIAS]
```

4. Match the SHA1 fingerprint to: `7F:BC:B0:C8:55:57:59:38:7F:B1:1B:D9:B5:11:92:AD:F0:DE:4E:96`

## Step 2: Update key.properties

Once you've identified the correct keystore, update `android/key.properties`:

```
storePassword=[KEYSTORE_PASSWORD]
keyPassword=[KEY_PASSWORD]
keyAlias=[KEY_ALIAS]
storeFile=../[KEYSTORE_FILENAME].jks
```

## Example (if Food-shala-keystore.jks is correct):

```
storePassword=YourPassword
keyPassword=YourPassword
keyAlias=your-key-alias
storeFile=../Food-shala-keystore.jks
```

## Step 3: Rebuild the App Bundle

After updating key.properties:

```bash
flutter clean
flutter build appbundle --release
```

## Important Notes:
- The keystore file used for Play Store uploads **must match** the one registered in Google Play Console
- If you've already uploaded an app with a different keystore, you **cannot** change it - you must use the original keystore
- Keep your keystore files and passwords secure and backed up

